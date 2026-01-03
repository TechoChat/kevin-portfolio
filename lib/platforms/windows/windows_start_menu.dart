import 'dart:ui'; // Required for ImageFilter (Blur effect)
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WindowsStartMenu extends StatelessWidget {
  final VoidCallback onOpenTerminal;
  final VoidCallback onOpenProjects;
  final VoidCallback onClose;

  const WindowsStartMenu({
    super.key,
    required this.onOpenTerminal,
    required this.onOpenProjects,
    required this.onClose,
  });

  // --- Actions ---
  Future<void> _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      onClose(); // Close menu after clicking
    }
  }

  Future<void> _launchMail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'kevinstech0@gmail.com',
      query: 'subject=Hello Kevin&body=I saw your portfolio...',
    );
    await launchUrl(emailLaunchUri);
    onClose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      // ✅ GLASS EFFECT: Blur behind the menu
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0), 
        child: Container(
          width: 640,
          height: 540, // ✅ Reduced height to fit content tightly
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            // ✅ TRANSPARENCY: More see-through (0.85 -> 0.75)
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
              // ==========================================================
              // 1. TOP SECTION: Search & Pinned Apps
              // ==========================================================
              
              // --- Search Bar ---
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 24, 32, 16),
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search for apps, settings, and documents',
                    hintStyle: const TextStyle(color: Colors.white54, fontSize: 13),
                    prefixIcon: const Icon(Icons.search, color: Colors.white54, size: 20),
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

              // --- Pinned Header ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Pinned",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        "All apps >",
                        style: TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),

              // --- Pinned Apps Grid ---
              Container(
                height: 100, // Compact
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
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
                      onTap: () => _launchURL("https://www.linkedin.com/in/techochat/"),
                    ),
                    // ✅ FUNCTIONAL: Opens Terminal & Closes Menu
                    _StartMenuApp(
                      icon: Icons.terminal,
                      name: "Terminal",
                      color: Colors.black,
                      onTap: () {
                        onClose();
                        onOpenTerminal();
                      },
                    ),
                    // ✅ FUNCTIONAL: Opens Projects & Closes Menu
                    _StartMenuApp(
                      icon: Icons.folder_special,
                      name: "Projects",
                      color: Colors.orangeAccent,
                      onTap: () {
                        onClose();
                        onOpenProjects();
                      },
                    ),
                    _StartMenuApp(
                      icon: Icons.picture_as_pdf,
                      name: "Resume",
                      color: Colors.redAccent,
                      onTap: () => _launchURL("https://drive.google.com/file/d/1_YtPDqTXcC_eBlAPqsHSq3G1n_2_MJPs/view?usp=sharing"),
                    ),
                  ],
                ),
              ),

              // ==========================================================
              // 2. BOTTOM SECTION: Contact Card (Pic 1 Style)
              // ==========================================================
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF252525).withValues(alpha: 0.5), // Subtle card
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                       _ContactRow(label: "Phone", value: "+61 0485 516 100"),
                       const Divider(color: Colors.white10, height: 16),
                       
                       _ContactRow(
                         label: "Email", 
                         value: "kevinstech0@gmail.com", 
                         isLink: true,
                         onTap: _launchMail
                       ),
                       const Divider(color: Colors.white10, height: 16),
                       
                       _ContactRow(
                         label: "Location", 
                         value: "Adelaide, South Australia",
                       ),
                       const Divider(color: Colors.white10, height: 16),

                       _ContactRow(
                         label: "Experience", 
                         value: "Embedded Firmware Dev (DSPWorks)\nBackend Dev (Wizard Infosys)",
                         isMultiLine: true
                       ),
                       const Divider(color: Colors.white10, height: 16),

                       _ContactRow(
                         label: "Skills", 
                         value: "Flutter, Dart, Python, AI/ML (RAG)\nIoT, Embedded Systems, Cloud",
                         isMultiLine: true
                       ),
                    ],
                  ),
                ),
              ),

              // ==========================================================
              // 3. FOOTER: User Profile
              // ==========================================================
              Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 32),
                decoration: const BoxDecoration(
                  color: Color(0xFF101010), // Solid dark footer
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    // ✅ FIXED AVATAR: Clean circle with border
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24, width: 2),
                        image: const DecorationImage(
                          image: AssetImage("assets/img/KevinShah.png"), 
                          fit: BoxFit.cover,
                          // Adjust alignment if the head is cut off
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
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    
                    const Spacer(),
                    
                    _FooterAction(icon: Icons.phone, onTap: () {}), 
                    const SizedBox(width: 8),
                    _FooterAction(icon: Icons.email, onTap: _launchMail),
                    const SizedBox(width: 8),
                    _FooterAction(icon: Icons.language, onTap: () => _launchURL("https://github.com/TechoChat")),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.power_settings_new, color: Colors.redAccent, size: 18),
                      onPressed: () {}, 
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
}

// -----------------------------------------------------------------------------
// HELPER WIDGETS
// -----------------------------------------------------------------------------

class _StartMenuApp extends StatelessWidget {
  final IconData icon;
  final String name;
  final Color color;
  final VoidCallback? onTap;

  const _StartMenuApp({
    required this.icon,
    required this.name,
    required this.color,
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
                color: color,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 4, offset: const Offset(0, 2))
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 20),
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
      crossAxisAlignment: isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 80, // Narrower label width
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
                fontSize: 12, // Compact font size
                height: 1.3,
                decoration: isLink ? TextDecoration.underline : TextDecoration.none,
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