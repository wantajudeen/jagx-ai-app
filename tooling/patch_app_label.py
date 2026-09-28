"""Force Android display name to JagX AI (pubspec package name stays jagx_ai)."""
from pathlib import Path
import re

manifest = Path("android/app/src/main/AndroidManifest.xml")
if manifest.exists():
    t = manifest.read_text()
    t = re.sub(
        r'android:label="[^"]*"',
        'android:label="JagX AI"',
        t,
        count=1,
    )
    # ensure application label if only activity had it
    if 'android:label="JagX AI"' not in t:
        t = t.replace(
            "<application",
            '<application android:label="JagX AI"',
            1,
        )
    manifest.write_text(t)
    print("manifest label -> JagX AI")
else:
    print("no manifest")

# Also patch strings if present
for p in Path("android").rglob("strings.xml"):
    t = p.read_text()
    t2 = re.sub(
        r'<string name="app_name">[^<]*</string>',
        '<string name="app_name">JagX AI</string>',
        t,
    )
    if t2 != t:
        p.write_text(t2)
        print("strings", p)

print("done")
