import 'package:equatable/equatable.dart';

/// Abstract base class for all Cubit states
/// All states in the app should extend from one of the concrete implementations
abstract class BaseState extends Equatable {
  const BaseState();

  @override
  List<Object?> get props => [];
}

/// Initial state - used when Cubit is first created
/// No data has been fetched yet, no loading in progress
class BaseInitial extends BaseState {
  const BaseInitial();
}

/// Loading state - used when an async operation is in progress
/// Shows spinner to user while waiting for data/API response
/// 
/// Example: When user clicks "Submit" on a form, emit LoadingState
///          while the API call is in progress
class BaseLoading extends BaseState {
  const BaseLoading();
}

/// Success state - used when an async operation completes successfully
/// Contains the data/result that was fetched or processed
/// 
/// Generic type T: The type of data being held
/// Example: BaseSuccess<List<Listing>> for fetched listings
/// Example: BaseSuccess<User> for user registration response
class BaseSuccess<T> extends BaseState {
  /// The data/result from successful operation
  final T data;

  const BaseSuccess(this.data);

  @override
  List<Object?> get props => [data];
}

/// Error state - used when an async operation fails
/// Contains error message to show to user
/// 
/// Example: When API request fails, emit ErrorState with error message
///          Screen can show error dialog or snackbar
class BaseError extends BaseState {
  /// User-friendly error message to display
  final String message;

  /// Optional: Raw exception for debugging
  final Exception? exception;

  const BaseError(this.message, {this.exception});

  @override
  List<Object?> get props => [message, exception];
}

/// Extension method for easy state creation
/// Usage: Cubit.emit(state.toSuccess(data))
extension BaseStateExtension on BaseState {
  /// Convert any state to Success state with new data
  BaseSuccess<T> toSuccess<T>(T data) => BaseSuccess(data);

  /// Convert any state to Error state
  BaseError toError(String message, {Exception? exception}) =>
      BaseError(message, exception: exception);

  /// Convert any state to Loading state
  BaseLoading toLoading() => const BaseLoading();

  /// Convert any state to Initial state
  BaseInitial toInitial() => const BaseInitial();
}
