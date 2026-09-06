# MAP.DEV

Flutter apps + marketing website for MAP.DEV app requests.

## Apps

| App | Role | Location |
| --- | --- | --- |
| **User** | End users: submit & track app requests | repo root (this project) |
| **Admin** | Team: view all requests & update status | [`admin/`](admin/) |
| **Website** | Public marketing + request form | [`website/`](website/) |

Both Flutter apps and the website share Firebase Realtime Database path `requests`.

## Run user app

From the repo root:

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

## Run website

```bash
cd website
npm install
npm run dev
```

## Request model (`requests/{id}`)

- `app_name`, `app_description`, `requester_name`, `contact`, `phone_number`
- `status`: `pending` | `reviewing` | `accepted` | `in_progress` | `completed` | `declined`
- `timestamp` (ISO-8601)
