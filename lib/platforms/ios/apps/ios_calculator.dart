import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../apps/calculator_app.dart';
import '../ios_status_bar.dart';

class IosCalculator extends StatelessWidget {
  const IosCalculator({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const IosStatusBar(), // Simulated Status Bar
        Expanded(
          child: CupertinoPageScaffold(
            navigationBar: const CupertinoNavigationBar(
              middle: Text("Calculator"),
              backgroundColor: CupertinoColors.black,
            ),
            backgroundColor: CupertinoColors.black,
            child: SafeArea(child: const CalculatorLayout()),
          ),
        ),
      ],
    );
  }
}
