#!/usr/bin/env python3

import os
import sys
import csv
import json
import gzip
import shutil
import hashlib
import zipfile
import argparse
import datetime
import io
from urllib.parse import urlparse

try:
    import requests
except ImportError:
    print("ERROR: requests не установлен. pip install requests")
    sys.exit(1)

_SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
_PROJECT_DIR = os.path.dirname(_SCRIPT_DIR)
_DATA_DIR = os.environ.get("MP_DATA_DIR", os.path.join(_PROJECT_DIR, "data"))

CONFIG = {
    "data_dir": _DATA_DIR,
    "yara_rules_dir": os.path.join(_DATA_DIR, "yara_rules"),
    "yara_community": os.path.join(_DATA_DIR, "yara_rules", "community"),
    "temp_dir": os.path.join(_SCRIPT_DIR, "temp"),
    "log_dir": os.path.join(_SCRIPT_DIR, "logs"),
    "timeout": 60,
    "chunk_size": 8192,
    "phishing_file": os.path.join(_DATA_DIR, "phishing_domains.txt"),
    "bazaar_file": os.path.join(_DATA_DIR, "malwarebazaar_hashes.txt"),
    "feeds": {
        "yara_abuse_ch": "https://yaraify-api.abuse.ch/download/yaraify-rules.zip",
        "yara_forge": "https://github.com/YARAHQ/yara-forge/releases/latest/download/yara-forge-rules-core.zip",
        "malwarebazaar_sha256_recent": "https://bazaar.abuse.ch/export/txt/sha256/recent/",
        "urlhaus_online": "https://urlhaus.abuse.ch/downloads/text_online/",
        "phishtank_csv": "https://data.phishtank.com/data/online-valid.csv",
    },
}

class Logger:
    def __init__(self, log_dir: str):
        os.makedirs(log_dir, exist_ok=True)
        ts = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
        self.log_path = os.path.join(log_dir, f"feeds_{ts}.log")
        self.log_file = open(self.log_path, "w", encoding="utf-8")

    def log(self, msg: str, level: str = "INFO"):
        ts = datetime.datetime.now().strftime("%H:%M:%S")
        line = f"[{ts}] [{level}] {msg}"
        print(line)
        self.log_file.write(line + "\n")
        self.log_file.flush()

    def close(self):
        self.log_file.close()

def download_to_memory(url: str, logger: Logger, timeout: int = 60):
    try:
        logger.log(f"Скачиваю: {url}")
        headers = {"User-Agent": "MentoringProtector-Updater/1.0"}
        resp = requests.get(url, timeout=timeout, headers=headers, stream=True)
        resp.raise_for_status()
        data = resp.content
        size_mb = len(data) / (1024 * 1024)
        logger.log(f"  Скачано: {size_mb:.1f} MB")
        return data
    except Exception as e:
        logger.log(f"  ОШИБКА скачивания: {e}", "ERROR")
        return None

def download_to_file(url: str, dest: str, logger: Logger, timeout: int = 60):
    try:
        logger.log(f"Скачиваю: {url}")
        headers = {"User-Agent": "MentoringProtector-Updater/1.0"}
        resp = requests.get(url, timeout=timeout, headers=headers, stream=True)
        resp.raise_for_status()

        os.makedirs(os.path.dirname(dest), exist_ok=True)
        total = 0
        with open(dest, "wb") as f:
            for chunk in resp.iter_content(CONFIG["chunk_size"]):
                f.write(chunk)
                total += len(chunk)
        logger.log(f"  Сохранено: {dest} ({total / 1024:.0f} KB)")
        return True
    except Exception as e:
        logger.log(f"  ОШИБКА: {e}", "ERROR")
        return False

