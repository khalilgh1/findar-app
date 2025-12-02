from django.urls import path
from .views import *

urlpatterns = [
    path('create-listing/', create_listing, name='create-listing'),
    path('my_listings/', my_listings, name='listings'),
    path('login/', login, name='login'),
    path('register/', register, name='register'),
    path('sponsored-listings/', sponsored_listings, name='sponsored-listings'),
    path('recent-listings/', recent_listings, name='recent-listings'),
    path('advanced-search/', advanced_search, name='advanced-search'),
]