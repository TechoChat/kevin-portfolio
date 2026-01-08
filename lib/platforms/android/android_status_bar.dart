import 'dart:async';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AndroidStatusBar extends StatefulWidget {
  final Color iconColor;
  const AndroidStatusBar({super.key, this.iconColor = Colors.white});

  @override
  State<AndroidStatusBar> createState() => _AndroidStatusBarState();
}

class _AndroidStatusBarState extends State<AndroidStatusBar> {
  String _timeString = "";
  late Timer _timer;
  int _batteryLevel = 100;
  BatteryState _batteryState = BatteryState.full;
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.wifi];

  // Battery & Connectivity
  final Battery _battery = Battery();
  late StreamSubscription<BatteryState> _batteryStateSubscription;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _timeString = _formatTime(DateTime.now());
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer t) => _getTime(),
    );

    _initBattery();
    _initConnectivity();
  }

  void _getTime() {
    final String formattedDateTime = _formatTime(DateTime.now());
    if (mounted && _timeString != formattedDateTime) {
      setState(() {
        _timeString = formattedDateTime;
      });
    }
  }

  String _formatTime(DateTime time) {
    return DateFormat('h:mm').format(time);
  }

  Future<void> _initBattery() async {
    _batteryStateSubscription = _battery.onBatteryStateChanged.listen((
      BatteryState state,
    ) {
      if (mounted) setState(() => _batteryState = state);
    });

    try {
      final level = await _battery.batteryLevel;
      if (mounted) setState(() => _batteryLevel = level);
    } catch (_) {}
  }

  Future<void> _initConnectivity() async {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> result,
    ) {
      if (mounted) setState(() => _connectionStatus = result);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _batteryStateSubscription.cancel();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          _timeString,
          style: TextStyle(
            color: widget.iconColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        Row(
          children: [
            Icon(
              _connectionStatus.contains(ConnectivityResult.wifi)
                  ? Icons.wifi
                  : Icons.signal_cellular_alt,
              color: widget.iconColor,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              "$_batteryLevel%",
              style: TextStyle(
                color: widget.iconColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              _batteryState == BatteryState.charging ||
                      _batteryState == BatteryState.full
                  ? Icons.battery_charging_full
                  : Icons.battery_full,
              color: widget.iconColor,
              size: 18,
            ),
          ],
        ),
      ],
    );
  }
}
