import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:findar/logic/cubits/auth_cubit.dart';
import 'package:findar/logic/cubits/boost_cubit.dart';
import 'package:findar/logic/cubits/home/recent_listings.dart';
import 'package:findar/logic/cubits/home/sponsored_listings.dart';
import 'package:findar/logic/cubits/my_listings_cubit.dart';
import 'package:findar/logic/cubits/property_details_cubit.dart';
import 'package:findar/logic/cubits/saved_listings_cubit.dart';

/// Clears the app-global cubits that hold the signed-out user's data, so the
/// next account signed in on this device starts from a clean slate.
/// Call after logout or session expiry, with a context below MainApp's
/// providers.
void resetUserSession(BuildContext context) {
  context.read<AuthCubit>().reset();
  context.read<MyListingsCubit>().reset();
  context.read<SavedListingsCubit>().reset();
  context.read<PropertyDetailsCubit>().reset();
  context.read<RecentCubit>().reset();
  context.read<SponsoredCubit>().reset();
  context.read<BoostCubit>().reset();
}
