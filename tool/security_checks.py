#!/usr/bin/env python3
"""Regression guardrails, not a vulnerability scanner or a security audit."""
from pathlib import Path
import subprocess
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
ANDROID = '{http://schemas.android.com/apk/res/android}'
manifest = ET.parse(ROOT / 'android/app/src/main/AndroidManifest.xml').getroot()
app = manifest.find('application')
assert app is not None
assert app.get(ANDROID + 'allowBackup') == 'false', 'Android backup must remain disabled'
assert app.get(ANDROID + 'usesCleartextTraffic') == 'false', 'Cleartext must remain disabled'
assert app.get(ANDROID + 'networkSecurityConfig') == '@xml/network_security_config'
for rules in ['backup_rules.xml', 'data_extraction_rules.xml']:
    tree = ET.parse(ROOT / 'android/app/src/main/res/xml' / rules)
    assert tree.findall('.//exclude'), f'{rules}: missing backup exclusions'
activity = (ROOT / 'android/app/src/main/kotlin/com/zephyrushq/capidock/MainActivity.kt').read_text()
assert 'FLAG_SECURE' in activity and 'setHideOverlayWindows' in activity
release = (ROOT / '.github/workflows/release.yml').read_text()
assert '--obfuscate' in release and '--split-debug-info=' in release
for path in (ROOT / 'lib').rglob('*.dart'):
    source = path.read_text()
    assert 'badCertificateCallback' not in source, f'TLS override in {path}'
    assert 'onDebug:' not in source, f'SSH wire logging in {path}'
    assert 'followRedirects = true' not in source, f'Authenticated redirects in {path}'
tracked = subprocess.check_output(['git', 'ls-files', '-z'], cwd=ROOT).decode().split('\0')
for name in tracked:
    assert not name.endswith(('.jks', '.keystore', 'key.properties')), f'Signing secret tracked: {name}'
print('Security regression guardrails passed.')
