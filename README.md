# JagX AI

**Nigeria-first multi-purpose AI** — native **Kotlin + Jetpack Compose**.

## Platforms

| Platform | Status | Artifact |
|----------|--------|----------|
| **Android** | Building now | `JagX-AI.apk` + `JagX-AI.jagx` |
| **Windows** | Next | Compose Multiplatform desktop |
| **macOS** | Next | Compose Multiplatform desktop |
| **Linux** | Next | Compose Multiplatform desktop |
| **iOS** | Next | Compose Multiplatform (macOS runner) |
| **Web** | Live | GitHub Pages (`index.html`) |

## Features (shipping)
- Dark Grok-style UI
- Ask / Imagine / Build / Bot tabs
- Named multi-agent system (free OpenRouter models)
- Image generation
- Company & finance planner
- Custom angular circuit J icon
- Supabase auth (next)

## Download

- **Android APK**: [Releases](https://github.com/wantajudeen/jagx-ai-app/releases) → `apk-latest`
- Or Actions → latest green run → Artifacts → `JagX-AI-Android-APK`

## Build locally

```bash
./gradlew assembleRelease
```

## Stack
- Kotlin 2.0
- Jetpack Compose + Material 3
- Navigation Compose
- OkHttp + Coroutines
- GitHub Actions CI
