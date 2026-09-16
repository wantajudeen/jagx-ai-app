# Domain + SSL (jagxai.name.ng)

## Your current SSL error

`NET::ERR_CERTIFICATE_TRANSPARENCY_REQUIRED` means the browser is forcing **HTTPS** but GitHub has **not finished** issuing a valid certificate for the custom domain yet.

This is **not** an app bug.

## Fix steps

1. GitHub → **Settings → Pages**
2. Custom domain: `jagxai.name.ng` (you already have DNS check successful)
3. Wait until **Enforce HTTPS** becomes clickable (can take 30 min – 24 hours after DNS is green)
4. Enable **Enforce HTTPS**
5. Until then, open the site as:
   - `http://jagxai.name.ng` (not https)
   - or `https://wantajudeen.github.io/jagx-ai-app/`

## DNS (keep these)

A records for `@`:

- 185.199.108.153
- 185.199.109.153
- 185.199.110.153
- 185.199.111.153

Optional CNAME `www` → `wantajudeen.github.io`

## If SSL stays broken

1. Pages → **Remove** custom domain
2. Wait 2 minutes
3. Add `jagxai.name.ng` again → Save
4. Wait for DNS check + certificate
5. Enable Enforce HTTPS

Repo root has `index.html` + `CNAME` so **Deploy from branch → main → /(root)** is correct.
