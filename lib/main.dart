import 'dart:async';
import 'dart:ui'; // Required for ImageFilter
import 'dart:ui_web' as ui_web; // For web-specific UI features
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:macos_ui/macos_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:universal_html/html.dart' as html;

import 'platforms/android/android_home.dart';
import 'platforms/ios/ios_home.dart';
import 'platforms/mac/mac_home.dart';
import 'platforms/windows/windows_home.dart';

void main() async {
  // We register a factory that CREATES the iframe.
  // To update it, we will just interact with the DOM elements or 
  // let the widget rebuild.
  
  // Actually, for a robust 'Search' demo, let's make the factory 
  // return a container that we can manipulate, or keep it simple:
  
  ui_web.platformViewRegistry.registerViewFactory(
    'iframe-view',
    (int viewId) => html.IFrameElement()
      ..style.height = '100%'
      ..style.width = '100%'
      ..style.border = 'none',
  );
  
  // Ensure Flutter bindings are initialized before doing anything else
  WidgetsFlutterBinding.ensureInitialized();

  // Safely remove the HTML loader
  if (kIsWeb) {
    final loader = html.document.getElementById('loading-indicator');
    if (loader != null) {
      loader.remove();
    }
  }

  runApp(const PlatformRoot());
}

class PlatformRoot extends StatefulWidget {
  const PlatformRoot({super.key});

  @override
  State<PlatformRoot> createState() => _PlatformRootState();
}

class _PlatformRootState extends State<PlatformRoot> {
  // 1. Start with loading = true
  bool _isLoading = true;
  TargetPlatform? _manualOverride;

  @override
  void initState() {
    super.initState();
    // 2. FORCE a 2-second delay before switching
    // We use a simple Timer here which is less likely to block the main thread than Future.delayed in some contexts
    Timer(const Duration(seconds: 2), () {
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
    // 3. Logic to pick the correct Main App Widget
    Widget mainAppWidget;
    // If override is null, fallback to browser default.
    // Note: On Web, defaultTargetPlatform often returns Android or iOS if you are on mobile, 
    // or Windows/Linux/Mac if on desktop. 
    final currentPlatform = _manualOverride ?? defaultTargetPlatform;

    if (currentPlatform == TargetPlatform.android) {
      mainAppWidget = MaterialApp(
        key: const ValueKey('Android'),
        title: 'Kevin\'s Tech',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
        home: AndroidHome(onPlatformSwitch: changePlatform),
      );
    } else if (currentPlatform == TargetPlatform.iOS) {
      mainAppWidget = CupertinoApp(
        key: const ValueKey('iOS'),
        title: 'Kevin\'s Tech',
        debugShowCheckedModeBanner: false,
        home: IosHome(onPlatformSwitch: changePlatform),
      );
    } else if (currentPlatform == TargetPlatform.macOS) {
      mainAppWidget = MacosApp(
        key: const ValueKey('Mac'),
        title: 'Kevin\'s Tech',
        debugShowCheckedModeBanner: false,
        theme: MacosThemeData.light(),
        home: MacHome(onPlatformSwitch: changePlatform),
      );
    } else {
      // Default to Windows for any other desktop OS (Windows/Linux)
      mainAppWidget = fluent.FluentApp(
        key: const ValueKey('Windows'),
        title: 'Kevin\'s Tech',
        debugShowCheckedModeBanner: false,
        theme: fluent.FluentThemeData(accentColor: fluent.Colors.blue),
        home: WindowsHome(onPlatformSwitch: changePlatform),
      );
    }

    // 4. The FADE TRANSITION Logic
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 1500), 
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: _isLoading
          ? const MaterialApp(
              key: ValueKey('Splash'),
              debugShowCheckedModeBanner: false,
              home: KevinPortfolioSplash(),
            )
          : mainAppWidget,
    );
  }
}

// -----------------------------------------------------------------------------
// --- SPLASH SCREEN (Optimized) ---
// -----------------------------------------------------------------------------
class KevinPortfolioSplash extends StatefulWidget {
  const KevinPortfolioSplash({super.key});

  @override
  State<KevinPortfolioSplash> createState() => _KevinPortfolioSplashState();
}

class _KevinPortfolioSplashState extends State<KevinPortfolioSplash> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  Alignment _alignment = Alignment.topLeft;
  Timer? _bgTimer; // Keep reference to cancel it

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start background animation
    // Using a Timer here to ensure we can cancel it on dispose
    _bgTimer = Timer(const Duration(milliseconds: 100), () {
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
    _bgTimer?.cancel(); // Cancel timer to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = kIsWeb && 
        (defaultTargetPlatform == TargetPlatform.windows || 
         defaultTargetPlatform == TargetPlatform.linux || 
         defaultTargetPlatform == TargetPlatform.macOS);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Animated Background
          AnimatedContainer(
            duration: const Duration(seconds: 5),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: _alignment,
                end: _alignment == Alignment.topLeft ? Alignment.bottomRight : Alignment.topLeft,
                colors: const [
                  Color(0xFF0F2027), 
                  Color(0xFF203A43), 
                  Color(0xFF2C5364), 
                ],
              ),
            ),
          ),
          // Texture Overlay
          Container(
             decoration: BoxDecoration(
               color: Colors.black.withValues(alpha: 0.2),
               backgroundBlendMode: BlendMode.darken,
             ),
          ),
          // Center Content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.terminal_rounded, color: Colors.white.withValues(alpha: 0.8), size: 48),
                const SizedBox(height: 24),
                Text(
                  "KEVIN'S PORTFOLIO",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4.0,
                    fontFamily: 'Roboto', 
                    shadows: [
                      Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                FadeTransition(
                  opacity: _pulseAnimation,
                  child: Text(
                    "Booting Operating System...",
                    style: TextStyle(
                      color: Colors.tealAccent[200],
                      fontSize: 14,
                      letterSpacing: 1.5,
                      fontFamily: 'Courier',
                    ),
                  ),
                ),
                const SizedBox(height: 40),
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
          // Desktop Hint
          if (isDesktop)
            Positioned(
              top: 30,
              right: 30,
              child: FadeTransition(
                opacity: _pulseAnimation,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
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
          // Footer
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const FlutterLogo(size: 16),
                        const SizedBox(width: 10),
                        Text(
                          "Made with Flutter",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12,
                            letterSpacing: 0.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.favorite, color: Colors.redAccent, size: 14),
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