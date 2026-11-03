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
- GitHub App OAuth → encrypted server-side token storage and repository-scoped API
- Sandbox client: run code; GitHub workspace browses files and commits approved edits through the JagX backend

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


## GitHub App OAuth setup

The GitHub workspace no longer accepts personal access tokens in the browser. Configure the backend variables documented in the JagX AI v2 repository's `.env.example`, create a GitHub App with **Contents: Read and write** and **Metadata: Read**, and install it only on repositories the user selects. The callback must be `https://jagx-ai-v2.onrender.com/github/callback` for the current backend URL. The integration remains unavailable until the App credentials, encryption key, and persistent token database are configured on the backend host and end-to-end tests pass.
