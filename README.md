# JagX AI (Flutter)

**Nigeria-first multipurpose AI** — Flutter (Dart) app by **JagX & JRILICENSE**.

## What this repo is

| Layer | Status |
|-------|--------|
| **Flutter app** (`lib/`, `pubspec.yaml`) | **Primary** — Android APK via GitHub Actions |
| **Web landing** (`index.html`) | GitHub Pages |
| **Kotlin `app/` folder** | Legacy — not used for Flutter APK builds |

## Why builds used to fail

CI was running **Gradle Kotlin** (`./gradlew assembleRelease`) while the real UI lives in **Flutter**. Manifest also referenced a missing `@drawable/ic_launcher`. That is fixed: CI now builds with **Flutter**.

## Build (CI)

Push to `main` or run **Actions → Build Flutter Android APK → Run workflow**.

Artifact: **JagX-AI-Flutter-APK** → `app-release.apk`

### Required GitHub Secrets

Repo → **Settings → Secrets and variables → Actions**

| Secret | Purpose |
|--------|---------|
| `JAGX_API_KEY` | Permanent key from Render backend `/create-key` |
| `JAGX_API_BASE` | Optional, default `https://jagx-ai-v2.onrender.com` |
| `OPENROUTER_API_KEY` | Optional fallback |

## Local build

```bash
flutter pub get
dart run flutter_launcher_icons
flutter build apk --release
```

APK path: `build/app/outputs/flutter-apk/app-release.apk`

## App icon

Dark **J** badge (`assets/icons/app_icon.png`) applied with `flutter_launcher_icons` (Android launcher icon).

## Backend

Chat prefers **JagX Backend** on Render (`POST /chat` + header `x-api-key`), then OpenRouter free models.
