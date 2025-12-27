import 'package:get_it/get_it.dart';
import 'package:findar/core/repositories/abstract_listing_repo.dart';
import 'package:findar/core/repositories/remote_listing_repo.dart';
import 'package:findar/core/services/findar_api_service.dart';

final GetIt getIt = GetIt.instance;

void SetupRepositories() {

  // Register FindarApiService
  getIt.registerLazySingleton<FindarApiService>(() => FindarApiService());
  // Register repository using the API service
  getIt.registerLazySingleton<ListingRepository>(
      () => RemoteListingRepository(getIt<FindarApiService>()));
}
