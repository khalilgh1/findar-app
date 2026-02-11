from django.urls import path
from .views import *

from rest_framework_simplejwt.views import (
    TokenObtainPairView,
)

urlpatterns = [
    path('health-check',health_check, name="health-check")
    path('get-listing/<int:listing_id>', get_listing, name='get-listing'),
    # authentication urls 
    path('auth/login' , login , name="login"),
    path('auth/oauth/' , oauth , name="oauth"),
    path('auth/logout' , logout , name="logout"),
    path('auth/register' , register, name="register"),
    path('auth/me' , me , name="me"),
    path('auth/token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('auth/refresh', CustomTokenRefreshView.as_view(), name='token_refresh'),
    path("auth/password-reset/request/", PasswordResetRequestAPI.as_view()),
    path("auth/password-reset/verify/", PasswordResetVerifyCodeAPI.as_view()),
    path("auth/password-reset/confirm/", PasswordResetConfirmAPI.as_view()),
    path("notifications/register-device/", register_device_token),
    
    path('create-listing/', create_listing, name='create-listing'),
    path('users/<int:user_id>/profile/', get_user_profile, name='get_user_profile'),
    path('users/profile', Profile.as_view(), name='update_profile'),
    path('users/profile/', Profile.as_view(), name='update_profile'),
    path('edit-listing/<int:listing_id>', edit_listing, name='edit-listing'),
    path('my_listings/', my_listings, name='listings'),
    path('toggle_active_listing/<int:listing_id>', toggle_active_listing, name='toggle_active_listing'),
    path('boost-listing/<int:listing_id>', boost_listing, name='boost_listing'),
    path('login/', login, name='login'),
    path('save_listing/<int:listing_id>', save_listing, name='save_listing'),
    path('saved-listings/', saved_listings, name='saved-listings'),
    path('register/', register, name='register'),
    path('listing-details/<int:listing_id>', listing_details, name='listing-details'),
    path('sponsored-listings/', sponsored_listings, name='sponsored-listings'),
    path('recent-listings/', recent_listings, name='recent-listings'),
    path('advanced-search/', advanced_search, name='advanced-search'),
    path('report-property/', report_property, name='report-property'),
]