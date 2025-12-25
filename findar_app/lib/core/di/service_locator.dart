import 'package:get_it/get_it.dart';
import 'package:findar/core/repositories/abstract_listing_repo.dart';
import 'package:findar/core/repositories/database_listing_repo.dart';

final GetIt getIt = GetIt.instance;

void SetupRepositories() {
  getIt.registerLazySingleton<ListingRepository>(
      () => LocalListingRepository());
}
