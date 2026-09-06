# MAP.DEV Marketing Website

Public marketing site for the MAP.DEV team: brand hero + “Request an App” form.

This lives next to the Flutter apps and does **not** replace them.

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

## Form submission (Firebase Realtime Database)

The form POSTs JSON to Firebase RTDB `requests` (same path the Flutter user and admin apps use).

Each request includes `status: "pending"` plus the form fields and an ISO timestamp.

## Stack

- Vite
- Vanilla HTML / CSS / JS
- Google Fonts: Orbitron + Rajdhani

## Flutter apps

- **User app** — repo root (`flutter run`)
- **Admin app** — `admin/` (`cd admin && flutter run`)

Develop and deploy this site from `website/` only.
