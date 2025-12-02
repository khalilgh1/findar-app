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
def my_listings(request, user_id):
    """
    user can view his own listings
    in the ui there is an option to filter by online / offline listings
    """
    pass


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
    