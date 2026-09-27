from pathlib import Path
import re

# Only patch the app module. Do NOT add root afterEvaluate —
# Flutter 3.27 Gradle already evaluates projects and that crashes:
# "Cannot run Project.afterEvaluate(Closure) when the project is already evaluated."

for rel in ("android/app/build.gradle", "android/app/build.gradle.kts"):
    p = Path(rel)
    if not p.exists():
        print("missing", rel)
        continue
    t = p.read_text()
    t = re.sub(r"compileSdk\s*=\s*flutter\.compileSdkVersion", "compileSdk = 35", t)
    t = re.sub(r"compileSdkVersion\s+flutter\.compileSdkVersion", "compileSdkVersion 35", t)
    t = re.sub(r"compileSdk\s*=\s*\d+", "compileSdk = 35", t)
    t = re.sub(r"minSdk\s*=\s*flutter\.minSdkVersion", "minSdk = 24", t)
    t = re.sub(r"minSdkVersion\s+flutter\.minSdkVersion", "minSdkVersion 24", t)
    t = re.sub(r"minSdk\s*=\s*\d+", "minSdk = 24", t)
    t = re.sub(r"targetSdk\s*=\s*flutter\.targetSdkVersion", "targetSdk = 35", t)
    t = re.sub(r"targetSdkVersion\s+flutter\.targetSdkVersion", "targetSdkVersion 35", t)
    t = re.sub(r"targetSdk\s*=\s*\d+", "targetSdk = 35", t)
    p.write_text(t)
    print("patched", rel)
print("done")
