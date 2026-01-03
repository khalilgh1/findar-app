from .models import *
from .serializers import *
from django.contrib.auth import authenticate
from rest_framework import status
from rest_framework.response import Response 
from rest_framework.decorators import api_view , permission_classes
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework.permissions import IsAuthenticated
from django.db.models import Q
from django.db.models import F, FloatField
from django.db.models.functions import ACos, Cos, Radians, Sin


"""
    for every view that needs a user ( authenticated user ) do 
    @api_view(['GET'])
    @permission_classes([IsAuthenticated])
"""

#########  LISTINGS VIEW  #########


#########Home VIEWS#########


@api_view(['GET'])
# @permission_classes([IsAuthenticated])
def sponsored_listings(request):
    sponsored_posts = Post.objects.filter(boosted=True , active=True)
    serialized_posts = PostSerializers(sponsored_posts , many=True).data
    return Response(serialized_posts , status=status.HTTP_200_OK)

    


@api_view(['GET'])
# @permission_classes([IsAuthenticated])
def recent_listings(request):
    # maybe we need pagination here
    #in the ui there is a search bar
    #also in the ui there is an option on the top to select the property type
    q = request.query_params.get('q' , None)
    q = '' if q is None else q
    listing_type = request.query_params.get('listing_type' , None) # rent / sale

    recent_posts = Post.objects.filter(active=True)
    if listing_type in ['rent' , 'sale']:
        recent_posts = recent_posts.filter(listing_type=listing_type)
    recent_posts = recent_posts.filter(Q(title__icontains=q) | Q(description__icontains=q))
    recent_posts = recent_posts.order_by('-created_at')[:20] # for now, get the 20 most recent active posts after filtering
    serialized_posts = PostSerializers(recent_posts , many=True).data
    return Response(serialized_posts , status=status.HTTP_200_OK)


#########get listing VIEW#########
@api_view(['GET'])
# @permission_classes([IsAuthenticated])
def get_listing(request , listing_id):
    try:
        post = Post.objects.get(id=listing_id , active=True)
    except Post.DoesNotExist:
        return Response({'errors':"not found"} , status=status.HTTP_404_NOT_FOUND)
    
    serialized_post = PostSerializers(post).data
    return Response(serialized_post , status=status.HTTP_200_OK)


#########Advanced Search VIEW#########

@api_view(['GET'])
# @permission_classes([IsAuthenticated])
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
    #constants
    radius_km = 20
    earth_radius_km = 6371
    posts = Post.objects.filter(active=True)
    # filtering logic here
    latitude        = request.query_params.get('latitude' , None)
    longitude       = request.query_params.get('longitude' , None)
    min_price       = request.query_params.get('min_price' , None)
    max_price       = request.query_params.get('max_price' , None)
    listing_type    = request.query_params.get('listing_type' , None) # rent / sale
    building_type   = request.query_params.get('building_type' , None)
    num_bedrooms    = request.query_params.get('num_bedrooms' , None)
    num_bathrooms   = request.query_params.get('num_bathrooms' , None)
    min_sqft        = request.query_params.get('min_sqft' , None)
    max_sqft        = request.query_params.get('max_sqft' , None)
    listed_by       = request.query_params.get('listed_by' , None) # normal / agency

    if latitude and longitude:
        latitude  = float(latitude)
        longitude = float(longitude)
        # calculate distance using Haversine formula
        posts = posts.annotate(
        distance=earth_radius_km * ACos(
            Cos(Radians(latitude)) * Cos(Radians(F('latitude'))) *
            Cos(Radians(F('longitude')) - Radians(longitude)) +
            Sin(Radians(latitude)) * Sin(Radians(F('latitude')))
        )
        ).filter(distance__lte=radius_km)
    if min_price:
        posts = posts.filter(price__gte=float(min_price))
    if max_price:
        posts = posts.filter(price__lte=float(max_price))
    if listing_type in ['rent' , 'sale']:
        posts = posts.filter(listing_type=listing_type)
    if building_type in dict(BUILDING_TYPE_CHOICES).keys():
        posts = posts.filter(building_type=building_type)
    if num_bedrooms:
        posts = posts.filter(bedrooms__gte=int(num_bedrooms))
    if num_bathrooms:
        posts = posts.filter(bathrooms__gte=int(num_bathrooms))
    if min_sqft:
        posts = posts.filter(area__gte=float(min_sqft))
    if max_sqft:
        posts = posts.filter(area__lte=float(max_sqft))
    if listed_by in dict(ACCOUNT_CHOICES).keys():
        posts = posts.filter(owner__account_type=listed_by)
    serialized_posts = PostSerializers(posts , many=True).data
    return Response(serialized_posts , status=status.HTTP_200_OK)

    

######## Save a listing VIEW#########

