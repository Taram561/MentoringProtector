#!/usr/bin/env python3

import os
import sys
import unittest
import fetch_signatures as fs

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

_TEMP_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "temp")

class _Logger:
    def __init__(self):
        self.lines = []
    def ok(self, msg):
        self.lines.append(("OK", msg))
    def warn(self, msg):
        self.lines.append(("WARN", msg))
    def error(self, msg):
        self.lines.append(("ERROR", msg))
    def info(self, msg):
        pass

def _load_cvd(name):
    path = os.path.join(_TEMP_DIR, name)
    if not os.path.isfile(path):
        return None
    with open(path, "rb") as f:
        header_bytes = f.read(512)
        payload = f.read()
    header_text = header_bytes.split(b"\0")[0].decode("ascii", errors="ignore")
    fields = header_text.split(":")
    return payload, fields

class NcodecAlphabetTests(unittest.TestCase):
    def test_ncodec_alphabet_exact(self):
        self.assertEqual(len(fs._DSIG_NCODEC), 64)
        self.assertEqual(len(set(fs._DSIG_NCODEC)), 64, "алфавит не должен содержать дублей")
        self.assertEqual(fs._DSIG_NCODEC, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789+/")

    def test_lowercase_letters_come_first(self):
        self.assertEqual(fs._DSIG_NCODEC[0], "a")
        self.assertEqual(fs._DSIG_NCODEC[25], "z")
        self.assertEqual(fs._DSIG_NCODEC[26], "A")

class DecodesigBignumTests(unittest.TestCase):
    def test_single_char_is_its_own_value(self):
        self.assertEqual(fs._cli_decodesig_bignum("a"), 0)
        self.assertEqual(fs._cli_decodesig_bignum("b"), 1)
    def test_decode_is_little_endian(self):
        self.assertEqual(fs._cli_decodesig_bignum("ab"), 0 + 1 * 64)
        self.assertEqual(fs._cli_decodesig_bignum("ba"), 1 + 0 * 64)
    def test_invalid_char_raises_value_error(self):
        with self.assertRaises(ValueError):
            fs._cli_decodesig_bignum("a!b")
    def test_empty_string_is_zero(self):
        self.assertEqual(fs._cli_decodesig_bignum(""), 0)

class VerifyCvdDsigUnitTests(unittest.TestCase):
    def test_missing_dsig_field_unavailable(self):
        logger = _Logger()
        fields = ["ClamAV-VDB", "1", "1", "1", "1", "e151d87703ca8215ef18c131c7ebf326"]
        self.assertEqual(fs._verify_cvd_dsig(b"body", fields, logger), "unavailable")
    def test_empty_dsig_unavailable(self):
        logger = _Logger()
        fields = ["ClamAV-VDB", "1", "1", "1", "1", "e151d87703ca8215ef18c131c7ebf326", ""]
        self.assertEqual(fs._verify_cvd_dsig(b"body", fields, logger), "unavailable")
    def test_placeholder_x_dsig_unavailable(self):
        logger = _Logger()
        fields = ["ClamAV-VDB", "1", "1", "1", "1", "e151d87703ca8215ef18c131c7ebf326", "X"]
        self.assertEqual(fs._verify_cvd_dsig(b"body", fields, logger), "unavailable")
    def test_malformed_md5_field_unavailable(self):
        logger = _Logger()
        fields = ["ClamAV-VDB", "1", "1", "1", "1", "not-a-valid-md5", "abc"]
        self.assertEqual(fs._verify_cvd_dsig(b"body", fields, logger), "unavailable")
    def test_body_mismatch_returns_mismatch_before_rsa(self):
        logger = _Logger()
        wrong_md5 = "0" * 32
        fields = ["ClamAV-VDB", "1", "1", "1", "1", wrong_md5, "abc"]
        self.assertEqual(fs._verify_cvd_dsig(b"some body", fields, logger), "mismatch")
    def test_non_ncodec_char_in_dsig_unavailable(self):
        logger = _Logger()
        import hashlib
        payload = b"test payload"
        real_md5 = hashlib.md5(payload).hexdigest()
        fields = ["ClamAV-VDB", "1", "1", "1", "1", real_md5, "a!b"]
        self.assertEqual(fs._verify_cvd_dsig(payload, fields, logger), "unavailable")
    def test_oversized_rsa_result_unavailable(self):
        logger = _Logger()
        import hashlib
        payload = b"test payload"
        real_md5 = hashlib.md5(payload).hexdigest()
        huge_dsig = "/" * 171
        fields = ["ClamAV-VDB", "1", "1", "1", "1", real_md5, huge_dsig]
        status = fs._verify_cvd_dsig(payload, fields, logger)
        self.assertIn(status, ("unavailable", "mismatch"))

@unittest.skipUnless(_load_cvd("daily.cvd") is not None and _load_cvd("main.cvd") is not None, "updater/temp/{daily,main}.cvd отсутствуют - скачать через 'python updater/fetch_signatures.py --force' для полной проверки")
class GenuineCvdTests(unittest.TestCase):
    def setUp(self):
        self.logger = _Logger()
    def test_genuine_daily_verified(self):
        payload, fields = _load_cvd("daily.cvd")
        self.assertEqual(fs._verify_cvd_dsig(payload, fields, self.logger), "verified")
    def test_genuine_main_verified(self):
        payload, fields = _load_cvd("main.cvd")
        self.assertEqual(fs._verify_cvd_dsig(payload, fields, self.logger), "verified")
    def test_tampered_dsig_rejected(self):
        payload, fields = _load_cvd("daily.cvd")
        tampered = list(fields)
        d = tampered[6]
        flipped = ("b" if d[0] != "b" else "c") + d[1:]
        tampered[6] = flipped
        status = fs._verify_cvd_dsig(payload, tampered, self.logger)
        self.assertNotEqual(status, "verified")
    def test_tampered_md5_field_mismatch(self):
        payload, fields = _load_cvd("daily.cvd")
        tampered = list(fields)
        m = tampered[5]
        tampered[5] = ("a" if m[0] != "a" else "0") + m[1:]
        status = fs._verify_cvd_dsig(payload, tampered, self.logger)
        self.assertEqual(status, "mismatch")
    def test_tampered_body_mismatch(self):
        payload, fields = _load_cvd("daily.cvd")
        tampered_payload = payload + b"\x00"
        status = fs._verify_cvd_dsig(tampered_payload, fields, self.logger)
        self.assertEqual(status, "mismatch")

if __name__ == "__main__":
    unittest.main()
