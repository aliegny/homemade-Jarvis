import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothService {
  BluetoothDevice? _connectedDevice;
  bool _isScanning = false;

  /// Scan for nearby BLE devices
  Stream<List<ScanResult>> scanForDevices({
    Duration timeout = const Duration(seconds: 10),
  }) async* {
    if (_isScanning) return;

    try {
      _isScanning = true;
      await FlutterBluePlus.startScan(timeout: timeout);
      yield* FlutterBluePlus.scanResults;
    } finally {
      _isScanning = false;
    }
  }

  /// Auto-connect to TG-1 smartwatch by scanning and matching device name
  Future<bool> connectToTG1() async {
    try {
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 8),
      );

      await for (final results in FlutterBluePlus.scanResults) {
        for (final r in results) {
          final name = r.device.platformName.toLowerCase();
          if (name.contains('tg-1') ||
              name.contains('tg1') ||
              name.contains('imiki') ||
              name.contains('smartwatch')) {
            await FlutterBluePlus.stopScan();
            await r.device.connect(
              timeout: const Duration(seconds: 10),
            );
            _connectedDevice = r.device;
            _listenToDisconnection(r.device);
            return true;
          }
        }
      }

      await FlutterBluePlus.stopScan();
      return false;
    } catch (e) {
      // ignore: avoid_print
      print('Bluetooth connection error: $e');
      await FlutterBluePlus.stopScan();
      return false;
    }
  }

  /// Connect to a specific device found during scanning
  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect(timeout: const Duration(seconds: 10));
      _connectedDevice = device;
      _listenToDisconnection(device);
      return true;
    } catch (e) {
      // ignore: avoid_print
      print('Device connect error: $e');
      return false;
    }
  }

  void _listenToDisconnection(BluetoothDevice device) {
    device.connectionState.listen((state) {
      if (state == BluetoothConnectionState.disconnected) {
        if (_connectedDevice == device) {
          _connectedDevice = null;
        }
      }
    });
  }

  Future<void> disconnect() async {
    if (_connectedDevice != null) {
      try {
        await _connectedDevice!.disconnect();
      } catch (e) {
        // ignore: avoid_print
        print('Disconnect error: $e');
      }
      _connectedDevice = null;
    }
  }

  Future<List<BluetoothDevice>> getConnectedDevices() async {
    try {
      return FlutterBluePlus.connectedDevices;
    } catch (e) {
      return [];
    }
  }

  Stream<BluetoothAdapterState> get adapterState =>
      FlutterBluePlus.adapterState;

  bool get isConnected =>
      _connectedDevice != null;

  BluetoothDevice? get connectedDevice => _connectedDevice;
  bool get isScanning => _isScanning;
}
