# JagX AI

**by JRILICENSE**

Free AI chat + multi-agent Bot + connectors. Mobile app (Flutter) and website.

## Links

| | |
|--|--|
| Website | https://jagxai.name.ng |
| Backend | https://jagx-ai-v2.onrender.com |
| Health | https://jagx-ai-v2.onrender.com/health |
| Ready | https://jagx-ai-v2.onrender.com/ready |
| APK | [Releases → apk-latest](https://github.com/wantajudeen/jagx-ai-app/releases/tag/apk-latest) |

## App (Flutter)

- Chat with JagX backend + OpenRouter fallback
- **Bot** goals run on the **server** (`POST /jobs`) — keep working after you close the app
- Connectors catalog + GitHub PAT → server vault
- Sandbox client: run code, import/export GitHub files

### Build APK

GitHub → **Actions** → **Build Flutter Android APK** → Run workflow  
Or push to `main` (workflow auto-runs). Download **JagX-AI.apk** from the release.

Secrets used: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, optional `OPENROUTER_API_KEY`, `JAGX_API_KEY`.

## Website

Static site (`index.html` + `app.js`). Deploy: **Actions → Deploy website**.  
Branding: **JagX by JRILICENSE** · Terms · Privacy.

## Backend features

`/chat` · `/news` · `/geo` · `/weather` · `/mcp/*` · `/jobs` · `/vault` · `/code/*` · `/memory` · `/sandbox/*` · `/ready`

## Supabase

See `SUPABASE_SETUP.md` and `supabase_schema.sql` (auth + future jobs/memory tables).
