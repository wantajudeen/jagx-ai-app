# JagX AI public web chat

The browser app must never ship a permanent JagX API key. The web workspace calls the rate-limited `POST /public-chat` endpoint on the JagX backend.

## Backend rollout

1. Merge and deploy the companion backend pull request: https://github.com/wantajudeen/jagx-backend/pull/1
2. On Render, confirm `GET /health` responds successfully.
3. The new guest endpoint applies the existing global IP limiter plus `JAGX_PUBLIC_CHAT_RPM` (default: 12 requests per minute per client IP).
4. Set `JAGX_CORS_ORIGINS` to a comma-separated list of exact trusted origins if the defaults do not match the deployed web domains.
5. Chat transcripts are not added to the training-data JSONL file unless `JAGX_TRAINING_DATA_ENABLED=true` is explicitly set.

## Frontend rollout

1. Merge and deploy the frontend pull request: https://github.com/wantajudeen/jagx-ai-app/pull/2
2. Verify guest chat, a rejected/oversized request, and rate-limit responses from a browser.
3. Revoke the old permanent API key that was previously bundled into browser JavaScript. Do this after the new frontend/backend deployment is live so existing clients are not broken during rollout.

## Important

The guest route is intentionally rate-limited and does not require users to paste an API key. It is not a replacement for a future authenticated usage and billing layer. Do not place provider keys, admin secrets, or permanent API keys in frontend files.
