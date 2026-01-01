import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from django.contrib.auth.hashers import make_password
from api.models import CustomUser

print("--- Creating Test Users with Known Credentials ---\n")

test_users = [
    {'username': 'test1', 'email': 'test1@test.com', 'password': 'test1', 'phone': '1111111111', 'account_type': 'normal'},
    {'username': 'test2', 'email': 'test2@test.com', 'password': 'test2', 'phone': '2222222222', 'account_type': 'agency'},
    {'username': 'test3', 'email': 'test3@test.com', 'password': 'test3', 'phone': '3333333333', 'account_type': 'normal'},
    {'username': 'test4', 'email': 'test4@test.com', 'password': 'test4', 'phone': '4444444444', 'account_type': 'agency'},
    {'username': 'test5', 'email': 'test5@test.com', 'password': 'test5', 'phone': '5555555555', 'account_type': 'normal'},
]

for user_data in test_users:
    password = user_data.pop('password')
    
    # Check if user exists by username or email
    existing_user = CustomUser.objects.filter(
        username=user_data['username']
    ).first() or CustomUser.objects.filter(
        email=user_data['email']
    ).first()
    
    if existing_user:
        # Update password and username if needed
        existing_user.set_password(password)
        if existing_user.username != user_data['username']:
            existing_user.username = user_data['username']
        existing_user.save()
        
        print(f"🔄 Updated user: {existing_user.username}")
        print(f"   Email: {existing_user.email}")
        print(f"   Password: {password}")
        print(f"   Account Type: {existing_user.account_type}")
        print(f"   User ID: {existing_user.id}\n")
    else:
        user = CustomUser.objects.create(
            **user_data,
            password=make_password(password)
        )
        print(f"✅ Created user: {user.username}")
        print(f"   Email: {user.email}")
        print(f"   Password: {password}")
        print(f"   Account Type: {user.account_type}")
        print(f"   User ID: {user.id}\n")

print("\n" + "="*50)
print("TEST CREDENTIALS")
print("="*50)
print("Username/Email       | Password | Type")
print("-" * 50)
for i in range(1, 6):
    print(f"test{i}/test{i}@test.com | test{i}    | {'Agency' if i % 2 == 0 else 'Normal'}")
print("="*50)
