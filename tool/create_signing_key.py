#!/usr/bin/env python3
"""Create a private Android release key and files for GitHub Actions secrets."""

import base64
import os
import secrets
import subprocess
from pathlib import Path


def main():
    root = Path(__file__).resolve().parent.parent
    private = root / ".secrets"
    properties = root / "android/key.properties"
    if private.exists() or properties.exists():
        raise SystemExit("Existing signing files found. Reuse and back them up; do not replace the release key.")
    os.umask(0o077)
    private.mkdir(mode=0o700)
    password = secrets.token_urlsafe(48)
    alias = "capidock"
    keystore = private / "capidock-release.jks"
    subprocess.run(
        [
            "keytool", "-genkeypair", "-keystore", str(keystore),
            "-storetype", "JKS", "-keyalg", "RSA", "-keysize", "4096",
            "-validity", "10000", "-alias", alias,
            "-dname", "CN=Capidock, O=Zephyrus",
            "-storepass:env", "CAPIDOCK_GENERATED_PASSWORD",
            "-keypass:env", "CAPIDOCK_GENERATED_PASSWORD",
        ],
        env={**os.environ, "CAPIDOCK_GENERATED_PASSWORD": password},
        check=True,
    )
    values = {
        "ANDROID_KEYSTORE_BASE64": base64.b64encode(keystore.read_bytes()).decode(),
        "ANDROID_KEYSTORE_PASSWORD": password,
        "ANDROID_KEY_ALIAS": alias,
        "ANDROID_KEY_PASSWORD": password,
    }
    for name, value in values.items():
        (private / f"{name}.txt").write_text(value)
    properties.write_text(
        f"storeFile=../.secrets/capidock-release.jks\n"
        f"storePassword={password}\nkeyAlias={alias}\nkeyPassword={password}\n"
    )
    print(f"Private signing files created in {private} (excluded from Git).")
    print("Back up this directory securely. Add the four ANDROID_*.txt values to GitHub Secrets.")
    print("No private key or password was printed.")


if __name__ == "__main__":
    main()
