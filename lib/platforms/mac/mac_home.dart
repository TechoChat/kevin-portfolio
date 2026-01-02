import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:kevins_tech/platforms/mac/mac_dock.dart';
import 'package:kevins_tech/platforms/mac/mac_menu_bar.dart';
import 'package:kevins_tech/platforms/mac/mac_widget.dart';
import 'package:kevins_tech/platforms/mac/desktop_icon.dart';

// ✅ Import your Weather Service
import '../../components/weather_service.dart';

class MacHome extends StatefulWidget {
  final ValueChanged<TargetPlatform> onPlatformSwitch;

  const MacHome({super.key, required this.onPlatformSwitch});

  @override
  State<MacHome> createState() => _MacHomeState();
}

class _MacHomeState extends State<MacHome> {
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
  String _weatherCity = "Cupertino"; // Default placeholder
  String _weatherCondition = "Loading";
  IconData _weatherIcon = CupertinoIcons.cloud_sun_fill; // Default Apple-style icon
  bool _isLoadingWeather = true;

  @override
  void initState() {
    super.initState();
    _initBattery();
    _initConnectivity();
    _initWeather(); // ✅ Start fetching weather

    // Listeners
    _batteryStateSubscription = _battery.onBatteryStateChanged.listen((state) {
      setState(() => _batteryState = state);
    });

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((result) {
      setState(() => _connectionStatus = result);
    });
  }

  // ✅ Fetch Weather Logic
  Future<void> _initWeather() async {
    final weather = await _weatherService.getWeather();
    if (mounted && weather != null) {
      setState(() {
        _weatherTemp = weather.temperature;
        _weatherCity = weather.cityName;
        _weatherCondition = weather.condition;
        // Map OpenWeather icon code to Cupertino Icons for Mac look
        _weatherIcon = _mapToCupertinoIcon(weather.iconCode);
        _isLoadingWeather = false;
      });
    }
  }

  // Helper to map API icons to Apple Style Icons
  IconData _mapToCupertinoIcon(String code) {
    switch (code) {
      case '01d': return CupertinoIcons.sun_max_fill;
      case '01n': return CupertinoIcons.moon_fill;
      case '02d': 
      case '02n': return CupertinoIcons.cloud_sun_fill;
      case '03d': 
      case '03n': 
      case '04d': 
      case '04n': return CupertinoIcons.cloud_fill;
      case '09d': 
      case '09n': 
      case '10d': 
      case '10n': return CupertinoIcons.cloud_rain_fill;
      case '11d': 
      case '11n': return CupertinoIcons.cloud_bolt_fill;
      case '13d': 
      case '13n': return CupertinoIcons.snow;
      default: return CupertinoIcons.cloud_fill;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Wallpaper
          Positioned.fill(
            child: Image.asset(
              'assets/img/mac/macOS-Light.jpg',
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2E004F), Color(0xFF8B00A0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),

          // 2. Desktop Widgets (Left Side)
          Positioned(
            top: 40,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Battery/Status Widget
                MacWidgetContainer(
                  width: 300,
                  height: 140,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      BatteryRing(
                        percent: _batteryLevel / 100,
                        label: "$_batteryLevel%",
                        icon: _batteryState == BatteryState.charging 
                            ? CupertinoIcons.bolt_fill 
                            : CupertinoIcons.device_laptop,
                        color: _batteryState == BatteryState.charging 
                            ? const Color(0xFF52D598) 
                            : (_batteryLevel < 20 ? Colors.red : const Color(0xFF52D598)),
                      ),
                      const BatteryRing(
                        percent: 1.00,
                        label: "100%",
                        icon: CupertinoIcons.headphones,
                        color: Colors.blueAccent,
                      ),
                      const BatteryRing(
                        percent: 0.08,
                        label: "8%",
                        icon: CupertinoIcons.battery_25,
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                // Calendar & Weather Row
                Row(
                  children: [
                    MacWidgetContainer(
                      width: 140,
                      height: 140,
                      color: Colors.white.withValues(alpha: 0.95),
                      child: const CalendarWidget(),
                    ),
                    const SizedBox(width: 15),
                    
                    // ✅ Updated Weather Widget Container
                    MacWidgetContainer(
                      width: 140,
                      height: 140,
                      color: Colors.blue.withValues(alpha: 0.6),
                      child: WeatherWidget(
                        temp: _weatherTemp,
                        city: _weatherCity,
                        condition: _weatherCondition,
                        icon: _weatherIcon,
                        isLoading: _isLoadingWeather,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 3. Desktop Icons ("Move to Windows")
          Positioned(
            top: 40,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                DesktopIcon(
                  label: "Move to\nWindows",
                  icon: CupertinoIcons.device_laptop,
                  color: Colors.white,
                  onTap: () => widget.onPlatformSwitch(TargetPlatform.windows),
                ),
                const SizedBox(height: 20),
                DesktopIcon(
                  label: "Macintosh HD",
                  icon: CupertinoIcons.cube_box_fill,
                  color: Colors.grey.shade300,
                  onTap: () {},
                ),
              ],
            ),
          ),

          // 4. The Top Menu Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 28,
            child: MacMenuBar(
              batteryLevel: _batteryLevel,
              batteryState: _batteryState,
              connectionStatus: _connectionStatus,
            ),
          ),

          // 5. The Dock
          const Positioned(bottom: 10, left: 0, right: 0, child: MacDock()),
        ],
      ),
    );
  }
}

