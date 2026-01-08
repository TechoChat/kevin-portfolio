import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class IosContact extends StatelessWidget {
  const IosContact({super.key});

  Future<void> _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _share(BuildContext context) {
    Share.share(
      'Check out Kevin Shah\'s Portfolio: https://www.kevinstech.co/',
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text("Contact")),
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),
            // Avatar
            Center(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage("assets/img/KevinShah.png"),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Name
            const Text(
              "Kevin Shah",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
                color: CupertinoColors.label,
                decoration: TextDecoration.none,
                fontFamily: '.SF Pro Display',
              ),
            ),
            const SizedBox(height: 4),
            // Title
            const Text(
              "Senior Flutter Engineer",
              style: TextStyle(
                fontSize: 16,
                color: CupertinoColors.secondaryLabel,
                decoration: TextDecoration.none,
                fontFamily: '.SF Pro Text',
              ),
            ),
            const SizedBox(height: 30),

            // Action Buttons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionButton(
                  context,
                  label: "message",
                  icon: CupertinoIcons.chat_bubble_fill,
                  color: CupertinoColors.activeBlue,
                  onTap: () => _launchUrl("sms:"),
                ),
                const SizedBox(width: 16),
                _buildActionButton(
                  context,
                  label: "call",
                  icon: CupertinoIcons.phone_fill,
                  color: CupertinoColors.activeGreen,
                  onTap: () => _launchUrl("tel:+610485516100"),
                ),
                const SizedBox(width: 16),
                _buildActionButton(
                  context,
                  label: "mail",
                  icon: CupertinoIcons.mail_solid,
                  color: CupertinoColors.systemGrey,
                  onTap: () => _launchUrl("mailto:kevinstech0@gmail.com"),
                ),
                const SizedBox(width: 16),
                _buildActionButton(
                  context,
                  label: "share",
                  icon: CupertinoIcons.share,
                  color: CupertinoColors.systemOrange,
                  onTap: () => _share(context),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Info Cells
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  color: CupertinoColors.secondarySystemGroupedBackground,
                  child: Column(
                    children: [
                      _buildInfoRow(
                        "mobile",
                        "+61 0485 516 100",
                        onTap: () => _launchUrl("tel:+610485516100"),
                      ),
                      Divider(
                        height: 1,
                        color: CupertinoColors.separator.withValues(alpha: 0.5),
                        indent: 16,
                      ),
                      _buildInfoRow(
                        "work",
                        "kevinstech0@gmail.com",
                        onTap: () => _launchUrl("mailto:kevinstech0@gmail.com"),
                      ),
                      Divider(
                        height: 1,
                        color: CupertinoColors.separator.withValues(alpha: 0.5),
                        indent: 16,
                      ),
                      _buildInfoRow(
                        "website",
                        "kevinstech.co",
                        onTap: () => _launchUrl("https://www.kevinstech.co/"),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // About Me Button
            CupertinoButton(
              onPressed: () => _showAboutMe(context),
              child: const Text("About Me"),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutMe(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => const IosAboutMeSheet(),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12), // Squircle-ish
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: CupertinoColors.activeBlue,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: Colors.transparent,
        child: Row(
          children: [
            SizedBox(
              width: 70,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  color: CupertinoColors.label,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  color: CupertinoColors.activeBlue,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class IosAboutMeSheet extends StatelessWidget {
  const IosAboutMeSheet({super.key});

  Future<void> _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      decoration: const BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Drag handle
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey4,
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              "About Me",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none,
                color: CupertinoColors.label,
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const Text(
                      "Driven and detail-oriented Software Engineer with over 3+ years of experience in mobile application development using Flutter, Dart, and related technologies.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: CupertinoColors.label,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildSectionHeader("Experience"),
                    _buildListItem("3+ years in Software Development"),
                    _buildListItem("1+ year in AI/ML Research"),

                    const SizedBox(height: 24),
                    _buildSectionHeader("Skills"),
                    _buildListItem("Flutter, Dart, Python"),
                    _buildListItem("AI/ML (RAG), TensorFlow"),
                    _buildListItem("IoT, Embedded Systems"),

                    const SizedBox(height: 30),
                    CupertinoButton.filled(
                      onPressed: () =>
                          _launchUrl("https://github.com/TechoChat"),
                      child: const Text("View My Projects"),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: CupertinoColors.label,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }

  Widget _buildListItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          color: CupertinoColors.secondaryLabel,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}
