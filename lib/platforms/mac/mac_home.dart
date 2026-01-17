import 'dart:async';
import 'dart:ui'; // Required for ImageFilter (Blur)
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // ✅ Make sure flutter_svg is in pubspec.yaml
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:kevins_tech/platforms/mac/mac_dock.dart';
import 'package:kevins_tech/platforms/mac/mac_menu_bar.dart';
import 'package:kevins_tech/platforms/mac/mac_widget.dart';
import 'package:kevins_tech/platforms/mac/desktop_icon.dart';
import 'package:kevins_tech/platforms/mac/mac_finder.dart';
import 'package:kevins_tech/platforms/mac/mac_terminal.dart';
import 'apps/mac_safari.dart';
import 'apps/mac_contact.dart';
import 'apps/mac_about_me.dart';
import 'package:kevins_tech/system_apps/calculator/mac_calculator.dart';
import 'package:url_launcher/url_launcher.dart';

// ✅ Import your Weather Service
import '../../components/weather_service.dart';
import '../../components/made_with_flutter.dart';

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

  // --- Weather State ---
  final WeatherService _weatherService = WeatherService();
  String _weatherTemp = "--";
  String _weatherCity = "Cupertino";
  String _weatherCondition = "Loading";
  IconData _weatherIcon = CupertinoIcons.cloud_sun_fill;
  bool _isLoadingWeather = true;

  // --- app Openers ---

  void _openFinder() {
    _openMacWindow(const MacFinder());
  }

  void _openTerminal() {
    _openMacWindow(const MacTerminal());
  }

  void _launchSafari() {
    _openMacWindow(const MacSafari());
  }

  Future<void> _launchMail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'kevinstech0@gmail.com',
    );
    await launchUrl(emailLaunchUri);
  }

  Future<void> _launchMaps() async {
    await launchUrl(Uri.parse("https://maps.google.com"));
  }

  // ✅ Contact App
  void _openContact() {
    _openMacWindow(
      MacContact(
        onOpenAboutMe: () {
          Navigator.pop(context); // Close Contact Window
          Future.delayed(const Duration(milliseconds: 100), () {
            _openMacWindow(const MacAboutMe()); // Open About Me Window
          });
        },
      ),
    );
  }

  // ✅ UPDATED: GitHub (Launchpad Only now)
  Future<void> _launchGitHub() async {
    await launchUrl(Uri.parse("https://github.com/TechoChat"));
  }

  // ✅ NEW: LinkedIn (Launchpad Only now)
  Future<void> _launchLinkedIn() async {
    await launchUrl(Uri.parse("https://www.linkedin.com/in/techochat/"));
  }

  void _openMacWindow(Widget child) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Close",
      pageBuilder: (context, _, _) => child,
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (context, anim, _, child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * anim.value),
          child: Opacity(opacity: anim.value, child: child),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // ✅ NEW: Launchpad Implementation
  // ---------------------------------------------------------------------------
  void _openLaunchpad() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Dismiss",
      pageBuilder: (context, anim, secAnim) {
        return Stack(
          children: [
            // 1. Blurred Background
            Positioned.fill(
              child: GestureDetector(
                onTap: () =>
                    Navigator.of(context).pop(), // Tap background to close
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.3), // Dark tint
                  ),
                ),
              ),
            ),

            // 2. App Grid
            Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1000),
                padding: const EdgeInsets.all(40),
                child: GridView.count(
                  crossAxisCount: 7, // 7 apps per row (Standard Mac Layout)
                  mainAxisSpacing: 30,
                  crossAxisSpacing: 30,
                  children: [
                    _LaunchpadItem(
                      label: "Finder",
                      svgPath: "assets/img/mac/icons/finder.svg",
                      color: Colors.blueAccent,
                      onTap: () {
                        Navigator.pop(context);
                        _openFinder();
                      },
                    ),
                    _LaunchpadItem(
                      label: "Safari",
                      icon: CupertinoIcons.compass, // System Icon
                      color: Colors.blue,
                      onTap: () {
                        Navigator.pop(context);
                        _launchSafari();
                      },
                    ),
                    _LaunchpadItem(
                      label: "Mail",
                      icon: CupertinoIcons.mail_solid, // System Icon
                      color: Colors.blueAccent,
                      onTap: () {
                        Navigator.pop(context);
                        _launchMail();
                      },
                    ),
                    _LaunchpadItem(
                      label: "Terminal",
                      // adding terminal image as SVG
                      svgPath: "assets/img/mac/icons/terminal.svg",
                      color: Colors.grey[800]!,
                      onTap: () {
                        Navigator.pop(context);
                        _openTerminal();
                      },
                    ),
                    _LaunchpadItem(
                      label: "Maps",
                      icon: CupertinoIcons.map_fill, // System Icon
                      color: Colors.greenAccent,
                      onTap: () {
                        Navigator.pop(context);
                        _launchMaps();
                      },
                    ),

                    // ✅ SVG Icon: GitHub
                    _LaunchpadItem(
                      label: "GitHub",
                      svgPath: "assets/img/mac/icons/github.svg",
                      onTap: () {
                        Navigator.pop(context);
                        _launchGitHub();
                      },
                    ),

                    // ✅ SVG Icon: LinkedIn
                    _LaunchpadItem(
                      label: "LinkedIn",
                      svgPath: "assets/img/mac/icons/linkedin.svg",
                      onTap: () {
                        Navigator.pop(context);
                        _launchLinkedIn();
                      },
                    ),

                    // ✅ Contact App
                    _LaunchpadItem(
                      label: "Contact",
                      icon: CupertinoIcons.person_crop_circle,
                      color: Colors.orangeAccent,
                      onTap: () {
                        Navigator.pop(context);
                        _openContact();
                      },
                    ),
                    _LaunchpadItem(
                      label: "Calculator",
                      icon: CupertinoIcons.minus_slash_plus,
                      color: Colors.orange,
                      onTap: () {
                        Navigator.pop(context);
                        _openMacWindow(const MacCalculator());
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, anim, _, child) {
        return FadeTransition(opacity: anim, child: child);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _initBattery();
    _initConnectivity();
    _initWeather();

    _batteryStateSubscription = _battery.onBatteryStateChanged.listen((state) {
      setState(() => _batteryState = state);
      _initBattery();
    });

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      result,
    ) {
      setState(() => _connectionStatus = result);
    });
  }

  Future<void> _initWeather() async {
    final weather = await _weatherService.getWeather();
    if (mounted && weather != null) {
      setState(() {
        _weatherTemp = weather.temperature;
        _weatherCity = weather.cityName;
        _weatherCondition = weather.condition;
        _weatherIcon = _mapToCupertinoIcon(weather.iconCode);
        _isLoadingWeather = false;
      });
    }
  }

  IconData _mapToCupertinoIcon(String code) {
    switch (code) {
      case '01d':
        return CupertinoIcons.sun_max_fill;
      case '01n':
        return CupertinoIcons.moon_fill;
      case '02d':
      case '02n':
        return CupertinoIcons.cloud_sun_fill;
      default:
        return CupertinoIcons.cloud_fill;
    }
  }

  Future<void> _initBattery() async {
    try {
      final level = await _battery.batteryLevel;
      if (level > 0) {
        setState(() => _batteryLevel = level);
      } else {
        setState(() => _batteryLevel = 100);
      }
    } catch (_) {
      setState(() => _batteryLevel = 100);
    }
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
            ),
          ),

          // 2. Desktop Widgets (Left Side)
          Positioned(
            top: 40,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Battery Widget
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
                            : Colors.blueAccent,
                      ),
                      const BatteryRing(
                        percent: 1.00,
                        label: "100%",
                        icon: CupertinoIcons.headphones,
                        color: Colors.blueAccent,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                // Calendar & Weather
                Row(
                  children: [
                    MacWidgetContainer(
                      width: 140,
                      height: 140,
                      color: Colors.white.withValues(alpha: 0.95),
                      child: const CalendarWidget(),
                    ),
                    const SizedBox(width: 15),
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

          // 3. Desktop Icons
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

          // 4. Menu Bar
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

          // Made With Flutter
          Positioned(
            bottom: 125,
            left: 0,
            right: 0,
            child: const Center(child: MadeWithFlutter()),
          ),

          // 4.5 Active Window
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: MacDock(
              onOpenLaunchpad: _openLaunchpad, // ✅ Added Launchpad Trigger
              onOpenFinder: _openFinder,
              onOpenTerminal: _openTerminal,
              onOpenSafari: _launchSafari,
              onOpenMail: _launchMail,
              onOpenContact: _openContact,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// ✅ NEW: Launchpad Icon Item (Supports SVG or Flutter Icon)
// -----------------------------------------------------------------------------
class _LaunchpadItem extends StatelessWidget {
  final String label;
  final IconData? icon;
  final String? svgPath;
  final Color? color;
  final VoidCallback onTap;

  const _LaunchpadItem({
    required this.label,
    this.icon,
    this.svgPath,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              // If it's a system icon, give it a background squircle
              color: svgPath == null
                  ? (color ?? Colors.blue)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: svgPath != null
                ? SvgPicture.asset(
                    svgPath!,
                    fit: BoxFit.contain,
                  ) // ✅ Render SVG
                : Icon(
                    icon,
                    size: 36,
                    color: Colors.white,
                  ), // ✅ Render System Icon
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}
