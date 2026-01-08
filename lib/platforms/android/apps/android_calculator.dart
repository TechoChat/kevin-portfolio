import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../apps/calculator_app.dart';
import '../android_status_bar.dart';

class AndroidCalculator extends StatelessWidget {
  const AndroidCalculator({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Simulated Status Bar
        Container(
          color: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: const AndroidStatusBar(
            iconColor: Colors.white,
          ), // Use our new widget
        ),
        Expanded(
          child: Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text(
                "Calculator",
                style: TextStyle(color: Colors.white),
              ),
              systemOverlayStyle: SystemUiOverlayStyle.light,
            ),
            body: const CalculatorLayout(),
          ),
        ),
      ],
    );
  }
}
