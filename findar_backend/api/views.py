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

@api_view(['GET'])
def get_user(request , id):
    try:
        user = CustomUser.objects.get(id=id)
    except CustomUser.DoesNotExist:
        return Response({"error": f"User with id {id} not found"}, status=status.HTTP_404_NOT_FOUND)
    serializer = CustomUserSerializers(user)
    return Response(serializer.data , status=status.HTTP_200_OK)

@api_view(['GET'])
def get_users(request):
    users = CustomUser.objects.all()
    serializer = CustomUserSerializers(users,many=True)
    return Response(serializer.data , status=status.HTTP_200_OK)

# still need authentication
@api_view(['POST'])
def post(request):
    serializer = CustomUserSerializers(data=request.data)
    serializer.is_valid( raise_exception=True )
    serializer.save()
    return Response(serializer.data,status=status.HTTP_201_CREATED)


#########Reports VIEW#########

class ReportView(APIView):
    def get(request):
        reports = Report.objects.all()
        serializer = ReportSerializers(data=reports)
        return Response(serializer.data , status=status.HTTP_302_FOUND)

    def post(request):
        serializer = ReportSerializers(data=request.data)
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
    
#########Boostings VIEW#########

# for now , no logic for creating ( boosting ur post )
class BoostingsView(APIView):
    def get(request):
        boosts = Boosting.objects.all()
        serializer = BoostingSerializers(data=boosts)
        return Response(serializer.data , status=status.HTTP_302_FOUND)
    