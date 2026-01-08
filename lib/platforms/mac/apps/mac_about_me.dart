import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../mac_window.dart';

class MacAboutMe extends StatelessWidget {
  const MacAboutMe({super.key});

  Future<void> _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MacWindow(
      onClose: () => Navigator.pop(context),
      width: 400,
      height: 540,
      child: Container(
        color: const Color(
          0xFF1E1E28,
        ), // Dark background matching Contact/Image
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
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
                radius: 45,
                backgroundImage: AssetImage("assets/img/KevinShah.png"),
              ),
            ),
            const SizedBox(height: 16),
            // Name
            const Text(
              "Kevin Shah",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
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
                fontSize: 13,
                fontWeight: FontWeight.w400,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 30),

            // Info Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    _InfoRow(
                      label: "Experience",
                      value:
                          "3+ years in Software Development\n1+ year in AI/ML Research",
                    ),
                    const SizedBox(height: 16),
                    _InfoRow(
                      label: "Skills",
                      value:
                          "Flutter, Dart, Python\nAI/ML (RAG), TensorFlow\nIoT, Embedded Systems, Cloud\nCI/CD, Git, REST APIs",
                    ),
                  ],
                ),
              ),
            ),

            // Buttons
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // My Projects
                  CupertinoButton(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    minSize: 0,
                    onPressed: () => _launchUrl("https://github.com/TechoChat"),
                    child: const Text(
                      "My Projects",
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Contact
                  CupertinoButton(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    minSize: 0,
                    onPressed: () => Navigator.pop(context), // Go back
                    child: const Text(
                      "Contact",
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.none,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w400,
              decoration: TextDecoration.none,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
