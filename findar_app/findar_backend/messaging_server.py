import firebase_admin
from firebase_admin import credentials, messaging
from flask import Flask, request, jsonify
from flask_cors import CORS
import schedule
import time
import threading
from datetime import datetime, timedelta
import sqlite3
import os

# Initialize Flask app
app = Flask(__name__)
CORS(app)

# Initialize Firebase Admin SDK
cred = credentials.Certificate('firebase-service-account.json')
firebase_admin.initialize_app(cred)

# Path to SQLite database (adjust to your Flutter app's database)
DB_PATH = '../android/app/src/main/assets/databases/listings.db'

def get_db_connection():
    """Get database connection"""
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn

def check_expiring_boosts():
    """
    Check for property boosts expiring in the next 24 hours
    and send notifications to property owners
    """
    print(f"[{datetime.now()}] Checking for expiring boosts...")
    
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # Get properties with boosts expiring in next 24 hours
        # boost_expiry_date is stored as Unix timestamp
        tomorrow = int((datetime.now() + timedelta(days=1)).timestamp())
        day_after = int((datetime.now() + timedelta(days=2)).timestamp())
        
        cursor.execute("""
            SELECT id, title, owner_name, boost_expiry_date 
            FROM property_listings 
            WHERE is_boosted = 1 
            AND boost_expiry_date IS NOT NULL
            AND boost_expiry_date > ?
            AND boost_expiry_date <= ?
        """, (int(datetime.now().timestamp()), day_after))
        
        expiring_listings = cursor.fetchall()
        conn.close()
        
        if not expiring_listings:
            print("No expiring boosts found.")
            return
        
        print(f"Found {len(expiring_listings)} expiring boosts.")
        
        # Send notification to each property owner
        for listing in expiring_listings:
            send_boost_expiry_notification(
                listing_id=listing['id'],
                listing_title=listing['title'],
                owner_name=listing['owner_name']
            )
    
    except Exception as e:
        print(f"Error checking expiring boosts: {e}")

def send_boost_expiry_notification(listing_id, listing_title, owner_name):
    """
    Send FCM notification about expiring boost
    
    In a real app, you would:
    1. Get the user's FCM token from your user database
    2. Send to that specific token
    
    For this demo, we'll send to a topic that all users are subscribed to
    """
    try:
        # Create notification message
        message = messaging.Message(
            notification=messaging.Notification(
                title='Boost Expiring Soon! 🚀',
                body=f'Your "{listing_title}" listing boost expires in 24 hours. Renew now to stay visible!',
            ),
            data={
                'listing_id': str(listing_id),
                'listing_title': listing_title,
                'type': 'boost_expiry',
                'action': 'open_listing'
            },
            # Send to topic (all app users)
            topic='all_users'
            
            # OR send to specific user's token:
            # token='user_fcm_token_here'
        )
        
        # Send message
        response = messaging.send(message)
        print(f"✅ Notification sent for listing '{listing_title}': {response}")
        
    except Exception as e:
        print(f"❌ Error sending notification for listing {listing_id}: {e}")

@app.route('/send-notification', methods=['POST'])
def send_notification():
    """
    API endpoint to manually send a notification
    
    POST body:
    {
        "token": "user_fcm_token",
        "title": "Boost Expiring Soon!",
        "body": "Your listing boost expires in 24 hours",
        "listing_id": "1",
        "listing_title": "Modern Apartment"
    }
    """
    try:
        data = request.get_json()
        
        token = data.get('token')
        title = data.get('title', 'Boost Expiring Soon!')
        body = data.get('body', 'Your property boost is expiring soon')
        listing_id = data.get('listing_id', '0')
        listing_title = data.get('listing_title', '')
        
        if not token:
            return jsonify({'error': 'FCM token is required'}), 400
        
        # Create message
        message = messaging.Message(
            notification=messaging.Notification(
                title=title,
                body=body,
            ),
            data={
                'listing_id': str(listing_id),
                'listing_title': listing_title,
                'type': 'boost_expiry',
                'action': 'open_listing'
            },
            token=token
        )
        
        # Send message
        response = messaging.send(message)
        
        return jsonify({
            'success': True,
            'message': 'Notification sent successfully',
            'response': response
        }), 200
    
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/send-to-topic', methods=['POST'])
def send_to_topic():
    """
    Send notification to all users subscribed to a topic
    
    POST body:
    {
        "topic": "all_users",
        "title": "New Feature!",
        "body": "Check out our new property filters",
        "listing_id": "1"
    }
    """
    try:
        data = request.get_json()
        
        topic = data.get('topic', 'all_users')
        title = data.get('title', 'Notification')
        body = data.get('body', '')
        listing_id = data.get('listing_id', '0')
        
        message = messaging.Message(
            notification=messaging.Notification(
                title=title,
                body=body,
            ),
            data={
                'listing_id': str(listing_id),
                'type': 'boost_expiry',
            },
            topic=topic
        )
        
        response = messaging.send(message)
        
        return jsonify({
            'success': True,
            'message': f'Notification sent to topic: {topic}',
            'response': response
        }), 200
    
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/check-expiring', methods=['GET'])
def manual_check_expiring():
    """Manually trigger check for expiring boosts"""
    try:
        check_expiring_boosts()
        return jsonify({
            'success': True,
            'message': 'Checked for expiring boosts'
        }), 200
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.now().isoformat(),
        'service': 'Firebase Messaging Server'
    }), 200

def run_scheduler():
    """Run scheduled tasks in background thread"""
    # Schedule checking for expiring boosts every hour
    schedule.every().hour.do(check_expiring_boosts)
    
    # For testing: check every 5 minutes
    # schedule.every(5).minutes.do(check_expiring_boosts)
    
    print("🕐 Scheduler started. Checking for expiring boosts every hour.")
    
    while True:
        schedule.run_pending()
        time.sleep(60)  # Check every minute if there's a task to run

if __name__ == '__main__':
    # Start scheduler in background thread
    scheduler_thread = threading.Thread(target=run_scheduler, daemon=True)
    scheduler_thread.start()
    
    print("🚀 Firebase Messaging Server starting...")
    print("📱 Server will check for expiring boosts every hour")
    print("🌐 API available at http://localhost:5000")
    print("\nEndpoints:")
    print("  POST /send-notification - Send to specific user")
    print("  POST /send-to-topic - Send to all users")
    print("  GET  /check-expiring - Manually check expiring boosts")
    print("  GET  /health - Health check")
    
    # Run Flask app
    app.run(debug=True, host='0.0.0.0', port=5000, use_reloader=False)
