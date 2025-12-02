from .models import *
from .serializers import *
from django.contrib.auth import authenticate
from rest_framework import status
from rest_framework.response import Response 
from rest_framework.decorators import api_view , permission_classes
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework.permissions import IsAuthenticated

"""
    for every view that needs a user ( authenticated user ) do 
    @api_view(['GET'])
    @permission_classes([IsAuthenticated])
"""

#########  LISTINGS VIEW  #########


#########Home VIEWS#########


@api_view(['GET'])
def sponsored_listings(request):
    pass

@api_view(['GET'])

def recent_listings(request):
    # maybe we need pagination here
    #in the ui there is a search bar
    #also in the ui there is an option on the top to select the property type
    pass


#########Advanced Search VIEW#########


def advanced_search(request):
    """
    this will be used after submitting the advanced search screen to go the search results screen
    user can filter by :
        - location (latitude , longitude)
        - price range (min , max)
        - property type (Any ,for sale, for rent)
        - Building type (House, apartment, condo , townhouse)
        - # bedrooms, # bathrooms
    """
    pass

######## Saved listing VIEW#########

def saved_listings(request, user_id):
    """
    user can view his saved listings
    """
    pass


######## Listing details VIEW#########


def listing_details(request, listing_id):
    """
    user can view the details of a specific listing
    """
    pass



######## My Listings VIEW#########
@api_view(["GET"])
@permission_classes([IsAuthenticated])
def my_listings(request):
    """
    user can view his own listings
    in the ui there is an option to filter by online / offline listings
    """
    posts = Post.objects.filter(owner=request.user)
    active_posts   = posts.filter(active=True )
    inactive_posts = posts.filter(active=False)
    active_posts   = PostSerializers(active_posts , many=True).data
    inactive_posts = PostSerializers(inactive_posts , many=True).data
    return Response({
            "active":active_posts,
            "inactive":inactive_posts,
        },
        status=status.HTTP_200_OK
    )

######## create Listings VIEW#########
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_listing(request):
    request.data['owner'] = request.user.id
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



