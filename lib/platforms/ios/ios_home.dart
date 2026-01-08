import 'dart:ui' as ui; // For ImageFilter
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:kevins_tech/platforms/ios/ios_status_bar.dart';
import 'package:kevins_tech/platforms/ios/ios_widget.dart';
import 'package:url_launcher/url_launcher.dart';

// ✅ Import your Weather Service
import '../../components/weather_service.dart';
import 'apps/ios_app_store.dart';
import '../../components/made_with_flutter.dart';

import 'apps/ios_safari.dart';
import 'apps/ios_settings.dart';
import 'apps/ios_terminal.dart';
import 'apps/ios_contact.dart';
import 'ios_app_library.dart';

class IosHome extends StatefulWidget {
  final ValueChanged<TargetPlatform> onPlatformSwitch;

  const IosHome({super.key, required this.onPlatformSwitch});

  @override
  State<IosHome> createState() => _IosHomeState();
}

class _IosHomeState extends State<IosHome> {
  // --- Battery State ---
  final Battery _battery = Battery();
  BatteryState _batteryState = BatteryState.unknown;
  int _batteryLevel = 100;
  StreamSubscription<BatteryState>? _batteryStateSubscription;

  // --- Network State ---
  final Connectivity _connectivity = Connectivity();
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  // --- Weather State ---
  final WeatherService _weatherService = WeatherService();
  String _weatherTemp = "--";
  String _weatherCity = "Loading...";
  String _weatherCondition = "Cloudy"; // Default text
  String _weatherHighLow =
      "H:-- L:--"; // We don't get H/L from current API easily, so we can mock or hide
  bool _isLoadingWeather = true;

