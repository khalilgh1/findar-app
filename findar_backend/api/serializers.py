from rest_framework import serializers
from .models import (
    CustomUser, Post, Photos, SavedPosts, Report, BoostingPlan, Boosting
)

class CustomUserSerializers(serializers.ModelSerializer):
    class Meta:
        model = CustomUser
        fields= "__all__"

class PostSerializers(serializers.ModelSerializer):
    class Meta:
        model = Post
        fields= "__all__"

class PhotosSerializers(serializers.ModelSerializer):
    class Meta:
        model = Photos
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
        fields = ("username", "email", "password", "phone_number", "profile_pic", "account_type")

    def create(self, validated_data):
        user = CustomUser.objects.create_user(
            username      = validated_data["username"],
            email         = validated_data["email"],
            password      = validated_data["password"],
            phone_number  = validated_data.get("phone_number"),
            profile_pic   = validated_data.get("profile_pic"),
            account_type  = validated_data.get("account_type", "user"),
        )
        return user
