import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MacDock extends StatelessWidget {
  final VoidCallback onOpenFinder;
  final VoidCallback onOpenLaunchpad;
  final VoidCallback onOpenTerminal;
  final VoidCallback onOpenSafari;
  final VoidCallback onOpenMail;
  final VoidCallback onOpenContact; // ✅ Added Contact Callback

  const MacDock({
    super.key,
    required this.onOpenFinder,
    required this.onOpenLaunchpad,
    required this.onOpenTerminal,
    required this.onOpenSafari,
    required this.onOpenMail,
    required this.onOpenContact,
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
                  width: 1.5,
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
                  GestureDetector(
                    onTap: onOpenFinder,
                    child: const _DockIcon(
                      "assets/img/mac/icons/finder.svg",
                      "Finder",
                    ),
                  ),

                  // Launchpad
                  GestureDetector(
                    onTap: onOpenLaunchpad,
                    child: const _DockIcon(
                      "assets/img/mac/icons/launchpad.svg",
                      "Launchpad",
                    ),
                  ),

                  GestureDetector(
                    onTap: onOpenSafari,
                    child: const _DockIcon(
                      "assets/img/mac/icons/safari.svg",
                      "Safari",
                    ),
                  ),

                  GestureDetector(
                    onTap: onOpenMail,
                    child: const _DockIcon(
                      "assets/img/mac/icons/mail.svg",
                      "Mail",
                    ),
                  ),

                  GestureDetector(
                    onTap: onOpenTerminal,
                    child: const _DockIcon(
                      "assets/img/mac/icons/terminal.svg",
                      "Terminal",
                    ),
                  ),

                  // Contact App (Replaces others)
                  GestureDetector(
                    onTap: onOpenContact,
                    child: const _DockIcon(
                      "assets/img/mac/icons/contacts.svg",
                      "Contact",
                      useSquircle: true,
                    ),
                  ),

                  const _DockIcon(
                    "assets/img/mac/icons/settings.svg",
                    "Settings",
                  ),
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
  final bool useSquircle;

  const _DockIcon(this.imagePath, this.label, {this.useSquircle = false});

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
            vertical: _isHovered ? 0 : 6, // Moves up when growing
          ),
          child: widget.imagePath == null
              ? const Icon(Icons.apps, color: Colors.grey)
              : _buildIconContent(isSvg, size),
        ),
      ),
    );
  }

  Widget _buildIconContent(bool isSvg, double size) {
    final icon = isSvg
        ? SvgPicture.asset(widget.imagePath!, fit: BoxFit.contain)
        : Image.asset(widget.imagePath!, fit: BoxFit.contain);

    if (widget.useSquircle) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.22),
        child: icon,
      );
    }
    return icon;
  }
}
