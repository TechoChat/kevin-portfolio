import 'dart:async';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

class IosStatusBar extends StatefulWidget {
  final bool isDark; // If true, text is black (for light backgrounds)

  const IosStatusBar({super.key, this.isDark = false});

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
    // 1. Priority: Charging
    if (_batteryState == BatteryState.charging) {
      return CupertinoIcons.battery_charging;
    }

    // 2. Logic Reversed: Check for LOW battery first
    // If battery is critically low (e.g. less than 15%), show empty
    if (_batteryLevel < 15) {
      return CupertinoIcons.battery_0;
    }

    // If battery is somewhat low (e.g. less than 40%), show the 25% icon
    // (You can adjust this number to your preference)
    if (_batteryLevel < 40) {
      return CupertinoIcons.battery_25;
    }

    // 3. Default: For 95%, 100%, or if data is "not available"
    // defaults to Full icon instead of Empty.
    return CupertinoIcons.battery_100;
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isDark ? Colors.black : Colors.white;

    return Container(
      height: 30,
      color: Colors.transparent, // Should be transparent for overlay
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Time
          Text(
            _timeString,
            style: TextStyle(
              color: color,
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
                color: color,
                size: 16,
              ),
              const SizedBox(width: 6),
              Icon(_getWifiIcon(), color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                "$_batteryLevel%",
                style: TextStyle(
                  color: color,
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
                    : color,
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
