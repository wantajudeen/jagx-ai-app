# JagX AI

**Nigeria-first multi-purpose AI** — native Android app built with **Kotlin + Jetpack Compose**.

## Features (in progress)
- Dark Grok-style UI
- Ask / Imagine / Build / Bot tabs
- Named multi-agent system (free OpenRouter models)
- Image generation
- Company & finance planner
- Supabase auth (coming)
- Custom angular circuit J icon

## Build

```bash
./gradlew assembleRelease
```

APK is produced automatically by GitHub Actions on every push to `main`.

Download the latest APK from the [Releases](https://github.com/wantajudeen/jagx-ai-app/releases) page or the Actions artifact.

## Stack
- Kotlin
- Jetpack Compose + Material 3
- Navigation Compose
- OkHttp + Coroutines (OpenRouter)
- GitHub Actions CI
