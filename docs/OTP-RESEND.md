# Supabase Email OTP with Resend

OTP fails when Supabase cannot send mail. Connect **Resend** (or use Supabase built-in SMTP).

## 1. Resend account

1. Sign up: https://resend.com
2. **API Keys** → Create key → copy `re_...`
3. **Domains** → Add your domain (e.g. `jagxai.name.ng` or a subdomain like `mail.jagxai.name.ng`)
4. Add the DNS records Resend shows (SPF, DKIM, etc.)
5. Wait until domain is **Verified**

## 2. Supabase SMTP (Resend)

Supabase Dashboard → **Project Settings** → **Authentication** → **SMTP Settings** (or **Email**)

| Field | Value |
|-------|--------|
| Enable custom SMTP | ON |
| Host | `smtp.resend.com` |
| Port | `465` (SSL) or `587` (STARTTLS) |
| Username | `resend` |
| Password | your Resend API key `re_...` |
| Sender email | e.g. `auth@jagxai.name.ng` (must be on verified domain) |
| Sender name | `JagX AI` |

Save.

## 3. Email auth provider

**Authentication → Providers → Email**

- Enable Email
- Enable **Email OTP** / magic link as you prefer
- Confirm email can stay ON for production

## 4. Templates (optional)

**Authentication → Email Templates** → Magic Link / OTP  
Make sure the template includes `{{ .Token }}` for the 6-digit code.

## 5. Test

1. Open JagX app → Send code
2. Check inbox + spam for the code from your sender address
3. If still failing: Supabase **Logs** → Auth / Auth emails

## Without Resend (quick test only)

Supabase free tier can send a **limited** number of emails from their default sender. For real users, use Resend (or another SMTP).
