import 'dart:ui' as ui; // Aliased for ImageFilter
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

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
                _MacWidgetContainer(
                  width: 300,
                  height: 140,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _BatteryRing(
                        percent: _batteryLevel / 100,
                        label: "$_batteryLevel%",
                        icon: _batteryState == BatteryState.charging 
                            ? CupertinoIcons.bolt_fill 
                            : CupertinoIcons.device_laptop,
                        color: _batteryState == BatteryState.charging 
                            ? const Color(0xFF52D598) 
                            : (_batteryLevel < 20 ? Colors.red : const Color(0xFF52D598)),
                      ),
                      const _BatteryRing(
                        percent: 1.00,
                        label: "100%",
                        icon: CupertinoIcons.headphones,
                        color: Colors.blueAccent,
                      ),
                      const _BatteryRing(
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
                    _MacWidgetContainer(
                      width: 140,
                      height: 140,
                      color: Colors.white.withValues(alpha: 0.95),
                      child: const _CalendarWidget(),
                    ),
                    const SizedBox(width: 15),
                    
                    // ✅ Updated Weather Widget Container
                    _MacWidgetContainer(
                      width: 140,
                      height: 140,
                      color: Colors.blue.withValues(alpha: 0.6),
                      child: _WeatherWidget(
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
                _DesktopIcon(
                  label: "Move to\nWindows",
                  icon: CupertinoIcons.device_laptop,
                  color: Colors.white,
                  onTap: () => widget.onPlatformSwitch(TargetPlatform.windows),
                ),
                const SizedBox(height: 20),
                _DesktopIcon(
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
            child: _MacMenuBar(
              batteryLevel: _batteryLevel,
              batteryState: _batteryState,
              connectionStatus: _connectionStatus,
            ),
          ),

          // 5. The Dock
          const Positioned(bottom: 10, left: 0, right: 0, child: _MacDock()),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// --- WIDGETS & COMPONENTS ---
// -----------------------------------------------------------------------------

class _MacWidgetContainer extends StatelessWidget {
  final double width;
  final double height;
  final Widget child;
  final Color? color;

  const _MacWidgetContainer({
    required this.width,
    required this.height,
    required this.child,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: width,
          height: height,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color ?? Colors.white.withValues(alpha: 0.4),
            border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
            borderRadius: BorderRadius.circular(22),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _BatteryRing extends StatelessWidget {
  final double percent;
  final String label;
  final IconData icon;
  final Color color;

  const _BatteryRing({
    required this.percent,
    required this.label,
    required this.icon,
    this.color = const Color(0xFF52D598),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                value: percent,
                strokeWidth: 4,
                backgroundColor: Colors.black12,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Icon(icon, size: 20, color: Colors.black87),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }
}

class _CalendarWidget extends StatelessWidget {
  const _CalendarWidget();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthName = _getMonthName(now.month).toUpperCase();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final firstDayOfWeek = DateTime(now.year, now.month, 1).weekday;
    final offset = firstDayOfWeek == 7 ? 0 : firstDayOfWeek;

    const fontStyle = TextStyle(
      fontFamily: '.SF Pro Text',
      decoration: TextDecoration.none,
      letterSpacing: -0.2,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6, top: 2),
          child: Text(
            monthName,
            style: fontStyle.copyWith(
              color: const Color(0xFFFF3B30),
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _WeekdayText("S"), _WeekdayText("M"), _WeekdayText("T"), _WeekdayText("W"),
              _WeekdayText("T"), _WeekdayText("F"), _WeekdayText("S"),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daysInMonth + offset,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7, mainAxisSpacing: 2, crossAxisSpacing: 2, childAspectRatio: 1.1,
            ),
            itemBuilder: (context, index) {
              if (index < offset) return const SizedBox();
              final dayNum = index - offset + 1;
              final isToday = dayNum == now.day;
              return Container(
                alignment: Alignment.center,
                decoration: isToday ? const BoxDecoration(color: Color(0xFFFF3B30), shape: BoxShape.circle) : null,
                child: Text("$dayNum", style: fontStyle.copyWith(fontSize: 10, fontWeight: isToday ? FontWeight.w700 : FontWeight.w500, color: isToday ? Colors.white : Colors.black87)),
              );
            },
          ),
        ),
      ],
    );
  }

  String _getMonthName(int month) => ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"][month - 1];
}

class _WeekdayText extends StatelessWidget {
  final String text;
  const _WeekdayText(this.text);
  @override
  Widget build(BuildContext context) => SizedBox(width: 14, child: Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black45, fontSize: 8, fontWeight: FontWeight.w600, decoration: TextDecoration.none, fontFamily: '.SF Pro Text')));
}

// ✅ UPDATED Weather Widget to Accept Data
class _WeatherWidget extends StatelessWidget {
  final String temp;
  final String city;
  final String condition;
  final IconData icon;
  final bool isLoading;

  const _WeatherWidget({
    required this.temp,
    required this.city,
    required this.condition,
    required this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CupertinoActivityIndicator(color: Colors.white));
    }

    // Mock High/Low based on current temp for display purposes
    final int t = int.tryParse(temp) ?? 20;
    final String highLow = "H:${t + 5}° L:${t - 4}°";

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            city, 
            style: const TextStyle(color: Colors.white, fontSize: 12, decoration: TextDecoration.none),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            "$temp°", 
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w300, decoration: TextDecoration.none)
          ),
          const SizedBox(height: 4),
          Icon(icon, color: Colors.yellowAccent, size: 20),
          const SizedBox(height: 4),
          Text(
            condition, 
            style: const TextStyle(color: Colors.white70, fontSize: 10, decoration: TextDecoration.none),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            highLow, 
            style: const TextStyle(color: Colors.white70, fontSize: 10, decoration: TextDecoration.none)
          ),
        ],
      ),
    );
  }
}

