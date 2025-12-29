import 'package:flutter/foundation.dart';
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
  // If this is null, we use the browser's default OS.
  // If this has a value, we force that specific OS.
  TargetPlatform? _manualOverride;

  void changePlatform(TargetPlatform platform) {
    setState(() {
      _manualOverride = platform;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Priority: Manual Override -> Browser Default
    final currentPlatform = _manualOverride ?? defaultTargetPlatform;

    // 1. ANDROID
    if (currentPlatform == TargetPlatform.android) {
      return MaterialApp(
        title: 'Android Style',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
        // Pass the switcher function
        home: AndroidHome(onPlatformSwitch: changePlatform),
      );
    }

    // 2. IOS
    if (currentPlatform == TargetPlatform.iOS) {
      return CupertinoApp(
        title: 'iOS Style',
        // ... theme params ...
        debugShowCheckedModeBanner: false,
        home: IosHome(onPlatformSwitch: changePlatform), // <--- PASS FUNCTION
      );
    }

    // 3. MACOS
    if (currentPlatform == TargetPlatform.macOS) {
      return MacosApp(
        title: 'Mac Style',
        debugShowCheckedModeBanner: false,
        theme: MacosThemeData.light(),
        // Pass the function here:
        home: MacHome(onPlatformSwitch: changePlatform), 
      );
    }

    // 4. WINDOWS (Default Fallback)
    return fluent.FluentApp(
      title: 'Windows Style',
      debugShowCheckedModeBanner: false,
      theme: fluent.FluentThemeData(accentColor: fluent.Colors.blue),
      // Pass the switcher function
      home: WindowsHome(onPlatformSwitch: changePlatform),
    );
  }
}