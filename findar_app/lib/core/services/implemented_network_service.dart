import 'package:findar/core/services/abstract_network_service.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ImplementedNetworkService implements NetworkService {
  final InternetConnection _connectionChecker;

  ImplementedNetworkService({InternetConnection? connectionChecker})
      : _connectionChecker = connectionChecker ?? InternetConnection();

  @override
  Future<bool> isConnected() async {
    return await _connectionChecker.hasInternetAccess;
  }
}
