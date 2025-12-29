import 'dart:ui' as ui; // For ImageFilter
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'dart:async';

class IosHome extends StatefulWidget {
  final ValueChanged<TargetPlatform> onPlatformSwitch;

  const IosHome({super.key, required this.onPlatformSwitch});

  @override
  State<IosHome> createState() => _IosHomeState();
}

class _IosHomeState extends State<IosHome> {
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
            top: false, // We handle top padding manually for the status bar
            bottom: false,
            child: Column(
              children: [
                // --- STATUS BAR (New) ---
                const Padding(
                  padding: EdgeInsets.only(top: 15, left: 24, right: 24, bottom: 10),
                  child: _IosStatusBar(),
                ),

                // --- TOP WIDGETS ROW ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Weather Widget
                      _IosWidgetContainer(
                        width: size.width * 0.43,
                        height: size.width * 0.43,
                        color: const Color(0xFF1C6BC8),
                        child: const _WeatherWidget(),
                      ),

                      // Map Widget
                      _IosWidgetContainer(
                        width: size.width * 0.43,
                        height: size.width * 0.43,
                        color: Colors.white.withValues(alpha: 0.8),
                        child: const _MapWidget(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // --- APP GRID ---
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 4,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.75,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _AppIcon(name: "FaceTime", color: Colors.green, icon: CupertinoIcons.videocam_fill),
                      _AppIcon(name: "Calendar", color: Colors.white, icon: CupertinoIcons.calendar, isWhite: true),
                      _AppIcon(name: "Photos", color: Colors.white, icon: CupertinoIcons.photo_on_rectangle, isWhite: true),
                      _AppIcon(name: "Camera", color: Colors.grey, icon: CupertinoIcons.camera_fill),

                      _AppIcon(name: "Mail", color: Colors.blue, icon: CupertinoIcons.mail_solid),
                      _AppIcon(name: "Notes", color: Colors.yellow.shade100, icon: CupertinoIcons.doc_text_fill, iconColor: Colors.orange),
                      _AppIcon(name: "Reminders", color: Colors.white, icon: CupertinoIcons.list_bullet, isWhite: true),
                      _AppIcon(name: "Clock", color: Colors.white, icon: CupertinoIcons.clock, isWhite: true),

                      _AppIcon(name: "News", color: Colors.pink, icon: CupertinoIcons.news),
                      _AppIcon(name: "TV", color: Colors.black, icon: CupertinoIcons.tv),
                      _AppIcon(name: "Podcasts", color: Colors.purple, icon: CupertinoIcons.mic_fill),
                      _AppIcon(name: "App Store", color: Colors.blueAccent, icon: CupertinoIcons.app_badge_fill),

                      _AppIcon(name: "Maps", color: Colors.greenAccent, icon: CupertinoIcons.location_fill),
                      _AppIcon(name: "Health", color: Colors.white, icon: CupertinoIcons.heart_fill, iconColor: Colors.red),
                      _AppIcon(name: "Wallet", color: Colors.black87, icon: CupertinoIcons.creditcard_fill),
                      _AppIcon(name: "Settings", color: Colors.grey, icon: CupertinoIcons.settings),

                      // Switch Button
                      GestureDetector(
                        onTap: () => widget.onPlatformSwitch(TargetPlatform.android),
                        child: Column(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.android, color: Colors.green, size: 35),
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

                // --- SEARCH PILL ---
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(CupertinoIcons.search, color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Text("Search", style: TextStyle(color: Colors.white, fontSize: 14)),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                // --- DOCK ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(35),
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        height: 95,
                        width: double.infinity,
                        color: Colors.white.withValues(alpha: 0.25),
                        padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _AppIcon(name: "", color: Colors.green, icon: CupertinoIcons.phone_fill, showLabel: false),
                            _AppIcon(name: "", color: Colors.blue, icon: CupertinoIcons.compass, showLabel: false),
                            _AppIcon(name: "", color: Colors.green, icon: CupertinoIcons.chat_bubble_fill, showLabel: false),
                            _AppIcon(name: "", color: Colors.red, icon: CupertinoIcons.music_note_2, showLabel: false),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// --- iOS WIDGET HELPERS ---
// -----------------------------------------------------------------------------

// 1. App Icon with Overflow Protection
class _AppIcon extends StatelessWidget {
  final String name;
  final Color color;
  final IconData icon;
  final bool showLabel;
  final bool isWhite;
  final Color? iconColor;

  const _AppIcon({
    super.key,
    required this.name,
    required this.color,
    required this.icon,
    this.showLabel = true,
    this.isWhite = false,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ FIX: FittedBox prevents overflow on small screens
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
              border: isWhite ? Border.all(color: Colors.black12, width: 1) : null,
              gradient: !isWhite ? LinearGradient(
                colors: [color, color.withValues(alpha: 0.8)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ) : null,
            ),
            child: Icon(
              icon,
              size: 32,
              color: iconColor ?? (isWhite ? Colors.black : Colors.white),
            ),
          ),
          if (showLabel) ...[
            const SizedBox(height: 5),
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.none,
                fontFamily: '.SF Pro Text',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

// 2. Large Widget Container (Weather/Map)
class _IosWidgetContainer extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final Widget child;

  const _IosWidgetContainer({
    super.key,
    required this.width,
    required this.height,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

// 3. Weather Widget Content (Fixed Overflow)
class _WeatherWidget extends StatelessWidget {
  const _WeatherWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text("San Francisco", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, decoration: TextDecoration.none)),
          Text("53°", style: TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w300, decoration: TextDecoration.none)),
          SizedBox(height: 15),
          Icon(CupertinoIcons.cloud_sun_fill, color: Colors.white, size: 24),
          SizedBox(height: 4),
          Text("Partly Cloudy", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500, decoration: TextDecoration.none)),
          Text("H:56° L:50°", style: TextStyle(color: Colors.white70, fontSize: 13, decoration: TextDecoration.none)),
        ],
      ),
    );
  }
}

// 4. Map Widget Content (Fixed Overflow)
class _MapWidget extends StatelessWidget {
  const _MapWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFE5F0D9), // Map green color
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(CupertinoIcons.location_solid, color: Colors.blue, size: 30),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
              child: const Icon(Icons.person, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            // ✅ FIX: Expanded prevents text from overflowing right side
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Marina Green", 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black, decoration: TextDecoration.none),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    "San Francisco", 
                    style: TextStyle(fontSize: 10, color: Colors.grey, decoration: TextDecoration.none),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }
}

// 5. iOS Status Bar (Time & Icons only - No fake Dynamic Island)
class _IosStatusBar extends StatefulWidget {
  const _IosStatusBar({super.key});

  @override
  State<_IosStatusBar> createState() => _IosStatusBarState();
}

class _IosStatusBarState extends State<_IosStatusBar> {
  late Timer _timer;
  late String _timeString;

  @override
  void initState() {
    super.initState();
    _timeString = _formatTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateTime());
  }

  void _updateTime() {
    final String formatted = _formatTime();
    if (_timeString != formatted) {
      setState(() => _timeString = formatted);
    }
  }

  String _formatTime() => DateFormat('h:mm').format(DateTime.now());

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30, // Keep height consistent
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Push items to edges
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Time (Left)
          Text(
            _timeString,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: '.SF Pro Text',
              decoration: TextDecoration.none,
            ),
          ),

          // 2. Status Icons (Right)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(CupertinoIcons.bars, color: Colors.white, size: 18), // Signal
              SizedBox(width: 6),
              Icon(CupertinoIcons.wifi, color: Colors.white, size: 18), // WiFi
              SizedBox(width: 6),
              Icon(CupertinoIcons.battery_25, color: Colors.white, size: 24), // Battery
            ],
          ),
        ],
      ),
    );
  }
}