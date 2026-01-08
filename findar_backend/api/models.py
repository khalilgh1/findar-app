from django.contrib.auth.models import AbstractUser
from django.db import models
from datetime import timedelta
from django.utils import timezone
from .services import new_agency_boosting_plans_notification, new_individual_boosting_plans_notification

OTP_EXPIRATION_MINUTES = 10

# Create your models here.


# changes to be made 
"""
    1 . pictures need to be have a random name (post and profile)
    2 . Report model needs to be bigger
    3 . main pic should not be an attribute of post, but rather a an boolean attribute in photos is_main
    4 . Credit attribute in user should be integer not float
"""


################# Customized User Model

ACCOUNT_CHOICES = [
    ('individual' , 'Individual'),
    ('agency' , 'Agency')
]

class CustomUser(AbstractUser):

    username = models.CharField(max_length=150,unique=False)    
    email = models.EmailField(unique=True)
    phone    = models.CharField(max_length=15 )
    profile_pic     = models.URLField(max_length=500 , null=True , blank=True)
    account_type    = models.CharField(max_length=20, choices=ACCOUNT_CHOICES)
    USERNAME_FIELD = "email"
    REQUIRED_FIELDS = ["username"]
    last_active = models.DateTimeField(auto_now=True)
    credits = models.IntegerField(default=0)
    
    def __str__(self):
        print(f"DEBUG - User ID: {self.id}, Username: {self.username}")
        return self.username
    
    
################# Post Model

LISTING_TYPE_CHOICES = [
    ('rent' , 'Rent'),
    ('sale' , 'Sale')
]

BUILDING_TYPE_CHOICES = [
    ('apartment' , 'Apartment'),
    ('house'     , 'House'),
    ('studio'    , 'Studio'),
    ('villa'     , 'Villa'),
    ('office'    , 'Office'),
]

class Post(models.Model):

    owner        = models.ForeignKey(CustomUser , on_delete=models.CASCADE)
    title        = models.CharField(max_length=255)
    price        = models.FloatField()
    description  = models.TextField(max_length=1000) 
    created_at   = models.DateTimeField(auto_now=True)
    active       = models.BooleanField(default=True)
    boosted      = models.BooleanField(default=False)
    main_pic     = models.URLField(max_length=500 , null=True , blank=True)
    pics = models.JSONField(null=True , blank=True, default=list)
    latitude     = models.FloatField(null = True)
    longitude    = models.FloatField(null = True)
    bedrooms     = models.IntegerField(default=0  , null=True)
    bathrooms    = models.IntegerField(default=0  , null=True)
    livingrooms  = models.IntegerField(default=0  , null=True)
    area         = models.FloatField(default=0.0  , null=True)
    listing_type  = models.CharField(max_length=50 , choices=LISTING_TYPE_CHOICES, null=True)  
    building_type = models.CharField(max_length=50 , choices=BUILDING_TYPE_CHOICES, null=True)  

    def __str__(self):
        print(f"DEBUG POST - ID: {self.id}, Owner ID: {self.owner.id}, Owner Username: {self.owner.username}, Title: {self.title}")
        return f"{self.owner} : {self.title}"

################# SavedPosts Model

class SavedPosts(models.Model):

    user    = models.ForeignKey(CustomUser, on_delete=models.CASCADE)
    post    = models.ForeignKey(Post, on_delete=models.CASCADE)    
    saved_at= models.DateTimeField(auto_now=True)

    class Meta:
        unique_together = ('user', 'post')

    def __str__(self):
        return f"{self.user} : {self.post}"
    
################# Report Model

class Report(models.Model):

    reporter_user    = models.ForeignKey(CustomUser, on_delete=models.CASCADE, related_name='reporter_user')
    reported_user    = models.ForeignKey(CustomUser, on_delete=models.CASCADE, related_name='reported_user')
    post             = models.ForeignKey(Post , null=True , blank=True, on_delete=models.CASCADE)   
    description      = models.TextField(max_length=1000) 
    created_at       = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.reporter_user} reported {self.reported_user}"
    

################# Business Plan Model

BOOSTING_PLAN_CHOICES = [
    ('basic'   , 'Basic'),
    ('premium' , 'Premium'),
    ('gold'    , 'Gold')
]
BUSINESS_PLAN_TARGET_CHOICES = [
    ('individuals' , 'Individuals'),
    ('agencies'   , 'Agencies')
]

class BoostingPlan(models.Model):
    plan_type           = models.CharField(max_length=20, choices=BOOSTING_PLAN_CHOICES, null = True)
    target_audience     = models.CharField(max_length=20, choices=BUSINESS_PLAN_TARGET_CHOICES, null = True)
    credit_cost         = models.FloatField(default=0.0)
    duration            = models.IntegerField() #not sure if in days, hours or seconds

    def save(self, *args, **kwargs):
        
        if self.target_audience == 'agencies':
            new_agency_boosting_plans_notification()
        elif self.target_audience == 'individuals':
            new_individual_boosting_plans_notification()
        super().save(*args, **kwargs)
    
################# Boosting Model


class Boosting(models.Model):
    boost_plan      = models.ForeignKey(BoostingPlan, on_delete=models.CASCADE)
    post            = models.ForeignKey(Post, on_delete=models.CASCADE)
    created_at      = models.DateTimeField(auto_now=True)
    expires_at      = models.DateTimeField()
    notified      = models.BooleanField(default=False)


################# Password-reset Model

class PasswordResetOTP(models.Model):
    user = models.ForeignKey(CustomUser, on_delete=models.CASCADE)
    code_hash = models.CharField(max_length=128)
    created_at = models.DateTimeField(auto_now_add=True)
    attempts = models.PositiveSmallIntegerField(default=0)
    used = models.BooleanField(default=False)

    def is_expired(self):
        return timezone.now() > self.created_at + timedelta(minutes=10)


################### Notification tokens 

class DeviceToken(models.Model):
    user = models.ForeignKey(
        CustomUser,
        on_delete=models.CASCADE,
        related_name="devices"
    )
    token = models.CharField(max_length=255, unique=True)
    created_at = models.DateTimeField(auto_now_add=True)
    last_seen = models.DateTimeField(auto_now=True)