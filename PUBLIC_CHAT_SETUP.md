# Public web chat (no API key for users)

So visitors on **jagxai.name.ng** can chat without pasting a key:

## On Render (JagX-ai-v2)

1. Open your web service → **Environment**
2. Add:

```
JAGX_ALLOW_PUBLIC_CHAT=true
JAGX_PUBLIC_HOURLY=60
```

3. Update `main.py` `/chat` handler to accept guests (IP rate limit) when that env is true.

### Patch for `/chat`

Replace the key check with:

- If `x-api-key` is valid → normal rate limit
- Else if `JAGX_ALLOW_PUBLIC_CHAT` → guest limit by IP (default 60/hour)
- Else → 401

Redeploy Render after saving.

## APK download (no GitHub login)

https://github.com/wantajudeen/jagx-ai-app/releases/download/apk-latest/JagX-AI.apk

Published automatically when the Flutter workflow succeeds.
