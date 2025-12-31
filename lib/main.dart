import 'dart:async';
import 'dart:ui'; // Required for ImageFilter (Glass effect)
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:macos_ui/macos_ui.dart';
import 'package:flutter/cupertino.dart';

import 'platforms/android/android_home.dart';
import 'platforms/ios/ios_home.dart';
import 'platforms/mac/mac_home.dart';
import 'platforms/windows/windows_home.dart';

void main() {
  runApp(const PlatformRoot());
}

class PlatformRoot extends StatefulWidget {
  const PlatformRoot({super.key});

  @override
  State<PlatformRoot> createState() => _PlatformRootState();
}

class _PlatformRootState extends State<PlatformRoot> {
  // 1. Loading State
  bool _isLoading = true;

  // Manual Platform Override
  TargetPlatform? _manualOverride;

  @override
  void initState() {
    super.initState();
    // 2. Simulate "Loading" process
    // This gives the app time to "process" and shows your animation
    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void changePlatform(TargetPlatform platform) {
    setState(() {
      _manualOverride = platform;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 3. IF LOADING: Show the Custom Splash Screen
    // We wrap it in a MaterialApp so it has access to Theme/Text styles immediately
    if (_isLoading) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: KevinPortfolioSplash(),
      );
    }

    // --- EXISTING LOGIC BELOW ---

    // Priority: Manual Override -> Browser Default
    final currentPlatform = _manualOverride ?? defaultTargetPlatform;

    // 1. ANDROID
    if (currentPlatform == TargetPlatform.android) {
      return MaterialApp(
        title: 'Android Style',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
        home: AndroidHome(onPlatformSwitch: changePlatform),
      );
    }

    // 2. IOS
    if (currentPlatform == TargetPlatform.iOS) {
      return CupertinoApp(
        title: 'iOS Style',
        debugShowCheckedModeBanner: false,
        home: IosHome(onPlatformSwitch: changePlatform),
      );
    }

    // 3. MACOS
    if (currentPlatform == TargetPlatform.macOS) {
      return MacosApp(
        title: 'Mac Style',
        debugShowCheckedModeBanner: false,
        theme: MacosThemeData.light(),
        home: MacHome(onPlatformSwitch: changePlatform),
      );
    }

    // 4. WINDOWS (Default Fallback)
    return fluent.FluentApp(
      title: 'Windows Style',
      debugShowCheckedModeBanner: false,
      theme: fluent.FluentThemeData(accentColor: fluent.Colors.blue),
      home: WindowsHome(onPlatformSwitch: changePlatform),
    );
  }
}

// --- NEW SPLASH SCREEN WIDGET ---
// --- NEW STUNNING SPLASH SCREEN ---
class KevinPortfolioSplash extends StatefulWidget {
  const KevinPortfolioSplash({super.key});

  @override
  State<KevinPortfolioSplash> createState() => _KevinPortfolioSplashState();
}

class _KevinPortfolioSplashState extends State<KevinPortfolioSplash>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Background Animation State
  Alignment _alignment = Alignment.topLeft;

  @override
  void initState() {
    super.initState();

    // 1. Text Pulse Animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // 2. Start Background Mesh Gradient Animation
    _startBackgroundAnimation();
  }

  void _startBackgroundAnimation() {
    // Simple recursive function to shift gradient alignment
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _alignment = _alignment == Alignment.topLeft
              ? Alignment.bottomRight
              : Alignment.topLeft;
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop =
        kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.macOS);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Animated Mesh Gradient Background
          AnimatedContainer(
            duration: const Duration(seconds: 5),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: _alignment,
                end: _alignment == Alignment.topLeft
                    ? Alignment.bottomRight
                    : Alignment.topLeft,
                colors: const [
                  Color(0xFF0F2027), // Deep Space Blue
                  Color(0xFF203A43), // Tealish Grey
                  Color(0xFF2C5364), // Horizon Blue
                ],
              ),
            ),
          ),

          // 2. Noise/Grain Overlay (Optional texture)
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha:0.2),
              backgroundBlendMode: BlendMode.darken,
            ),
          ),

          // 3. Center Content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo or Icon (Optional)
                Icon(
                  Icons.terminal_rounded,
                  color: Colors.white.withValues(alpha:0.8),
                  size: 48,
                ),
                const SizedBox(height: 24),

                // Main Title
                Text(
                  "KEVIN'S PORTFOLIO",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4.0,
                    fontFamily: 'Roboto', // Or your preferred font
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha:0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Pulsing "Processing" Text
                FadeTransition(
                  opacity: _pulseAnimation,
                  child: Text(
                    "Booting Operating System...",
                    style: TextStyle(
                      color: Colors.tealAccent[200],
                      fontSize: 14,
                      letterSpacing: 1.5,
                      fontFamily: 'Courier', // Monospace for "tech" vibe
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Thin Progress Bar
                Container(
                  width: 180,
                  height: 2,
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: const LinearProgressIndicator(
                    color: Colors.tealAccent,
                    backgroundColor: Colors.transparent,
                    minHeight: 2,
                  ),
                ),
              ],
            ),
          ),

          // 4. "Press F11" Hint (Top Right, unobtrusive)
          if (isDesktop)
            Positioned(
              top: 30,
              right: 30,
              child: FadeTransition(
                opacity: _pulseAnimation,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha:  0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.fullscreen, color: Colors.white54, size: 16),
                      SizedBox(width: 8),
                      Text(
                        "Press F11 for Full Screen",
                        style: TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 5. Bottom Glassmorphism "Made With Love"
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha:0.08),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withValues(alpha:0.1)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const FlutterLogo(size: 16), // Flutter Logo
                        const SizedBox(width: 10),
                        Text(
                          "Made with Flutter",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha:0.9),
                            fontSize: 12,
                            letterSpacing: 0.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.favorite,
                          color: Colors.redAccent,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
