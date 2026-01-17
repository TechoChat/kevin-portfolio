import 'dart:ui';
import 'package:flutter/material.dart';
import 'calculator_app.dart';
import '../../platforms/windows/window_control.dart';

class WindowsCalculator extends StatefulWidget {
  final VoidCallback? onClose;
  const WindowsCalculator({super.key, this.onClose});

  @override
  State<WindowsCalculator> createState() => _WindowsCalculatorState();
}

class _WindowsCalculatorState extends State<WindowsCalculator> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 320,
          height: 550, // Increased to prevent overflow
          decoration: BoxDecoration(
            color: const Color(0xFF202020),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            children: [
              // --- TITLE BAR ---
              Container(
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFF2B2B2B),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                ),
                padding: const EdgeInsets.only(left: 12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calculate,
                      color: Colors.white70,
                      size: 14,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Calculator",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const Spacer(),
                    WindowControl(
                      icon: Icons.minimize,
                      onTap:
                          widget.onClose ?? () => Navigator.of(context).pop(),
                    ),
                    WindowControl(
                      icon: Icons.crop_square,
                      onTap: () {}, // Maximize not implemented for fixed size
                    ),
                    WindowControl(
                      icon: Icons.close,
                      color: Colors.redAccent,
                      onTap:
                          widget.onClose ?? () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // --- CONTENT ---
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(8),
                  ),
                  child: const CalculatorLayout(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
