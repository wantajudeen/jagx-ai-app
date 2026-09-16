# Connect jagxai.name.ng to JagX website

The site lives in `/docs` and deploys with **GitHub Pages**.

## 1. Enable GitHub Pages

1. Open https://github.com/wantajudeen/jagx-ai-app/settings/pages  
2. **Source**: GitHub Actions  
3. Wait for the **Deploy website** workflow to finish  
4. Temporary URL will look like:  
   `https://wantajudeen.github.io/jagx-ai-app/`

## 2. Custom domain in GitHub

Still on **Settings → Pages**:

1. **Custom domain**: `jagxai.name.ng`  
2. Save  
3. Enable **Enforce HTTPS** (after DNS works)

A `docs/CNAME` file is already in the repo with `jagxai.name.ng`.

## 3. DNS at your domain registrar (name.ng)

### Option A — Apex domain `jagxai.name.ng` (recommended)

Add **A** records pointing to GitHub Pages IPs:

| Type | Host / Name | Value |
|------|-------------|--------|
| A | `@` | `185.199.108.153` |
| A | `@` | `185.199.109.153` |
| A | `@` | `185.199.110.153` |
| A | `@` | `185.199.111.153` |

Optional **www**:

| Type | Host | Value |
|------|------|--------|
| CNAME | `www` | `wantajudeen.github.io` |

### Option B — Only subdomain `www.jagxai.name.ng`

| Type | Host | Value |
|------|------|--------|
| CNAME | `www` | `wantajudeen.github.io` |

Then set custom domain in GitHub to `www.jagxai.name.ng`.

## 4. Wait & verify

- DNS can take **5 minutes to 48 hours**  
- GitHub Pages → domain should show **DNS check successful**  
- Turn on **Enforce HTTPS**  
- Visit https://jagxai.name.ng

## 5. If SSL errors (wrong cert)

- Remove and re-add the custom domain in GitHub Pages  
- Confirm A/CNAME records match the tables above  
- Wait for HTTPS to provision  
- Do **not** use Cloudflare “Full (strict)” until GitHub shows a valid cert

## 6. APK downloads

Mobile builds: **Actions → Build APK → Artifacts**