def fetch_yara_rules(logger: Logger):
    stats = {"sources": 0, "rules_files": 0, "errors": 0}
    community_dir = CONFIG["yara_community"]
    os.makedirs(community_dir, exist_ok=True)
    temp_dir = CONFIG["temp_dir"]
    os.makedirs(temp_dir, exist_ok=True)
    sources = [
        ("abuse.ch YARAify", CONFIG["feeds"]["yara_abuse_ch"]),
        ("YARA-Forge", CONFIG["feeds"]["yara_forge"]),
    ]
    for name, url in sources:
        logger.log(f"\n--- YARA: {name} ---")
        zip_path = os.path.join(temp_dir, f"yara_{name.replace(' ', '_')}.zip")
        if not download_to_file(url, zip_path, logger, CONFIG["timeout"]):
            stats["errors"] += 1
            continue
        stats["sources"] += 1
        try:
            count = 0
            with zipfile.ZipFile(zip_path, "r") as zf:
                for entry in zf.namelist():
                    if entry.endswith(".yar") or entry.endswith(".yara"):
                        basename = os.path.basename(entry)
                        if not basename: continue
                        prefix = name.lower().replace(" ", "_").replace(".", "_")
                        dest_name = f"{prefix}_{basename}"
                        dest_path = os.path.join(community_dir, dest_name)
                        with zf.open(entry) as src, open(dest_path, "wb") as dst:
                            dst.write(src.read())
                        count += 1
            logger.log(f"  Распаковано: {count} .yar файлов")
            stats["rules_files"] += count
        except Exception as e:
            logger.log(f"  ОШИБКА распаковки: {e}", "ERROR")
            stats["errors"] += 1
        try:
            os.remove(zip_path)
        except OSError:
            pass

    logger.log(f"\nYARA итого: {stats['sources']} источников, {stats['rules_files']} файлов правил, {stats['errors']} ошибок")

    if stats["rules_files"] > 0:
        compiled_cache = os.path.join(CONFIG["yara_rules_dir"], "compiled_rules.yrc")
        if os.path.exists(compiled_cache):
            try:
                os.remove(compiled_cache)
                logger.log("  compiled_rules.yrc удалён - при следующем запуске C++ пересоберёт кэш из всех .yar")
            except OSError as e:
                logger.log(f"  ПРЕДУПРЕЖДЕНИЕ: не удалось удалить compiled_rules.yrc: {e}", "WARN")

    return stats

