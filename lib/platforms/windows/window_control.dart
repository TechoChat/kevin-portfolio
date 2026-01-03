import 'package:flutter/material.dart';

// Helper for window buttons
class WindowControl extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const WindowControl({
    required this.icon,
    this.color = Colors.white70,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}