  @override
  void initState() {
    super.initState();
    _initBattery();
    _initConnectivity();
    _initWeather();

    // Listeners
    _batteryStateSubscription = _battery.onBatteryStateChanged.listen((state) {
      setState(() => _batteryState = state);
      _initBattery();
    });
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (result) => setState(() => _connectionStatus = result),
    );
  }

  Future<void> _initWeather() async {
    final weather = await _weatherService.getWeather();
    if (mounted && weather != null) {
      setState(() {
        _weatherTemp = weather.temperature;
        _weatherCity = weather.cityName;
        _weatherCondition = weather.condition;
        // Mocking High/Low since current API call only gives 'current' temp
        // You would need the 'One Call API' for daily forecast
        _weatherHighLow =
            "H:${(int.parse(weather.temperature) + 5)}° L:${(int.parse(weather.temperature) - 3)}°";
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

  void _openApp(Widget app) {
    Navigator.of(context).push(CupertinoPageRoute(builder: (context) => app));
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 1. Wallpaper
          Positioned.fill(
            child: Image.asset(
              'assets/img/ios/iphone.webp',
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2E8B57), Color(0xFF87CEEB)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),

          // 2. Main Content
          SafeArea(
            top: false,
            bottom: false,
            child: Column(
              children: [
                // --- STATUS BAR (Dynamic) ---
                Padding(
                  padding: const EdgeInsets.only(
                    top: 15,
                    left: 24,
                    right: 24,
                    bottom: 10,
                  ),
                  child: IosStatusBar(
                    batteryLevel: _batteryLevel,
                    batteryState: _batteryState,
                    connectionStatus: _connectionStatus,
                  ),
                ),

                // --- PAGE VIEW (Home Screens + App Library) ---
                Expanded(
                  child: PageView(
                    children: [
                      // Page 1: Main Home Screen
                      Column(
                        children: [
                          // --- TOP WIDGETS ROW ---
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // ✅ Dynamic Weather Widget
                                IosWidgetContainer(
                                  width: size.width * 0.43,
                                  height: size.width * 0.43,
                                  color: const Color(0xFF1C6BC8),
                                  child: WeatherWidget(
                                    temp: _weatherTemp,
                                    city: _weatherCity,
                                    condition: _weatherCondition,
                                    highLow: _weatherHighLow,
                                    isLoading: _isLoadingWeather,
                                  ),
                                ),

                                // Map Widget (Still Static/Mocked for now)
                                IosWidgetContainer(
                                  width: size.width * 0.43,
                                  height: size.width * 0.43,
                                  color: Colors.white.withValues(alpha: 0.8),
                                  child: MapWidget(
                                    city: _weatherCity,
                                  ), // Pass city name to map too
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 25),

                          // --- APP GRID ---
                          Expanded(
                            child: GridView.count(
                              crossAxisCount: 4,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              mainAxisSpacing: 20,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.75,
                              physics: const BouncingScrollPhysics(),
                              children: [
                                AppIcon(
                                  name: "Mail",
                                  color: Colors.blue,
                                  icon: CupertinoIcons.mail_solid,
                                  onTap: () =>
                                      _launchURL("mailto:contact@techo.chat"),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    const url =
                                        'https://drive.google.com/file/d/1_YtPDqTXcC_eBlAPqsHSq3G1n_2_MJPs/view?usp=sharing';
                                    if (await canLaunchUrl(Uri.parse(url))) {
                                      await launchUrl(
                                        Uri.parse(url),
                                        mode: LaunchMode.externalApplication,
                                      );
                                    }
                                  },
                                  child: AppIcon(
                                    name: "Acrobat",
                                    color: Colors.yellow.shade100,
                                    icon: CupertinoIcons.doc_text_fill,
                                    iconColor: Colors.orange,
                                  ),
                                ),
                                AppIcon(
                                  name: "Clock",
                                  color: Colors.white,
                                  icon: CupertinoIcons.clock,
                                  isWhite: true,
                                  iconColor: Colors.black,
                                ),
                                AppIcon(
                                  name: "Terminal",
                                  color: Colors.black,
                                  icon: CupertinoIcons.command,
                                  onTap: () => _openApp(const IosTerminal()),
                                ),
                                AppIcon(
                                  name: "App Store",
                                  color: Colors.blueAccent,
                                  icon: CupertinoIcons.app_badge_fill,
                                  onTap: () => _openApp(const IosAppStore()),
                                ),

                                AppIcon(
                                  name: "Maps",
                                  color: Colors.greenAccent,
                                  icon: CupertinoIcons.location_fill,
                                  onTap: () =>
                                      _launchURL("https://maps.google.com"),
                                ),
                                AppIcon(
                                  name: "LinkedIn",
                                  color: const Color(0xFF0077B5),
                                  icon: CupertinoIcons.briefcase_fill,
                                  onTap: () => _launchURL(
                                    "https://www.linkedin.com/in/techochat/",
                                  ),
                                ),
                                AppIcon(
                                  name: "Settings",
                                  color: Colors.grey,
                                  icon: CupertinoIcons.settings,
                                  onTap: () => _openApp(
                                    IosSettings(
                                      onPlatformSwitch: widget.onPlatformSwitch,
                                    ),
                                  ),
                                ),

                                // Switch Button
                                GestureDetector(
                                  onTap: () => widget.onPlatformSwitch(
                                    TargetPlatform.android,
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.android,
                                          color: Colors.green,
                                          size: 35,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      const Text(
                                        "Switch OS",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontFamily: '.SF Pro Text',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // --- MADE WITH CAPSULE ---
                          const MadeWithFlutter(),

                          const SizedBox(height: 15),

                          // --- DOCK ---
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(35),
                              child: BackdropFilter(
                                filter: ui.ImageFilter.blur(
                                  sigmaX: 20,
                                  sigmaY: 20,
                                ),
                                child: Container(
                                  height: 95,
                                  width: double.infinity,
                                  color: Colors.white.withValues(alpha: 0.25),
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    18,
                                    16,
                                    18,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      AppIcon(
                                        name: "",
                                        color: Colors.grey,
                                        icon: CupertinoIcons
                                            .person_crop_circle_fill,
                                        showLabel: false,
                                        onTap: () =>
                                            _openApp(const IosContact()),
                                      ),
                                      AppIcon(
                                        name: "",
                                        color: Colors.blue,
                                        icon: CupertinoIcons.compass,
                                        showLabel: false,
                                        onTap: () =>
                                            _openApp(const IosSafari()),
                                      ),
                                      AppIcon(
                                        name: "",
                                        color: Colors.green,
                                        icon: CupertinoIcons.chat_bubble_fill,
                                        showLabel: false,
                                        onTap: () => _launchURL("sms:"),
                                      ),
                                      AppIcon(
                                        name: "",
                                        color: Colors.red,
                                        icon: CupertinoIcons.music_note_2,
                                        showLabel: false,
                                        onTap: () {},
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),

                      // Page 2: App Library (Drawer)
                      IosAppLibrary(onPlatformSwitch: widget.onPlatformSwitch),
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