class _DesktopIcon extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DesktopIcon({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  State<_DesktopIcon> createState() => _DesktopIconState();
}

class _DesktopIconState extends State<_DesktopIcon> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Container(
          width: 85,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _isHovered ? Colors.white.withValues(alpha: 0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: _isHovered ? Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1) : Border.all(color: Colors.transparent),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 48, color: widget.color),
              const SizedBox(height: 4),
              Text(widget.label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500, shadows: [Shadow(color: Colors.black, blurRadius: 4)], decoration: TextDecoration.none)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MacMenuBar extends StatefulWidget {
  final int batteryLevel;
  final BatteryState batteryState;
  final List<ConnectivityResult> connectionStatus;

  const _MacMenuBar({
    required this.batteryLevel,
    required this.batteryState,
    required this.connectionStatus,
  });

  @override
  State<_MacMenuBar> createState() => _MacMenuBarState();
}

class _MacMenuBarState extends State<_MacMenuBar> {
  late Timer _timer;
  late String _timeString;

  @override
  void initState() {
    super.initState();
    _timeString = _formatDateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => _getTime());
  }

  void _getTime() {
    final String formattedDateTime = _formatDateTime();
    if (_timeString != formattedDateTime) {
      setState(() => _timeString = formattedDateTime);
    }
  }

  String _formatDateTime() => DateFormat('E MMM d  h:mm a').format(DateTime.now());

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  IconData _getNetworkIcon() {
    if (widget.connectionStatus.contains(ConnectivityResult.ethernet)) return CupertinoIcons.link;
    if (widget.connectionStatus.contains(ConnectivityResult.wifi)) return CupertinoIcons.wifi;
    if (widget.connectionStatus.contains(ConnectivityResult.mobile)) return CupertinoIcons.antenna_radiowaves_left_right;
    return CupertinoIcons.wifi_slash;
  }

  IconData _getBatteryIcon() {
    if (widget.batteryState == BatteryState.charging) return CupertinoIcons.battery_charging;
    if (widget.batteryLevel >= 100) return CupertinoIcons.battery_100;
    if (widget.batteryLevel >= 25) return CupertinoIcons.battery_25;
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
              const _MenuText("Finder"),
              const _MenuText("File"),
              const _MenuText("Edit"),
              const _MenuText("View"),
              const _MenuText("Go"),
              const _MenuText("Window"),
              const _MenuText("Help"),
              const Spacer(),
              Icon(_getNetworkIcon(), size: 16, color: Colors.white),
              const SizedBox(width: 15),
              Row(
                children: [
                  Text("${widget.batteryLevel}%", style: const TextStyle(color: Colors.white, fontSize: 13, decoration: TextDecoration.none, fontWeight: FontWeight.w500)),
                  const SizedBox(width: 6),
                  Icon(_getBatteryIcon(), size: 18, color: widget.batteryLevel < 20 && widget.batteryState != BatteryState.charging ? Colors.redAccent : Colors.white),
                ],
              ),
              const SizedBox(width: 15),
              _MenuText(_timeString),
              const SizedBox(width: 15),
              const Icon(CupertinoIcons.control, size: 16, color: Colors.white),
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
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(right: 16), child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500, decoration: TextDecoration.none)));
}

