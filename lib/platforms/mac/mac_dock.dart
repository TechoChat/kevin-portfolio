import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MacDock extends StatelessWidget {
  final VoidCallback onOpenFinder;
  final VoidCallback onOpenLaunchpad; // ✅ Added Launchpad Callback
  final VoidCallback onOpenTerminal;
  final VoidCallback onOpenSafari;
  final VoidCallback onOpenMail;
  final VoidCallback onOpenMaps;
  final VoidCallback onOpenGitHub;    // ✅ Added GitHub Callback
  final VoidCallback onOpenLinkedIn;  // ✅ Added LinkedIn Callback

  const MacDock({
    super.key,
    required this.onOpenFinder,
    required this.onOpenLaunchpad,
    required this.onOpenTerminal,
    required this.onOpenSafari,
    required this.onOpenMail,
    required this.onOpenMaps,
    required this.onOpenGitHub,
    required this.onOpenLinkedIn,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20), // Lift dock off bottom edge
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12), // Glass Blur
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3), 
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.4), 
                  width: 1.5
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 25,
                    spreadRadius: -5,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(onTap: onOpenFinder, child: const _DockIcon("assets/img/mac/icons/finder.svg", "Finder")),
                  
                  // ✅ Wired up Launchpad
                  GestureDetector(onTap: onOpenLaunchpad, child: const _DockIcon("assets/img/mac/icons/launchpad.svg", "Launchpad")),
                  
                  GestureDetector(onTap: onOpenSafari, child: const _DockIcon("assets/img/mac/icons/safari.svg", "Safari")),
                  
                  // ✅ Replaced Messages with LinkedIn
                  GestureDetector(onTap: onOpenLinkedIn, child: const _DockIcon("assets/img/mac/icons/linkedin.svg", "LinkedIn")),
                  
                  GestureDetector(onTap: onOpenMail, child: const _DockIcon("assets/img/mac/icons/mail.svg", "Mail")),
                  GestureDetector(onTap: onOpenMaps, child: const _DockIcon("assets/img/mac/icons/maps.svg", "Maps")),
                  
                  // ✅ Replaced Photos with GitHub
                  GestureDetector(onTap: onOpenGitHub, child: const _DockIcon("assets/img/mac/icons/github.svg", "GitHub")),
                  
                  GestureDetector(onTap: onOpenTerminal, child: const _DockIcon("assets/img/mac/icons/terminal.svg", "Terminal")),
                  const _DockIcon("assets/img/mac/icons/settings.svg", "Settings"),
                  
                  const SizedBox(width: 12),
                  // Divider Line
                  Container(width: 1.5, height: 45, color: Colors.white.withValues(alpha: 0.4), margin: const EdgeInsets.only(bottom: 5)),
                  const SizedBox(width: 12),
                  
                  const _DockIcon("assets/img/mac/icons/bin.svg", "Bin"),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DockIcon extends StatefulWidget {
  final String? imagePath;
  final String label;
  const _DockIcon(this.imagePath, this.label);

  @override
  State<_DockIcon> createState() => _DockIconState();
}

class _DockIconState extends State<_DockIcon> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // macOS Dock Effect: Icons grow significantly when hovered
    final double size = _isHovered ? 60 : 48; 
    
    final isSvg = widget.imagePath?.toLowerCase().endsWith('.svg') ?? false;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Tooltip(
        message: widget.label,
        preferBelow: false,
        verticalOffset: 70, // Push tooltip above the magnified icon
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic, // Bouncy/Smooth animation
          width: size,
          height: size,
          margin: EdgeInsets.symmetric(
            horizontal: _isHovered ? 6 : 8, 
            vertical: _isHovered ? 0 : 6 // Moves up when growing
          ),
          child: widget.imagePath == null
              ? const Icon(Icons.apps, color: Colors.grey)
              : (isSvg
                  ? SvgPicture.asset(widget.imagePath!, fit: BoxFit.contain)
                  : Image.asset(widget.imagePath!, fit: BoxFit.contain)),
        ),
      ),
    );
  }
}