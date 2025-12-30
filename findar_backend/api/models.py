from django.contrib.auth.models import AbstractUser

from django.db import models

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
    ('normal' , 'Normal'),
    ('agency' , 'Agency')
]

class CustomUser(AbstractUser):

    email = models.EmailField(unique=True)
    phone_number    = models.CharField(max_length=15)
    profile_pic     = models.ImageField(upload_to="profiles/" , blank=True , null=True)
    account_type    = models.CharField(max_length=20, choices=ACCOUNT_CHOICES, default='normal')
    credits         = models.FloatField(default=0.0) 


    def __str__(self):
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
    main_pic     = models.ImageField(upload_to="profiles/" , blank=True , null=True)
    latitude     = models.FloatField(null = True)
    longitude    = models.FloatField(null = True)
    bedrooms     = models.IntegerField(default=0  , null=True)
    bathrooms    = models.IntegerField(default=0  , null=True)
    livingrooms  = models.IntegerField(default=0  , null=True)
    area         = models.FloatField(default=0.0  , null=True)
    listing_type  = models.CharField(max_length=50 , choices=LISTING_TYPE_CHOICES, null=True)  
    building_type = models.CharField(max_length=50 , choices=BUILDING_TYPE_CHOICES, null=True)  

    def __str__(self):
        return f"{self.owner} : {self.title}"

################# Photos Model

class Photos(models.Model):

    post    = models.ForeignKey(Post, on_delete=models.CASCADE)    
    picture = models.ImageField(upload_to="profiles/" , blank=True , null=True)


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

    
################# Boosting Model


class Boosting(models.Model):
    boost_plan      = models.ForeignKey(BoostingPlan, on_delete=models.CASCADE)
    post            = models.ForeignKey(Post, on_delete=models.CASCADE)
    created_at      = models.DateTimeField(auto_now=True)
    expires_at      = models.DateTimeField()

