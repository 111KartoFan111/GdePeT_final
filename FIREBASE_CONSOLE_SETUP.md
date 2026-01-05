# Firebase Console: Create Project + APIs (Step-by-step)

This guide shows exactly what to create in **Firebase Console** and in
**Google Cloud Console**. Follow in order.

## 1) Firebase Console: Create project

1. Open https://console.firebase.google.com/.
2. Click **Add project**.
3. Project name: choose any (example: `gde-pet`).
4. **Continue**.
5. Google Analytics:
   - If you do not need analytics now, choose **Not enabled**.
   - If you want analytics, enable it and pick/create a Analytics account.
6. Click **Create project**.

## 2) Firebase Console: Add iOS app

1. In the new project, click **iOS** icon to add an iOS app.
2. **iOS bundle ID**: enter your real bundle ID (must match Xcode).
   - Example: `com.adinaadilova.gdePet`
3. **App nickname**: any.
4. **App Store ID**: optional (leave empty if not published).
5. Click **Register app**.
6. Download **GoogleService-Info.plist**.
7. Click **Next** until finished.

## 3) Firebase Console: Enable Authentication

1. Go to **Build → Authentication**.
2. Click **Get started**.
3. **Sign-in method** tab:
   - Enable **Email/Password**.
   - Enable **Google** (choose a support email).
4. Click **Save**.

## 4) Firebase Console: Enable Firestore + Storage (if used)

Firestore:
1. Go to **Build → Firestore Database**.
2. Click **Create database**.
3. Choose **Start in test mode** for development.
4. Pick region.

Storage:
1. Go to **Build → Storage**.
2. Click **Get started**.
3. Choose **Start in test mode** for development.
4. Pick region.

## 5) Firebase Console: Authorized domains

1. Authentication → **Settings** → **Authorized domains**.
2. Make sure these exist:
   - `localhost`
   - `<project-id>.firebaseapp.com`
   - `<project-id>.web.app`

## 6) Google Cloud Console: Create OAuth client (for iOS Google Sign-In)

1. Open https://console.cloud.google.com/ and select the same project.
2. Go to **APIs & Services → Credentials**.
3. Click **Create credentials → OAuth client ID**.
4. Application type: **iOS**.
5. **Bundle ID**: same as in step 2.
6. Create.
7. Copy the **Client ID**.

Note:
- If you downloaded `GoogleService-Info.plist` after enabling Google provider,
  it should already contain `CLIENT_ID` and `REVERSED_CLIENT_ID`.

## 7) Google Cloud Console: API key (Firebase Auth uses it)

1. APIs & Services → **Credentials**.
2. Find the API key created automatically by Firebase.
3. If it is expired, click it and **Regenerate key**.
4. Copy the key.

## 8) Local project updates (you will do after download)

1. Replace:
   - `gde_pet/ios/Runner/GoogleService-Info.plist`
2. Regenerate Flutter config:
   - `flutterfire configure`
3. Ensure `Info.plist` has:
   - `GIDClientID` = `CLIENT_ID` from plist
   - URL scheme = `REVERSED_CLIENT_ID` from plist

## 9) Verify in Firebase Auth

1. Authentication → Users.
2. Create a new user in the app.
3. Check `Email verified` flag in Firebase Auth (not only Firestore).

