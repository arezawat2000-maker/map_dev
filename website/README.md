# MAP.DEV Marketing Website

Public marketing site for the MAP.DEV team: brand hero + “Request an App” form.

This lives next to the Flutter app and does **not** replace it.

## Run locally

```bash
cd website
npm install
npm run dev
```

Open the URL Vite prints (default `http://localhost:5173`).

### Production build

```bash
npm run build
npm run preview
```

Static output is in `website/dist/` — deploy that folder to any static host (Netlify, Vercel, Cloudflare Pages, Firebase Hosting, etc.).

## Brand assets

- Logo / primary visual: `public/assets/logo.png`
- Favicon: `public/favicon.png`
- Apple touch icon: `public/apple-touch-icon.png`

## Form fields

| Field | Required | Notes |
| --- | --- | --- |
| App name | Yes | Short product name |
| App description | Yes | What to build |
| Your name | No | Requester |
| Email / contact | No | So the team can reply |

Client-side validation blocks empty required fields and overly short descriptions.

## Form submission (Formspree)

The form POSTs JSON to Formspree via `fetch`.

1. Create a free form at [formspree.io](https://formspree.io).
2. Copy your form ID (e.g. `xpwzgkqj`).
3. Either:
   - Set it in `src/config.js` by replacing `YOUR_FORM_ID`, **or**
   - Create `website/.env` (do not commit secrets):

```env
VITE_FORMSPREE_ID=your_real_form_id
```

4. Restart `npm run dev`.

Until Formspree is configured, submit opens a `mailto:` draft as a temporary fallback and still shows the success state for demos.

## Optional: Firebase / Firestore

Project `map-dev-19fb0` already has Android (and possibly iOS) apps. The Firebase **JS** SDK needs a **Web** app config — Android `google-services.json` alone is not enough (different `appId`).

To store requests in Firestore collection `app_requests`:

1. Firebase Console → Project settings → Add app → **Web**.
2. Copy the web config object.
3. Paste into `FIREBASE_WEB_CONFIG` in `src/config.js` (or wire env vars yourself).
4. Enable Firestore and add write rules appropriate for public form intake (prefer a Cloud Function or App Check in production).
5. Extend `src/main.js` to `addDoc` into `app_requests` after (or instead of) Formspree.

Do not invent or commit fake web API keys. The Android API key in `android/app/google-services.json` is for mobile clients only.

## Stack

- Vite
- Vanilla HTML / CSS / JS
- Google Fonts: Orbitron + Rajdhani

## Flutter app

Leave the Flutter project at the repo root untouched. Develop and deploy this site from `website/` only.
