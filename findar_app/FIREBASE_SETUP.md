# Firebase Messaging Setup Guide

## Current Progress ✅
- ✅ Firebase packages added to pubspec.yaml
- ✅ FirebaseMessagingService created
- ✅ BoostNotification model created
- ✅ Android Gradle files configured
- ✅ Firebase options template created

## Next Steps - YOU NEED TO DO THESE:

### 1. Create Firebase Project (5 minutes)

1. Go to https://console.firebase.google.com/
2. Click **"Add project"** or **"Create a project"**
3. Project name: **"findar-app"** (or any name you want)
4. Click Continue
5. **Disable** Google Analytics (optional, we don't need it for messaging)
6. Click **"Create project"**
7. Wait for project creation, then click **"Continue"**

---

### 2. Add Android App to Firebase (10 minutes)

1. In your Firebase project dashboard, click the **Android icon**
2. Register app:
   - **Android package name**: `com.example.findar`
   - **App nickname**: Findar App (optional)
   - **Debug signing certificate SHA-1**: Leave empty for now
   - Click **"Register app"**

3. **Download google-services.json**:
   - Click **"Download google-services.json"**
   - Save the file
   
4. **Place the file** in your project:
   - Copy `google-services.json` to:
     ```
     C:\Users\HP\Desktop\MobileRepo\findar-app\android\app\google-services.json
     ```
   - ⚠️ **IMPORTANT**: It must be in `android/app/` folder, NOT `android/`

5. Click **"Next"** and **"Continue to console"**

---

### 3. Update firebase_options.dart with Real Credentials

1. In Firebase Console, go to **Project Settings** (gear icon)
2. Scroll down to **"Your apps"** section
3. You'll see your Android app listed
4. Click on it to expand
5. Find these values:
   - **API Key** (looks like: `AIzaSyC...`)
   - **App ID** (looks like: `1:123456789:android:abc...`)
   - **Project ID** (looks like: `findar-app-12345`)
   - **Messaging Sender ID** (looks like: `123456789`)

6. Open `lib/firebase_options.dart` and replace:
   ```dart
   static const FirebaseOptions android = FirebaseOptions(
     apiKey: 'YOUR_ANDROID_API_KEY',        // Replace with actual API Key
     appId: 'YOUR_ANDROID_APP_ID',          // Replace with actual App ID
     messagingSenderId: 'YOUR_SENDER_ID',   // Replace with actual Sender ID
     projectId: 'YOUR_PROJECT_ID',          // Replace with actual Project ID
     storageBucket: 'YOUR_PROJECT_ID.appspot.com',  // Replace YOUR_PROJECT_ID
   );
   ```

---

### 4. Enable Cloud Messaging in Firebase

1. In Firebase Console, go to **"Cloud Messaging"** (left sidebar)
2. Click on **"Cloud Messaging API (Legacy)"** if you see it
3. You might see a notice about enabling Cloud Messaging API - click **"Enable"** if prompted
4. No other configuration needed here for now

---

### 5. Update main.dart to Initialize Firebase

I'll do this for you now...

