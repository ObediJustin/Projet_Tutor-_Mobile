// lib/core/network/network_info.dart
import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

@LazySingleton(as: NetworkInfo)
class NetworkInfoImpl implements NetworkInfo {
  final InternetConnectionChecker _connectionChecker;

  NetworkInfoImpl() : _connectionChecker = InternetConnectionChecker.instance;

  @override
  Future<bool> get isConnected => _connectionChecker.hasConnection;
}
