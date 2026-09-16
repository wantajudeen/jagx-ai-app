# JagX AI logo

## Brand mark (app icon)
- Black square background
- Abstract geometric mark: node network + angular **X** (not a plain letter J)
- White / silver only — high contrast for Android adaptive icons
- Safe padding so the mark is not cropped on round icons

## Wordmark (splash / website)
- **JagX** in bold modern sans, white
- **AI** smaller, muted gray beside or under
- Optional small mark to the left of the wordmark

## Do not use
- Default Flutter / Dart logo
- Single-letter J as the only mark long-term
- Green Material default avatars as brand identity

## Source of truth
After you pick a generated design, export PNG 512×512 and 1024×1024 into:
- `assets/icons/app_icon.png`
- `assets/icons/app_icon_fg.png`

CI overwrites launcher mipmaps from `assets/icons/app_icon.png` on every APK build.
