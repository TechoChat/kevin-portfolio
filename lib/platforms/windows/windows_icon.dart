import 'package:flutter/material.dart';


class DesktopIcon extends StatefulWidget {
  final String iconPath;
  final String label;
  final VoidCallback onTap;

  const DesktopIcon({
    super.key,
    required this.iconPath,
    required this.label,
    required this.onTap,
  });

  @override
  State<DesktopIcon> createState() => _DesktopIconState();
}

class _DesktopIconState extends State<DesktopIcon> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 85,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: _isHovered ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
            border: Border.all(
              color: _isHovered ? Colors.white.withValues(alpha: 0.2) : Colors.transparent,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(widget.iconPath, width: 48, height: 48, fit: BoxFit.contain),
              const SizedBox(height: 6),
              Text(
                widget.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  height: 1.2,
                  shadows: [Shadow(offset: Offset(1, 1), blurRadius: 4, color: Colors.black)],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}