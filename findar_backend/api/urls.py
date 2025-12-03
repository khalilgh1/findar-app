from django.urls import path
from .views import *
urlpatterns = [
    path('listings/', get_listings, name='listings'),
    path('create-listing/', create_listing, name='create-listing'),
]