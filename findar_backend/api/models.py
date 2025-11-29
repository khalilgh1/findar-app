from django.contrib.auth.models import AbstractUser

from django.db import models

# Create your models here.


# changes to be made 
"""
    1 . pictures need to be have a random name (post and profile)
    2 . Report model needs to be bigger
"""


################# Customized User Model

ACCOUNT_CHOICES = [
    ('normal' , 'Normal'),
    ('agency' , 'Agency')
]

class CustomUser(AbstractUser):

    phone_number    = models.CharField(max_length=15)
    profile_pic     = models.ImageField(upload_to="profiles/" , blank=True , null=True)
    account_type    = models.CharField(max_length=20, choices=ACCOUNT_CHOICES, default='user')
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
    titel        = models.CharField(max_length=255)
    price        = models.FloatField()
    description  = models.TextField(max_length=1000) 
    created_at   = models.DateTimeField(auto_now=True)
    active       = models.BooleanField(default=True)
    boosted      = models.BooleanField(default=False)
    main_pic     = models.ImageField(upload_to="profiles/" , blank=True , null=True)
    latitude     = models.FloatField()
    longitude    = models.FloatField()
    bedrooms     = models.IntegerField(default=0  , null=True)
    bathrooms    = models.IntegerField(default=0  , null=True)
    livingrooms  = models.IntegerField(default=0  , null=True)
    area         = models.FloatField(default=0.0  , null=True)
    listingtype  = models.CharField(max_length=50 , choices=LISTING_TYPE_CHOICES, null=True)  
    buildingtype = models.CharField(max_length=50 , choices=BUILDING_TYPE_CHOICES, null=True)  

    def __str__(self):
        return f"{self.owner} : {self.titel}"

################# Photos Model

class Photos(models.Model):

    post    = models.ForeignKey(Post)    
    picture = models.ImageField(upload_to="profiles/" , blank=True , null=True)


################# SavedPosts Model

class SavedPosts(models.Model):

    user    = models.ForeignKey(CustomUser)
    post    = models.ForeignKey(Post)    
    saved_at= models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.user} : {self.post}"
    
################# Report Model

class Report(models.Model):

    reporter_user    = models.ForeignKey(CustomUser)
    reported_user    = models.ForeignKey(CustomUser)
    post             = models.ForeignKey(Post , null=True , blank=True)   
    description      = models.TextField(max_length=1000) 
    created_at       = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.reporter_user} reported {self.reported_user}"