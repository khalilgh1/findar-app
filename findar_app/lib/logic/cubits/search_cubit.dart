import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findar/core/repositories/search_repository.dart';
import 'package:findar/core/services/api_service.dart';

/// SearchCubit handles property search with filters
/// 
/// State structure:
/// {
///   'data': List<SearchResult>,   // Search results
///   'state': 'initial|loading|done|error',
///   'message': 'success or error message'
/// }
class SearchCubit extends Cubit<Map<String, dynamic>> {
  late final SearchRepository searchRepository;

  SearchCubit() : super({
    'data': [],
    'state': 'initial',
    'message': ''
  }) {
    searchRepository = SearchRepository(apiService: ApiService());
  }

  /// Search listings with filters
  Future<void> search({
    String? query,
    String? location,
    double? minPrice,
    double? maxPrice,
    int? minBedrooms,
    int? maxBedrooms,
    String? propertyType,
    String? classification,
  }) async {
    emit({
      ...state,
      'state': 'loading',
      'message': ''
    });

    try {
      final result = await searchRepository.search(
        query: query,
        location: location,
        minPrice: minPrice,
        maxPrice: maxPrice,
        minBedrooms: minBedrooms,
        maxBedrooms: maxBedrooms,
        propertyType: propertyType,
        classification: classification,
      );

      if (result.state) {
        emit({
          ...state,
          'state': 'done',
          'message': result.message,
        });
      } else {
        emit({
          ...state,
          'state': 'error',
          'message': result.message,
        });
      }
    } catch (e) {
      emit({
        ...state,
        'state': 'error',
        'message': 'Search error: ${e.toString()}',
      });
    }
  }

  /// Get search suggestions
  Future<void> getSearchSuggestions() async {
    try {
      final result = await searchRepository.getSearchSuggestions();

      if (result.state) {
        emit({
          ...state,
          'message': result.message,
        });
      }
    } catch (e) {
      emit({
        ...state,
        'message': 'Error fetching suggestions: ${e.toString()}',
      });
    }
  }

  /// Get available filter options
  Future<void> getFilterOptions() async {
    try {
      final result = await searchRepository.getFilterOptions();

      if (result.state) {
        emit({
          ...state,
          'message': result.message,
        });
      }
    } catch (e) {
      emit({
        ...state,
        'message': 'Error fetching filter options: ${e.toString()}',
      });
    }
  }

  /// Save search filter
  Future<void> saveFilter({
    required String name,
    required Map<String, dynamic> filters,
  }) async {
    emit({
      ...state,
      'state': 'loading',
    });

    try {
      final result = await searchRepository.saveFilter(
        name: name,
        filters: filters,
      );

      if (result.state) {
        emit({
          ...state,
          'state': 'done',
          'message': result.message,
        });
      } else {
        emit({
          ...state,
          'state': 'error',
          'message': result.message,
        });
      }
    } catch (e) {
      emit({
        ...state,
        'state': 'error',
        'message': 'Error saving filter: ${e.toString()}',
      });
    }
  }

  /// Get saved filters
  Future<void> getSavedFilters() async {
    try {
      final result = await searchRepository.getSavedFilters();

      if (result.state) {
        emit({
          ...state,
          'message': result.message,
        });
      }
    } catch (e) {
      emit({
        ...state,
        'message': 'Error fetching saved filters: ${e.toString()}',
      });
    }
  }

  String get stateType => state['state'] as String;
  String get message => state['message'] as String;
  List get results => state['data'] as List;
}
