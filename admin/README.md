# MAP.DEV Admin

Standalone Flutter admin app for MAP.DEV.

## Auth

Google Sign-In. Access requires a Firestore doc at:

```
admin/{emailLowercased}
  username: "YourName"
```

Unauthorized Google accounts are signed out with an access-denied message.

## Navigation

- **Users** — profiles from `users/{email}/informations/profile`; tap → Requests | Chat
- **Posts** — create/edit/delete `posts/{id}` (shown on the user Posts tab)

## Chat

Same Firestore paths as the user app. Gear on Chat toggles `chat_enabled`. Admin always sends; user is gated. Admin bubbles show `username` from the admin registry; users see **Map.dev**.

## Run

```bash
cd admin
flutter pub get
flutter run
```
