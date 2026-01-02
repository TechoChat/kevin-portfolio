import 'package:flutter/material.dart';

class DesktopIcon extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const DesktopIcon({required this.label, required this.icon, required this.color, required this.onTap, super.key});

  @override
  State<DesktopIcon> createState() => DesktopIconState();
}

class DesktopIconState extends State<DesktopIcon> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Container(
          width: 85,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _isHovered ? Colors.white.withValues(alpha: 0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: _isHovered ? Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1) : Border.all(color: Colors.transparent),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 48, color: widget.color),
              const SizedBox(height: 4),
              Text(widget.label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500, shadows: [Shadow(color: Colors.black, blurRadius: 4)], decoration: TextDecoration.none)),
            ],
          ),
        ),
      ),
    );
  }
}

