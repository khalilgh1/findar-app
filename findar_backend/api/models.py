from django.contrib.auth.models import AbstractUser

from django.db import models

# Create your models here.


# changes to be made 
"""
    1 . pictures need to be have a random name
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

class Post(models.Model):

    owner        = models.ForeignKey(CustomUser , on_delete=models.CASCADE)
    titel        = models.CharField(max_length=255)
    price        = models.FloatField()
    description  = models.TextField(max_length=1000) 
    created_at   = models.DateTimeField(auto_now=True)
    active       = models.BooleanField(default=True)
    boosted      = models.BooleanField(default=False)
    main_pic  = models.ImageField(upload_to="profiles/" , blank=True , null=True)
    latitude     = models.FloatField()
    longitude    = models.FloatField()

    def __str__(self):
        return f"{self.owner} : {self.titel}"

################# Photos Model

class Photos(models.Model):

    post    = models.ForeignKey(Post)    
    picture = models.ImageField(upload_to="profiles/" , blank=True , null=True)
