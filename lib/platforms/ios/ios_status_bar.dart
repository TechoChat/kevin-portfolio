import 'dart:async';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

// 5. ✅ UPDATED iOS Status Bar (Receives Real Data)
class IosStatusBar extends StatefulWidget {
  final int batteryLevel;
  final BatteryState batteryState;
  final List<ConnectivityResult> connectionStatus;

  const IosStatusBar({
    required this.batteryLevel,
    required this.batteryState,
    required this.connectionStatus,
    super.key,
  });

  @override
  State<IosStatusBar> createState() => _IosStatusBarState();
}

class _IosStatusBarState extends State<IosStatusBar> {
  late Timer _timer;
  late String _timeString;

  @override
  void initState() {
    super.initState();
    _timeString = _formatTime();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer t) => _updateTime(),
    );
  }

  void _updateTime() {
    final String formatted = _formatTime();
    if (_timeString != formatted) {
      setState(() => _timeString = formatted);
    }
  }

  String _formatTime() => DateFormat('h:mm').format(DateTime.now());

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // Helpers for icons
  IconData _getWifiIcon() {
    if (widget.connectionStatus.contains(ConnectivityResult.wifi)) {
      return CupertinoIcons.wifi;
    } else if (widget.connectionStatus.contains(ConnectivityResult.mobile)) {
      return CupertinoIcons.antenna_radiowaves_left_right; // "5G/LTE" metaphor
    } else {
      return CupertinoIcons.wifi_slash;
    }
  }

  IconData _getBatteryIcon() {
    if (widget.batteryState == BatteryState.charging) {
      return CupertinoIcons.battery_charging;
    }
    // Apple icon logic approximates fullness
    if (widget.batteryLevel >= 100) return CupertinoIcons.battery_100;
    if (widget.batteryLevel >= 25) return CupertinoIcons.battery_25;
    return CupertinoIcons.battery_0;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Time (Left)
          Text(
            _timeString,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: '.SF Pro Text',
              decoration: TextDecoration.none,
            ),
          ),

          // 2. Status Icons (Right)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Signal Bars (Mocked mostly, or tied to connection type)
              Icon(
                widget.connectionStatus.contains(ConnectivityResult.none)
                    ? CupertinoIcons.bars
                    : CupertinoIcons.antenna_radiowaves_left_right,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 6),

              // WiFi Icon
              Icon(_getWifiIcon(), color: Colors.white, size: 18),
              const SizedBox(width: 6),

              // NEW: Battery Percentage
              Text(
                "${widget.batteryLevel}%",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: '.SF Pro Text',
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(width: 4),

              // Battery Icon
              Icon(
                _getBatteryIcon(),
                color:
                    widget.batteryLevel < 20 &&
                        widget.batteryState != BatteryState.charging
                    ? Colors.red
                    : Colors.white,
                size: 24,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
