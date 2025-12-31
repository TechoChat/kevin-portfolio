import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// ✅ Import your new component
import '../../components/weather_service.dart';

class AndroidHome extends StatefulWidget {
  final ValueChanged<TargetPlatform> onPlatformSwitch;

  const AndroidHome({super.key, required this.onPlatformSwitch});

  @override
  State<AndroidHome> createState() => _AndroidHomeState();
}

class _AndroidHomeState extends State<AndroidHome> {
  late Timer _clockTimer;
  DateTime _currentTime = DateTime.now();
  String _weatherCity = "";

  // Battery & Network
  final Battery _battery = Battery();
  BatteryState _batteryState = BatteryState.unknown;
  int _batteryLevel = 100;
  StreamSubscription<BatteryState>? _batteryStateSubscription;
  final Connectivity _connectivity = Connectivity();
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  // ✅ Weather State
  final WeatherService _weatherService = WeatherService();
  String _weatherTemp = "--"; // Default loading state
  IconData _weatherIcon = Icons.cloud_sync; // Default loading icon
  bool _isLoadingWeather = true;

  @override
  void initState() {
    super.initState();
    _initBattery();
    _initConnectivity();
    _initWeather(); // ✅ Start fetching weather

    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _currentTime = DateTime.now());
    });

    _batteryStateSubscription = _battery.onBatteryStateChanged.listen(
      (state) => setState(() => _batteryState = state),
    );
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (result) => setState(() => _connectionStatus = result),
    );
  }

  // ✅ Fetch Weather Logic
  Future<void> _initWeather() async {
    final weather = await _weatherService.getWeather();
    if (mounted && weather != null) {
      setState(() {
        _weatherTemp = weather.temperature;
        _weatherIcon = _weatherService.getWeatherIcon(weather.iconCode);
        _weatherCity = weather.cityName; // Save the city
        _isLoadingWeather = false;
      });
    } else if (mounted) {
      // Fallback if API fails or location denied
      setState(() {
        _weatherTemp = "24";
        _weatherIcon = Icons.cloud;
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
    _clockTimer.cancel();
    _batteryStateSubscription?.cancel();
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  // --- Icons Helpers ---
  IconData _getBatteryIcon() {
    if (_batteryState == BatteryState.charging){
      return Icons.battery_charging_full;
    }
    if (_batteryLevel >= 95) return Icons.battery_full;
    if (_batteryLevel >= 80) return Icons.battery_6_bar;
    if (_batteryLevel >= 60) return Icons.battery_5_bar;
    if (_batteryLevel >= 40) return Icons.battery_4_bar;
    if (_batteryLevel >= 20) return Icons.battery_2_bar;
    return Icons.battery_alert;
  }

  IconData? _getNetworkIcon() {
    if (_connectionStatus.contains(ConnectivityResult.wifi)) return Icons.wifi;
    if (_connectionStatus.contains(ConnectivityResult.mobile)){
      return Icons.signal_cellular_alt;
    }
    return Icons.signal_cellular_connected_no_internet_4_bar;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Wallpaper
          Positioned.fill(
            child: Image.asset(
              'assets/img/android/android.webp', // Ensure path is correct
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
              opacity: const AlwaysStoppedAnimation(0.9),
            ),
          ),

          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.4),
                  ],
                  stops: const [0.0, 0.2, 0.8, 1.0],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Status Bar ---
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('h:mm a').format(_currentTime),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            _getNetworkIcon(),
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _getBatteryIcon(),
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // --- "At A Glance" Widget ---
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('E, MMM d').format(_currentTime),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Roboto',
                          shadows: [
                            Shadow(
                              color: Colors.black38,
                              blurRadius: 4,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 4),

                      // ✅ REAL WEATHER ROW
                      Row(
                        children: [
                          // Show loading spinner if waiting for location/api
                          if (_isLoadingWeather)
                            const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          else
                            Icon(_weatherIcon, color: Colors.white, size: 16),

                          const SizedBox(width: 8),

                          Text(
                            "$_weatherTemp°C in $_weatherCity", // Shows "24°C in Toronto"
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Spacer(), // Push content down
                // --- App Grid ---
                SizedBox(
                  height: 290,
                  child: GridView.count(
                    crossAxisCount: 4,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.75,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      const _AndroidAppIcon(
                        name: "Gmail",
                        asset: "gmail",
                        bgColor: Colors.white,
                      ),
                      const _AndroidAppIcon(
                        name: "Maps",
                        asset: "maps",
                        bgColor: Colors.white,
                      ),
                      const _AndroidAppIcon(
                        name: "Photos",
                        asset: "photos",
                        bgColor: Colors.white,
                      ),
                      const _AndroidAppIcon(
                        name: "YouTube",
                        asset: "youtube",
                        bgColor: Colors.white,
                      ),
                      const _AndroidAppIcon(
                        name: "Drive",
                        asset: "pdf",
                        bgColor: Colors.white,
                      ),
                      const _AndroidAppIcon(
                        name: "Settings",
                        asset: "settings",
                        bgColor: Colors.grey,
                      ),
                      GestureDetector(
                        onTap: () =>
                            widget.onPlatformSwitch(TargetPlatform.iOS),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.apple,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              "Move to iOS",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // --- Bottom Dock & Search ---
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: const [
                          _AndroidAppIcon(
                            name: "",
                            asset: "phone",
                            showLabel: false,
                            bgColor: Color(0xFFE8F0FE),
                          ),
                          _AndroidAppIcon(
                            name: "",
                            asset: "messages",
                            showLabel: false,
                            bgColor: Color(0xFFE8F0FE),
                          ),
                          _AndroidAppIcon(
                            name: "",
                            asset: "chrome",
                            showLabel: false,
                            bgColor: Colors.transparent,
                          ),
                          _AndroidAppIcon(
                            name: "",
                            asset: "camera",
                            showLabel: false,
                            bgColor: Color(0xFFEFEFEF),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F1F5),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/img/android/icons/google_g.webp',
                              width: 26,
                              errorBuilder: (c, o, s) => const Text(
                                "G",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                "Search...",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 18,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                            ),
                            Image.asset(
                              'assets/img/android/icons/google_mic.png',
                              width: 24,
                              errorBuilder: (c, o, s) => const Icon(
                                Icons.mic,
                                color: Colors.blueAccent,
                              ),
                            ),
                            const SizedBox(width: 18),
                            Image.asset(
                              'assets/img/android/icons/google_lens.png',
                              width: 24,
                              errorBuilder: (c, o, s) => const Icon(
                                Icons.camera_alt,
                                color: Colors.blueAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: 48,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AndroidAppIcon extends StatelessWidget {
  final String name;
  final String asset;
  final bool showLabel;
  final Color bgColor;

  const _AndroidAppIcon({
    required this.name,
    required this.asset,
    this.showLabel = true,
    this.bgColor = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bgColor,
            boxShadow: bgColor != Colors.transparent
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          padding: bgColor != Colors.transparent
              ? const EdgeInsets.all(10)
              : EdgeInsets.zero,
          child: Image.asset(
            'assets/img/android/icons/$asset.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.android, color: Colors.green),
          ),
        ),
        if (showLabel) ...[
          const SizedBox(height: 6),
          Flexible(
            child: Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: 'Roboto',
                letterSpacing: 0.2,
                shadows: [
                  Shadow(
                    color: Colors.black54,
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }
}
