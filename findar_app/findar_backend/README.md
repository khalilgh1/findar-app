# Firebase Messaging Backend Server

Simple Python Flask server for sending Firebase Cloud Messaging notifications about expiring property boosts.

## Setup Instructions

### 1. Get Firebase Service Account Key

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **findar-4a43c**
3. Click the gear icon (⚙️) → **Project Settings**
4. Go to the **Service Accounts** tab
5. Click **"Generate New Private Key"**
6. Click **"Generate Key"** in the confirmation dialog
7. Save the downloaded JSON file as `firebase-service-account.json` in this folder (`findar_backend/`)

**Important:** Keep this file secret! Add it to `.gitignore`

### 2. Configure Database Path

The server needs to access your Flutter app's SQLite database. Update the `DB_PATH` in `messaging_server.py`:

```python
# Current default:
DB_PATH = '../android/app/src/main/assets/databases/listings.db'

# Change to your actual database location
```

### 3. Install Dependencies

Dependencies are already installed! ✅

### 4. Run the Server

```bash
python messaging_server.py
```

The server will start on `http://localhost:5000`

## Testing the Server

### Test with Your FCM Token

Use the token from your device (already obtained):
```
dbnlMNDgRganzGWvzIzbwr:APA91bHCon6CGYPJEjhg1FNjrJgsAkGqsb9HRrfTcEyZKYLeVhbJf0Eu2ISAjWAgPKCHAaEaCWmB066S88IX5EXCucAjlmEmvd8dmKO7372nIFV_GsZDDBA
```

### Send Test Notification

Using PowerShell:
```powershell
$body = @{
    token = "dbnlMNDgRganzGWvzIzbwr:APA91bHCon6CGYPJEjhg1FNjrJgsAkGqsb9HRrfTcEyZKYLeVhbJf0Eu2ISAjWAgPKCHAaEaCWmB066S88IX5EXCucAjlmEmvd8dmKO7372nIFV_GsZDDBA"
    title = "Boost Expiring Soon! 🚀"
    body = "Your apartment boost expires in 24 hours"
    listing_id = "123"
    listing_title = "Modern Apartment"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:5000/send-notification" -Method POST -Body $body -ContentType "application/json"
```

Using curl:
```bash
curl -X POST http://localhost:5000/send-notification \
-H "Content-Type: application/json" \
-d '{
  "token":"dbnlMNDgRganzGWvzIzbwr:APA91bHCon6CGYPJEjhg1FNjrJgsAkGqsb9HRrfTcEyZKYLeVhbJf0Eu2ISAjWAgPKCHAaEaCWmB066S88IX5EXCucAjlmEmvd8dmKO7372nIFV_GsZDDBA",
  "title":"Test Notification",
  "body":"Testing from backend!",
  "listing_id":"1"
}'
```

### Send to All Users (Topic)

```powershell
$body = @{
    topic = "all_users"
    title = "Boost Expiring!"
    body = "Your property boost expires soon"
    listing_id = "1"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:5000/send-to-topic" -Method POST -Body $body -ContentType "application/json"
```

### Manually Check Expiring Boosts

```powershell
Invoke-RestMethod -Uri "http://localhost:5000/check-expiring" -Method GET
```

### Health Check

```powershell
Invoke-RestMethod -Uri "http://localhost:5000/health" -Method GET
```

## API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/send-notification` | POST | Send notification to specific user by FCM token |
| `/send-to-topic` | POST | Send notification to all users subscribed to a topic |
| `/check-expiring` | GET | Manually trigger check for expiring boosts |
| `/health` | GET | Health check |

## Automated Scheduling

The server automatically checks for expiring boosts **every hour**.

To change the frequency, edit `messaging_server.py`:
```python
# Check every hour (default)
schedule.every().hour.do(check_expiring_boosts)

# OR check every 5 minutes for testing
schedule.every(5).minutes.do(check_expiring_boosts)
```

## How It Works

1. **Scheduler runs every hour** → checks database for boosts expiring in next 24 hours
2. **For each expiring boost** → sends FCM notification to property owner
3. **User receives notification** → can tap to open property details
4. **Notification stored locally** → available in notification history

## Troubleshooting

### Error: "Could not find firebase-service-account.json"
- Make sure you've downloaded the service account key from Firebase Console
- Place it in the `findar_backend` folder
- File name must be exactly `firebase-service-account.json`

### Error: "Unable to open database file"
- Update `DB_PATH` in `messaging_server.py` to point to your actual database location
- Make sure the database file exists and is accessible

### Notification not received
- Check that the FCM token is correct and up-to-date
- Make sure the Flutter app has subscribed to the "all_users" topic
- Check Firebase Console → Cloud Messaging for delivery status

### Port already in use
- Change the port in `messaging_server.py`: `app.run(port=5001)`

## Next Steps

1. ✅ Get Firebase service account key
2. ✅ Update database path
3. ✅ Test sending notification to your device
4. ⬜ Add navigation handling in Flutter app (when notification tapped)
5. ⬜ Create notifications history screen in app (optional)
