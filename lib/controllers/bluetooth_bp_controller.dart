import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothBPController extends GetxController {
  // 🔵 State Variables
  var isScanning = false.obs;
  var isConnecting = false.obs;
  var connectedDevice = Rxn<BluetoothDevice>();
  var scanResults = <ScanResult>[].obs;

  // 🟢 Data Stream
  var statusMessage = "Ready to Scan".obs;

  // 🏥 Standard Blood Pressure UUIDs
  final Guid BP_SERVICE_UUID = Guid("1810");
  final Guid BP_CHARACTERISTIC_UUID = Guid("2A35");

  @override
  void onInit() {
    super.onInit();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    // Request Android 12+ Bluetooth permissions
    await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
  }

  // 1️⃣ START SCANNING
  void startScan() async {
    scanResults.clear();
    isScanning.value = true;
    statusMessage.value = "Scanning for BP Cuffs...";

    try {
      // Listen to scan results
      FlutterBluePlus.scanResults.listen((results) {
        scanResults.value = results;
      });

      // Start scan (timeout 15s)
      await FlutterBluePlus.startScan(
          timeout: const Duration(seconds: 15),
        withServices: [Guid("1810")],);

    } catch (e) {
      statusMessage.value = "Scan Error: $e";
    } finally {
      isScanning.value = false;
    }
  }

  void stopScan() {
    FlutterBluePlus.stopScan();
    isScanning.value = false;
  }

  // 2️⃣ CONNECT TO DEVICE
  Future<void> connectToDevice(BluetoothDevice device) async {
    isConnecting.value = true;
    statusMessage.value = "Connecting to ${device.platformName}...";
    stopScan(); // Stop scanning when connecting

    try {
      await device.connect(autoConnect: false);
      connectedDevice.value = device;
      statusMessage.value = "Connected! Finding BP Service...";

      // Discover Services
      await _discoverServices(device);

    } catch (e) {
      statusMessage.value = "Connection Failed";
      print("Connect Error: $e");
    } finally {
      isConnecting.value = false;
    }
  }

  // 3️⃣ DISCOVER & LISTEN
  Future<void> _discoverServices(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();

    BluetoothService? bpService;

    // Find the Blood Pressure Service (1810)
    for (var service in services) {
      if (service.uuid == BP_SERVICE_UUID) {
        bpService = service;
        break;
      }
    }

    if (bpService != null) {
      statusMessage.value = "Service Found! Waiting for Reading...";
      _setupCharacteristicNotification(bpService);
    } else {
      statusMessage.value = "Error: Not a BP Monitor";
      disconnect();
    }
  }

  void _setupCharacteristicNotification(BluetoothService service) async {
    for (var characteristic in service.characteristics) {
      if (characteristic.uuid == BP_CHARACTERISTIC_UUID) {

        // Enable Notifications
        await characteristic.setNotifyValue(true);

        // Listen for Data
        characteristic.lastValueStream.listen((value) {
          if (value.isNotEmpty) {
            _parseBPData(value);
          }
        });
      }
    }
  }

  // 4️⃣ PARSE DATA (The tricky part)
  void _parseBPData(List<int> data) {
    int flags = data[0];
    bool isMMHg = (flags & 0x01) == 0;
    bool hasTimestamp = (flags & 0x02) != 0; // 👈 Check if time exists

    // 1. Parse BP Values
    double systolic = _parseSFloat(data, 1);
    double diastolic = _parseSFloat(data, 3);
    double map = _parseSFloat(data, 5);

    if (!isMMHg) {
      systolic *= 7.50062;
      diastolic *= 7.50062;
    }

    // 2. Parse Timestamp (If present)
    DateTime timestamp = DateTime.now(); // Default to now
    if (hasTimestamp) {
      // Year is 16-bit little endian (Byte 7 & 8)
      int year = data[7] + (data[8] << 8);
      int month = data[9];
      int day = data[10];
      int hour = data[11];
      int minute = data[12];
      int second = data[13];

      timestamp = DateTime(year, month, day, hour, minute, second);
    }

    // 3. Show Result
    Get.snackbar(
      "Reading Received",
      "BP: ${systolic.toInt()}/${diastolic.toInt()}\nTime: $timestamp",
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
    );

    // Call your save function here passing 'timestamp'
    // Get.find<BloodPressureController>().saveFromBluetooth(systolic, diastolic, timestamp);

    //disconnect();
  }

  // Helper for IEEE-11073 16-bit SFLOAT
  double _parseSFloat(List<int> data, int offset) {
    int value = data[offset] + (data[offset + 1] << 8);
    if ((value & 0x8000) != 0) {
      value = -(0x10000 - value);
    }
    // Mantissa and Exponent logic (simplified for standard BP cuffs)
    return value.toDouble();
  }

  void disconnect() {
    connectedDevice.value?.disconnect();
    connectedDevice.value = null;
    statusMessage.value = "Disconnected";
  }
}