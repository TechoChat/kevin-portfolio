import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // For Cupertino icons

class MacWindow extends StatefulWidget {
  final Widget child;
  final double width;
  final double height;
  final VoidCallback onClose;
  final VoidCallback? onMinimize; // ✅ Added optional minimize

  const MacWindow({
    super.key,
    required this.child,
    this.width = 950,
    this.height = 600,
    required this.onClose,
    this.onMinimize,
  });

  @override
  State<MacWindow> createState() => _MacWindowState();
}

class _MacWindowState extends State<MacWindow> {
  bool _isMaximized = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double currentWidth = _isMaximized ? size.width : widget.width;
    final double currentHeight = _isMaximized ? size.height : widget.height;
    final double borderRadius = _isMaximized ? 0 : 12;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          width: currentWidth,
          height: currentHeight,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E).withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(borderRadius),
            border: _isMaximized
                ? null
                : Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 1,
                  ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 50,
                spreadRadius: 10,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Stack(
                children: [
                  // Content
                  widget.child,

                  // Traffic Lights (Positioned absolutely to overlay neatly)
                  Positioned(
                    top: 14,
                    left: 14,
                    child: MacTrafficLights(
                      onClose: widget.onClose,
                      onMinimize: () => Navigator.pop(
                        context,
                      ), // Minimize usually closes in portfolio demos
                      onMaximize: () {
                        setState(() {
                          _isMaximized = !_isMaximized;
                        });
                      },
                    ),
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

// -----------------------------------------------------------------------------
// ✅ AUTHENTIC MAC TRAFFIC LIGHTS
// -----------------------------------------------------------------------------
class MacTrafficLights extends StatefulWidget {
  final VoidCallback onClose;
  final VoidCallback onMinimize;
  final VoidCallback onMaximize;

  const MacTrafficLights({
    super.key,
    required this.onClose,
    required this.onMinimize,
    required this.onMaximize,
  });

  @override
  State<MacTrafficLights> createState() => _MacTrafficLightsState();
}

class _MacTrafficLightsState extends State<MacTrafficLights> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      // When mouse enters the GROUP, show icons on ALL buttons
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Red (Close)
          _MacWindowButton(
            color: const Color(0xFFFF5F57),
            borderColor: const Color(0xFFE0443E),
            icon: Icons.close,
            showIcon: _isHovering,
            onTap: widget.onClose,
          ),
          const SizedBox(width: 8),

          // 2. Yellow (Minimize)
          _MacWindowButton(
            color: const Color(0xFFFFBD2E),
            borderColor: const Color(0xFFDEA123),
            icon: Icons.remove,
            showIcon: _isHovering,
            onTap: widget.onMinimize,
          ),
          const SizedBox(width: 8),

          // 3. Green (Maximize)
          _MacWindowButton(
            color: const Color(0xFF28C840),
            borderColor: const Color(0xFF1AAB29),
            icon: CupertinoIcons.fullscreen, // Arrows icon
            iconSize: 10, // Maximize icon needs to be slightly smaller visually
            showIcon: _isHovering,
            onTap: widget.onMaximize,
          ),
        ],
      ),
    );
  }
}

class _MacWindowButton extends StatelessWidget {
  final Color color;
  final Color borderColor;
  final IconData icon;
  final bool showIcon;
  final VoidCallback onTap;
  final double iconSize;

  const _MacWindowButton({
    required this.color,
    required this.borderColor,
    required this.icon,
    required this.showIcon,
    required this.onTap,
    this.iconSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 13, // Standard macOS size
        height: 13,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          // Subtle border for authentic look
          border: Border.all(
            color: borderColor.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
        alignment: Alignment.center,
        child: showIcon
            ? Icon(
                icon,
                size: iconSize,
                color: Colors.black.withValues(alpha: 0.6),
              )
            : null,
      ),
    );
  }
}
