import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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

  // Weather State
  final WeatherService _weatherService = WeatherService();
  String _weatherTemp = "--";
  IconData _weatherIcon = Icons.cloud_sync;
  String _weatherCity = "";
  bool _isLoadingWeather = true;

  @override
  void initState() {
    super.initState();
    _initWeather();

    // Clock for the "At a Glance" widget date
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _currentTime = DateTime.now());
    });
  }

  // --- OPEN SEARCH PAGE ---
  void _openSearchPage() {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) {
          return const GoogleSearchPage();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  // --- Weather Logic ---
  Future<void> _initWeather() async {
    final weather = await _weatherService.getWeather();
    if (mounted && weather != null) {
      setState(() {
        _weatherTemp = weather.temperature;
        _weatherIcon = _weatherService.getWeatherIcon(weather.iconCode);
        _weatherCity = weather.cityName;
        _isLoadingWeather = false;
      });
    } else if (mounted) {
      setState(() {
        _weatherTemp = "24";
        _weatherIcon = Icons.cloud;
        _isLoadingWeather = false;
      });
    }
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Wallpaper
            Positioned.fill(
              child: Image.asset(
                'assets/img/android/android.webp',
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
                opacity: const AlwaysStoppedAnimation(0.7),
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
                  // ✅ REUSABLE STATUS BAR (White for Home)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: AndroidStatusBar(iconColor: Colors.white),
                  ),

                  // "At A Glance" Widget
                  Padding(
                    padding: const EdgeInsets.only(top: 10, left: 24),
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
                        Row(
                          children: [
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
                              "$_weatherTemp°C in $_weatherCity",
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

                  const Spacer(),

                  // App Grid
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
                          child: const _AndroidAppIcon(
                            name: "Acrobat", // Renamed from "Drive" for clarity
                            asset:
                                "pdf", // Ensure 'pdf.png' exists in assets/img/android/icons/
                            bgColor: Colors.white,
                          ),
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

                  // Bottom Dock & Search
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

                        // Search Bar
                        GestureDetector(
                          onTap: _openSearchPage,
                          child: Hero(
                            tag: 'search_bar_hero',
                            child: Material(
                              color: Colors.transparent,
                              child: Container(
                                height: 52,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0F1F5),
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.12,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
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
                            ),
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
      ),
    );
  }
}

// ---------------------------------------------------------
// ✅ REUSABLE STATUS BAR WIDGET
// ---------------------------------------------------------
class AndroidStatusBar extends StatefulWidget {
  final Color iconColor;
  const AndroidStatusBar({super.key, required this.iconColor});

  @override
  State<AndroidStatusBar> createState() => _AndroidStatusBarState();
}

class _AndroidStatusBarState extends State<AndroidStatusBar> {
  late Timer _timer;
  DateTime _time = DateTime.now();

  // Battery
  final Battery _battery = Battery();
  int _batteryLevel = 100;
  BatteryState _batteryState = BatteryState.unknown;
  StreamSubscription? _batterySub;

  // Network
  final Connectivity _connectivity = Connectivity();
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  StreamSubscription? _connectivitySub;

  @override
  void initState() {
    super.initState();
    _initBattery();
    _initConnectivity();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() => _time = DateTime.now()),
    );

    _batterySub = _battery.onBatteryStateChanged.listen(
      (state) => setState(() => _batteryState = state),
    );
    _connectivitySub = _connectivity.onConnectivityChanged.listen(
      (res) => setState(() => _connectionStatus = res),
    );
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
    _timer.cancel();
    _batterySub?.cancel();
    _connectivitySub?.cancel();
    super.dispose();
  }

  IconData _getBatteryIcon() {
    if (_batteryState == BatteryState.charging) {
      return Icons.battery_charging_full;
    }
    if (_batteryLevel >= 95) return Icons.battery_full;
    if (_batteryLevel >= 80) return Icons.battery_6_bar;
    if (_batteryLevel >= 60) return Icons.battery_5_bar;
    if (_batteryLevel >= 40) return Icons.battery_4_bar;
    if (_batteryLevel >= 20) return Icons.battery_2_bar;
    return Icons.battery_alert;
  }

  IconData _getNetworkIcon() {
    if (_connectionStatus.contains(ConnectivityResult.wifi)) return Icons.wifi;
    if (_connectionStatus.contains(ConnectivityResult.mobile)) {
      return Icons.signal_cellular_alt;
    }
    return Icons.signal_cellular_connected_no_internet_4_bar;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          DateFormat('h:mm a').format(_time),
          style: TextStyle(
            color: widget.iconColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
          ),
        ),
        Row(
          children: [
            Icon(_getNetworkIcon(), color: widget.iconColor, size: 18),
            const SizedBox(width: 8),
            Icon(_getBatteryIcon(), color: widget.iconColor, size: 18),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------
// ✅ SEARCH PAGE (With Status Bar)
// ---------------------------------------------------------
class GoogleSearchPage extends StatefulWidget {
  const GoogleSearchPage({super.key});

  @override
  State<GoogleSearchPage> createState() => _GoogleSearchPageState();
}

class _GoogleSearchPageState extends State<GoogleSearchPage> {
  final TextEditingController _controller = TextEditingController();

  Future<void> _launchGoogleSearch(String query) async {
    if (query.trim().isEmpty) return;
    final Uri url = Uri.https('www.google.com', '/search', {'q': query});
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
          webOnlyWindowName: '_blank',
        );
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F1F5),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ✅ REUSABLE STATUS BAR (Black for Search Page)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: AndroidStatusBar(iconColor: Colors.black),
              ),

              const SizedBox(height: 8),

              // --- HERO SEARCH BAR ---
              Hero(
                tag: 'search_bar_hero',
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.grey,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            autofocus: true,
                            textInputAction: TextInputAction.search,
                            decoration: const InputDecoration(
                              hintText: "Search Google...",
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(bottom: 4),
                            ),
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                            onSubmitted: _launchGoogleSearch,
                          ),
                        ),
                        if (_controller.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.grey),
                            onPressed: () =>
                                setState(() => _controller.clear()),
                          )
                        else
                          IconButton(
                            icon: const Icon(Icons.mic, color: Colors.blue),
                            onPressed: () {},
                          ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                ),
              ),

              // --- RECENT SEARCHES ---
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  children: [
                    Text(
                      "RECENT SEARCHES",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildHistoryItem("Flutter web new tab"),
                    _buildHistoryItem("Android weather widget"),
                    _buildHistoryItem("Best pizza in town"),
                    _buildHistoryItem("How to use hero animation"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(String text) {
    return InkWell(
      onTap: () => _launchGoogleSearch(text),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            const Icon(Icons.history, color: Colors.grey, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
            const Icon(Icons.north_west, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }
}

// --- App Icon Component ---
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
