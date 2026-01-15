import 'dart:async';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

class IosStatusBar extends StatefulWidget {
  const IosStatusBar({super.key});

  @override
  State<IosStatusBar> createState() => _IosStatusBarState();
}

class _IosStatusBarState extends State<IosStatusBar> {
  late Timer _timer;
  String _timeString = "";

  // Data
  int _batteryLevel = 100;
  BatteryState _batteryState = BatteryState.full;
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.wifi];

  final Battery _battery = Battery();
  late StreamSubscription<BatteryState> _batteryStateSubscription;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _timeString = _formatTime();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer t) => _updateTime(),
    );
    _initBattery();
    _initConnectivity();
  }

  Future<void> _initBattery() async {
    _batteryStateSubscription = _battery.onBatteryStateChanged.listen((state) {
      if (mounted) setState(() => _batteryState = state);
    });
    try {
      final level = await _battery.batteryLevel;
      if (mounted) setState(() => _batteryLevel = level);
    } catch (_) {}
  }

  Future<void> _initConnectivity() async {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      result,
    ) {
      if (mounted) setState(() => _connectionStatus = result);
    });
  }

  void _updateTime() {
    final String formatted = _formatTime();
    if (_timeString != formatted) {
      if (mounted) setState(() => _timeString = formatted);
    }
  }

  String _formatTime() => DateFormat('h:mm').format(DateTime.now());

  @override
  void dispose() {
    _timer.cancel();
    _batteryStateSubscription.cancel();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  IconData _getWifiIcon() {
    if (_connectionStatus.contains(ConnectivityResult.wifi)) {
      return CupertinoIcons.wifi;
    } else if (_connectionStatus.contains(ConnectivityResult.mobile)) {
      return CupertinoIcons.antenna_radiowaves_left_right;
    } else {
      return CupertinoIcons.wifi_slash;
    }
  }

  IconData _getBatteryIcon() {
    if (_batteryState == BatteryState.charging) {
      return CupertinoIcons.battery_charging;
    }
    if (_batteryLevel >= 100) return CupertinoIcons.battery_100;
    if (_batteryLevel >= 25) return CupertinoIcons.battery_25;
    return CupertinoIcons.battery_0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      color: Colors.black, // Typical iOS status bar background on dark apps
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Time
          Text(
            _timeString,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: '.SF Pro Text',
              decoration: TextDecoration.none,
            ),
          ),

          // Icons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _connectionStatus.contains(ConnectivityResult.none)
                    ? CupertinoIcons.bars
                    : CupertinoIcons.antenna_radiowaves_left_right,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 6),
              Icon(_getWifiIcon(), color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(
                "$_batteryLevel%",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: '.SF Pro Text',
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                _getBatteryIcon(),
                color:
                    _batteryLevel < 20 && _batteryState != BatteryState.charging
                    ? Colors.red
                    : Colors.white,
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
