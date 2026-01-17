import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../system_apps/calculator/windows_calculator.dart';

class WindowsStartMenu extends StatefulWidget {
  final VoidCallback onOpenTerminal;
  final VoidCallback onOpenProjects;
  final VoidCallback onClose; // This callback is what closes the start menu

  const WindowsStartMenu({
    super.key,
    required this.onOpenTerminal,
    required this.onOpenProjects,
    required this.onClose,
  });

  @override
  State<WindowsStartMenu> createState() => _WindowsStartMenuState();
}

class _WindowsStartMenuState extends State<WindowsStartMenu> {
  bool _showAllApps = false;
  final TextEditingController _searchController = TextEditingController();

  // --- Actions ---
  Future<void> _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      widget.onClose();
    }
  }

  Future<void> _launchMail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'kevinstech0@gmail.com',
      query: 'subject=Hello Kevin&body=I saw your portfolio...',
    );
    await launchUrl(emailLaunchUri);
    widget.onClose();
  }

  Future<void> _sharePortfolio(BuildContext context) async {
    const String text = "Check out Kevin Shah's Portfolio!";
    const String url = "https://www.kevinstech.co/";

    widget.onClose();

    try {
      await SharePlus.instance.share(ShareParams(text: "$text\n$url"));
    } catch (e) {
      debugPrint("Error sharing: $e");
    }
  }

  void _openCalculator() {
    widget.onClose();
    // Launch as a dialog to simulate a floating window on top of the desktop
    showDialog(
      context: context,
      barrierColor:
          Colors.transparent, // Don't darken background for window feel
      builder: (_) => const WindowsCalculator(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
        child: Container(
          width: 540,
          height: 600, // Slightly taller for All Apps
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1C).withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 50,
                spreadRadius: 5,
              ),
            ],
            border: Border.all(color: Colors.white10, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. TOP SECTION: Search
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search for apps, settings, and documents',
                    hintStyle: const TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Colors.white54,
                      size: 20,
                    ),
                    filled: true,
                    fillColor: const Color(0xFF1F1F1F),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),

              // 2. MAIN CONTENT (Pinned vs All Apps)
              Expanded(
                child: _showAllApps ? _buildAllApps() : _buildPinnedApps(),
              ),

              // 3. FOOTER: User Profile
              Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                decoration: const BoxDecoration(
                  color: Color(0xFF101010),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24, width: 2),
                        image: const DecorationImage(
                          image: AssetImage("assets/img/KevinShah.png"),
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Kevin Shah",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Masters in AI & ML Student",
                          style: TextStyle(color: Colors.white54, fontSize: 10),
                        ),
                      ],
                    ),

                    const Spacer(),

                    _FooterAction(
                      icon: Icons.phone,
                      onTap: () {
                        _launchURL("tel:+610485516100");
                      },
                    ),
                    const SizedBox(width: 8),
                    _FooterAction(icon: Icons.email, onTap: _launchMail),
                    const SizedBox(width: 8),
                    _FooterAction(
                      icon: Icons.language,
                      onTap: () => _launchURL("https://github.com/TechoChat"),
                    ),
                    const SizedBox(width: 8),

                    IconButton(
                      icon: const Icon(
                        Icons.ios_share,
                        color: Colors.white70,
                        size: 18,
                      ),
                      tooltip: "Share Portfolio",
                      onPressed: () => _sharePortfolio(context),
                    ),

                    // Power Button
                    IconButton(
                      icon: const Icon(
                        Icons.power_settings_new,
                        color: Colors.white70,
                        size: 18,
                      ),
                      tooltip: "Power",
                      onPressed: widget.onClose, // Just close menu for now
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinnedApps() {
    return Column(
      children: [
        // Pinned Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Pinned",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              InkWell(
                onTap: () => setState(() => _showAllApps = true),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    "All apps >",
                    style: TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Pinned Apps Grid
        Container(
          height: 100,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StartMenuApp(
                icon: Icons.code,
                name: "GitHub",
                color: const Color(0xFF24292e),
                onTap: () => _launchURL("https://github.com/TechoChat"),
              ),
              _StartMenuApp(
                icon: Icons.business,
                name: "LinkedIn",
                color: const Color(0xFF0077b5),
                onTap: () =>
                    _launchURL("https://www.linkedin.com/in/techochat/"),
              ),

              // Terminal
              _StartMenuApp(
                assetPath: "assets/img/windows/icons/terminal.png",
                name: "Terminal",
                onTap: () {
                  widget.onClose();
                  widget.onOpenTerminal();
                },
              ),

              _StartMenuApp(
                icon: Icons.folder_special,
                name: "Projects",
                color: Colors.orangeAccent,
                onTap: () {
                  widget.onClose();
                  widget.onOpenProjects();
                },
              ),

              // Mail
              _StartMenuApp(
                assetPath: "assets/img/windows/icons/email.png",
                name: "Mail",
                onTap: _launchMail,
              ),
            ],
          ),
        ),

        // Bottom Section: Contact Card
        Expanded(
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF252525).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const _ContactRow(label: "Phone", value: "+61 0485 516 100"),
                const Divider(color: Colors.white10, height: 12),

                _ContactRow(
                  label: "Email",
                  value: "kevinstech0@gmail.com",
                  isLink: true,
                  onTap: _launchMail,
                ),
                const Divider(color: Colors.white10, height: 12),

                const _ContactRow(
                  label: "website",
                  value: "https://www.kevinstech.co/",
                ),
                const Divider(color: Colors.white10, height: 12),

                const _ContactRow(
                  label: "Experience",
                  value:
                      "3+ years in Software Development\n1+ year in AI/ML Research",
                  isMultiLine: true,
                ),
                const Divider(color: Colors.white10, height: 12),

                const _ContactRow(
                  label: "Skills",
                  value:
                      "Flutter, Dart, Python, AI/ML (RAG)\nIoT, Embedded Systems, Cloud",
                  isMultiLine: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAllApps() {
    return Column(
      children: [
        // All Apps Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "All apps",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              InkWell(
                onTap: () => setState(() => _showAllApps = false),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.arrow_back, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text(
                        "Back",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // List
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              _buildLetterHeader("C"),
              _buildAppListItem(
                "Calculator",
                Icons.calculate,
                Colors.white,
                onTap: _openCalculator,
              ),
              _buildAppListItem("Calendar", Icons.calendar_today, Colors.blue),
              _buildAppListItem("Camera", Icons.camera_alt, Colors.grey),
              _buildAppListItem("Clock", Icons.access_time, Colors.white),

              const SizedBox(height: 12),
              _buildLetterHeader("F"),
              _buildAppListItem(
                "File Explorer",
                Icons.folder,
                Colors.yellow[700]!,
              ),

              const SizedBox(height: 12),
              _buildLetterHeader("G"),
              _buildAppListItem(
                "GitHub",
                Icons.code,
                Colors.black,
                onTap: () => _launchURL("https://github.com/TechoChat"),
              ),
              _buildAppListItem("Google Chrome", Icons.public, Colors.blue),

              const SizedBox(height: 12),
              _buildLetterHeader("L"),
              _buildAppListItem(
                "LinkedIn",
                Icons.business,
                Colors.blue[800]!,
                onTap: () => _launchURL("https://linkedin.com/in/techochat"),
              ),

              const SizedBox(height: 12),
              _buildLetterHeader("M"),
              _buildAppListItem(
                "Mail",
                Icons.mail,
                Colors.blueAccent,
                onTap: _launchMail,
              ),
              _buildAppListItem("Maps", Icons.map, Colors.green),
              _buildAppListItem("Microsoft Edge", Icons.web, Colors.blue),

              const SizedBox(height: 12),
              _buildLetterHeader("P"),
              _buildAppListItem("Photos", Icons.photo, Colors.red),
              _buildAppListItem(
                "PowerPoint",
                Icons.slideshow,
                Colors.red[900]!,
              ),

              const SizedBox(height: 12),
              _buildLetterHeader("S"),
              _buildAppListItem("Settings", Icons.settings, Colors.grey),
              _buildAppListItem("Spotify", Icons.music_note, Colors.green),

              const SizedBox(height: 12),
              _buildLetterHeader("T"),
              _buildAppListItem(
                "Terminal",
                Icons.terminal,
                Colors.white,
                onTap: () {
                  widget.onClose();
                  widget.onOpenTerminal();
                },
              ),

              const SizedBox(height: 12),
              _buildLetterHeader("W"),
              _buildAppListItem("Word", Icons.description, Colors.blue[900]!),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLetterHeader(String letter) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Text(
        letter,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildAppListItem(
    String name,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      hoverColor: Colors.white.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 16),
            Text(
              name,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// HELPER WIDGETS
// -----------------------------------------------------------------------------

// ✅ UPDATED: Supports 'assetPath' for PNG images
class _StartMenuApp extends StatelessWidget {
  final IconData? icon; // Made nullable
  final String? assetPath; // Added for PNG support
  final String name;
  final Color? color; // Made nullable
  final VoidCallback? onTap;

  const _StartMenuApp({
    this.icon,
    this.assetPath,
    required this.name,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      hoverColor: Colors.white.withValues(alpha: 0.1),
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                // Use the provided color, or transparent if using an image
                color: assetPath != null
                    ? Colors.transparent
                    : (color ?? Colors.grey),
                borderRadius: BorderRadius.circular(6),
                boxShadow: assetPath != null
                    ? [] // No shadow box for PNGs (they usually have their own depth)
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: assetPath != null
                  // Render Image
                  ? Image.asset(
                      assetPath!,
                      width: 20,
                      height: 20,
                      fit: BoxFit.contain,
                    )
                  // Render Icon
                  : Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              name,
              style: const TextStyle(color: Colors.white, fontSize: 10),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLink;
  final bool isMultiLine;
  final VoidCallback? onTap;

  const _ContactRow({
    required this.label,
    required this.value,
    this.isLink = false,
    this.isMultiLine = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: isMultiLine
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Text(
              value,
              style: TextStyle(
                color: isLink ? Colors.blueAccent : Colors.white,
                fontSize: 12,
                height: 1.3,
                decoration: isLink
                    ? TextDecoration.underline
                    : TextDecoration.none,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FooterAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _FooterAction({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white10),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, color: Colors.white70, size: 14),
      ),
    );
  }
}
