import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:intl/intl.dart';

class MacMenuBar extends StatefulWidget {
  final int batteryLevel;
  final BatteryState batteryState;
  final List<ConnectivityResult> connectionStatus;

  const MacMenuBar({
    required this.batteryLevel,
    required this.batteryState,
    required this.connectionStatus,
    super.key,
  });

  @override
  State<MacMenuBar> createState() => _MacMenuBarState();
}

class _MacMenuBarState extends State<MacMenuBar> {
  late Timer _timer;
  late String _timeString;

  @override
  void initState() {
    super.initState();
    _timeString = _formatDateTime();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer t) => _getTime(),
    );
  }

  void _getTime() {
    final String formattedDateTime = _formatDateTime();
    if (_timeString != formattedDateTime) {
      setState(() => _timeString = formattedDateTime);
    }
  }

  String _formatDateTime() =>
      DateFormat('E MMM d  h:mm a').format(DateTime.now());

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  IconData _getNetworkIcon() {
    if (widget.connectionStatus.contains(ConnectivityResult.ethernet))
      return CupertinoIcons.link;
    if (widget.connectionStatus.contains(ConnectivityResult.wifi))
      return CupertinoIcons.wifi;
    if (widget.connectionStatus.contains(ConnectivityResult.mobile))
      return CupertinoIcons.antenna_radiowaves_left_right;
    return CupertinoIcons.wifi_slash;
  }

  IconData _getBatteryIcon() {
    if (widget.batteryState == BatteryState.charging)
      return CupertinoIcons.battery_charging;
    if (widget.batteryLevel >= 90) return CupertinoIcons.battery_full;
    if (widget.batteryLevel >= 25) return CupertinoIcons.battery_25_percent;
    return CupertinoIcons.battery_0;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: Colors.white.withValues(alpha: 0.3),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(Icons.apple, size: 20, color: Colors.white),
              const SizedBox(width: 20),
              // Use Expanded/SingleChildScrollView to handle overflow
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const _MenuText("Finder"),
                      const _MenuText("File"),
                      const _MenuText("Edit"),
                      const _MenuText("View"),
                      const _MenuText("Go"),
                      const _MenuText("Window"),
                      const _MenuText("Help"),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // System Tray
              Row(
                mainAxisSize: MainAxisSize.min, // Keep tight
                children: [
                  Icon(_getNetworkIcon(), size: 16, color: Colors.white),
                  const SizedBox(width: 15),
                  Row(
                    children: [
                      Text(
                        "${widget.batteryLevel}%",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        _getBatteryIcon(),
                        size: 18,
                        color:
                            widget.batteryLevel < 20 &&
                                widget.batteryState != BatteryState.charging
                            ? Colors.redAccent
                            : Colors.white,
                      ),
                    ],
                  ),
                  const SizedBox(width: 15),
                  _MenuText(_timeString),
                  const SizedBox(width: 0), // Reduce spacing if needed
                  const Icon(
                    CupertinoIcons.control,
                    size: 16,
                    color: Colors.white,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuText extends StatelessWidget {
  final String text;
  const _MenuText(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 16),
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 13,
        fontWeight: FontWeight.w500,
        decoration: TextDecoration.none,
      ),
    ),
  );
}
