import 'package:flutter/material.dart';


// ... Include Start Menu & Desktop Icon classes from previous code ...
// (I omitted them here for brevity as they haven't changed, but keep them in your file)
class WindowsStartMenu extends StatelessWidget {
  const WindowsStartMenu({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600,
      height: 640,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF242424).withValues(alpha: 0.98),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
        border: Border.all(color: Colors.white10, width: 1),
      ),
      // ... Content of start menu ...
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Search Bar ---
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 32, 32, 16),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search for apps, settings, and documents',
                hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF1A1A1A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // --- Pinned Section Header ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Pinned",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    "All apps >",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          // --- Pinned Apps Grid ---
          Expanded(
            child: GridView.count(
              crossAxisCount: 6,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
              mainAxisSpacing: 20,
              crossAxisSpacing: 10,
              children: const [
                _StartMenuApp(
                  icon: Icons.language,
                  name: "Edge",
                  color: Colors.blue,
                ),
                _StartMenuApp(
                  icon: Icons.mail,
                  name: "Mail",
                  color: Colors.blueAccent,
                ),
                _StartMenuApp(
                  icon: Icons.calendar_month,
                  name: "Calendar",
                  color: Colors.blue,
                ),
                _StartMenuApp(
                  icon: Icons.store,
                  name: "Store",
                  color: Colors.white,
                ),
                _StartMenuApp(
                  icon: Icons.photo,
                  name: "Photos",
                  color: Colors.white,
                ),
                _StartMenuApp(
                  icon: Icons.settings,
                  name: "Settings",
                  color: Colors.grey,
                ),
                _StartMenuApp(
                  icon: Icons.calculate,
                  name: "Calculator",
                  color: Colors.white,
                ),
                _StartMenuApp(
                  icon: Icons.note,
                  name: "Notepad",
                  color: Colors.white,
                ),
                _StartMenuApp(
                  icon: Icons.folder,
                  name: "Explorer",
                  color: Colors.amber,
                ),
                _StartMenuApp(
                  icon: Icons.terminal,
                  name: "Terminal",
                  color: Colors.black,
                ),
                _StartMenuApp(
                  icon: Icons.movie,
                  name: "Movies",
                  color: Colors.redAccent,
                ),
                _StartMenuApp(
                  icon: Icons.music_note,
                  name: "Music",
                  color: Colors.red,
                ),
              ],
            ),
          ),

          // --- Footer (User Profile) ---
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 48),
            decoration: const BoxDecoration(
              color: Color(0xFF181818),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.teal,
                  radius: 14,
                  child: Text(
                    "U",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "User",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    Icons.power_settings_new,
                    color: Colors.white,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Helper widget for apps inside the menu
class _StartMenuApp extends StatelessWidget {
  final IconData icon;
  final String name;
  final Color color;

  const _StartMenuApp({
    required this.icon,
    required this.name,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 32,
          width: 32,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(color: Colors.white, fontSize: 11),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}