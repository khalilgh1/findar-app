import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:findar/core/constants/constants.dart';
import 'package:findar/core/models/property_listing_model.dart';

part 'findar_api_service.g.dart';

@RestApi(baseUrl: DjangoBaseUrl)
abstract class FindarApiService {
  factory FindarApiService(Dio dio, {String baseUrl}) = _FindarApiService;

  @POST('create-listing/')
  Future<HttpResponse<PropertyListing>> createListing(@Body() Map<String, dynamic> body);

  @GET('get-listing/{listing_id}')
  Future<HttpResponse<PropertyListing>> getListing(@Path("listing_id") int listingId);

  @PUT('edit-listing/{listing_id}')
  Future<HttpResponse<PropertyListing>> editListing(
      @Path("listing_id") int listingId, @Body() Map<String, dynamic> body);

  @GET('my_listings/')
  Future<HttpResponse<List<PropertyListing>>> myListings();

  @POST('toggle_active_listing/{listing_id}')
  Future<HttpResponse<Map<String, dynamic>>> toggleActiveListing(@Path("listing_id") int listingId);

  @POST('login/')
  Future<HttpResponse<Map<String, dynamic>>> login(@Body() Map<String, dynamic> body);

  @POST('save_listing/{listing_id}')
  Future<HttpResponse<Map<String, dynamic>>> saveListing(@Path("listing_id") int listingId);

  @POST('register/')
  Future<HttpResponse<Map<String, dynamic>>> register(@Body() Map<String, dynamic> body);

  @GET('listing-details/{listing_id}')
  Future<HttpResponse<PropertyListing>> listingDetails(@Path("listing_id") int listingId);

  @GET('sponsored-listings/')
  Future<HttpResponse<List<PropertyListing>>> sponsoredListings();

  @GET('recent-listings/')
  Future<HttpResponse<List<PropertyListing>>> recentListings();

  @POST('advanced-search/')
  Future<HttpResponse<List<PropertyListing>>> advancedSearch(@Body() Map<String, dynamic> body);
}