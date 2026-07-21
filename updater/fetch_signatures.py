import os
import sys
import hmac
import stat
import time
import gzip
import json
import shutil
import hashlib
import tarfile
import argparse
import datetime
import requests

_SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
_PROJECT_DIR = os.path.dirname(_SCRIPT_DIR)

_DATA_DIR = os.environ.get("MP_DATA_DIR", os.path.join(_PROJECT_DIR, "data"))
_UPDATER_DIR = os.environ.get("MP_UPDATER_DIR", _SCRIPT_DIR)

CONFIG = {
    "data_dir": _DATA_DIR,
    "temp_dir": os.path.join(_UPDATER_DIR, "temp"),
    "keep_extracted": True,
    "log_dir": os.path.join(_UPDATER_DIR, "logs"),

    "output_file": os.path.join(_DATA_DIR, "signatures.msdb"),
    "test_db_file": os.path.join(_DATA_DIR, "test_signatures.msdb"),
    "version_file": os.path.join(_DATA_DIR, "signatures_version.txt"),

    "clamav_base_url": "https://database.clamav.net",
    "databases": ["main.cvd", "daily.cvd"],

    "max_signatures": 500000,
    "timeout": 30,
    "chunk_size": 8192,

    "strict_verify": True,
    "pinned_host": "database.clamav.net",
    "pins_file": os.path.join(_UPDATER_DIR, "pins.json"),
}

class Logger:
    def __init__(self, log_dir: str):
        os.makedirs(log_dir, exist_ok=True)
        timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
        log_path = os.path.join(log_dir, f"update_{timestamp}.log")
        self.log_file = open(log_path, "w", encoding="utf-8")
        self.log_path = log_path

    def log(self, message: str, level: str = "INFO"):
        timestamp = datetime.datetime.now().strftime("%H:%M:%S")
        formatted = f"[{timestamp}] [{level}] {message}"
        print(formatted)
        self.log_file.write(formatted + "\n")
        self.log_file.flush()

    def info(self, message: str):
        self.log(message, "INFO")

    def ok(self, message: str):
        self.log(message, "OK")

    def warn(self, message: str):
        self.log(message, "WARN")

    def error(self, message: str):
        self.log(message, "ERROR")

    def close(self):
        self.log_file.close()

def _load_pins(logger):
    path = CONFIG.get("pins_file", "")
    if not path or not os.path.exists(path): return []
    try:
        with open(path, "r", encoding="utf-8") as f:
            data = json.load(f)
        return [p.strip() for p in data.get("spki_sha256", []) if p and p.strip()]
    except Exception as ex:
        logger.warn(f"pins.json: ошибка чтения ({ex}) - pinning отключён")
        return []


def _spki_sha256_b64(cert_der: bytes):
    try:
        import base64
        from cryptography import x509
        from cryptography.hazmat.primitives import serialization
        cert = x509.load_der_x509_certificate(cert_der)
        spki = cert.public_key().public_bytes(serialization.Encoding.DER, serialization.PublicFormat.SubjectPublicKeyInfo)
        return base64.b64encode(hashlib.sha256(spki).digest()).decode("ascii")
    except Exception:
        return None

class _SPKIPinningAdapter(requests.adapters.HTTPAdapter):
    def __init__(self, pins, logger, *args, **kwargs):
        self._pins = set(pins)
        self._logger = logger
        super().__init__(*args, **kwargs)

    def send(self, request, **kwargs):
        resp = super().send(request, **kwargs)
        if not self._pins: return resp
        der = None
        try:
            der = resp.raw.connection.sock.getpeercert(binary_form=True)
        except Exception:
            der = None
        if not der:
            resp.close()
            raise requests.exceptions.SSLError("SPKI pinning: не удалось получить сертификат сервера (fail-closed)")
        spki = _spki_sha256_b64(der)
        if spki is None:
            resp.close()
            raise requests.exceptions.SSLError("SPKI pinning: пакет 'cryptography' не установлен, проверка невозможна (fail-closed)")
        if spki not in self._pins:
            resp.close()
            raise requests.exceptions.SSLError(f"SPKI pinning MISMATCH: сертификат сервера не в pins.json (got {spki})")
        self._logger.ok(f"SPKI pin OK: {spki}")
        return resp

