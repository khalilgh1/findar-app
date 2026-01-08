from .models import *
from .serializers import *
from django.contrib.auth import authenticate
from rest_framework import status
from rest_framework.response import Response 
from rest_framework.decorators import api_view , permission_classes
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework.permissions import IsAuthenticated
from rest_framework.views import APIView
from django.db.models import Q
from django.db.models import F, FloatField
from django.db.models.functions import ACos, Cos, Radians, Sin

from django.contrib.auth.hashers import check_password
import random
from django.utils import timezone
from django.contrib.auth.hashers import make_password
from rest_framework.views import APIView
from rest_framework.response import Response

from .services import *
"""
    for every view that needs a user ( authenticated user ) do 
    @api_view(['GET'])
    @permission_classes([IsAuthenticated])
"""

#########  LISTINGS VIEW  #########


#########Home VIEWS#########

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def sponsored_listings(request):
    sponsored_posts = Post.objects.filter(boosted=True , active=True)
    serialized_posts = PostSerializers(sponsored_posts , many=True).data
    return Response(serialized_posts , status=status.HTTP_200_OK)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def recent_listings(request):
    # maybe we need pagination here
    #in the ui there is a search bar
    #also in the ui there is an option on the top to select the property type
    print('request query params:' , request.query_params)
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
@permission_classes([IsAuthenticated])
def get_listing(request , listing_id):
    try:
        post = Post.objects.get(id=listing_id , active=True)
    except Post.DoesNotExist:
        return Response({'errors':"not found"} , status=status.HTTP_404_NOT_FOUND)
    
    serialized_post = PostSerializers(post).data
    return Response(serialized_post , status=status.HTTP_200_OK)


