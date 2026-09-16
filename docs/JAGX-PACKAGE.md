# .jagx package format

`.jagx` is the branded install package for the **JagX ecosystem** (JagX OS / JagX devices).

## Current (Android)

On every successful Android build we produce:

- `JagX-AI.apk` — standard Android package
- `JagX-AI.jagx` — same binary, branded extension for JagX OS / sideload pipelines

Both install on normal Android. The `.jagx` name is for:

1. JagX OS package manager recognition
2. Branded downloads and releases
3. Future signed JagX-only distribution

## Future

- Desktop: `JagX-AI-windows.jagx` (or `.exe` + `.jagx` sidecar)
- iOS / macOS: `.jagx` as a distribution wrapper when targets land
- Custom installer that registers with JagX OS

Until JagX OS ships a native package manager, treat `.jagx` as the official JagX-branded APK.
