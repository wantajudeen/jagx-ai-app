# Domain fix — jagxai.name.ng

## Status (server side)

- `https://jagxai.name.ng` → **200 OK** on GitHub Pages
- TLS certificate valid for `jagxai.name.ng` and `www.jagxai.name.ng`
- GitHub Pages IPs: 185.199.108.153 / .109 / .110 / .111

If your phone shows **ERR_CONNECTION_REFUSED**, the problem is almost always **your network DNS**, not the site being offline.

## Use these URLs (in order)

1. **https://jagxai.name.ng** (no `www`)
2. **https://wantajudeen.github.io/jagx-ai-app/** (always works as backup)
3. Avoid only `www.` if your ISP breaks it — both should work when DNS is healthy

## Phone fixes

1. Switch Wi‑Fi ↔ mobile data
2. Chrome Incognito → paste `https://jagxai.name.ng`
3. Android: Settings → Network → **Private DNS** → Off, then retry
4. Clear Chrome cache for the site or clear DNS (toggle airplane mode 15s)

## DNS at your registrar (name.ng)

**A records** for `@` (apex):

- 185.199.108.153
- 185.199.109.153
- 185.199.110.153
- 185.199.111.153

**CNAME** for `www`:

- `www` → `wantajudeen.github.io`

Delete any old A/AAAA records that point elsewhere.

## GitHub Pages reset (if still broken on your side only)

1. Repo → **Settings → Pages**
2. Custom domain: remove `jagxai.name.ng` → Save
3. Wait 2 minutes
4. Add `jagxai.name.ng` again → Save
5. Wait until DNS check is green
6. Enable **Enforce HTTPS**
7. Source: **Deploy from branch** → `main` → `/ (root)`

## Not an app code bug

Google can list the site while your phone still fails if your ISP cannot open a connection to GitHub’s edge. Use the **github.io** link until your DNS works.
