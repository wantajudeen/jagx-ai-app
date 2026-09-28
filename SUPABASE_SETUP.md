# Supabase auth for JagX AI

## GitHub Secrets (required)

Repo → **Settings → Secrets and variables → Actions**

| Secret | Example |
|--------|---------|
| `SUPABASE_URL` | `https://xxxx.supabase.co` |
| `SUPABASE_ANON_KEY` | `eyJhbGciOi...` (anon / public key) |

Optional (already used):
- `JAGX_API_KEY`, `JAGX_API_BASE`, `OPENROUTER_API_KEY`

## Supabase dashboard

1. **Authentication → Providers**
   - Enable **Email**
   - Enable **Google** (paste Google Client ID + Secret)
2. **Authentication → URL configuration**
   - Site URL: `https://jagxai.name.ng`
   - Redirect URLs:
     - `https://jagxai.name.ng`
     - `https://jagxai.name.ng/**`
     - `com.jagx.jagxai://login-callback/`
3. For Google Cloud OAuth client:
   - Authorized redirect URI must include your Supabase callback:
     `https://<project-ref>.supabase.co/auth/v1/callback`

## Email confirmation

If "Confirm email" is ON, users must open the email link before the first sign-in works.
You can turn confirmation off under **Authentication → Providers → Email** for faster testing.

## After saving secrets

Push to `main` or re-run:
- **Build Flutter Android APK**
- **Deploy website**
