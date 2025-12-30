import 'dart:ui' as ui; // Aliased for ImageFilter
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:async';
// ✅ CRITICAL FIX: Hide TextDirection from intl to prevent conflict with Flutter's TextDirection
import 'package:intl/intl.dart' hide TextDirection;

class MacHome extends StatefulWidget {
  final ValueChanged<TargetPlatform> onPlatformSwitch;

  const MacHome({super.key, required this.onPlatformSwitch});

  @override
  State<MacHome> createState() => _MacHomeState();
}

class _MacHomeState extends State<MacHome> {
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
                    children: const [
                      _BatteryRing(
                        percent: 0.78,
                        label: "78%",
                        icon: CupertinoIcons.device_laptop,
                      ),
                      _BatteryRing(
                        percent: 1.00,
                        label: "100%",
                        icon: CupertinoIcons.headphones,
                      ),
                      _BatteryRing(
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
                    _MacWidgetContainer(
                      width: 140,
                      height: 140,
                      color: Colors.blue.withValues(alpha: 0.6),
                      child: const _WeatherWidget(),
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
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 28,
            child: _MacMenuBar(),
          ),

          // 5. The Dock (Bottom)
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
    super.key,
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
    super.key,
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
  const _CalendarWidget({super.key});

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
              _WeekdayText("S"),
              _WeekdayText("M"),
              _WeekdayText("T"),
              _WeekdayText("W"),
              _WeekdayText("T"),
              _WeekdayText("F"),
              _WeekdayText("S"),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daysInMonth + offset,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
              childAspectRatio: 1.1,
            ),
            itemBuilder: (context, index) {
              if (index < offset) return const SizedBox();

              final dayNum = index - offset + 1;
              final isToday = dayNum == now.day;

              return Container(
                alignment: Alignment.center,
                decoration: isToday
                    ? const BoxDecoration(
                        color: Color(0xFFFF3B30),
                        shape: BoxShape.circle,
                      )
                    : null,
                child: Text(
                  "$dayNum",
                  style: fontStyle.copyWith(
                    fontSize: 10,
                    fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                    color: isToday ? Colors.white : Colors.black87,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      "JAN",
      "FEB",
      "MAR",
      "APR",
      "MAY",
      "JUN",
      "JUL",
      "AUG",
      "SEP",
      "OCT",
      "NOV",
      "DEC",
    ];
    return months[month - 1];
  }
}

class _WeekdayText extends StatelessWidget {
  final String text;
  const _WeekdayText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 14,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.black45,
          fontSize: 8,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.none,
          fontFamily: '.SF Pro Text',
        ),
      ),
    );
  }
}

