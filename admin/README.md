# MAP.DEV Admin

Standalone Flutter admin app for reviewing and updating MAP.DEV app requests.

Shares Firebase Realtime Database path `requests` with the user app and website.

## Run

```bash
cd admin
flutter pub get
flutter run
```

## Features

- List all requests from Firebase
- Update request status (`pending`, `reviewing`, `accepted`, `in_progress`, `completed`, `declined`)

## Related

- User app: repo root (`flutter run`)
- Website: `website/`