def fetch_malwarebazaar(logger: Logger):
    stats = {"hashes_downloaded": 0, "hashes_new": 0, "errors": 0}
    url = CONFIG["feeds"]["malwarebazaar_sha256_recent"]
    dest = CONFIG["bazaar_file"]
    logger.log("\n--- MalwareBazaar SHA256 feed ---")
    data = download_to_memory(url, logger, CONFIG["timeout"])
    if data is None:
        stats["errors"] += 1
        return stats

    existing = set()
    if os.path.exists(dest):
        with open(dest, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith("#"):
                    existing.add(line.lower())

    new_hashes = []
    for line in data.decode("utf-8", errors="replace").splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        if len(line) == 64 and all(c in "0123456789abcdef" for c in line.lower()):
            stats["hashes_downloaded"] += 1
            h = line.lower()
            if h not in existing:
                new_hashes.append(h)
                existing.add(h)

    stats["hashes_new"] = len(new_hashes)

    if new_hashes:
        with open(dest, "a", encoding="utf-8") as f:
            if os.path.getsize(dest) == 0 if os.path.exists(dest) else True:
                f.write("# MalwareBazaar SHA256 hashes (abuse.ch, CC0)\n")
                f.write(f"# Updated: {datetime.datetime.now().isoformat()}\n")
            f.write(f"# +{len(new_hashes)} new ({datetime.datetime.now().strftime('%Y-%m-%d')})\n")
            for h in new_hashes:
                f.write(h + "\n")

    logger.log(f"MalwareBazaar: {stats['hashes_downloaded']} скачано, {stats['hashes_new']} новых, {len(existing)} всего в базе")
    return stats

def fetch_urlhaus(logger: Logger):
    stats = {"urls_downloaded": 0, "domains_new": 0, "errors": 0}
    url = CONFIG["feeds"]["urlhaus_online"]
    phishing_file = CONFIG["phishing_file"]

    logger.log("\n--- URLhaus malicious URLs ---")
    data = download_to_memory(url, logger, CONFIG["timeout"])
    if data is None:
        stats["errors"] += 1
        return stats

    existing = _load_existing_domains(phishing_file)

    new_entries = []
    for line in data.decode("utf-8", errors="replace").splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        stats["urls_downloaded"] += 1
        try:
            parsed = urlparse(line if "://" in line else f"http://{line}")
            domain = parsed.hostname
            if domain and domain not in existing:
                new_entries.append(f"{domain}\tmalware\t85\tURLhaus")
                existing.add(domain)
        except Exception:
            continue

    stats["domains_new"] = len(new_entries)

    if new_entries:
        with open(phishing_file, "a", encoding="utf-8") as f:
            f.write(f"\n# URLhaus feed ({datetime.datetime.now().strftime('%Y-%m-%d')}) - {len(new_entries)} new domains\n")
            for entry in new_entries:
                f.write(entry + "\n")

    logger.log(f"URLhaus: {stats['urls_downloaded']} URLs, {stats['domains_new']} новых доменов")
    return stats

def fetch_phishtank(logger: Logger):
    stats = {"urls_downloaded": 0, "domains_new": 0, "errors": 0}
    url = CONFIG["feeds"]["phishtank_csv"]
    phishing_file = CONFIG["phishing_file"]

    logger.log("\n--- PhishTank verified phishing ---")
    data = download_to_memory(url, logger, CONFIG["timeout"])
    if data is None:
        logger.log("  PhishTank может потребовать API key. Зарегистрируйся на phishtank.org.", "WARN")
        stats["errors"] += 1
        return stats

    existing = _load_existing_domains(phishing_file)

    new_entries = []
    try:
        text = data.decode("utf-8", errors="replace")
        reader = csv.DictReader(io.StringIO(text))
        for row in reader:
            phish_url = row.get("url", "")
            if not phish_url:
                continue
            stats["urls_downloaded"] += 1
            try:
                parsed = urlparse(phish_url)
                domain = parsed.hostname
                if domain and domain not in existing:
                    target = row.get("target", "unknown")
                    new_entries.append(f"{domain}\tphishing\t90\tPhishTank:{target}")
                    existing.add(domain)
            except Exception:
                continue
    except Exception as e:
        logger.log(f"  ОШИБКА парсинга CSV: {e}", "ERROR")
        stats["errors"] += 1
        return stats

    stats["domains_new"] = len(new_entries)

    if new_entries:
        with open(phishing_file, "a", encoding="utf-8") as f:
            f.write(f"\n# PhishTank feed ({datetime.datetime.now().strftime('%Y-%m-%d')}) - {len(new_entries)} new domains\n")
            for entry in new_entries:
                f.write(entry + "\n")

    logger.log(f"PhishTank: {stats['urls_downloaded']} URLs, {stats['domains_new']} новых доменов")
    return stats

def _load_existing_domains(phishing_file: str):
    existing = set()
    if os.path.exists(phishing_file):
        with open(phishing_file, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line or line.startswith("#"):
                    continue
                parts = line.split("\t")
                if parts:
                    existing.add(parts[0].lower())
    return existing

def main():
    parser = argparse.ArgumentParser(description="MentoringProtector - Threat Feed Updater")
    parser.add_argument("--yara", action="store_true", help="Скачать YARA community rules")
    parser.add_argument("--malwarebazaar", action="store_true", help="Скачать MalwareBazaar SHA256 feed")
    parser.add_argument("--urlhaus", action="store_true", help="Скачать URLhaus malicious URLs")
    parser.add_argument("--phishtank", action="store_true", help="Скачать PhishTank phishing URLs")
    args = parser.parse_args()

    all_feeds = not (args.yara or args.malwarebazaar or args.urlhaus or args.phishtank)

    logger = Logger(CONFIG["log_dir"])
    logger.log("=" * 60)
    logger.log("MentoringProtector - Threat Feed Updater v1.0")
    logger.log("=" * 60)

    results = {}

    if all_feeds or args.yara: results["yara"] = fetch_yara_rules(logger)
    if all_feeds or args.malwarebazaar: results["malwarebazaar"] = fetch_malwarebazaar(logger)
    if all_feeds or args.urlhaus: results["urlhaus"] = fetch_urlhaus(logger)
    if all_feeds or args.phishtank: results["phishtank"] = fetch_phishtank(logger)

    logger.log("\n" + "=" * 60)
    logger.log("ИТОГО:")
    for name, stats in results.items():
        logger.log(f"  {name}: {stats}")
    logger.log("=" * 60)

    if "yara" in results and results["yara"]["rules_files"] > 0:
        logger.log("\nYARA: перезагрузите правила в приложении (FFI: yara_reload_rules или перезапуск)")

    if "malwarebazaar" in results and results["malwarebazaar"]["hashes_new"] > 0:
        logger.log(f"\nMalwareBazaar: {results['malwarebazaar']['hashes_new']} новых хешей в {CONFIG['bazaar_file']}")
        logger.log("  Для интеграции: Scanner должен загружать этот файл как дополнение к ClamAV сигнатурам")

    if any(name in results for name in ("urlhaus", "phishtank")):
        total_new = sum(results.get(n, {}).get("domains_new", 0) for n in ("urlhaus", "phishtank"))
        if total_new > 0:
            logger.log(f"\nWeb protection: {total_new} новых доменов в {CONFIG['phishing_file']}")
            logger.log("  Перезагрузите web protection (FFI: web_protection_reload_db)")

    logger.log(f"\nЛог: {logger.log_path}")
    logger.close()

if __name__ == "__main__":
    main()
