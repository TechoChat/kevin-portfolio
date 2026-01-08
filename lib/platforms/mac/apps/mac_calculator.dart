import 'package:flutter/material.dart';
import '../../../../apps/calculator_app.dart';
import '../mac_window.dart';

class MacCalculator extends StatelessWidget {
  final VoidCallback? onClose;
  final VoidCallback? onMinimize;

  const MacCalculator({super.key, this.onClose, this.onMinimize});

  @override
  Widget build(BuildContext context) {
    return MacWindow(
      width: 300,
      height: 530, // Increased to prevent overflow
      onClose: onClose ?? () => Navigator.pop(context),
      onMinimize: onMinimize ?? () => Navigator.pop(context),
      child: Container(
        color: const Color(0xFF1C1C1E), // Mac darker bg
        child: Column(
          children: [
            // Drag handle / Title area
            Container(
              height: 28,
              alignment: Alignment.center,
              child: const Text(
                "Calculator",
                style: TextStyle(color: Colors.white38, fontSize: 13),
              ),
            ),
            const Expanded(child: CalculatorLayout()),
          ],
        ),
      ),
    );
  }
}
