"""
Test Chargily API directly without UI
"""
from chargily_pay import ChargilyClient
from chargily_pay.entity import Checkout
from decouple import config

# Your credentials from .env
API_KEY = config('CHARGILY_API_KEY')
SECRET_KEY = config('CHARGILY_SECRET_KEY')

print("=" * 60)
print("Testing Chargily API")
print("=" * 60)

# Initialize client
print(f"\n1. Creating ChargilyClient")
print(f"   API Key: {API_KEY[:30]}...")
print(f"   Secret Key: {SECRET_KEY[:30]}...")

try:
    client = ChargilyClient(
        key=API_KEY,
        secret=SECRET_KEY
    )
    print("   ✓ Client created successfully")
    print(f"   URL: {client.url}")
    print(f"   Headers: {client.headers}")
except Exception as e:
    print(f"   ✗ Error creating client: {e}")
    exit(1)

# Create checkout
print(f"\n2. Creating Checkout object")
try:
    checkout_obj = Checkout(
        amount=1000,
        currency="dzd",
        success_url="http://example.com/success",
        failure_url="http://example.com/failure",
        webhook_endpoint="http://example.com/webhook",
        description="Test payment",
        locale="ar",
        metadata=[{
            "listing_id": "11",
            "plan_id": "1",
            "user_id": "5"
        }]
    )
    print("   ✓ Checkout object created")
    print(f"   Amount: {checkout_obj.amount} {checkout_obj.currency}")
    print(f"   Description: {checkout_obj.description}")
except Exception as e:
    print(f"   ✗ Error creating checkout: {e}")
    exit(1)

# Try to create checkout via API
print(f"\n3. Calling Chargily API to create checkout")
try:
    checkout = client.create_checkout(checkout_obj)
    print("   ✓ Checkout created successfully!")
    print(f"   Checkout ID: {checkout.get('id')}")
    print(f"   Checkout URL: {checkout.get('checkout_url')}")
    print(f"   Full response: {checkout}")
except Exception as e:
    print(f"   ✗ API Error: {e}")
    print(f"   Error type: {type(e).__name__}")
    
    # Try to get more details
    import traceback
    print("\n   Full traceback:")
    traceback.print_exc()

print("\n" + "=" * 60)
