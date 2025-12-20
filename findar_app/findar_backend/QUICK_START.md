# 🚀 Quick Start Guide - Testing Firebase Notifications

Follow these steps IN ORDER to test your notification system:

## Step 1: Get Firebase Service Account Key ⚠️ REQUIRED

1. Open [Firebase Console](https://console.firebase.google.com/)
2. Select project: **findar-4a43c**
3. Click ⚙️ → **Project Settings** → **Service Accounts** tab
4. Click **"Generate New Private Key"** button
5. Click **"Generate Key"** (downloads a JSON file)
6. **Rename** the downloaded file to `firebase-service-account.json`
7. **Move** it to: `C:\Users\HP\Desktop\MobileRepo\findar-app\findar_backend\`

❗ **The server will NOT work without this file!**

## Step 2: Create Test Database

Since the real database is inside your Android app's private storage, create a test database:

```powershell
cd C:\Users\HP\Desktop\MobileRepo\findar-app\findar_backend
python create_test_db.py
```

This creates `test_listings.db` with sample properties:
- ✅ 2 properties expiring in next 24 hours (will trigger notifications)
- ⏳ 1 property expiring in 2 days (won't trigger yet)
- ❌ 1 expired property (won't trigger)
- 📋 1 non-boosted property (won't trigger)

## Step 3: Update Database Path

Open `messaging_server.py` and change line 21:

```python
# FROM:
DB_PATH = '../android/app/src/main/assets/databases/listings.db'

# TO:
DB_PATH = 'test_listings.db'
```

## Step 4: Run the Server

```powershell
python messaging_server.py
```

You should see:
```
🚀 Firebase Messaging Server starting...
📱 Server will check for expiring boosts every hour
🌐 API available at http://localhost:5000
```

## Step 5: Test Sending a Notification

### Open your Flutter app first!
Make sure your app is running on your device/emulator so it can receive notifications.

### Option A: Send to Your Device (RECOMMENDED)

Your FCM token from earlier:
```
dbnlMNDgRganzGWvzIzbwr:APA91bHCon6CGYPJEjhg1FNjrJgsAkGqsb9HRrfTcEyZKYLeVhbJf0Eu2ISAjWAgPKCHAaEaCWmB066S88IX5EXCucAjlmEmvd8dmKO7372nIFV_GsZDDBA
```

**In a NEW PowerShell window** (keep server running):

```powershell
# Create the request body
$body = @{
    token = "dbnlMNDgRganzGWvzIzbwr:APA91bHCon6CGYPJEjhg1FNjrJgsAkGqsb9HRrfTcEyZKYLeVhbJf0Eu2ISAjWAgPKCHAaEaCWmB066S88IX5EXCucAjlmEmvd8dmKO7372nIFV_GsZDDBA"
    title = "Boost Expiring Soon! 🚀"
    body = "Your Modern Apartment listing boost expires in 12 hours!"
    listing_id = "1"
    listing_title = "Modern Apartment in City Center"
} | ConvertTo-Json

# Send the notification
Invoke-RestMethod -Uri "http://localhost:5000/send-notification" -Method POST -Body $body -ContentType "application/json"
```

### Option B: Check for Expiring Boosts (Automatic)

```powershell
Invoke-RestMethod -Uri "http://localhost:5000/check-expiring" -Method GET
```

This will:
1. Query the database for properties expiring in next 24 hours
2. Send notifications for each one

## Step 6: Verify It Works ✅

### In the Server Console:
You should see:
```
[2025-12-15 ...] Checking for expiring boosts...
Found 2 expiring boosts.
✅ Notification sent for listing 'Modern Apartment in City Center': projects/.../messages/...
✅ Notification sent for listing 'Luxury Villa with Garden': projects/.../messages/...
```

### On Your Device:
- 📱 You should see a notification appear
- 🔔 Title: "Boost Expiring Soon! 🚀"
- 📝 Body: "Your ... listing boost expires in ... hours!"
- 👆 **Tap it** - it should save to notification history (navigation not yet implemented)

### In Your Flutter App Console:
```
I/flutter: 📬 Foreground message received
I/flutter: ✅ Notification saved to storage
```

## Troubleshooting

### ❌ Error: "Could not find firebase-service-account.json"
- Make sure you downloaded the key from Firebase Console (Step 1)
- File must be named exactly `firebase-service-account.json`
- File must be in `findar_backend` folder

### ❌ Error: "Unable to open database file"
- Make sure you ran `python create_test_db.py` (Step 2)
- Make sure you updated DB_PATH in messaging_server.py (Step 3)

### ❌ Notification not received
- Make sure your Flutter app is running
- Check that the FCM token is correct (look in app console for "📱 FCM Token:")
- For topic-based messaging, make sure the app subscribed to "all_users" topic

### ❌ "ModuleNotFoundError"
- Make sure you installed dependencies: `pip install -r messaging_requirements.txt`

## What Happens Next?

The server will automatically check for expiring boosts **every hour**. For testing, you can:

1. **Change the schedule** to check every 5 minutes:
   - Open `messaging_server.py`
   - Line 254: Change `schedule.every().hour.do(...)` to `schedule.every(5).minutes.do(...)`
   - Restart the server

2. **Manually trigger** checks anytime:
   ```powershell
   Invoke-RestMethod -Uri "http://localhost:5000/check-expiring" -Method GET
   ```

## Using with Real Database

To use your actual Flutter app database:

1. **Run your Flutter app** on a device/emulator
2. **Find the database path**:
   ```dart
   // Add this to your Flutter code temporarily
   print('DB Path: ${await getDatabasesPath()}');
   ```
3. **Pull the database from device** using adb:
   ```powershell
   adb pull /data/data/com.example.findar/databases/listings.db C:\Users\HP\Desktop\MobileRepo\findar-app\findar_backend\
   ```
4. **Update DB_PATH** in `messaging_server.py`:
   ```python
   DB_PATH = 'listings.db'
   ```

## Next Steps After Testing ✅

Once notifications are working:
1. ✅ Implement navigation in `_handleNotificationTap()` (Firebase service)
2. ✅ Create notifications history screen (optional)
3. ✅ Deploy backend to a cloud server
4. ✅ Update database path to use real app database
