# MAP.DEV user app — Google Play checklist

Package: `com.mapdev.map_dev`  
Version in `pubspec.yaml`: `1.0.0+1`

## Upload key fingerprints (add these in Firebase)

**SHA-1**
```
4D:E1:53:64:07:0A:DD:6C:3D:BF:92:F0:25:26:25:CA:5A:69:DE:37
```

**SHA-256**
```
52:91:22:04:C7:DC:39:82:C9:EE:DC:8C:7C:18:F6:7C:C5:56:AE:CA:08:FB:6F:75:26:74:C3:90:36:BE:9D:37
```

These come from your **upload keystore** (`android/app/upload-keystore.jks`).  
Passwords/alias are only in local files (not committed):
- `android/key.properties`
- `android/PLAY_SIGNING_SECRETS.txt`

**Back up** the `.jks` + those two files somewhere safe (password manager / encrypted drive). Losing them makes updates harder.

---

## What was already done in the project

- [x] Created upload keystore
- [x] Wired release signing in `android/app/build.gradle.kts`
- [x] Gitignored keystore + secrets
- [x] Built release App Bundle (`.aab`) when the build step succeeded

AAB path (after build):
`build/app/outputs/bundle/release/app-release.aab`

---

## What YOU must do (cannot be automated here)

### A) Firebase (required for Google Sign-In on Play builds)
1. Open [Firebase Console](https://console.firebase.google.com) → your project  
2. Project settings → Android app `com.mapdev.map_dev`  
3. **Add fingerprint** → paste **SHA-1** and **SHA-256** above  
4. Download updated `google-services.json` only if Firebase asks / if the file changes, and replace `android/app/google-services.json`  
5. Keep your existing **debug** SHA too (for local debug installs)

### B) Google Play Console
1. Pay / open [Play Console](https://play.google.com/console)  
2. **Create app** → MAP.DEV (or your name)  
3. Fill required sections:
   - Store listing (title, descriptions, screenshots, icon 512×512, feature graphic 1024×500)
   - Privacy policy URL (required — you store users/chat/bans)
     - After you deploy hosting: `https://map-dev-19fb0.web.app`
     - Privacy page files are already in `website/dist/` — deploy with the Firebase account that owns project `map-dev-19fb0`:
       `firebase deploy --only hosting`
   - Data safety form
   - Content rating questionnaire
   - Target audience / news / ads declarations
4. **Release → Testing → Internal testing** (recommended first):
   - Create release  
   - Upload `app-release.aab`  
   - Add yourself as a tester  
   - Roll out  
5. Enable **Play App Signing** when prompted (recommended). After first upload, Play may show a second “App signing key” certificate — **also add those SHA-1/SHA-256 to Firebase**.

### C) Reviewer access
If login is required, add a test account in Play Console **App access** so Google can review the app.

### D) Later updates
Bump version in `pubspec.yaml`, e.g. `1.0.1+2` (number after `+` must always increase), then:

```bash
cd /Users/awat/Downloads/projects/map_dev/map_dev
flutter build appbundle --release
```

Upload the new `.aab` to Play Console.

---

## Do not publish the admin app to Play

Admin package `com.mapdev.admin` is separate; keep it sideloaded / private unless you intentionally create another Play listing.