_SESSION = None

def _get_session(logger):
    global _SESSION
    if _SESSION is not None: return _SESSION
    s = requests.Session()
    pins = _load_pins(logger)
    if pins:
        s.mount("https://", _SPKIPinningAdapter(pins, logger))
        logger.info(f"TLS SPKI pinning активен ({len(pins)} пин(ов))")
    else: logger.info("TLS SPKI pinning отключён (pins.json пуст) - активны TLS + strict RSA-dsig")
    _SESSION = s
    return s

def record_pin(host, logger):
    import ssl
    import socket
    import json
    logger.info(f"Получаем SPKI сертификата {host}:443 ...")
    try:
        ctx = ssl.create_default_context()
        with socket.create_connection((host, 443), timeout=15) as sock:
            with ctx.wrap_socket(sock, server_hostname=host) as ssock:
                der = ssock.getpeercert(binary_form=True)
    except Exception as ex:
        logger.error(f"Не удалось подключиться к {host}: {ex}")
        return False
    spki = _spki_sha256_b64(der)
    if not spki:
        logger.error("Не удалось вычислить SPKI - установите 'cryptography': pip install cryptography")
        return False
    logger.ok(f"SPKI {host}: {spki}")
    path = CONFIG.get("pins_file")
    data = {"_comment": "SPKI sha256 (base64) для TLS-pinning. Сверять при ротации сертификата сервера.", "host": host, "spki_sha256": [spki]}
    try:
        with open(path, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
        logger.ok(f"Записано в {path}")
        return True
    except Exception as ex:
        logger.error(f"Не удалось записать {path}: {ex}")
        return False


def download_file(url: str, dest_path: str, logger: Logger, timeout: int = 30):
    logger.info(f"Скачиваем: {url}")
    try:
        headers = {"User-Agent": "ClamAV/1.0 (MentoringProtector; Windows)"}
        session = _get_session(logger)
        response = session.get(url, stream=True, timeout=timeout, headers=headers)
        response.raise_for_status()
        total_size = int(response.headers.get("content-length", 0))
        downloaded = 0
        with open(dest_path, "wb") as f:
            for chunk in response.iter_content(chunk_size=CONFIG["chunk_size"]):
                if chunk:
                    f.write(chunk)
                    downloaded += len(chunk)
                    if total_size > 0:
                        percent = downloaded / total_size * 100
                        mb_done = downloaded / 1024 / 1024
                        mb_total = total_size / 1024 / 1024
                        print(f"\r  Прогресс: {percent:.1f}% ({mb_done:.1f} / {mb_total:.1f} МБ)", end="", flush=True)
        print()
        mb_final = downloaded / 1024 / 1024
        logger.ok(f"Скачано: {mb_final:.1f} МБ -> {dest_path}")
        return True

    except requests.exceptions.ConnectionError:
        logger.error("Нет подключения к интернету")
        return False
    except requests.exceptions.Timeout:
        logger.error(f"Таймаут запроса ({timeout} сек)")
        return False
    except requests.exceptions.HTTPError as e:
        logger.error(f"HTTP ошибка: {e}")
        return False
    except Exception as e:
        logger.error(f"Неизвестная ошибка: {e}")
        return False

_CLAMAV_RSA_N = 118640995551645342603070001658453189751527774412027743746599405743243142607464144767361060640655844749760788890022283424922762488917565551002467771109669598189410434699034532232228621591089508178591428456220796841621637175567590476666928698770143328137383952820383197532047771780196576957695822641224262693037
_CLAMAV_RSA_E = 100001027

_DSIG_NCODEC = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789+/"

def _cli_decodesig_bignum(sig: str) -> int:
    c = 0
    for ch in reversed(sig):
        pos = _DSIG_NCODEC.find(ch)
        if pos < 0:
            raise ValueError(f"cli_ndecode: char {repr(ch)} not in ncodec")
        c = c * 64 + pos
    return c

_DSIG_TRUSTED = True

def _verify_cvd_dsig(payload: bytes, fields: list, logger: 'Logger') -> str:
    if len(fields) <= 6: return "unavailable"
    dsig_str = fields[6].strip()
    if not dsig_str or dsig_str == 'X': return "unavailable"

    header_md5_hex = fields[5].strip().lower() if len(fields) > 5 else ""
    if len(header_md5_hex) != 32:
        logger.warn(f"CVD dsig: поле MD5 некорректно (len={len(header_md5_hex)})")
        return "unavailable"

    actual_md5_hex = hashlib.md5(payload).hexdigest().lower()
    if not hmac.compare_digest(actual_md5_hex, header_md5_hex):
        logger.warn(f"CVD dsig: md5(payload)={actual_md5_hex} != fields[5]={header_md5_hex} - тело подменено или повреждено")
        return "mismatch"

    try:
        c = _cli_decodesig_bignum(dsig_str)
        if c <= 0:
            logger.warn("CVD dsig: c <= 0 после cli_decodesig_bignum")
            return "unavailable"

        p = pow(c, _CLAMAV_RSA_E, _CLAMAV_RSA_N)

        if p.bit_length() > 128:
            logger.warn(f"CVD dsig: RSA результат {p.bit_length()} бит > 128 (ClamAV cli_decodesig отверг бы такой результат)")
            return "unavailable"

        result_hex = p.to_bytes(16, 'big').hex()
        if hmac.compare_digest(result_hex, header_md5_hex):
            logger.ok("CVD dsig RSA-MD5: подпись подлинна (Cisco/ClamAV cli_versig)")
            return "verified"

        logger.warn(f"CVD dsig RSA-MD5 НЕСОВПАДЕНИЕ. result={result_hex}, header_md5={header_md5_hex}")
        logger.error("[SECURITY] CVD dsig мисматч - возможна подмена базы или нужна перепроверка ключа ClamAV.")
        return "mismatch"

    except ValueError as ve:
        logger.warn(f"CVD dsig: {ve}. [ACTION-REQUIRED?] возможен переход на cli_versig2.")
        return "unavailable"
    except Exception as ex:
        logger.warn(f"CVD dsig верификация: неожиданная ошибка ({ex})")
        return "unavailable"

def validate_cvd(cvd_path: str, logger: Logger, strict: bool = True):
    logger.info(f"Проверяем целостность: {os.path.basename(cvd_path)}")
    try:
        with open(cvd_path, "rb") as f:
            header_bytes = f.read(512)
            payload = f.read()

        if len(header_bytes) < 512:
            logger.error("Файл слишком маленький (< 512 байт)")
            return False

        header_text = header_bytes.split(b'\0')[0].decode('ascii', errors='ignore')
        fields = header_text.split(':')

        if len(fields) < 6 or not fields[0].startswith('ClamAV-VDB'):
            logger.error(f"Не ClamAV CVD формат (заголовок: {header_text[:60]}...)")
            return False

        expected_md5 = fields[5].strip().lower()

        dsig_status = (_verify_cvd_dsig(payload, fields, logger) if len(fields) > 6 else "unavailable")
        if _DSIG_TRUSTED:
            if dsig_status != "verified":
                if strict:
                    logger.error(f"[SECURITY] CVD не прошёл проверку подписи (status={dsig_status}) - апдейт ОТКЛОНeН (fail-closed). Остаётся прежняя база. Dev-обход: --no-strict или MP_UPDATER_STRICT=0.")
                    return False
                logger.warn(f"CVD dsig status={dsig_status}; strict выключен - продолжаем (advisory dev-режим).")
        elif dsig_status != "verified":
            logger.warn(f"CVD dsig: _DSIG_TRUSTED=False (ручной dev-режим), status={dsig_status}. Защита: TLS + MD5 + SPKI-pin.")

        if len(expected_md5) != 32:
            logger.warn(f"MD5 в заголовке некорректен ({expected_md5}), пропускаем проверку")
            return True

        actual_md5 = hashlib.md5(payload).hexdigest().lower()

        if actual_md5 == expected_md5:
            logger.ok(f"MD5 совпадает: {actual_md5} (version: {fields[2]}, sigs: {fields[3]})")
            return True
        else:
            logger.error(f"MD5 НЕ совпадает! Ожидали: {expected_md5}, Получили: {actual_md5}")
            logger.error("Файл поврежден или подменен - НЕ используем")
            return False

    except Exception as e:
        logger.error(f"Ошибка валидации CVD: {e}")
        return False

def extract_cvd(cvd_path: str, extract_dir: str, logger: Logger):
    logger.info(f"Распаковываем: {os.path.basename(cvd_path)}")
    try:
        os.makedirs(extract_dir, exist_ok=True)
        with open(cvd_path, "rb") as f:
            header = f.read(512)
            tar_data = f.read()

        tar_path = cvd_path + ".tar.gz"
        with open(tar_path, "wb") as f:
            f.write(tar_data)

        with tarfile.open(tar_path, "r:gz") as tar:
            tar.extractall(extract_dir, filter='data')

        os.remove(tar_path)
        files = os.listdir(extract_dir)
        logger.ok(f"Распаковано файлов: {len(files)}")
        for f in sorted(files):
            fpath = os.path.join(extract_dir, f)
            size_kb = os.path.getsize(fpath) / 1024
            logger.info(f"  -> {f} ({size_kb:.1f} КБ)")

        return True

    except tarfile.TarError as e:
        logger.error(f"Ошибка распаковки tar: {e}")
        return False
    except Exception as e:
        logger.error(f"Ошибка распаковки: {e}")
        return False

def parse_hdb(hdb_path: str, logger: Logger) -> dict:
    threats = {}
    count = 0

    try:
        with open(hdb_path, "r", encoding="utf-8", errors="ignore") as f:
            for line in f:
                line = line.strip()
                if not line or line.startswith("#"): continue
                parts = line.split(":")
                if len(parts) >= 3:
                    threat_name = parts[2].strip()
                    if threat_name:
                        threats[threat_name] = True
                        count += 1
    except Exception as e:
        logger.warn(f"Ошибка парсинга {hdb_path}: {e}")

    return threats

def parse_hdb_full(hdb_path: str, logger: Logger, max_count: int = 500000):
    signatures = []
    count = 0
    errors = 0

    file_ext = os.path.splitext(hdb_path)[1].lower()

    if file_ext in (".hdb", ".hdu"):
        valid_lengths = {32}
        hash_type = "MD5"
    elif file_ext in (".hsb", ".hsu"):
        valid_lengths = {32, 40, 64}
        hash_type = "MIXED"
    else:
        valid_lengths = {32, 40, 64}
        hash_type = "UNKNOWN"

    logger.info(f"Анализируем формат {os.path.basename(hdb_path)}:")
    try:
        with open(hdb_path, "r", encoding="utf-8", errors="ignore") as f:
            for i, line in enumerate(f):
                if i >= 3: break
                if line.strip() and not line.startswith("#"): logger.info(f"  Строка {i+1}: {line.strip()[:80]}")
    except Exception:
        pass

    logger.info(f"Парсим {hash_type}: {os.path.basename(hdb_path)}")

    try:
        with open(hdb_path, "r", encoding="utf-8", errors="ignore") as f:
            for line in f:
                if count >= max_count:
                    logger.warn(f"Достигнут лимит {max_count}")
                    break

                line = line.strip()
                if not line or line.startswith("#"): continue

                parts = line.split(":")
                if len(parts) >= 3:
                    file_hash = parts[0].strip().lower()
                    size_str = parts[1].strip()
                    threat_name = parts[2].strip()

                    if (len(file_hash) in valid_lengths and all(c in "0123456789abcdef" for c in file_hash)):
                        try:
                            file_size = int(size_str)
                        except ValueError:
                            file_size = -1

                        signatures.append((file_hash, file_size, threat_name))
                        count += 1
                    else:
                        errors += 1

    except FileNotFoundError:
        logger.warn(f"Файл не найден: {hdb_path}")
    except Exception as e:
        logger.error(f"Ошибка парсинга: {e}")

    logger.ok(f"Спарсено: {count} {hash_type} сигнатур (ошибок: {errors})")
    return signatures

def parse_msdb(msdb_path: str, logger: Logger, max_count: int = 500000):
    signatures = []
    count = 0
    errors = 0
    logger.info(f"Парсим: {os.path.basename(msdb_path)}")
    try:
        with open(msdb_path, "r", encoding="utf-8", errors="ignore") as f:
            for line in f:
                if count >= max_count:
                    logger.warn(f"Достигнут лимит {max_count} сигнатур")
                    break
                line = line.strip()
                if not line or line.startswith("#"): continue
                parts = line.split(":")
                if len(parts) >= 3:
                    sha256 = parts[0].strip()
                    size_str = parts[1].strip()
                    threat_name = parts[2].strip()
                    if len(sha256) == 64:
                        try:
                            file_size = int(size_str)
                        except ValueError:
                            file_size = -1

                        signatures.append((sha256, file_size, threat_name))
                        count += 1
                    else: errors += 1
    except FileNotFoundError:
        logger.warn(f"Файл не найден: {msdb_path}")
    except Exception as e:
        logger.error(f"Ошибка парсинга: {e}")

    logger.ok(f"Спарсено: {count} сигнатур (ошибок: {errors})")
    return signatures

def write_msdb(signatures: list, output_path: str, logger: Logger):
    logger.info(f"Записываем базу: {output_path}")
    try:
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        now = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")

        with open(output_path, "w", encoding="utf-8") as f:
            f.write(f"# MentoringProtector Signature Database\n")
            f.write(f"# Обновлено: {now}\n")
            f.write(f"# Сигнатур: {len(signatures)}\n")
            f.write(f"# Источник: ClamAV\n")
            f.write(f"# Формат: MD5:размер:название\n")
            f.write("#\n")

            for sha256, file_size, threat_name in signatures:
                f.write(f"{sha256}:{file_size}:{threat_name}\n")

        mb = os.path.getsize(output_path) / 1024 / 1024
        logger.ok(f"База записана: {len(signatures)} сигнатур ({mb:.1f} МБ)")
        return True

    except Exception as e:
        logger.error(f"Ошибка записи: {e}")
        return False

def save_version(version_path: str, count: int, msdb_sha256: str = ""):
    now = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open(version_path, "w", encoding="utf-8") as f:
        f.write(f"last_updated={now}\n")
        f.write(f"signature_count={count}\n")
        f.write(f"source=ClamAV\n")
        if msdb_sha256: f.write(f"signatures_sha256={msdb_sha256}\n")

def check_update_needed(version_path: str):
    if not os.path.exists(version_path): return True
    try:
        with open(version_path, "r") as f:
            for line in f:
                if line.startswith("last_updated="):
                    date_str = line.split("=")[1].strip()
                    last_update = datetime.datetime.strptime(date_str, "%Y-%m-%d %H:%M:%S")
                    hours_passed = (datetime.datetime.now() - last_update).total_seconds() / 3600
                    return hours_passed >= 24
    except Exception:
        return True

    return True

def run_test_mode(logger: Logger):
    logger.info("=== ТЕСТОВЫЙ РЕЖИМ ===")

    for key, path in [("data_dir", CONFIG["data_dir"]), ("temp_dir", CONFIG["temp_dir"]), ("log_dir", CONFIG["log_dir"])]:
        exists = os.path.exists(path)
        status = "существует" if exists else "не найдена"
        logger.info(f"  {key}: {path} - {status}")

    for key, path in [("test_db", CONFIG["test_db_file"]), ("signatures", CONFIG["output_file"])]:
        if os.path.exists(path):
            size = os.path.getsize(path)
            with open(path, "r", encoding="utf-8", errors="ignore") as f:
                sig_count = sum(1 for line in f if line.strip() and not line.startswith("#"))
            logger.ok(f"{key}: {sig_count} сигнатур ({size / 1024:.1f} КБ)")
        else:
            logger.warn(f"{key}: файл не найден - {path}")

    logger.info("=== ТЕСТ ЗАВЕРШеН ===")

def main():
    parser = argparse.ArgumentParser(description="MentoringProtector - обновление базы сигнатур")
    parser.add_argument("--force", action="store_true", help="Принудительное обновление даже если база свежая")
    parser.add_argument("--test", action="store_true", help="Тестовый режим без скачивания")
    parser.add_argument("--local", action="store_true", help="Обработать уже скачанные файлы без повторного скачивания")
    parser.add_argument("--strict", dest="strict", action="store_true", default=None, help="Fail-closed: блокировать апдейт при провале RSA-dsig (по умолчанию вкл)")
    parser.add_argument("--no-strict", dest="strict", action="store_false", help="Dev: RSA-dsig advisory (НЕ блокировать) - только для разработки")
    parser.add_argument("--record-pin", action="store_true", help="Получить текущий SPKI сервера ClamAV и записать в pins.json, затем выйти")
    args = parser.parse_args()

    logger = Logger(CONFIG["log_dir"])
    logger.info("=" * 50)
    logger.info("MentoringProtector - Обновление базы сигнатур")
    logger.info(f"Дата: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    logger.info("=" * 50)

    if args.record_pin:
        record_pin(CONFIG["pinned_host"], logger)
        logger.close()
        return

    if args.strict is not None: strict = args.strict
    else:
        _env = os.environ.get("MP_UPDATER_STRICT")
        strict = ((_env not in ("0", "false", "False", "no")) if _env is not None else CONFIG["strict_verify"])
    logger.info(f"Верификация апдейта: {'STRICT (fail-closed)' if strict else 'ADVISORY (dev, небезопасно)'}")

    if args.test:
        run_test_mode(logger)
        logger.close()
        return

    if not args.force and not args.local:
        if not check_update_needed(CONFIG["version_file"]):
            logger.info("База актуальна (обновлялась менее 24 часов назад)")
            logger.info("Используй --force для принудительного обновления")
            logger.close()
            return

    temp_dir = CONFIG["temp_dir"]
    os.makedirs(temp_dir, exist_ok=True)
    os.makedirs(CONFIG["data_dir"], exist_ok=True)

    all_signatures = []
    success = False

    for db_name in CONFIG["databases"]:
        logger.info(f"\n--- Обрабатываем: {db_name} ---")

        cvd_path = os.path.join(temp_dir, db_name)
        url = f"{CONFIG['clamav_base_url']}/{db_name}"

        if args.local and os.path.exists(cvd_path): logger.info(f"Используем существующий файл: {cvd_path}")
        elif not download_file(url, cvd_path, logger, CONFIG["timeout"]):
            logger.error(f"Не удалось скачать {db_name}")
            continue

        if not validate_cvd(cvd_path, logger, strict):
            logger.error(f"Файл {db_name} не прошел валидацию - пропускаем")
            try:
                os.remove(cvd_path)
            except OSError:
                pass
            continue

        extract_dir = os.path.join(temp_dir, db_name + "_extracted")
        if os.path.exists(extract_dir):
            def remove_readonly(func, path, _):
                os.chmod(path, stat.S_IWRITE)
                func(path)
            shutil.rmtree(extract_dir, onerror=remove_readonly)

        if not extract_cvd(cvd_path, extract_dir, logger):
            logger.error(f"Не удалось распаковать {db_name}")
            continue

        msdb_files = [f for f in os.listdir(extract_dir) if f.endswith(".hdb") or f.endswith(".hsb")]

        if not msdb_files:
            logger.warn(f"Нет .msdb файлов в {db_name}")
            logger.info("Доступные файлы:")
            for f in os.listdir(extract_dir):
                logger.info(f"  {f}")
        else:
            for msdb_name in msdb_files:
                msdb_path = os.path.join(extract_dir, msdb_name)
                sigs = parse_hdb_full(msdb_path, logger, CONFIG["max_signatures"])
                all_signatures.extend(sigs)
                logger.ok(f"Добавлено из {msdb_name}: {len(sigs)} сигнатур")

        success = True
        if db_name != CONFIG["databases"][-1]:
            logger.info("Пауза 10 секунд перед следующим запросом...")
            time.sleep(10)
    
    if all_signatures:
        logger.info("\nУдаляем дубликаты...")
        seen = set()
        unique_sigs = []
        for sig in all_signatures:
            if sig[0] not in seen:
                seen.add(sig[0])
                unique_sigs.append(sig)

        logger.ok(f"Уникальных сигнатур: {len(unique_sigs)} (удалено дубликатов: {len(all_signatures) - len(unique_sigs)})")
        output_file = CONFIG["output_file"]
        new_file = output_file + ".new"
        bak_file = output_file + ".bak"

        if write_msdb(unique_sigs, new_file, logger):
            new_size = os.path.getsize(new_file)
            if new_size < 100:
                logger.error(f"Новый файл подозрительно маленький ({new_size} байт) - rollback")
                os.remove(new_file)
            else:
                if os.path.exists(output_file):
                    try:
                        shutil.copy2(output_file, bak_file)
                        logger.info(f"Backup создан: {os.path.basename(bak_file)}")
                    except Exception as e:
                        logger.warn(f"Не удалось создать backup: {e}")

                try:
                    if os.path.exists(output_file): os.remove(output_file)
                    os.rename(new_file, output_file)
                    msdb_sha256 = ""
                    try:
                        with open(output_file, "rb") as _f:
                            msdb_sha256 = hashlib.sha256(_f.read()).hexdigest()
                    except Exception:
                        pass
                    save_version(CONFIG["version_file"], len(unique_sigs), msdb_sha256)
                    logger.ok("База успешно обновлена (с rollback-защитой)")
                    success = True
                except Exception as e:
                    logger.error(f"Ошибка замены файла: {e}")
                    if os.path.exists(bak_file):
                        try:
                            shutil.copy2(bak_file, output_file)
                            logger.warn("Восстановлена предыдущая версия из backup")
                        except Exception:
                            pass
        else: logger.error("Не удалось записать новый файл базы")

    elif success:
        logger.warn("SHA256 сигнатуры не найдены в базах ClamAV. Возможно формат изменился.")
        logger.info("Тестовая база test_signatures.msdb остается активной.")

    if not CONFIG.get("keep_extracted", False):
        logger.info("\nОчищаем временные файлы...")
        try:
            def remove_readonly(func, path, _):
                os.chmod(path, stat.S_IWRITE)
                func(path)
            shutil.rmtree(temp_dir, onerror=remove_readonly)
            logger.ok("Временные файлы удалены")
        except Exception as e:
            logger.warn(f"Не удалось удалить временные файлы: {e}")
    else: logger.info("Временные файлы сохранены для диагностики")

    logger.info("\n" + "=" * 50)
    if success: logger.ok("Обновление завершено успешно!")
    else: logger.error("Обновление завершено с ошибками")
    logger.info("=" * 50)
    logger.close()

if __name__ == "__main__":
    main()