import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kevins_tech/platforms/ios/ios_status_bar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../platforms/android/android_status_bar.dart';

class MobileAppShellSimple extends StatelessWidget {
  final Widget child;
  final bool isAndroid;
  final String title;

  const MobileAppShellSimple({
    super.key,
    required this.child,
    this.isAndroid = false,
    this.title = "App",
  });

  @override
  Widget build(BuildContext context) {
    return Localizations(
      locale: const Locale('en', 'US'),
      delegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Theme(
          data: ThemeData(
            useMaterial3: true,
            platform: isAndroid ? TargetPlatform.android : TargetPlatform.iOS,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness:
                  Brightness.dark, // Defaulting to dark for that "sleek" look
            ),
          ),
          child: Scaffold(
            backgroundColor: isAndroid ? const Color(0xFF1E1E1E) : Colors.black,
            body: SafeArea(
              top: false,
              bottom: false,
              child: Column(
                children: [
                  // --- ANDROID CHROME TOP BAR ---
                  if (isAndroid)
                    _AndroidChromeBar(
                      title: title,
                      onBack: () => Navigator.of(context).pop(),
                    ),

                  // --- CONTENT AREA ---
                  Expanded(
                    child: Stack(
                      children: [
                        // If iOS, we need the top status bar space
                        if (!isAndroid)
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            height: 44,
                            child: Container(
                              color: Colors.black,
                              child: const IosStatusBar(isDark: false),
                            ),
                          ),

                        // Main Content
                        Positioned.fill(
                          top: !isAndroid
                              ? 44
                              : 0, // Push down for iOS status bar
                          child: ClipRRect(
                            // Optional: Round corners at top for iOS "card" look? Maybe not for full browser feel.
                            child: child,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- IOS SAFARI BOTTOM BAR ---
                  if (!isAndroid)
                    _IosSafariBottomBar(
                      onBack: () => Navigator.of(context).pop(),
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

class _AndroidChromeBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _AndroidChromeBar({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF2B2B2B), // Chrome Dark Grey
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status Bar Area
          const SizedBox(
            height: 32,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: AndroidStatusBar(
                iconColor: Colors.white,
              ), // White icons for dark mode
            ),
          ),

          // Url Bar Area
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white70),
                  onPressed: onBack,
                ),
                Expanded(
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E), // Slightly darker URL bar
                      borderRadius: BorderRadius.circular(24),
                    ),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        const Icon(Icons.lock, size: 14, color: Colors.white54),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            title.toLowerCase().replaceAll(" ", "") + ".com",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Tab Count
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white70, width: 2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "1",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.more_vert, color: Colors.white70),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IosSafariBottomBar extends StatelessWidget {
  final VoidCallback onBack;

  const _IosSafariBottomBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80, // Includes home indicator area
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E).withOpacity(0.9), // Dark translucent
        border: const Border(
          top: BorderSide(color: Colors.white12, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.only(top: 10, bottom: 20, left: 20, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(CupertinoIcons.chevron_back, color: Colors.blue),
            onPressed: onBack,
          ),
          const IconButton(
            icon: Icon(CupertinoIcons.chevron_forward, color: Colors.grey),
            onPressed: null,
          ),
          const IconButton(
            icon: Icon(CupertinoIcons.share, color: Colors.blue),
            onPressed: null,
          ),
          const IconButton(
            icon: Icon(CupertinoIcons.book, color: Colors.blue),
            onPressed: null,
          ),
          const IconButton(
            icon: Icon(CupertinoIcons.square_on_square, color: Colors.blue),
            onPressed: null,
          ),
        ],
      ),
    );
  }
}
