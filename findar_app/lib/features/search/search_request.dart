/// Route argument for '/search-results'.
///
/// * [query] runs a text search (city, district, title).
/// * [listingType] / [buildingType] run a filtered search instead.
/// * [useCurrentFilters] re-runs SearchCubit's current filters (after the
///   Advanced search screen applied them).
/// * [focus] opens with the keyboard up (the Home search pill).
class SearchRequest {
  const SearchRequest({
    this.query = '',
    this.listingType,
    this.buildingType,
    this.useCurrentFilters = false,
    this.focus = false,
    this.filters,
  });

  /// Full filter map (SearchCubit's shape) to run, from Advanced search.
  final Map<String, dynamic>? filters;

  final String query;
  final String? listingType;
  final String? buildingType;
  final bool useCurrentFilters;
  final bool focus;

  bool get isFiltered =>
      useCurrentFilters ||
      filters != null ||
      listingType != null ||
      buildingType != null;
}
