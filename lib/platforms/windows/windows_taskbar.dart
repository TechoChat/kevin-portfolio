import 'dart:async';
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:kevins_tech/platforms/windows/window_control.dart';
import 'package:kevins_tech/platforms/windows/windows_terminal.dart';
import 'package:universal_html/html.dart' as html;
import '../../components/weather_service.dart';
import 'package:url_launcher/url_launcher.dart';

class WindowsTaskbar extends StatefulWidget {
  final VoidCallback onStartMenuTap;

  const WindowsTaskbar({super.key, required this.onStartMenuTap});

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

  // --- Weather State ---
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
    _initWeather();

    _batteryStateSubscription = _battery.onBatteryStateChanged.listen((
      BatteryState state,
    ) {
      setState(() => _batteryState = state);
    });

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> result,
    ) {
      setState(() => _connectionStatus = result);
    });
  }

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

  Future<void> _openMail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'kevinstech0@gmail.com',
      query: 'subject=Inquiry&body=Hello, I would like to reach out...',
    );

    if (!await launchUrl(emailLaunchUri)) {
      debugPrint("Could not launch email client");
    }
  }

  void _openSearchWindow() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Close",
      pageBuilder: (context, _, _) => const WindowsBrowser(),
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (context, anim, _, child) {
        return Transform.scale(
          scale: anim.value,
          child: Opacity(opacity: anim.value, child: child),
        );
      },
    );
  }

  void _openTerminalWindow() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Close",
      pageBuilder: (context, _, _) => const WindowsTerminal(),
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (context, anim, _, child) {
        return Transform.scale(
          scale: anim.value,
          child: Opacity(opacity: anim.value, child: child),
        );
      },
    );
  }

  @override
  void dispose() {
    _batteryStateSubscription?.cancel();
    _connectivitySubscription?.cancel();
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
    if (_connectionStatus.contains(ConnectivityResult.ethernet)) {
      return Icons.settings_ethernet;
    }
    if (_connectionStatus.contains(ConnectivityResult.wifi)) return Icons.wifi;
    if (_connectionStatus.contains(ConnectivityResult.mobile)) {
      return Icons.signal_cellular_4_bar;
    }
    return Icons.public_off;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF202020).withValues(alpha: 0.85),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          // 1. LEFT SIDE: Weather Widget
          if (!_isLoadingWeather)
            _TaskbarWeather(
              temp: _weatherTemp,
              condition: _weatherCondition,
              icon: _weatherIcon,
            ),

          const Spacer(),

          // 2. CENTER: Start Button, Search, Terminal & Outlook
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
                onTap: _openSearchWindow,
              ),
              const SizedBox(width: 8),

              // ✅ UPDATED: Terminal Image Icon
              _TaskbarIcon(
                assetPath: "assets/img/windows/icons/terminal.png",
                onTap: _openTerminalWindow,
              ),

              const SizedBox(width: 8),

              // ✅ UPDATED: Email Image Icon
              _TaskbarIcon(
                assetPath: "assets/img/windows/icons/email.png",
                onTap: _openMail,
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
                message: _connectionStatus.contains(ConnectivityResult.none)
                    ? "Not Connected"
                    : "Connected",
                child: Icon(_getNetworkIcon(), color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.volume_up, color: Colors.white, size: 20),
              const SizedBox(width: 12),

              Tooltip(
                message:
                    "$_batteryLevel% ${_batteryState == BatteryState.charging ? '(Charging)' : ''}",
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
// Weather Widget
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
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: _isHovered
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(widget.icon, color: Colors.orangeAccent, size: 24),
            const SizedBox(width: 8),
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
                  widget.condition,
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
// ✅ UPDATED HELPER: _TaskbarIcon (Supports both IconData and Images)
// -----------------------------------------------------------------------------

class _TaskbarIcon extends StatefulWidget {
  final IconData? icon; // Optional Icon
  final String? assetPath; // Optional Image Path
  final Color? color; // Optional Color (for Icons)
  final VoidCallback onTap;

  const _TaskbarIcon({
    this.icon,
    this.assetPath,
    this.color,
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
          // Center content
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _isHovered
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: widget.assetPath != null
              // If assetPath is provided, use Image
              ? Image.asset(
                  widget.assetPath!,
                  width: 26,
                  height: 26,
                  fit: BoxFit.contain,
                )
              // Otherwise, use Icon
              : Icon(
                  widget.icon,
                  color: widget.color ?? Colors.white,
                  size: 26,
                ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Clock
// -----------------------------------------------------------------------------
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

// -----------------------------------------------------------------------------
// Browser Window
// -----------------------------------------------------------------------------
class WindowsBrowser extends StatefulWidget {
  const WindowsBrowser({super.key});

  @override
  State<WindowsBrowser> createState() => _WindowsBrowserState();
}

class _WindowsBrowserState extends State<WindowsBrowser> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _urlFocusNode = FocusNode();

  bool _isMaximized = false;
  bool _isUrlFocused = false;
  String? _currentUrl;
  Key _key = UniqueKey();

  @override
  void initState() {
    super.initState();
    _urlFocusNode.addListener(() {
      setState(() {
        _isUrlFocused = _urlFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _urlFocusNode.dispose();
    super.dispose();
  }

  void _navigateTo(String query) {
    if (query.trim().isEmpty) return;

    String url;
    if (query.startsWith('http')) {
      url = query;
    } else {
      url = "https://www.google.com/search?q=$query&igu=1";
    }

    setState(() {
      _currentUrl = url;
      _searchController.text = url;
      _key = UniqueKey();
    });
    _urlFocusNode.unfocus();
  }

  void _goHome() {
    setState(() {
      _currentUrl = null;
      _searchController.clear();
    });
  }

  void _reloadPage() {
    if (_currentUrl != null) {
      setState(() => _key = UniqueKey());
    }
  }

  void _toggleMaximize() {
    setState(() {
      _isMaximized = !_isMaximized;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: _isMaximized ? size.width : 900,
          height: _isMaximized ? size.height : 600,
          decoration: BoxDecoration(
            color: const Color(0xFF202020),
            borderRadius: _isMaximized
                ? BorderRadius.zero
                : BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 20,
              ),
            ],
            border: Border.all(
              color: Colors.white24,
              width: _isMaximized ? 0 : 1,
            ),
          ),
          child: Column(
            children: [
              // Browser Title/Address Bar
              Container(
                height: 45,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: const BoxDecoration(
                  color: Color(0xFF2B2B2B),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                ),
                child: Row(
                  children: [
                    WindowControl(icon: Icons.arrow_back, onTap: _goHome),
                    WindowControl(icon: Icons.refresh, onTap: _reloadPage),
                    const SizedBox(width: 8),

                    Expanded(
                      child: Container(
                        height: 30,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: _isUrlFocused
                                ? Colors.blueAccent
                                : Colors.white12,
                            width: 1.5,
                          ),
                        ),
                        child: TextField(
                          controller: _searchController,
                          focusNode: _urlFocusNode,
                          cursorColor: Colors.white,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              Icons.lock_outline,
                              color: Colors.green,
                              size: 14,
                            ),
                            hintText: "Search Google or type a URL",
                            hintStyle: TextStyle(color: Colors.white24),
                            contentPadding: EdgeInsets.only(bottom: 14),
                          ),
                          onSubmitted: _navigateTo,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    WindowControl(
                      icon: Icons.minimize,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    WindowControl(
                      icon: _isMaximized
                          ? Icons.filter_none
                          : Icons.crop_square,
                      onTap: _toggleMaximize,
                    ),
                    WindowControl(
                      icon: Icons.close,
                      color: Colors.redAccent,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // Browser Body
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(_isMaximized ? 0 : 8),
                  ),
                  child: _currentUrl == null
                      ? _buildHomeScreen()
                      : _buildWebView(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeScreen() {
    return Container(
      color: const Color(0xFF202020),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Google",
            style: TextStyle(
              color: Colors.white,
              fontSize: 56,
              fontWeight: FontWeight.bold,
              letterSpacing: -2,
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: 500,
            child: TextField(
              controller: _searchController,
              cursorColor: Colors.white,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF303030),
                hintText: "Search Google or type a URL",
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: _navigateTo,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebView() {
    final viewId = 'iframe-view-${_currentUrl.hashCode}';

    try {
      ui_web.platformViewRegistry.registerViewFactory(viewId, (int viewId) {
        final iframe = html.IFrameElement();
        iframe.src = _currentUrl!;
        iframe.style.height = '100%';
        iframe.style.width = '100%';
        iframe.style.border = 'none';
        return iframe;
      });
    } catch (_) {}

    return HtmlElementView(key: _key, viewType: viewId);
  }
}
