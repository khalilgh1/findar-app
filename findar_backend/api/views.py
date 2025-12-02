from django.shortcuts import render
from .models import *
from .serializers import *
from django.db.models import Q
from rest_framework.response import Response 
from rest_framework import  status
from rest_framework.decorators import api_view
from rest_framework.views import APIView

# Create your views here.
#########LISTINGS VIEW#########


@api_view(['GET'])
def get_listings(request):
    posts = Post.objects.all()
    serializer = PostSerializers(posts, many=True)
    return Response(serializer.data)


@api_view(['POST'])
def create_listing(request):
    print(request)
    serializer = PostSerializers(data=request.data)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data, status=201)
    return Response(serializer.errors, status=400)



#########User VIEW#########

class UserView(APIView):
    def get(request , id):
        try:
            users = CustomUser.objects.get(id=id)
        except CustomUser.DoesNotExist:
            return Response({"id" : id}, status=status.HTTP_404_NOT_FOUND)
        serializer = CustomUserSerializers(data=users)
        return Response(serializer.data , status=status.HTTP_302_FOUND)

    # still need authentication
    def post(request):
        serializer = CustomUserSerializers(data=request.data)
        serializer.is_valid( raise_exception=True )
        serializer.save()
        return Response(serializer.data,status=status.HTTP_201_CREATED)
    
#########Boosting Plan VIEW#########

class BoostingPlanView(APIView):
    def get(request):
        plans = BoostingPlan.objects.all()
        serializer = BoostingPlanSerializers(data=plans)
        return Response(serializer.data , status=status.HTTP_302_FOUND)

    def post(request):
        serializer = BoostingPlanSerializers(data=request.data)
        serializer.is_valid( raise_exception=True )
        serializer.save()
        return Response(serializer.data,status=status.HTTP_201_CREATED)