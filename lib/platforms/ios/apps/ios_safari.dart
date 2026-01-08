import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class IosSafari extends StatelessWidget {
  const IosSafari({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.white,
      navigationBar: const CupertinoNavigationBar(
        // Search Bar Mock
        middle: Text("Safari"),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Favorites Grid
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Favorites",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            Expanded(
              child: GridView.count(
                crossAxisCount: 4,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                childAspectRatio: 0.8,
                mainAxisSpacing: 20,
                children: [
                  _buildFavorite(
                    context,
                    title: "GitHub",
                    color: Colors.black,
                    icon: Icons.code,
                    url: "https://github.com/TechoChat",
                  ),
                  _buildFavorite(
                    context,
                    title: "LinkedIn",
                    color: Colors.blue[700]!,
                    icon: CupertinoIcons.globe,
                    url: "https://www.linkedin.com/in/techochat/",
                  ),
                  _buildFavorite(
                    context,
                    title: "Resume",
                    color: Colors.red,
                    icon: CupertinoIcons.doc_text,
                    url:
                        "https://drive.google.com/file/d/1_YtPDqTXcC_eBlAPqsHSq3G1n_2_MJPs/view?usp=sharing",
                  ),
                  _buildFavorite(
                    context,
                    title: "Google",
                    color: Colors.blue,
                    icon: CupertinoIcons.search,
                    url: "https://www.google.com",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavorite(
    BuildContext context, {
    required String title,
    required Color color,
    required IconData icon,
    required String url,
  }) {
    return GestureDetector(
      onTap: () => launchUrl(Uri.parse(url)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black,
              decoration: TextDecoration.none,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