#########Advanced Search VIEW#########

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def advanced_search(request):
    """
    this will be used after submitting the advanced search screen to go the search results screen
    user can filter by :
        - location (latitude , longitude)
        - price range (min , max)
        - property type (Any ,for sale, for rent)
        - Building type (House, apartment, condo , townhouse)
        - # bedrooms, # bathrooms
    user can sort by:
        - price (ascending/descending)
        - distance (when location provided)
        - date_posted (newest/oldest)
        - area/sqft (ascending/descending)
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
    sort_by         = request.query_params.get('sort_by', 'date_posted')  # New parameter
    
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
    if listing_type and listing_type in ['rent' , 'sale']:
        posts = posts.filter(listing_type=listing_type)
    if building_type:
        building_type = building_type.lower()
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
    
    # Sorting logic
    sort_mapping = {
        'price_asc': 'price',
        'price_desc': '-price',
        'date_newest': '-created_at',
        'date_oldest': 'created_at',
        'area_asc': 'area',
        'area_desc': '-area',
    }
    
    # Apply sorting
    if sort_by in sort_mapping:
        posts = posts.order_by(sort_mapping[sort_by])
    else:
        # Default sort by newest first
        posts = posts.order_by('-created_at')
    
    serialized_posts = PostSerializers(posts , many=True).data
    return Response(serialized_posts , status=status.HTTP_200_OK)

    
######## Save a listing VIEW#########

@api_view(["GET", "DELETE"])
@permission_classes([IsAuthenticated])
def save_listing(request , listing_id ):
    try:
        post = Post.objects.get(id=listing_id)
    except Post.DoesNotExist:
        return Response({'errors':"not found"} , status=status.HTTP_404_NOT_FOUND)
    
    # Get authenticated user ID
    user_id = request.user.id
    
    # Handle DELETE request (unsave)
    if request.method == "DELETE":
        try:
            saved_post = SavedPosts.objects.get(user=user_id, post=post)
            saved_post.delete()
            return Response({"message": "Listing unsaved successfully"}, status=status.HTTP_200_OK)
        except SavedPosts.DoesNotExist:
            return Response({"error": "Listing was not saved"}, status=status.HTTP_404_NOT_FOUND)
    
    # Handle GET request (save)
    if post.owner.id == user_id:
        return Response({"error" : "you cant save your posts"} , status=status.HTTP_400_BAD_REQUEST)
    
    # Check if already saved
    if SavedPosts.objects.filter(user=user_id, post=post).exists():
        return Response({"message": "Listing already saved"}, status=status.HTTP_200_OK)
    
    data = {
        "user": user_id,
        "post": post.id
    }

    serializer = SavedPostsSerializers(data=data)
    
    if not serializer.is_valid():
        return Response({"errors" : serializer.errors},status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    
    serializer.save()
    return Response({"message": "Listing saved successfully"}, status=status.HTTP_200_OK)


######## Saved listing VIEW#########

@api_view(["GET"])
@permission_classes([IsAuthenticated])
def saved_listings(request):
    # Get authenticated user ID
    user_id = request.user.id
    saved_posts = SavedPosts.objects.filter(user=user_id).select_related('post')
    # Extract the actual Post objects from SavedPosts
    posts = [saved.post for saved in saved_posts if saved.post.active]
    serialized_posts = PostSerializers(posts, many=True).data
    return Response(serialized_posts, status=status.HTTP_200_OK)


######## Listing details VIEW#########

@api_view(["GET"])
@permission_classes([IsAuthenticated])
def listing_details(request, listing_id):
    """
    user can view the details of a specific listing
    """
    try:
        post = Post.objects.get(id=listing_id)
    except Post.DoesNotExist:
        return Response({'errors':"not found"} , status=status.HTTP_404_NOT_FOUND)
    
    post = PostSerializers(post).data
    return Response(post , status=status.HTTP_200_OK)
    

######## My Listings VIEW#########

@api_view(["GET"])
@permission_classes([IsAuthenticated])
def my_listings(request):
    """
    user can view his own listings
    in the ui there is an option to filter by online / offline listings
    """
    # Get authenticated user ID
    user_id = request.user.id
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
@permission_classes([IsAuthenticated])
def create_listing(request):
    """
     get users location for post position or we will get it from frontend?
    """
    # Use authenticated user as owner
    request.data['owner'] = request.user.id
    
    serializer = PostSerializers(data=request.data)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data, status=201)
    return Response(serializer.errors, status=400)


######## edit Listing VIEW#########

@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def edit_listing(request , listing_id):
    try:
        post = Post.objects.get(id=listing_id)
    except Post.DoesNotExist:
        return Response({'errors':"not found"} , status=status.HTTP_404_NOT_FOUND)
    
    # Check if user owns the listing
    if post.owner.id != request.user.id:
        return Response({"error" : "dont have permission"} , status=status.HTTP_401_UNAUTHORIZED)
    
    serializer = PostSerializers(post , data=request.data , partial=True)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data , status=status.HTTP_200_OK)
    return Response(serializer.errors , status=status.HTTP_400_BAD_REQUEST)


######## toggle active-unactive Listing VIEW#########

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def toggle_active_listing(request , listing_id):
    try:
        post = Post.objects.get(id=listing_id)
    except Post.DoesNotExist:
        return Response({'errors':"not found"} , status=status.HTTP_404_NOT_FOUND)
    
    # Get authenticated user ID
    user_id = request.user.id
    if post.owner.id != user_id:
        return Response({"error" : "dont have permission"} , status=status.HTTP_401_UNAUTHORIZED)
    
    print(f"DEBUG TOGGLE - Before: Post ID {post.id}, active={post.active}")
    post.active = not post.active
    post.save()
    print(f"DEBUG TOGGLE - After: Post ID {post.id}, active={post.active}")
    return Response({"message": "Listing status updated", "active": post.active}, status=status.HTTP_200_OK)


#########  Update Profile  #########

@api_view(["PUT"])
@permission_classes([IsAuthenticated])
def update_profile(request):

    full_name = request.data.get("full_name")
    phone_number = request.data.get("phone")
    email = request.data.get("email")
    profile_pic = request.data.get("profile_pic")

    serializer = RegisterSerializer(
            data={"phone": phone_number , "username" : full_name},
            partial=True
        )
    user = CustomUser.objects.get(id=request.user.id)

    if email is not None and email != request.user.email:
        return Response( {"success":False , "message":"cant change email"} , status=status.HTTP_400_BAD_REQUEST )
    
    if phone_number is not None:
        try:
            validated_phone = serializer.validate_phone(value=phone_number)
            user.phone = phone_number
            
        except ValidationError as e:
            return Response( {"success":False , "message":e.detail } , status=status.HTTP_400_BAD_REQUEST )
        
    if full_name is not None:
        try:
            validated_username = serializer.validate_username(value=full_name)
            user.username = full_name 
        except ValidationError as e:
            return Response( {"success":False , "message":e.detail } , status=status.HTTP_400_BAD_REQUEST )        
        

    if profile_pic is not None:
        print("profile pic url:" , profile_pic)
        user.profile_pic = profile_pic
    
    user.save()
    user = UserSerializers(user).data
    print( user )

    return Response( {"success":True , "message":"updated successfully" , "data":user } , status=status.HTTP_201_CREATED )


#########  Login as User  #########

@api_view(["POST"])
def login(request):
    email = request.data.get("email")
    password = request.data.get("password")

    errors = ""
    if email is None or email == "":
        errors += "email should not be empty ,"
    if password is None or password == "":
        errors += "password should not be empty"

    if errors != "":
        return Response(errors , status=status.HTTP_400_BAD_REQUEST)
    

    user = authenticate(request=request,email=email, password=password)
    print( request.data  )

    if not user:
        return Response("incorrect email or password", status=status.HTTP_400_BAD_REQUEST)

    refresh = RefreshToken.for_user(user)
    #serialize user
    user = RegisterSerializer(user).data

    return Response({
        "success": True,
        "message": "Login successful",
        "data": {
        "refresh": str(refresh),
        "access": str(refresh.access_token),
        "user": user
        }
    })

@api_view(["POST"])
@permission_classes([IsAuthenticated])
def logout(request):
    """
    Logout the user by blacklisting their refresh token
    """
    refresh_token = request.data.get("refresh")
    device_token = request.data.get("device_token")

    if not refresh_token:
        return Response({"error": "Refresh token is required"}, status=status.HTTP_400_BAD_REQUEST)
    
    try:
        token = RefreshToken(refresh_token)
        # Remove device token from backend
        if device_token:
            DeviceToken.objects.filter(user=request.user, token=device_token).delete()
        token.blacklist()
        return Response({"message": "Logout successful"}, status=status.HTTP_200_OK)
    except Exception as e:
        return Response({"error": "Invalid token"}, status=status.HTTP_400_BAD_REQUEST)

@api_view(["POST"])
def register(request):

    account_type = request.data.get("account_type")
    if account_type:
        request.data["account_type"] = account_type.lower()

    serializer = RegisterSerializer(data=request.data)
    print( request.data )

    if not serializer.is_valid():

        response = Response( 
            serializer.errors
        , status=status.HTTP_400_BAD_REQUEST)

        return response
    
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
    serializer = UserSerializers(user)
    return Response(serializer.data, status=status.HTTP_200_OK)

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

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def register_device_token(request):
    """
    Register a device token for push notifications
    """
    token = request.data.get('token')
    if not token:
        return Response({
            "error": "Device token is required"
        }, status=status.HTTP_400_BAD_REQUEST)
    
    # Check if token already exists for the user
    existing_token = DeviceToken.objects.filter(user=request.user, token=token).first()
    if existing_token:
        return Response({
            "message": "Device token already registered",
            "success": True
        }, status=status.HTTP_200_OK)
    
    # Create new device token entry
    DeviceToken.objects.create(
        user=request.user,
        token=token
    )
    
    return Response({
        "message": "Device token registered successfully",
        "success": True
    }, status=status.HTTP_201_CREATED)


############################# forget password feature

class PasswordResetRequestAPI(APIView):
    authentication_classes = []
    permission_classes = []

    def post(self, request):
        email = request.data.get("email")

        user = CustomUser.objects.filter(email=email).first()
        if not user:
            return Response({"message": "the email is not linked to an account" , "success" : True } , status=status.HTTP_200_OK)

        code = f"{random.randint(0, 999999):06d}"

        PasswordResetOTP.objects.create(
            user=user,
            code_hash=make_password(code)
        )

        send_reset_code_email(user.email, code)

        return Response({"message": "code has been sent" , "success" : True } , status=status.HTTP_200_OK)

class PasswordResetVerifyCodeAPI(APIView):
    authentication_classes = []
    permission_classes = []

    def post(self, request):
        email = request.data.get("email")
        code = request.data.get("code")

        user = CustomUser.objects.filter(email=email).first()
        if not user:
            return Response(
                {"message": "Invalid code", "success": False},
                status=status.HTTP_400_BAD_REQUEST
            )

        otp = (
            PasswordResetOTP.objects
            .filter(user=user, used=False)
            .order_by("-created_at")
            .first()
        )

        if not otp:
            return Response(
                {"message": "Invalid code", "success": False},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        if otp.is_expired():
            otp.used = True 
            otp.save()
            return Response(
                {"message": "Code expired", "success": False},
                status=status.HTTP_400_BAD_REQUEST
            )

        if otp.attempts >= 5:
            return Response(
                {"message": "Too many attempts", "success": False},
                status=status.HTTP_400_BAD_REQUEST
            )

        if not check_password(code, otp.code_hash):
            otp.attempts += 1
            otp.save()
            return Response(
                {"message": "Invalid code", "success": False},
                status=status.HTTP_400_BAD_REQUEST
            )
        


        return Response(
            {"message": "Code is valid", "success": True},
            status=status.HTTP_200_OK
        )
    
class PasswordResetConfirmAPI(APIView):
    authentication_classes = []
    permission_classes = []

    def post(self, request):
        email = request.data.get("email")
        code = request.data.get("code")
        new_password = request.data.get("new_password")

        user = CustomUser.objects.filter(email=email).first()
        if not user:
            return Response(
                {"message": "Invalid request", "success": False},
                status=status.HTTP_400_BAD_REQUEST
            )

        otp = (
            PasswordResetOTP.objects
            .filter(user=user, used=False)
            .order_by("-created_at")
            .first()
        )

        if not otp:
            return Response(
                {"message": "Invalid code", "success": False},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        if otp.is_expired():
            otp.used = True 
            otp.save()
            return Response(
                {"message": "Code expired", "success": False},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        if not check_password(code, otp.code_hash):
            otp.attempts += 1
            otp.save()
            return Response(
                {"message": "Invalid code", "success": False},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        password_checks = ""
        if new_password is None:
            return Response({"success":False , "message":"the new password field is empty"} , status=status.HTTP_400_BAD_REQUEST)

        if len(new_password) < 8:
            password_checks+="Password must be at least 8 characters long."

        if not re.search(r'[A-Z]', new_password):
            password_checks+="Password must contain at least one uppercase letter."

        if not re.search(r'[a-z]', new_password):
            password_checks+="Password must contain at least one lowercase letter."

        if not re.search(r'\d', new_password):
            password_checks+="Password must contain at least one digit."

        if password_checks != "":
            return Response({"success":False , "message":password_checks} , status=status.HTTP_400_BAD_REQUEST)

        user.set_password(new_password)
        user.save()

        otp.used = True
        otp.save()

        return Response(
            {"message": "Password updated", "success": True},
            status=status.HTTP_200_OK
        )