class _WeatherWidget extends StatelessWidget {
  const _WeatherWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            "Cupertino",
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              decoration: TextDecoration.none,
            ),
          ),
          Text(
            "78°",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w300,
              decoration: TextDecoration.none,
            ),
          ),
          SizedBox(height: 4),
          Icon(CupertinoIcons.cloud_sun_fill, color: Colors.yellow, size: 20),
          SizedBox(height: 4),
          Text(
            "Mostly Sunny",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10,
              decoration: TextDecoration.none,
            ),
          ),
          Text(
            "H:86° L:60°",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10,
              decoration: TextDecoration.none,
            ),
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

  const _DesktopIcon({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    super.key,
  });

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
            color: _isHovered
                ? Colors.white.withValues(alpha: 0.2) // Fixed consistency
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: _isHovered
                ? Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  )
                : Border.all(color: Colors.transparent),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 48, color: widget.color),
              const SizedBox(height: 4),
              Text(
                widget.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MacMenuBar extends StatefulWidget {
  const _MacMenuBar({super.key});

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
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer t) => _getTime(),
    );
  }

  void _getTime() {
    final String formattedDateTime = _formatDateTime();
    if (_timeString != formattedDateTime) {
      setState(() {
        _timeString = formattedDateTime;
      });
    }
  }

  String _formatDateTime() {
    return DateFormat('E MMM d  h:mm a').format(DateTime.now());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
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
              const Icon(CupertinoIcons.wifi, size: 16, color: Colors.white),
              const SizedBox(width: 15),
              const Icon(
                CupertinoIcons.battery_100,
                size: 16,
                color: Colors.white,
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
  const _MenuText(this.text, {super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
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
}

class _MacDock extends StatelessWidget {
  const _MacDock({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            // 3. REDUCE PADDING
            // Original was (horizontal: 16, vertical: 12) -> too tall
            // New: tighter vertical padding to make icons fill the bar
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),

            decoration: BoxDecoration(
              // 4. LIGHTER BACKGROUND & SUBTLE BORDER
              color: Colors.white.withValues(alpha: 0.2), // Keep translucent
              borderRadius: BorderRadius.circular(24),
              // Make the border much fainter (alpha 0.1 instead of 0.2)
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1.5,
              ),
              // Optional: Add a subtle shadow to the DOCK ITSELF, not the icons
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 15,
                  spreadRadius: -5,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const _DockIcon(
                  "assets/img/mac/icons/finder.png",
                  // Colors.blue,
                  "Finder",
                ),
                const _DockIcon(
                  // CupertinoIcons.rocket_fill,
                  "assets/img/mac/icons/launchpad.png",
                  // Colors.grey,
                  "Launchpad",
                ),
                const _DockIcon(
                  // CupertinoIcons.compass,
                  "assets/img/mac/icons/safari.png",
                  // Colors.blueAccent,
                  "Safari",
                ),
                const _DockIcon(
                  // CupertinoIcons.chat_bubble_fill,
                  "assets/img/mac/icons/messages.png",
                  // Colors.green,
                  "Messages",
                ),
                const _DockIcon(
                  "assets/img/mac/icons/mail.png",
                  // Colors.blue,
                  "Mail",
                ),
                const _DockIcon(
                  // CupertinoIcons.map_fill,
                  "assets/img/mac/icons/maps.png",
                  // Colors.greenAccent,
                  "Maps",
                ),
                const _DockIcon(
                  "assets/img/mac/icons/photos.png",
                  // Colors.pink,
                  "Photos",
                ),
                const _DockIcon(
                  // CupertinoIcons.settings,
                  "assets/img/mac/icons/settings.png",
                  // Colors.grey,
                  "Settings",
                ),
                const SizedBox(width: 10),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white30,
                  margin: const EdgeInsets.only(bottom: 5),
                ),
                const SizedBox(width: 10),
                const _DockIcon(
                  "assets/img/mac/icons/bin.png",
                  // Colors.grey,
                  "Bin",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DockIcon extends StatefulWidget {
  // final IconData? icon;
  final String? imagePath;
  // final Color color;
  final String label;

  const _DockIcon(
    // this.icon,
    this.imagePath,
    // this.color,
    this.label, {
    super.key,
  });

  @override
  State<_DockIcon> createState() => _DockIconState();
}

class _DockIconState extends State<_DockIcon> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // 1. Define base size. macOS icons are usually quite large in the dock.
    final double size = _isHovered ? 65 : 50;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Tooltip(
        message: widget.label,
        preferBelow: false,
        verticalOffset: 60, // Push tooltip higher so it doesn't overlap
        // ... (Keep your existing tooltip decoration code) ...
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic, // Smoother bounce like Mac
          width: size,
          height: size,
          margin: EdgeInsets.symmetric(
            horizontal: _isHovered ? 4 : 8, // Adjust spacing dynamically
            vertical: _isHovered ? 0 : 8, // Lift icon up when hovered
          ),
          // 2. REMOVE THE DECORATION ENTIRELY
          // The image itself is the decoration. We don't need a box behind it.
          child: SvgPicture.asset(
            // Ensure your asset path ends in .svg
            widget.imagePath!.replaceAll('.png', '.svg'),
            width: size,
            height: size,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// --- HELPER CLASS FOR TOOLTIP SHAPE (Speech Bubble) ---
// -----------------------------------------------------------------------------
class _TooltipShape extends ShapeBorder {
  final double arrowHeight;
  final double arrowWidth;
  final double radius;

  const _TooltipShape({
    this.arrowHeight = 5,
    this.arrowWidth = 10,
    this.radius = 6,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.only(bottom: arrowHeight);

  @override
  // No explicit types needed here because 'intl' TextDirection is hidden via import
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path();

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    rect = Rect.fromPoints(
      rect.topLeft,
      rect.bottomRight - Offset(0, arrowHeight),
    );

    return Path()
      ..moveTo(rect.left + radius, rect.top)
      ..lineTo(rect.right - radius, rect.top)
      ..arcToPoint(
        Offset(rect.right, rect.top + radius),
        radius: Radius.circular(radius),
      )
      ..lineTo(rect.right, rect.bottom - radius)
      ..arcToPoint(
        Offset(rect.right - radius, rect.bottom),
        radius: Radius.circular(radius),
      )
      ..lineTo(rect.center.dx + arrowWidth / 2, rect.bottom)
      ..lineTo(rect.center.dx, rect.bottom + arrowHeight)
      ..lineTo(rect.center.dx - arrowWidth / 2, rect.bottom)
      ..lineTo(rect.left + radius, rect.bottom)
      ..arcToPoint(
        Offset(rect.left, rect.bottom - radius),
        radius: Radius.circular(radius),
      )
      ..lineTo(rect.left, rect.top + radius)
      ..arcToPoint(
        Offset(rect.left + radius, rect.top),
        radius: Radius.circular(radius),
      )
      ..close();
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
}
