import 'dart:async';
import 'package:flutter/material.dart';

class MadeWithFlutter extends StatefulWidget {
  const MadeWithFlutter({super.key});

  @override
  State<MadeWithFlutter> createState() => _MadeWithFlutterState();
}

class _MadeWithFlutterState extends State<MadeWithFlutter> {
  late PageController _pageController;
  Timer? _timer;
  final List<String> _words = ["Passion", "Care", "Love", "Flutter"];
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    _timer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
      if (_pageController.hasClients) {
        _currentPage++;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutQuart,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const FlutterLogo(size: 14),
          const SizedBox(width: 8),
          const Text(
            "Made with ",
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontFamily: "Segoe UI",
              decoration: TextDecoration.none,
              fontWeight: FontWeight.normal,
            ),
          ),
          SizedBox(
            height: 18,
            width: 54,
            child: PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _words[index % _words.length],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Segoe UI",
                      height: 1.0,
                      decoration: TextDecoration.none,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
