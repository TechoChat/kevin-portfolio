import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AndroidHome extends StatefulWidget {
  final ValueChanged<TargetPlatform> onPlatformSwitch;

  const AndroidHome({super.key, required this.onPlatformSwitch});

  @override
  State<AndroidHome> createState() => _AndroidHomeState();
}

class _AndroidHomeState extends State<AndroidHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 1. Wallpaper
          Positioned.fill(
            child: Image.asset(
              'assets/img/android/android.webp',
              opacity: const AlwaysStoppedAnimation<double>(0.9),
              fit: BoxFit.cover,
            ),
          ),

          // 2. Main Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                // --- TOP STATUS BAR (New) ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Time (Left)
                      Text(
                        DateFormat('h:mm').format(DateTime.now()), // e.g. 8:39
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      // Status Icons (Right)
                      Row(
                        children: const [
                          Icon(Icons.wifi, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Icon(Icons.signal_cellular_alt, color: Colors.white, size: 16),
                          SizedBox(width: 8),
                          Icon(Icons.battery_full, color: Colors.white, size: 18),
                        ],
                      ),
                    ],
                  ),
                ),

                // --- Date Widget ("At a Glance") ---
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('E, MMM d').format(DateTime.now()),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Roboto',
                          shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // --- App Grid (Middle) ---
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 4,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.70,
                    children: [
                      // Apps
                      const _AndroidAppIcon(name: "Gmail", asset: "gmail"),
                      const _AndroidAppIcon(name: "Maps", asset: "maps"),
                      const _AndroidAppIcon(name: "Photos", asset: "photos"),
                      const _AndroidAppIcon(name: "YouTube", asset: "youtube"),
                      const _AndroidAppIcon(name: "Drive", asset: "pdf"),
                      const _AndroidAppIcon(name: "Settings", asset: "settings"),

                      // Move to iOS
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => widget.onPlatformSwitch(TargetPlatform.iOS),
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black,
                              ),
                              child: const Icon(Icons.apple, color: Colors.white, size: 28),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Move to iOS",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontFamily: 'Roboto',
                              shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // --- Bottom Dock & Search ---
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: const [
                          _AndroidAppIcon(name: "", asset: "phone", showLabel: false),
                          _AndroidAppIcon(name: "", asset: "messages", showLabel: false),
                          _AndroidAppIcon(name: "", asset: "chrome", showLabel: false),
                          _AndroidAppIcon(name: "", asset: "camera", showLabel: false),
                        ],
                      ),
                      const SizedBox(height: 25),
                      // Search Bar
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F3F5),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha:  0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: Colors.grey),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "Search...",
                                style: TextStyle(color: Colors.grey[600], fontSize: 16),
                              ),
                            ),
                            const Icon(Icons.mic, color: Colors.blueGrey),
                            const SizedBox(width: 16),
                            const Icon(Icons.camera_alt_outlined, color: Colors.blueGrey),
                          ],
                        ),
                      ),
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

// --- Helper Widget: Android App Icon ---
class _AndroidAppIcon extends StatelessWidget {
  final String name;
  final String asset;
  final bool showLabel;

  const _AndroidAppIcon({
    required this.name,
    required this.asset,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Use LayoutBuilder to know how much space we actually have in the grid cell
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          // 2. Center vertically to look nice even if space is extra
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon Image
            Container(
              width: 50, // Slightly reduced from 55 for safety on small screens
              height: 50,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
              ),
              child: Image.asset(
                'assets/img/android/icons/$asset.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => CircleAvatar(
                  backgroundColor: Colors.grey[800],
                  child: const Icon(Icons.android, color: Colors.green),
                ),
              ),
            ),

            if (showLabel) ...[
              const SizedBox(height: 4), // Reduced gap from 8 to 4
              // 3. Wrap Text in Flexible/FittedBox to prevent 18px overflow
              Flexible(
                child: Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11, // Slightly smaller font
                    fontFamily: 'Roboto',
                    shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1, // Force single line
                  overflow: TextOverflow.ellipsis, // Add "..." if too long
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
