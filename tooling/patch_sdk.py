from pathlib import Path
import re

for rel in ("android/app/build.gradle", "android/app/build.gradle.kts"):
    p = Path(rel)
    if not p.exists():
        print("missing", rel)
        continue
    t = p.read_text()
    t = re.sub(r"compileSdk\s*=\s*flutter\.compileSdkVersion", "compileSdk = 35", t)
    t = re.sub(r"compileSdk\s*=\s*\d+", "compileSdk = 35", t)
    t = re.sub(r"minSdk\s*=\s*flutter\.minSdkVersion", "minSdk = 24", t)
    t = re.sub(r"minSdk\s*=\s*\d+", "minSdk = 24", t)
    t = re.sub(r"targetSdk\s*=\s*flutter\.targetSdkVersion", "targetSdk = 35", t)
    t = re.sub(r"targetSdk\s*=\s*\d+", "targetSdk = 35", t)
    p.write_text(t)
    print("patched", rel)

root = Path("android/build.gradle")
if root.exists():
    extra = """
subprojects { sub ->
  sub.afterEvaluate {
    def a = sub.extensions.findByName('android')
    if (a != null) {
      try { a.compileSdkVersion(35) } catch (Throwable ignored) {}
      try { a.compileSdk = 35 } catch (Throwable ignored) {}
    }
  }
}
"""
    text = root.read_text()
    if "compileSdkVersion(35)" not in text:
        root.write_text(text + extra)
print("done")
