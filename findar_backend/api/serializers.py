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