@api_view(["GET"])
# @permission_classes([IsAuthenticated])
def save_listing(request , listing_id ):
    try:
        post = Post.objects.get(id=listing_id)
    except Post.DoesNotExist:
        return Response({'errors':"not found"} , status=status.HTTP_404_NOT_FOUND)
    
    # Use default user ID 1 for testing
    user_id = 1
    if post.owner.id == user_id:
        return Response({"error" : "you cant save your posts"} , status=status.HTTP_400_BAD_REQUEST)
    
    data = {
        "user": user_id,
        "post": post.id
    }

    serializer = SavedPostsSerializers(data=data)
    
    if not serializer.is_valid():
        return Response({"errors" : serializer.errors},status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    
    serializer.save()
    return Response(status=status.HTTP_200_OK)


######## Saved listing VIEW#########

@api_view(["GET"])
# @permission_classes([IsAuthenticated])
def saved_listings(request):
    # Use default user ID 1 for testing
    user_id = 1
    saved_posts = SavedPosts.objects.filter(user=user_id).select_related('post')
    # Extract the actual Post objects from SavedPosts
    posts = [saved.post for saved in saved_posts if saved.post.active]
    serialized_posts = PostSerializers(posts, many=True).data
    return Response(serialized_posts, status=status.HTTP_200_OK)


######## Listing details VIEW#########

@api_view(["GET"])
# @permission_classes([IsAuthenticated])
def listing_details(request, listing_id):
    """
    user can view the details of a specific listing
    """
    try:
        post = Post.objects.get(id=listing_id)
        post_images  = Photos.objects.filter(post=post.id)
    except Post.DoesNotExist:
        return Response({'errors':"not found"} , status=status.HTTP_404_NOT_FOUND)
    
    post = PostSerializers(post).data
    post_images = PhotosSerializers(post_images,many=True).data
    return Response({'post' : post , 'images' : post_images} , status=status.HTTP_200_OK)
    

######## My Listings VIEW#########

@api_view(["GET"])
# @permission_classes([IsAuthenticated])
def my_listings(request):
    """
    user can view his own listings
    in the ui there is an option to filter by online / offline listings
    """
    # Use default user ID 1 for testing
    user_id = 1
    posts = Post.objects.filter(owner_id=user_id)
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

######## create Listing VIEW#########

@api_view(['POST'])
# @permission_classes([IsAuthenticated])  # Temporarily disabled for testing
def create_listing(request):
    """
     get users location for post position or we will get it from frontend?
    """
    # Use a default owner ID if not authenticated (for testing)
    if hasattr(request, 'user') and request.user.is_authenticated:
        request.data['owner'] = request.user.id
    else:
        # Use owner ID 1 for testing (make sure you have a user with ID 1)
        request.data['owner'] = 1
    
    serializer = PostSerializers(data=request.data)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data, status=201)
    return Response(serializer.errors, status=400)


######## edit Listing VIEW#########
@api_view(['PUT'])
# @permission_classes([IsAuthenticated])
def edit_listing(request , listing_id):
    try:
        post = Post.objects.get(id=listing_id)
    except Post.DoesNotExist:
        return Response({'errors':"not found"} , status=status.HTTP_404_NOT_FOUND)
    #TODO turn this on later after authentication is done
    # if post.owner.id != request.user.id:
    #     return Response({"error" : "dont have permission"} , status=status.HTTP_401_UNAUTHORIZED)
    
    serializer = PostSerializers(post , data=request.data , partial=True)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data , status=status.HTTP_200_OK)
    return Response(serializer.errors , status=status.HTTP_400_BAD_REQUEST)


######## toggle active-unactive Listing VIEW#########

@api_view(['POST'])
# @permission_classes([IsAuthenticated])
def toggle_active_listing(request , listing_id):
    try:
        post = Post.objects.get(id=listing_id)
    except Post.DoesNotExist:
        return Response({'errors':"not found"} , status=status.HTTP_404_NOT_FOUND)
    
    # Use default user ID 1 for testing
    user_id = 1
    if post.owner.id != user_id:
        return Response({"error" : "dont have permission"} , status=status.HTTP_401_UNAUTHORIZED)
    
    post.active = not post.active
    post.save()
    return Response(status=status.HTTP_200_OK)

#########  AUTHENTICATION VIEWS  #########

@api_view(["POST"])
def login(request):
    email = request.data.get("email")
    password = request.data.get("password")

    user = authenticate(request=request,email=email, password=password)
    print( request.data  )
    if not user:
        return Response({"error": "Invalid credentials"}, status=status.HTTP_400_BAD_REQUEST)

    refresh = RefreshToken.for_user(user)
    user = UserSerializers(user).data

    response= Response({
        "message":"login successful",
        "success":True,
        "data": {
        "refresh": str(refresh),
        "access": str(refresh.access_token),
        "user": user
        }
    })

    return response 

@api_view(["POST"])
def register(request):

    serializer = RegisterSerializer(data=request.data)
    print( request.data )

    if not serializer.is_valid():
        print( serializer._errors )

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    user = serializer.save()
    
    refresh = RefreshToken.for_user(user)
    user = RegisterSerializer(user).data

    response = Response({
        "message":"registered successful",
        "success":True,
        "data": {
        "refresh": str(refresh),
        "access": str(refresh.access_token),
        "user": user
        }
    })

    return response

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def me(request):
    
    user = request.user
    user = UserSerializers(user).data

    response= Response({
        "user": user
    } , status=status.HTTP_200_OK )

    return response

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def report_property(request):
    """
    Report a property with issue description
    """
    property_id = request.data.get('property_id')
    issue_description = request.data.get('issue_description')
    reporter_email = request.data.get('reporter_email')
    
    if not property_id or not issue_description or not reporter_email:
        return Response({
            "error": "property_id, issue_description, and reporter_email are required"
        }, status=status.HTTP_400_BAD_REQUEST)
    
    try:
        # Check if property exists
        property_post = Post.objects.get(id=property_id)
        
        # Create report entry
        report = Report.objects.create(
            post=property_post,
            user=request.user,
            reason=issue_description[:500],  # Limit to 500 characters
        )
        
        return Response({
            "message": "Property reported successfully",
            "success": True,
            "report_id": report.id
        }, status=status.HTTP_201_CREATED)
        
    except Post.DoesNotExist:
        return Response({
            "error": "Property not found"
        }, status=status.HTTP_404_NOT_FOUND)
    except Exception as e:
        return Response({
            "error": f"Failed to submit report: {str(e)}"
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)