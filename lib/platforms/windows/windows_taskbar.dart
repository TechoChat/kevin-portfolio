import 'dart:async';
import 'package:flutter/material.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../components/weather_service.dart';


class WindowsTaskbar extends StatefulWidget {
  final VoidCallback onStartMenuTap;

  const WindowsTaskbar({
    super.key,
    required this.onStartMenuTap,
  });

  @override
  State<WindowsTaskbar> createState() => _WindowsTaskbarState();
}

class _WindowsTaskbarState extends State<WindowsTaskbar> {
  // --- Battery State ---
  final Battery _battery = Battery();
  BatteryState _batteryState = BatteryState.unknown;
  int _batteryLevel = 100;
  StreamSubscription<BatteryState>? _batteryStateSubscription;

  // --- Network State ---
  final Connectivity _connectivity = Connectivity();
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  // --- ✅ Weather State ---
  final WeatherService _weatherService = WeatherService();
  String _weatherTemp = "--";
  String _weatherCondition = "Loading";
  IconData _weatherIcon = Icons.wb_sunny;
  bool _isLoadingWeather = true;

  @override
  void initState() {
    super.initState();
    _initBattery();
    _initConnectivity();
    _initWeather(); // Start fetching

    _batteryStateSubscription = _battery.onBatteryStateChanged.listen((BatteryState state) {
      setState(() => _batteryState = state);
    });

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> result) {
      setState(() => _connectionStatus = result);
    });
  }

  // ✅ Fetch Weather Logic
  Future<void> _initWeather() async {
    final weather = await _weatherService.getWeather();
    if (mounted && weather != null) {
      setState(() {
        _weatherTemp = weather.temperature;
        _weatherCondition = weather.condition;
        _weatherIcon = _weatherService.getWeatherIcon(weather.iconCode);
        _isLoadingWeather = false;
      });
    }
  }

  Future<void> _initBattery() async {
    try {
      final level = await _battery.batteryLevel;
      setState(() => _batteryLevel = level);
    } catch (_) {}
  }

  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      setState(() => _connectionStatus = result);
    } catch (_) {}
  }

  @override
  void dispose() {
    _batteryStateSubscription?.cancel();
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  IconData _getBatteryIcon() {
    if (_batteryState == BatteryState.charging) return Icons.battery_charging_full;
    if (_batteryLevel >= 95) return Icons.battery_full;
    if (_batteryLevel >= 80) return Icons.battery_6_bar;
    if (_batteryLevel >= 60) return Icons.battery_5_bar;
    if (_batteryLevel >= 40) return Icons.battery_4_bar;
    if (_batteryLevel >= 20) return Icons.battery_2_bar;
    return Icons.battery_alert;
  }

  IconData _getNetworkIcon() {
    if (_connectionStatus.contains(ConnectivityResult.ethernet)) return Icons.settings_ethernet;
    if (_connectionStatus.contains(ConnectivityResult.wifi)) return Icons.wifi;
    if (_connectionStatus.contains(ConnectivityResult.mobile)) return Icons.signal_cellular_4_bar;
    return Icons.public_off;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF202020).withValues(alpha: 0.85),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          // ✅ 1. LEFT SIDE: Weather Widget
          // We wrap it in a container with a fixed width or just let it sit there.
          if (!_isLoadingWeather) 
             _TaskbarWeather(
               temp: _weatherTemp, 
               condition: _weatherCondition, 
               icon: _weatherIcon
             ),
          
          const Spacer(),

          // 2. CENTER: Start Button & Search
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _TaskbarIcon(
                icon: Icons.window,
                color: Colors.blueAccent,
                onTap: widget.onStartMenuTap,
              ),
              const SizedBox(width: 8),
              _TaskbarIcon(
                icon: Icons.search,
                color: Colors.white,
                onTap: () {},
              ),
            ],
          ),

          const Spacer(),

          // 3. RIGHT SIDE: System Tray
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.expand_less, color: Colors.white70, size: 20),
              const SizedBox(width: 12),
              
              Tooltip(
                message: _connectionStatus.contains(ConnectivityResult.none) ? "Not Connected" : "Connected",
                child: Icon(_getNetworkIcon(), color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.volume_up, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              
              Tooltip(
                message: "$_batteryLevel% ${_batteryState == BatteryState.charging ? '(Charging)' : ''}",
                child: Icon(_getBatteryIcon(), color: Colors.white, size: 20),
              ),

              const SizedBox(width: 16),
              const WindowsClock(),
              const SizedBox(width: 10),
              Container(width: 5, color: Colors.white12),
            ],
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// ✅ NEW WIDGET: Windows 11 Style Weather Widget (Left Taskbar)
// -----------------------------------------------------------------------------
class _TaskbarWeather extends StatefulWidget {
  final String temp;
  final String condition;
  final IconData icon;

  const _TaskbarWeather({
    required this.temp,
    required this.condition,
    required this.icon,
  });

  @override
  State<_TaskbarWeather> createState() => _TaskbarWeatherState();
}

class _TaskbarWeatherState extends State<_TaskbarWeather> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        height: 40, // Matches taskbar height mostly
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: _isHovered ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Weather Icon (Sun/Cloud)
            Icon(widget.icon, color: Colors.orangeAccent, size: 24),
            const SizedBox(width: 8),
            
            // Text Column (Temp & Condition)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${widget.temp}°C",
                  style: const TextStyle(
                    color: Colors.white, 
                    fontSize: 11, 
                    fontWeight: FontWeight.w600,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.condition, // e.g., "Sunny"
                  style: const TextStyle(
                    color: Colors.white70, 
                    fontSize: 10,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// --- UNCHANGED HELPERS ---
// -----------------------------------------------------------------------------

class _TaskbarIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _TaskbarIcon({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_TaskbarIcon> createState() => _TaskbarIconState();
}

class _TaskbarIconState extends State<_TaskbarIcon> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _isHovered
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(widget.icon, color: widget.color, size: 26),
        ),
      ),
    );
  }
}

class WindowsClock extends StatefulWidget {
  const WindowsClock({super.key});

  @override
  State<WindowsClock> createState() => _WindowsClockState();
}

class _WindowsClockState extends State<WindowsClock> {
  late Timer _timer;
  late DateTime _currentTime;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String minute = _currentTime.minute.toString().padLeft(2, '0');
    String day = _currentTime.day.toString().padLeft(2, '0');
    String month = _currentTime.month.toString().padLeft(2, '0');
    String year = _currentTime.year.toString();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          "${_currentTime.hour >= 12 ? _currentTime.hour - 12 : _currentTime.hour}:$minute ${_currentTime.hour >= 12 ? 'PM' : 'AM'}",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          "$day-$month-$year",
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }
}