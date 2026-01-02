import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MacDock extends StatelessWidget {
  const MacDock({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1.5),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 15, spreadRadius: -5, offset: const Offset(0, 10))],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const _DockIcon("assets/img/mac/icons/finder.svg", "Finder"),
                GestureDetector(
                  onTap: () async {
                    const url =
                        'https://drive.google.com/file/d/1_YtPDqTXcC_eBlAPqsHSq3G1n_2_MJPs/view?usp=sharing';
                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(
                        Uri.parse(url),
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                  child: const _DockIcon("assets/img/mac/icons/acrobat.svg", "acrobat"),
                ),
                const _DockIcon("assets/img/mac/icons/safari.svg", "Safari"),
                const _DockIcon("assets/img/mac/icons/messages.svg", "Messages"),
                const _DockIcon("assets/img/mac/icons/mail.svg", "Mail"),
                const _DockIcon("assets/img/mac/icons/maps.svg", "Maps"),
                const _DockIcon("assets/img/mac/icons/photos.svg", "Photos"),
                const _DockIcon("assets/img/mac/icons/settings.svg", "Settings"),
                const SizedBox(width: 10),
                Container(width: 1, height: 40, color: Colors.white30, margin: const EdgeInsets.only(bottom: 5)),
                const SizedBox(width: 10),
                const _DockIcon("assets/img/mac/icons/bin.svg", "Bin"),
              ],
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
    final double size = _isHovered ? 65 : 50;
    
    // Check if the file is an SVG to use the correct widget
    final isSvg = widget.imagePath?.toLowerCase().endsWith('.svg') ?? false;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Tooltip(
        message: widget.label,
        preferBelow: false,
        verticalOffset: 60,
        decoration: const ShapeDecoration(
          color: Color(0xFF2C2C2C),
          shape: _TooltipShape(),
        ),
        textStyle: const TextStyle(color: Colors.white, fontSize: 12),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          width: size,
          height: size,
          margin: EdgeInsets.symmetric(
            horizontal: _isHovered ? 4 : 8, 
            vertical: _isHovered ? 0 : 8
          ),
          // ✅ FIX: Conditionally render SVG or Standard Image
          child: isSvg 
            ? SvgPicture.asset(
                widget.imagePath!,
                width: size,
                height: size,
                fit: BoxFit.contain,
                // Optional: Helper to debug if path is wrong
                placeholderBuilder: (BuildContext context) => const Icon(Icons.error, color: Colors.red),
              )
            : Image.asset(
                widget.imagePath!,
                width: size,
                height: size,
                fit: BoxFit.contain,
                errorBuilder: (c, o, s) => const Icon(Icons.apps, color: Colors.grey),
              ),
        ),
      ),
    );
  }
}

// ✅ FIXED: Removed unused constructor parameters to clear warnings
class _TooltipShape extends ShapeBorder {
  static const double arrowHeight = 5;
  static const double arrowWidth = 10;
  static const double radius = 6;

  const _TooltipShape();

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.only(bottom: arrowHeight);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path();

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    rect = Rect.fromPoints(rect.topLeft, rect.bottomRight - const Offset(0, arrowHeight));
    return Path()
      ..moveTo(rect.left + radius, rect.top)
      ..lineTo(rect.right - radius, rect.top)
      ..arcToPoint(Offset(rect.right, rect.top + radius), radius: const Radius.circular(radius))
      ..lineTo(rect.right, rect.bottom - radius)
      ..arcToPoint(Offset(rect.right - radius, rect.bottom), radius: const Radius.circular(radius))
      ..lineTo(rect.center.dx + arrowWidth / 2, rect.bottom)
      ..lineTo(rect.center.dx, rect.bottom + arrowHeight)
      ..lineTo(rect.center.dx - arrowWidth / 2, rect.bottom)
      ..lineTo(rect.left + radius, rect.bottom)
      ..arcToPoint(Offset(rect.left, rect.bottom - radius), radius: const Radius.circular(radius))
      ..lineTo(rect.left, rect.top + radius)
      ..arcToPoint(Offset(rect.left + radius, rect.top), radius: const Radius.circular(radius))
      ..close();
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
}