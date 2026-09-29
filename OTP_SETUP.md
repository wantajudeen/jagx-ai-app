# Email OTP for JagX users (Resend + Supabase)

Users get a **6-digit OTP** in email, then type it on the sign-in screen.

## 1. Resend SMTP (required or emails fail)

Supabase → **Authentication → Emails → SMTP Settings**:

| Field | Value |
|--------|--------|
| Host | smtp.resend.com |
| Port | 465 |
| Username | resend |
| Password | your Resend API key `re_...` |
| Sender email | verified domain e.g. noreply@yourdomain.com |
| Sender name | JagX AI |

## 2. Email template = OTP code (not only magic link)

Supabase → **Authentication → Email Templates → Magic Link**

Change body so it includes the token, for example:

```
Your JagX AI code is: {{ .Token }}

This code expires soon. Enter it on the sign-in screen.
```

Use `{{ .Token }}` for the digits.
You can keep or remove `{{ .ConfirmationURL }}`.

## 3. Site behaviour (already coded)

1. User enters email → **Send OTP code**
2. Supabase sends email via Resend
3. User enters 6-digit code → **Verify & sign in**
4. Password and Google still work as backup

## 4. Redirect URLs

Authentication → URL Configuration:

- Site URL: https://jagxai.name.ng
- Redirect: https://jagxai.name.ng/** and https://wantajudeen.github.io/jagx-ai-app/**

## 5. Test

1. Open site → Sign in
2. Enter real email → Send OTP
3. Check inbox + spam
4. Paste code → Verify

If no email arrives: Resend domain not verified, or SMTP not saved, or rate limit.
