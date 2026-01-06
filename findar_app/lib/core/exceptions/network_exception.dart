/// Exception thrown when a network operation fails due to no internet connection.
///
/// This exception is used by the composite repository to indicate that
/// an operation requires internet connectivity but the device is offline.
class NetworkException implements Exception {
  final String message;
  final String? operation;

  const NetworkException({
    this.message = 'No internet connection',
    this.operation,
  });

  @override
  String toString() {
    if (operation != null) {
      return 'NetworkException: $message (Operation: $operation)';
    }
    return 'NetworkException: $message';
  }

  /// Factory constructor for offline mode
  factory NetworkException.offline([String? operation]) {
    return NetworkException(
      message: 'This feature requires an internet connection',
      operation: operation,
    );
  }

  /// Factory constructor for feature not available offline
  factory NetworkException.featureUnavailable(String feature) {
    return NetworkException(
      message: '$feature is not available in offline mode',
      operation: feature,
    );
  }
}
