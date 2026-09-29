# Resend + Supabase email auth (JagX AI)

Resend does **not** replace login by itself. It **sends** Supabase auth emails (signup confirm, magic link, password reset) reliably.

## 1. Resend
1. Create account at https://resend.com
2. Add and verify domain (e.g. `jagxai.name.ng` or your email domain)
3. Create API key (Sending access)

## 2. Supabase SMTP
Dashboard → **Authentication** → **Emails** → **SMTP Settings**:

| Field | Value |
|--------|--------|
| Host | `smtp.resend.com` |
| Port | `465` |
| Username | `resend` |
| Password | your Resend API key (`re_...`) |
| Sender email | e.g. `noreply@your-verified-domain` |
| Sender name | `JagX AI` |

Save. Test with **Email magic link** on the site.

## 3. Site behaviour
- **Password** signup / sign-in (existing)
- **Google** OAuth (existing)
- **Email magic link (Resend)** — uses `signInWithOtp`; email is delivered via Resend SMTP

## 4. Redirect URLs
Supabase → Authentication → URL configuration:
- Site URL: `https://jagxai.name.ng`
- Redirect: `https://jagxai.name.ng/**` and your Vercel URL if used
