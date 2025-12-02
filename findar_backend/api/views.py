from .models import *
from .serializers import *
from django.contrib.auth import authenticate
from rest_framework import status
from rest_framework.response import Response 
from rest_framework.decorators import api_view
from rest_framework_simplejwt.tokens import RefreshToken

#########  LISTINGS VIEW  #########


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


#########  Create User  #########

@api_view(["POST"])
def register(request):
    serializer = RegisterSerializer(data=request.data)

    if not serializer.is_valid():
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    user = serializer.save()
    refresh = RefreshToken.for_user(user)
    return Response({
                    "message": "User created",
                    "access": str(refresh.access_token),
                    "username": user.username,
                    "email": user.email,
                    "account_type": user.account_type,
                    }, status=status.HTTP_201_CREATED)

#########  Login as User  #########

@api_view(["POST"])
def login(request):
    username = request.data.get("username")
    password = request.data.get("password")

    user = authenticate(username=username, password=password)

    if not user:
        return Response({"error": "Invalid credentials"}, status=status.HTTP_400_BAD_REQUEST)

    refresh = RefreshToken.for_user(user)

    return Response({
        "refresh": str(refresh),
        "access": str(refresh.access_token),
        "username": user.username,
        "email": user.email,
        "account_type": user.account_type,
        "credits": user.credits,
    })



