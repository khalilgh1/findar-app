import 'package:get_it/get_it.dart';
import 'package:findar/core/repositories/abstract_listing_repo.dart';
import 'package:findar/core/repositories/remote_listing_repo.dart';
import 'package:findar/core/services/findar_api_service.dart';
import 'package:findar/core/services/cloudinary_service.dart';

final GetIt getIt = GetIt.instance;

void SetupRepositories() {

  // Register CloudinaryService
  getIt.registerLazySingleton<CloudinaryService>(() => CloudinaryService());

  // Register FindarApiService
  getIt.registerLazySingleton<FindarApiService>(() => FindarApiService());
  
  // Register repository using the API service and Cloudinary service
  getIt.registerLazySingleton<ListingRepository>(
      () => RemoteListingRepository(
        getIt<FindarApiService>(),
        getIt<CloudinaryService>(),
      ));
}
