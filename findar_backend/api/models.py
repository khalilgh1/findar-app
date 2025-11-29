from django.contrib.auth.models import AbstractUser

from django.db import models

# Create your models here.


################# Customized User 

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
    
###################################
