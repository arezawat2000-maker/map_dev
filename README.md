# MAP.DEV

Flutter apps + marketing website for MAP.DEV app requests.

## Apps

| App | Role | Location |
| --- | --- | --- |
| **User** | Google login, profile, posts, requests, gated chat | repo root (this project) |
| **Admin** | Google login (admin registry), users, posts, chat control | [`admin/`](admin/) |
| **Website** | Public marketing + request form | [`website/`](website/) |

User + admin apps share Firebase Realtime Database path `requests`.
Profiles, chat, posts, and admin registry use **Cloud Firestore**.

## Auth flow (user app)

```
Splash / auth check
  → not signed in     → Google Sign-In screen
  → signed in, no username → Profile setup (username, phone; email locked)
  → signed in + username   → Dashboard (Posts | Request | Chat)
```

## Auth flow (admin app)

```
Splash / auth check
  → not signed in → Google Sign-In
  → signed in, but no doc at admin/{email} → sign out + access denied
  → signed in + admin/{email} exists → Shell (Users | Posts)
```

Create admins in Firestore:

```
admin/{emailLowercased}
  username: "Alex"
```

## Navigation

**User (3 tabs):** Posts · Request · Chat  
**Admin (2 tabs):** Users · Posts  
**User detail (admin):** Requests · Chat (gear toggles `chat_enabled`)

## Firestore paths

| Path | Purpose |
| --- | --- |
| `users/{email}/informations/profile` | username, phone, email, photoUrl |
| `users/{email}/informations/chat` | `{ chat_enabled: bool }` — admin toggles messaging |
| `users/{email}/chats/{id}` | messages (`text`, `sender`, `senderName`, `senderEmail`, `createdAt`) |
| `posts/{id}` | admin posts (`title`, `body`, `createdAt`, `updatedAt`) |
| `admin/{email}` | admin registry (`username`) |

`{email}` = Google account email, lowercased (document id).

## Chat gating

- Empty thread → user may send **one** first message (warning shown).
- After first message while `chat_enabled == false` → user blocked.
- Admin gear sets `chat_enabled` ON → user may send freely.
- Admin can always send.

## Chat display names

- **User app:** admin bubbles always show **Map.dev**.
- **Admin app:** admin bubbles show `admin/{email}.username` (stored as `senderName`); user bubbles show the user's name.

## Run user app

```bash
flutter pub get
flutter run
```

## Run admin app

```bash
cd admin
flutter pub get
flutter run
```

## Request model (`requests/{id}` — Realtime Database)

- `app_name`, `app_description`, `requester_name`, `contact`, `phone_number`
- `status`: `pending` | `accepted` | `completed` | `declined` (+ legacy `reviewing` / `in_progress`)
- `estimated_duration` (when accepted)
- `timestamp` (ISO-8601)

## Suggested Firestore rules (tighten for production)

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function signedIn() { return request.auth != null; }
    function isOwner(email) {
      return signedIn() && request.auth.token.email.lower() == email.lower();
    }
    function isAdmin() {
      return signedIn()
        && exists(/databases/$(database)/documents/admin/$(request.auth.token.email.lower()));
    }

    match /admin/{email} {
      allow read: if isAdmin() || (signedIn() && request.auth.token.email.lower() == email.lower());
      allow write: if false;
    }
    match /users/{email}/informations/{doc} {
      allow read, write: if isOwner(email) || isAdmin();
    }
    match /users/{email}/chats/{msgId} {
      allow read, write: if isOwner(email) || isAdmin();
    }
    match /posts/{id} {
      allow read: if signedIn();
      allow write: if isAdmin();
    }
  }
}
```
