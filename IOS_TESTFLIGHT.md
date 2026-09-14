# MAP.DEV iOS — Internal Testing (TestFlight)

Bundle ID: `com.mapdev.map-dev`  
Display name: Map Dev  
Version: `1.0.0+1` (from `pubspec.yaml`)

Google Sign-In URL scheme + `GIDClientID` are already in `ios/Runner/Info.plist`.  
Firebase iOS config: `ios/Runner/GoogleService-Info.plist`.

---

## A) What you do in Apple / Xcode (required once)

### 1. Sign in to Xcode
1. Open **Xcode**
2. **Xcode → Settings → Accounts**
3. Click **+** → add your Apple ID (the one with Apple Developer Program)
4. Select the account → **Manage Certificates…** → **+** → **Apple Distribution** (and Development if missing)

### 2. Register the App ID
1. Open [Apple Developer → Identifiers](https://developer.apple.com/account/resources/identifiers/list)
2. **+** → App IDs → App
3. Description: `MAP.DEV`
4. Bundle ID (Explicit): `com.mapdev.map-dev`
5. Enable any needed capabilities (Sign In with Apple only if you use it; Google Sign-In does not require it)
6. Register

### 3. Create the app in App Store Connect
1. Open [App Store Connect](https://appstoreconnect.apple.com) → **My Apps** → **+**
2. Bundle ID: `com.mapdev.map-dev`
3. Name: `Map.dev` (or similar)
4. Primary language: English
5. SKU: `mapdev-user` (any unique string)
6. Create

### 4. Set Team in the iOS project
Open:
`ios/Runner.xcworkspace`

Select **Runner** target → **Signing & Capabilities**:
- ✅ Automatically manage signing
- Team: your Apple Developer team

(Or tell the assistant your **Team ID** — 10 characters like `AB12CD34EF` — and they can set it in the project.)

---

## B) Build & upload IPA

From project root:

```bash
cd /Users/awat/Downloads/projects/map_dev/map_dev
flutter build ipa --release
```

IPA path (typical):
`build/ios/ipa/*.ipa`

Upload options:
- **Transporter** app (Mac App Store) → deliver the `.ipa`
- Or Xcode → **Window → Organizer** after archive
- Or:

```bash
xcrun altool --upload-app --type ios -f build/ios/ipa/*.ipa \
  --apiKey YOUR_API_KEY --apiIssuer YOUR_ISSUER_ID
```

---

## C) Internal Testing (TestFlight)

1. App Store Connect → your app → **TestFlight**
2. Wait for the build to finish processing (often 5–30 minutes)
3. Answer **Export Compliance** if asked (usually: encryption only HTTPS → Yes / No as appropriate — typically “uses encryption only for HTTPS” exemption)
4. **Internal Testing** → add group → add testers (App Store Connect Users with access)
5. Add the build to the internal group
6. Testers install **TestFlight** from the App Store and install Map.dev

Internal testers must be users under your App Store Connect team (Admin/Developer/Marketing/App Manager), up to 100.

---

## Google Sign-In on iOS

Firebase already has iOS app `com.mapdev.map-dev`.  
If login fails on device:
1. Confirm Bundle ID matches exactly: `com.mapdev.map-dev`
2. Confirm URL scheme in Info.plist matches `REVERSED_CLIENT_ID`
3. In Google Cloud / Firebase, ensure the iOS OAuth client exists for that bundle ID

---

## Privacy / App Privacy

Before external TestFlight or App Store release you’ll need App Privacy answers (similar to Android Data safety).  
Internal Testing usually works after the first build processes.
