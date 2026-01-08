import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'mac_window.dart';

class MacFinder extends StatelessWidget {
  final VoidCallback? onClose;
  final VoidCallback? onMinimize; // ✅ Added
  const MacFinder({super.key, this.onClose, this.onMinimize});

  @override
  Widget build(BuildContext context) {
    return MacWindow(
      onClose: onClose ?? () => Navigator.pop(context),
      onMinimize: onMinimize, // Pass to MacWindow
      child: Row(
        children: [
          // --- SIDEBAR (Left) ---
          Container(
            width: 200,
            padding: const EdgeInsets.only(top: 16, left: 16, right: 10),
            color: Colors.white.withValues(
              alpha: 0.05,
            ), // Slightly transparent dark
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Traffic Lights are here now
                // MacTrafficLights(onClose: () => Navigator.pop(context)),
                const SizedBox(height: 25),

                // 2. Favorites
                const _SidebarHeader("Favorites"),
                _SidebarItem(
                  icon: CupertinoIcons.star_fill,
                  label: "Recents",
                  color: Colors.blueAccent,
                  isSelected: false,
                ),
                _SidebarItem(
                  icon: CupertinoIcons.desktopcomputer,
                  label: "Desktop",
                  color: Colors.blueAccent,
                  isSelected: false,
                ),
                _SidebarItem(
                  icon: CupertinoIcons.doc_fill,
                  label: "Documents",
                  color: Colors.blueAccent,
                  isSelected: false,
                ),
                _SidebarItem(
                  icon: CupertinoIcons.arrow_down_circle_fill,
                  label: "Downloads",
                  color: Colors.blueAccent,
                  isSelected: false,
                ),

                const SizedBox(height: 20),
                // 3. Locations
                const _SidebarHeader("Locations"),
                _SidebarItem(
                  icon: CupertinoIcons.device_laptop,
                  label: "Macintosh HD",
                  color: Colors.grey,
                  isSelected: false,
                ),
                _SidebarItem(
                  icon: CupertinoIcons.cloud_fill,
                  label: "iCloud Drive",
                  color: Colors.grey,
                  isSelected: false,
                ),

                const SizedBox(height: 20),
                // 4. Tags
                const _SidebarHeader("Tags"),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const SizedBox(width: 8),
                    const Icon(
                      CupertinoIcons.circle_fill,
                      size: 10,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Red",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // --- CONTENT AREA (Right) ---
          Expanded(
            child: Container(
              color: const Color(0xFF121212), // Deep black background
              child: Column(
                children: [
                  // --- Toolbar ---
                  Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        const Icon(
                          CupertinoIcons.back,
                          color: Colors.white24,
                          size: 20,
                        ),
                        const SizedBox(width: 20),
                        const Icon(
                          CupertinoIcons.forward,
                          color: Colors.white24,
                          size: 20,
                        ),
                        const SizedBox(width: 16),

                        // Title
                        const Expanded(
                          child: Text(
                            "Finder",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const Icon(
                          CupertinoIcons.list_bullet,
                          color: Colors.white24,
                          size: 18,
                        ),
                        const SizedBox(width: 16),
                        const Icon(
                          CupertinoIcons.square_grid_2x2,
                          color: Colors.white24,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Colors.white12),

                  // --- Grid Content ---
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: GridView.count(
                        crossAxisCount: 4,
                        childAspectRatio: 0.8,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 20,
                        children: [
                          _MacFileItem(
                            label: "Projects",
                            icon: CupertinoIcons.folder_fill,
                            color: Colors.blueAccent,
                            onTap: () => launchUrl(
                              Uri.parse("https://github.com/TechoChat"),
                            ),
                          ),
                          _MacFileItem(
                            label: "Resume",
                            icon: CupertinoIcons.doc_text_fill,
                            color: Colors.white,
                            onTap: () => launchUrl(
                              Uri.parse(
                                "https://drive.google.com/file/d/1_YtPDqTXcC_eBlAPqsHSq3G1n_2_MJPs/view?usp=sharing",
                              ),
                            ),
                          ),
                          _MacFileItem(
                            label: "GitHub",
                            icon: CupertinoIcons.globe,
                            color: Colors.grey,
                            onTap: () => launchUrl(
                              Uri.parse("https://github.com/TechoChat"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // --- Footer Status ---
                  Container(
                    height: 30,
                    alignment: Alignment.center,
                    child: const Text(
                      "3 items, 200 GB available",
                      style: TextStyle(color: Colors.white30, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper Widgets
class _SidebarHeader extends StatelessWidget {
  final String title;
  const _SidebarHeader(this.title);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 12, bottom: 8),
    child: Text(
      title,
      style: const TextStyle(
        color: Colors.white30,
        fontSize: 11,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isSelected;
  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _MacFileItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MacFileItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 60, color: color),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
