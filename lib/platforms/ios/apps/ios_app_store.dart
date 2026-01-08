import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class IosAppStore extends StatelessWidget {
  const IosAppStore({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("App Store"),
        backgroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF2F2F7), // iOS Grouped Bkg
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Featured Header
            Text(
              "Today",
              style: CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              "WEDNESDAY, JANUARY 8",
              style: TextStyle(
                color: CupertinoColors.systemGrey,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),

            // Projects List (App Style)
            _buildAppItem(
              context,
              title: "AI Automation",
              subtitle: "OpenAI + WordPress",
              color: Colors.purpleAccent,
              icon: CupertinoIcons.wand_stars,
              url: "https://github.com/TechoChat",
            ),
            _buildAppItem(
              context,
              title: "RAG Prototype",
              subtitle: "Python + VectorDB",
              color: Colors.orangeAccent,
              icon: CupertinoIcons.layers_alt,
              url: "https://github.com/TechoChat",
            ),
            _buildAppItem(
              context,
              title: "Flutter Stock App",
              subtitle: "Dart + PHP",
              color: Colors.blueAccent,
              icon: CupertinoIcons.graph_circle,
              url: "https://github.com/TechoChat",
            ),
            _buildAppItem(
              context,
              title: "DSP Firmware",
              subtitle: "C + Embedded",
              color: Colors.green,
              icon: CupertinoIcons.tray,
              url: null, // No link for this one in windows_home.dart
              actionLabel: "INSTALLED",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
    required String? url,
    String actionLabel = "GET",
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),

          // Texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),
          ),

          // Action Button
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            borderRadius: BorderRadius.circular(20),
            color: CupertinoColors.systemGrey6,
            minimumSize: const Size(0, 0),
            onPressed: url != null ? () => launchUrl(Uri.parse(url)) : null,
            child: Text(
              actionLabel,
              style: const TextStyle(
                color: CupertinoColors.activeBlue,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
