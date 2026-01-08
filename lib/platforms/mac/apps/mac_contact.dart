import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../mac_window.dart';

class MacContact extends StatelessWidget {
  final VoidCallback onOpenAboutMe;

  const MacContact({super.key, required this.onOpenAboutMe});

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
    return MacWindow(
      onClose: () => Navigator.pop(context),
      width: 400,
      height: 560, // Increased to fix overflow
      child: Container(
        color: const Color(0xFF1E1E28), // Dark background from image
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Avatar
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white10, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
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
            const SizedBox(height: 16),
            // Name
            const Text(
              "Kevin Shah",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 4),
            // Title
            const Text(
              "Masters in AI & ML Student",
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 32),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ActionButton(
                  icon: CupertinoIcons.phone_fill,
                  label: "call",
                  color: Colors.blueAccent,
                  onTap: () => _launchUrl("tel:+610485516100"),
                ),
                const SizedBox(width: 20),
                _ActionButton(
                  icon: CupertinoIcons.mail_solid,
                  label: "mail",
                  color: Colors.blueAccent,
                  onTap: () => _launchUrl("mailto:kevinstech0@gmail.com"),
                ),
                const SizedBox(width: 20),
                _ActionButton(
                  icon: CupertinoIcons.globe,
                  label: "web",
                  color: Colors.blueAccent,
                  onTap: () => _launchUrl("https://www.kevinstech.co/"),
                ),
                const SizedBox(width: 20),
                _ActionButton(
                  icon: CupertinoIcons.share,
                  label: "share",
                  color: Colors.blueAccent,
                  onTap: () => _share(context),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Details List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  _DetailRow(label: "phone", value: "+61 0485 516 100"),
                  const Divider(color: Colors.white10, height: 24),
                  _DetailRow(label: "email", value: "kevinstech0@gmail.com"),
                  const Divider(color: Colors.white10, height: 24),
                  _DetailRow(
                    label: "website",
                    value: "https://www.kevinstech.co/",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // About Me Button (Bottom)
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: CupertinoButton(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(30),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 10,
                ),
                minSize: 0,
                onPressed: onOpenAboutMe,
                child: const Text(
                  "About Me",
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.blueAccent,
              fontSize: 12,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            decoration: TextDecoration.none,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }
}
