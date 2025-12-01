from django.shortcuts import render
from .models import *
from .serializers import *
from django.db.models import Q
from rest_framework.response import Response
from rest_framework.decorators import api_view
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