class _MacDock extends StatelessWidget {
  const _MacDock();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1.5),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 15, spreadRadius: -5, offset: const Offset(0, 10))],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const _DockIcon("assets/img/mac/icons/finder.png", "Finder"),
                const _DockIcon("assets/img/mac/icons/launchpad.png", "Launchpad"),
                const _DockIcon("assets/img/mac/icons/safari.png", "Safari"),
                const _DockIcon("assets/img/mac/icons/messages.png", "Messages"),
                const _DockIcon("assets/img/mac/icons/mail.png", "Mail"),
                const _DockIcon("assets/img/mac/icons/maps.png", "Maps"),
                const _DockIcon("assets/img/mac/icons/photos.png", "Photos"),
                const _DockIcon("assets/img/mac/icons/settings.png", "Settings"),
                const SizedBox(width: 10),
                Container(width: 1, height: 40, color: Colors.white30, margin: const EdgeInsets.only(bottom: 5)),
                const SizedBox(width: 10),
                const _DockIcon("assets/img/mac/icons/bin.png", "Bin"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DockIcon extends StatefulWidget {
  final String? imagePath;
  final String label;
  const _DockIcon(this.imagePath, this.label);
  @override
  State<_DockIcon> createState() => _DockIconState();
}

class _DockIconState extends State<_DockIcon> {
  bool _isHovered = false;
  @override
  Widget build(BuildContext context) {
    final double size = _isHovered ? 65 : 50;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Tooltip(
        message: widget.label,
        preferBelow: false,
        verticalOffset: 60,
        decoration: const ShapeDecoration(
          color: Color(0xFF2C2C2C),
          shape: _TooltipShape(), // Fixed const warning
        ),
        textStyle: const TextStyle(color: Colors.white, fontSize: 12),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          width: size,
          height: size,
          margin: EdgeInsets.symmetric(horizontal: _isHovered ? 4 : 8, vertical: _isHovered ? 0 : 8),
          child: Image.asset(
            widget.imagePath!,
            width: size,
            height: size,
            fit: BoxFit.contain,
            errorBuilder: (c, o, s) => const Icon(Icons.apps, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}

// ✅ FIXED: Removed unused constructor parameters to clear warnings
class _TooltipShape extends ShapeBorder {
  static const double arrowHeight = 5;
  static const double arrowWidth = 10;
  static const double radius = 6;

  const _TooltipShape();

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.only(bottom: arrowHeight);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path();

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    rect = Rect.fromPoints(rect.topLeft, rect.bottomRight - const Offset(0, arrowHeight));
    return Path()
      ..moveTo(rect.left + radius, rect.top)
      ..lineTo(rect.right - radius, rect.top)
      ..arcToPoint(Offset(rect.right, rect.top + radius), radius: const Radius.circular(radius))
      ..lineTo(rect.right, rect.bottom - radius)
      ..arcToPoint(Offset(rect.right - radius, rect.bottom), radius: const Radius.circular(radius))
      ..lineTo(rect.center.dx + arrowWidth / 2, rect.bottom)
      ..lineTo(rect.center.dx, rect.bottom + arrowHeight)
      ..lineTo(rect.center.dx - arrowWidth / 2, rect.bottom)
      ..lineTo(rect.left + radius, rect.bottom)
      ..arcToPoint(Offset(rect.left, rect.bottom - radius), radius: const Radius.circular(radius))
      ..lineTo(rect.left, rect.top + radius)
      ..arcToPoint(Offset(rect.left + radius, rect.top), radius: const Radius.circular(radius))
      ..close();
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
}