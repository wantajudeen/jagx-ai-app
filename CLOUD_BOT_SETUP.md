# JagX cloud bot on Render (free) — no Oracle needed

Oracle is not required. Your backend is already on Render:

`https://jagx-ai-v2.onrender.com` (health returns OK).

## Why not Oracle

Opay virtual cards often fail cloud signups. **Render free** works with no card for the free tier.

## 1) Keep Render awake (do this today)

Free Render **sleeps after 15 minutes** of no traffic.

### Option A — UptimeRobot (easiest, free)

1. Sign up at https://uptimerobot.com (free)
2. **Add New Monitor**
3. Type: **HTTP(s)**
4. URL: `https://jagx-ai-v2.onrender.com/health`
5. Interval: **5 minutes**
6. Save

**Do not** monitor `/robots.txt` — while asleep, Render answers that itself and **does not wake** your app.

### Option B — GitHub Action (already in this repo)

Workflow: `.github/workflows/keep-alive.yml`  
Pings `/health` every ~10 minutes.  
In GitHub → **Actions** → enable workflows if asked → run **Keep Render awake** once manually.

### Option C — cron-job.org

1. https://cron-job.org
2. Create job → URL `https://jagx-ai-v2.onrender.com/health`
3. Every **10 minutes**

**Note:** One free service awake ~24/7 uses most of the **750 free hours/month**. That is fine for one backend.

---

## 2) How “login once on X” works for you AND other users

Grok Bot: each person logs into X **on a cloud PC**; the session stays on that machine.

On **free Render** the disk is temporary, so the safe free design is:

| Who | What they do |
|-----|----------------|
| **You (admin)** | Create an X developer app (free) once |
| **Each user** | Connect **their own** X account (OAuth or API keys) |
| **JagX** | Stores tokens **per user** (Vault on device + optional Supabase `bot_credentials`) |
| **Backend job** | Uses **that user’s** token only — never shares accounts |

### What each user should do (product flow)

1. Sign in to JagX (Google / OTP / password).
2. **Settings → Connectors** → add **X** with their `@handle`.
3. **Settings → Vault** → label `X` + paste **their** token (or complete OAuth when we wire it).
4. **Bot → Start** → e.g. “Draft 3 posts for my X; wait for my OK before posting.”

**Never** ask users for X/Facebook **passwords** in chat. Use OAuth or API tokens only.

### Free X API reality (2026)

X free developer access is limited. Drafting + scheduling in JagX always works. **Live auto-post** depends on what X allows on free API. Prefer: bot drafts → user taps Approve → post.

---

## 3) Supabase SQL (run once)

Supabase → **SQL Editor** → paste from `supabase_schema.sql` (includes `bot_jobs` + `bot_credentials` after update) → **Run**.

---

## 4) What Render can / cannot do for free

| Feature | Free Render |
|---------|-------------|
| Chat API (you have this) | Yes |
| Keep awake with ping | Yes |
| Job queue in Supabase | Yes |
| Per-user tokens | Yes |
| Full Chrome “computer use” 24/7 | Weak (512MB RAM; no persistent disk) |
| True Grok-style overnight browser | Needs paid always-on or free always-on VM later |

**Phase 1 (now):** jobs + drafts + wake-up + per-user connectors.  
**Phase 2:** optional browser worker if RAM allows, or paid small instance.

---

## 5) Your checklist (order)

1. [ ] UptimeRobot → monitor `/health` every 5 min  
2. [ ] Enable GitHub Action keep-alive  
3. [ ] Run updated SQL in Supabase  
4. [ ] Confirm `https://jagx-ai-v2.onrender.com/health` stays fast  
5. [ ] In app: Connectors + Vault for **your** X  
6. [ ] Tell users: each person connects **their** X, not one shared login  

When phase 1 is solid, we add `POST /jobs` on the backend and “Approve post” in the site.
