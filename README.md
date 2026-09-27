# JagX AI (Flutter only)

**Nigeria-first multipurpose AI** by **JagX & JRILICENSE**.

This repo is **Flutter/Dart only**. All Kotlin/Gradle native modules were removed.

## Build APK (GitHub Actions)

1. Repo → **Settings → Secrets and variables → Actions**
   - `JAGX_API_KEY` = your permanent key from Render
   - `JAGX_API_BASE` = `https://jagx-ai-v2.onrender.com` (optional)
   - `OPENROUTER_API_KEY` = optional fallback
2. **Actions → Build Flutter Android APK → Run workflow**
3. Download artifact **JagX-AI-Flutter-APK**

## Local

```bash
flutter pub get
dart run flutter_launcher_icons
flutter build apk --release
```

## Features
- Dark violet UI (Grok-style)
- Chat with suggestion chips
- Works **without login** if Supabase is not configured
- Talks to **JagX Render backend** first, then OpenRouter
- Multilingual
- Bot / settings / premium screens

## Icon
Launcher **J** badge generated in CI (`assets/icons/app_icon.png`).
