from pathlib import Path

manifest = Path("android/app/src/main/AndroidManifest.xml")
if not manifest.exists():
    print("no AndroidManifest.xml")
    raise SystemExit(0)

text = manifest.read_text()
if "com.jagx.jagxai" in text:
    print("oauth intent already present")
    raise SystemExit(0)

intent = '''
            <!-- Supabase Google OAuth callback -->
            <intent-filter>
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data android:scheme="com.jagx.jagxai" android:host="login-callback" />
            </intent-filter>
'''

needle = "</activity>"
if needle not in text:
    print("could not find </activity>")
    raise SystemExit(1)

# Insert before the first MainActivity closing tag only once
parts = text.split(needle, 1)
text = parts[0] + intent + needle + parts[1]
manifest.write_text(text)
print("oauth intent patched")
