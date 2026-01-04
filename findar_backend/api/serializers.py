from rest_framework import serializers
from rest_framework.serializers import ValidationError
import re

from .models import (
    CustomUser, Post, SavedPosts, Report, BoostingPlan, Boosting
)

class UserSerializers(serializers.ModelSerializer):
    class Meta:
        model = CustomUser
        exclude = ('id',"password" , "is_superuser" , "is_staff" , "is_active" , "groups" , "user_permissions")

class PostSerializers(serializers.ModelSerializer):
    class Meta:
        model = Post
        fields= "__all__"

class SavedPostsSerializers(serializers.ModelSerializer):
    class Meta:
        model = SavedPosts
        fields= "__all__"

class ReportSerializers(serializers.ModelSerializer):
    class Meta:
        model = Report
        fields= "__all__"

class BoostingPlanSerializers(serializers.ModelSerializer):
    class Meta:
        model = BoostingPlan
        fields= "__all__"

class BoostingSerializers(serializers.ModelSerializer):
    class Meta:
        model = Boosting
        fields= "__all__"


class RegisterSerializer(serializers.ModelSerializer):

    password = serializers.CharField(write_only=True)

    class Meta:
        model = CustomUser
        fields = ("username", "email", "password", "phone", "profile_pic", "account_type")

    def validate_account_type(self, value):
        if value not in ["individual", "Individual" , "agency" , "Agency"]:
            raise ValidationError("Invalid account type.")
        return value
    
    def validate_username(self,value):
        if len(value) < 4:
            raise ValidationError("Username must be at least 4 characters long.")

        if not re.match(r'^[a-zA-Z0-9_ ]+$', value):
            raise ValidationError("Username can only contain letters, numbers, and underscores.")

        if CustomUser.objects.filter(username=value).exists():
            raise ValidationError("This username is already taken.")
        return value


    def validate_password(self,value):
        if len(value) < 8:
            raise ValidationError("Password must be at least 8 characters long.")

        if not re.search(r'[A-Z]', value):
            raise ValidationError("Password must contain at least one uppercase letter.")

        if not re.search(r'[a-z]', value):
            raise ValidationError("Password must contain at least one lowercase letter.")

        if not re.search(r'\d', value):
            raise ValidationError("Password must contain at least one digit.")
        return value


    def validate_phone(self,value):
        if value and not re.match(r'^\+?\d{9,15}$', value):
            raise ValidationError("Enter a valid phone number.")
        return value
    
    def create(self, validated_data):
        user = CustomUser.objects.create_user(
            **validated_data
        )
        return user
    
