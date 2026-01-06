// A simple abstract network service to check connectivity status


abstract class NetworkService {
  Future<bool> isConnected();
}