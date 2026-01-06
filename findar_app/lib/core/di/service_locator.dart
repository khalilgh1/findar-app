import 'package:findar/core/repositories/composite_listing_repo.dart';
import 'package:findar/core/repositories/database_listing_repo.dart';
import 'package:get_it/get_it.dart';
import 'package:findar/core/repositories/abstract_listing_repo.dart';
import 'package:findar/core/repositories/remote_listing_repo.dart';
import 'package:findar/core/services/findar_api_service.dart';
import 'package:findar/core/services/cloudinary_service.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

final GetIt getIt = GetIt.instance;

void SetupRepositories() {
  // Services
  getIt.registerLazySingleton<CloudinaryService>(
    () => CloudinaryService(),
  );

  getIt.registerLazySingleton<FindarApiService>(
    () => FindarApiService(),
  );

  getIt.registerLazySingleton<InternetConnection>(
    () => InternetConnection(),
  );

  // Local repository
  getIt.registerLazySingleton<LocalListingRepository>(
    () => LocalListingRepository(),
  );

  // Remote repository
  getIt.registerLazySingleton<RemoteListingRepository>(
    () => RemoteListingRepository(
      getIt<FindarApiService>(),
      getIt<CloudinaryService>(),
    ),
  );

  // Composite repository (the only one exposed)
  getIt.registerLazySingleton<ListingRepository>(
      () => CompositeListingRepository(
            getIt<LocalListingRepository>(),
            getIt<RemoteListingRepository>(),
            getIt<InternetConnection>(),
          ));
}
