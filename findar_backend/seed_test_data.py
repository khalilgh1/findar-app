import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from api.models import CustomUser, Post, SavedPosts

print("--- Creating Users ---")
# Create additional users
users = []
for i in range(3, 8):
    user, created = CustomUser.objects.get_or_create(
        username=f'testuser{i}',
        defaults={
            'email': f'test{i}@test.com',
            'phone': f'123456789{i}',
            'account_type': 'agency' if i % 2 == 0 else 'normal'
        }
    )
    users.append(user)
    status = "Created" if created else "Already exists"
    print(f'User {i}: {status}')

print("\n--- Creating Posts ---")
# Create various posts
posts_data = [
    {'owner_id': 2, 'title': 'Luxury Villa with Pool', 'price': 500000, 'bedrooms': 5, 'bathrooms': 4, 'listing_type': 'sale', 'building_type': 'villa', 'area': 350.0, 'boosted': True},
    {'owner_id': 3, 'title': 'Modern Apartment Downtown', 'price': 2000, 'bedrooms': 2, 'bathrooms': 1, 'listing_type': 'rent', 'building_type': 'apartment', 'area': 80.0, 'boosted': True},
    {'owner_id': 4, 'title': 'Cozy Studio near University', 'price': 800, 'bedrooms': 1, 'bathrooms': 1, 'listing_type': 'rent', 'building_type': 'studio', 'area': 45.0, 'boosted': False},
    {'owner_id': 5, 'title': 'Spacious Family House', 'price': 350000, 'bedrooms': 4, 'bathrooms': 3, 'listing_type': 'sale', 'building_type': 'house', 'area': 220.0, 'boosted': True},
    {'owner_id': 6, 'title': 'Office Space City Center', 'price': 3500, 'bedrooms': 0, 'bathrooms': 2, 'listing_type': 'rent', 'building_type': 'office', 'area': 120.0, 'boosted': False},
    {'owner_id': 2, 'title': 'Beachfront Apartment', 'price': 280000, 'bedrooms': 3, 'bathrooms': 2, 'listing_type': 'sale', 'building_type': 'apartment', 'area': 110.0, 'boosted': True},
    {'owner_id': 3, 'title': 'Penthouse with View', 'price': 4500, 'bedrooms': 3, 'bathrooms': 2, 'listing_type': 'rent', 'building_type': 'apartment', 'area': 150.0, 'boosted': False},
    {'owner_id': 4, 'title': 'Charming Villa Garden', 'price': 420000, 'bedrooms': 4, 'bathrooms': 3, 'listing_type': 'sale', 'building_type': 'villa', 'area': 280.0, 'boosted': True},
]

created_posts = []
for data in posts_data:
    post = Post.objects.create(active=True, description='Test listing for demo', **data)
    created_posts.append(post)
    status = 'SPONSORED' if post.boosted else 'Regular'
    print(f'Post {post.id}: {post.title[:30]}... ({status})')

print("\n--- Creating Saved Listings for User 1 ---")
# User 1 saves some listings
user1 = CustomUser.objects.get(id=1)
posts_to_save = [p for p in created_posts if p.owner_id != 1][:4]

for post in posts_to_save:
    saved, created = SavedPosts.objects.get_or_create(user=user1, post=post)
    status = "New" if created else "Already saved"
    print(f'Saved Post {post.id}: {post.title[:30]}... ({status})')

print("\n--- Summary ---")
print(f'Total Users: {CustomUser.objects.count()}')
print(f'Total Posts: {Post.objects.count()}')
print(f'Sponsored Posts: {Post.objects.filter(boosted=True).count()}')
print(f'User 1 Saved Listings: {SavedPosts.objects.filter(user=user1).count()}')
