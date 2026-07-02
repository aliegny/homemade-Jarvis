import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:io';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  /// Returns true if device has an active internet connection.
  /// First checks connectivity type, then pings Google DNS to verify actual internet.
  Future<bool> hasInternet() async {
    try {
      final result = await _connectivity.checkConnectivity();
      final hasNetwork = result.contains(ConnectivityResult.mobile) ||
          result.contains(ConnectivityResult.wifi) ||
          result.contains(ConnectivityResult.ethernet);

      if (!hasNetwork) return false;

      // Extra verification: actual internet ping
      try {
        final lookup = await InternetAddress.lookup('google.com')
            .timeout(const Duration(seconds: 3));
        return lookup.isNotEmpty && lookup.first.rawAddress.isNotEmpty;
      } catch (_) {
        return false;
      }
    } catch (e) {
      // ignore: avoid_print
      print('Connectivity check error: $e');
      return false;
    }
  }

  /// Stream of connectivity changes
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;
}
