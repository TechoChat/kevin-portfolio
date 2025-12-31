import 'dart:async';
import 'package:flutter/material.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class WindowsHome extends StatefulWidget {
  // ✅ FIX 1: Change type back to accept a TargetPlatform input
  final ValueChanged<TargetPlatform> onPlatformSwitch;

  const WindowsHome({
    super.key,
    // ✅ FIX 2: Make it required so main.dart knows it must be passed
    required this.onPlatformSwitch,
  });

  @override
  State<WindowsHome> createState() => _WindowsHomeState();
}

class _WindowsHomeState extends State<WindowsHome> {
  // 1. Add state variable to track if menu is open
  bool _isStartMenuOpen = false;

  void _toggleStartMenu() {
    setState(() {
      _isStartMenuOpen = !_isStartMenuOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Wallpaper
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                if (_isStartMenuOpen) setState(() => _isStartMenuOpen = false);
              },
              child: Image.asset(
                'assets/img/windows/windows-Light.jpg', // Ensure this path is correct
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 2. Desktop Icons (Top Left Column) -> NEW CODE HERE
          Positioned(
            top: 10,
            left: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DesktopIcon(
                  iconPath: "assets/img/windows/icons/computer.png",
                  label: "This PC",
                  onTap: () => {}, //print("This PC"),
                ),

                DesktopIcon(
                  iconPath: "assets/img/windows/icons/network.png",
                  label: "Network",
                  onTap: () => {}, //print("Network"),
                ),

                DesktopIcon(
                  iconPath: "assets/img/windows/icons/explorer.png",
                  label: "File Explorer",
                  onTap: () => {}, //print("Explorer"),
                ),

                DesktopIcon(
                  iconPath: "assets/img/windows/icons/adobe.png",
                  label: "Adobe Acrobat",
                  onTap: () => {}, //print("Adobe"),
                ),

                const SizedBox(height: 20), // Separate the Mac button slightly

                DesktopIcon(
                  iconPath: "assets/img/windows/icons/macos.png",
                  label: "Move to Mac",
                  onTap: () {
                    widget.onPlatformSwitch(TargetPlatform.macOS);
                  },
                ),
              ],
            ),
          ),

          // 3. Start Menu (Z-index handled by order in stack)
          if (_isStartMenuOpen)
            const Positioned(
              bottom: 48,
              left: 0,
              right: 0,
              child: Center(child: WindowsStartMenu()),
            ),

          // 4. Taskbar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 48,
            child: WindowsTaskbar(onStartMenuTap: _toggleStartMenu),
          ),
        ],
      ),
    );
  }
}

// ✅ UPDATED: Changed to StatefulWidget to handle Battery logic
class WindowsTaskbar extends StatefulWidget {
  final VoidCallback onStartMenuTap;

  const WindowsTaskbar({
    super.key,
    required this.onStartMenuTap,
  });

  @override
  State<WindowsTaskbar> createState() => _WindowsTaskbarState();
}

class _WindowsTaskbarState extends State<WindowsTaskbar> {
  // --- Battery State ---
  final Battery _battery = Battery();
  BatteryState _batteryState = BatteryState.unknown;
  int _batteryLevel = 100;
  StreamSubscription<BatteryState>? _batteryStateSubscription;

  // --- Network State ---
  final Connectivity _connectivity = Connectivity();
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _initBattery();
    _initConnectivity();

    // Listen for Battery changes
    _batteryStateSubscription = _battery.onBatteryStateChanged.listen((BatteryState state) {
      setState(() => _batteryState = state);
    });

    // Listen for Network changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> result) {
      setState(() => _connectionStatus = result);
    });
  }

  // Initial Battery Check
  Future<void> _initBattery() async {
    try {
      final level = await _battery.batteryLevel;
      setState(() => _batteryLevel = level);
    } catch (e) {
      //print("Battery Error: $e");
    }
  }

  // Initial Network Check
  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      setState(() => _connectionStatus = result);
    } catch (e) {
      //print("Connectivity Error: $e");
    }
  }

  @override
  void dispose() {
    _batteryStateSubscription?.cancel();
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  // --- Helper: Get Battery Icon ---
  IconData _getBatteryIcon() {
    if (_batteryState == BatteryState.charging) return Icons.battery_charging_full;
    if (_batteryLevel >= 95) return Icons.battery_full;
    if (_batteryLevel >= 80) return Icons.battery_6_bar;
    if (_batteryLevel >= 60) return Icons.battery_5_bar;
    if (_batteryLevel >= 40) return Icons.battery_4_bar;
    if (_batteryLevel >= 20) return Icons.battery_2_bar;
    return Icons.battery_alert;
  }

  // --- Helper: Get Network Icon ---
  IconData _getNetworkIcon() {
    // Check Ethernet first (LAN connection)
    if (_connectionStatus.contains(ConnectivityResult.ethernet)) {
      return Icons.settings_ethernet; // Represents a LAN cable/port
    } 
    // Check Wi-Fi
    else if (_connectionStatus.contains(ConnectivityResult.wifi)) {
      return Icons.wifi;
    } 
    // Check Mobile Data
    else if (_connectionStatus.contains(ConnectivityResult.mobile)) {
      return Icons.signal_cellular_4_bar; 
    }
    // No Internet (Windows uses a globe icon for disconnected)
    return Icons.public_off; 
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF202020).withValues(alpha: 0.85),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Spacer(),

          // Start & Search
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _TaskbarIcon(
                icon: Icons.window,
                color: Colors.blueAccent,
                onTap: widget.onStartMenuTap,
              ),
              const SizedBox(width: 8),
              _TaskbarIcon(
                icon: Icons.search,
                color: Colors.white,
                onTap: () => {}, //print("Search Clicked"),
              ),
            ],
          ),

          const Spacer(),

          // System Tray
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.expand_less, color: Colors.white70, size: 20),
              const SizedBox(width: 12),

              // ✅ DYNAMIC NETWORK ICON
              Tooltip(
                message: _connectionStatus.contains(ConnectivityResult.none) 
                    ? "Not Connected" 
                    : "Connected",
                child: Icon(
                  _getNetworkIcon(), 
                  color: Colors.white, 
                  size: 20
                ),
              ),
              
              const SizedBox(width: 12),
              const Icon(Icons.volume_up, color: Colors.white, size: 20),
              const SizedBox(width: 12),

              // ✅ DYNAMIC BATTERY ICON
              Tooltip(
                message: "$_batteryLevel% ${_batteryState == BatteryState.charging ? '(Charging)' : ''}",
                child: Icon(
                  _getBatteryIcon(), 
                  color: Colors.white, 
                  size: 20
                ),
              ),

              const SizedBox(width: 16),
              const WindowsClock(),
              const SizedBox(width: 10),
              Container(width: 5, color: Colors.white12),
            ],
          ),
        ],
      ),
    );
  }
}

// --- Helper Widget: Hoverable Taskbar Icon ---
class _TaskbarIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _TaskbarIcon({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_TaskbarIcon> createState() => _TaskbarIconState();
}

class _TaskbarIconState extends State<_TaskbarIcon> {
  // ✅ FIX: Initialize to false so it is never null
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            // Light background when hovered
            color: _isHovered
                ? Colors.white.withValues(alpha: 0.1) // Use withOpacity for safety
                : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(widget.icon, color: widget.color, size: 26),
        ),
      ),
    );
  }
}

// --- Helper Widget: Live Clock ---
class WindowsClock extends StatefulWidget {
  const WindowsClock({super.key});

  @override
  State<WindowsClock> createState() => _WindowsClockState();
}

class _WindowsClockState extends State<WindowsClock> {
  late Timer _timer;
  late DateTime _currentTime;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    // Update the UI every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Format time: 09:41
    String hour = _currentTime.hour.toString().padLeft(2, '0');
    String minute = _currentTime.minute.toString().padLeft(2, '0');

    // Format date: 29-12-2025
    String day = _currentTime.day.toString().padLeft(2, '0');
    String month = _currentTime.month.toString().padLeft(2, '0');
    String year = _currentTime.year.toString();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          "$hour:$minute",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          "$day-$month-$year",
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }
}

class WindowsStartMenu extends StatelessWidget {
  const WindowsStartMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600,
      height: 640,
      margin: const EdgeInsets.only(bottom: 12), // Slight gap above taskbar
      decoration: BoxDecoration(
        color: const Color(0xFF242424).withValues(alpha: 0.98),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
        border: Border.all(color: Colors.white10, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Search Bar ---
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 32, 32, 16),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search for apps, settings, and documents',
                hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF1A1A1A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // --- Pinned Section Header ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Pinned",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    "All apps >",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          // --- Pinned Apps Grid ---
          Expanded(
            child: GridView.count(
              crossAxisCount: 6,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
              mainAxisSpacing: 20,
              crossAxisSpacing: 10,
              children: const [
                _StartMenuApp(
                  icon: Icons.language,
                  name: "Edge",
                  color: Colors.blue,
                ),
                _StartMenuApp(
                  icon: Icons.mail,
                  name: "Mail",
                  color: Colors.blueAccent,
                ),
                _StartMenuApp(
                  icon: Icons.calendar_month,
                  name: "Calendar",
                  color: Colors.blue,
                ),
                _StartMenuApp(
                  icon: Icons.store,
                  name: "Store",
                  color: Colors.white,
                ),
                _StartMenuApp(
                  icon: Icons.photo,
                  name: "Photos",
                  color: Colors.white,
                ),
                _StartMenuApp(
                  icon: Icons.settings,
                  name: "Settings",
                  color: Colors.grey,
                ),
                _StartMenuApp(
                  icon: Icons.calculate,
                  name: "Calculator",
                  color: Colors.white,
                ),
                _StartMenuApp(
                  icon: Icons.note,
                  name: "Notepad",
                  color: Colors.white,
                ),
                _StartMenuApp(
                  icon: Icons.folder,
                  name: "Explorer",
                  color: Colors.amber,
                ),
                _StartMenuApp(
                  icon: Icons.terminal,
                  name: "Terminal",
                  color: Colors.black,
                ),
                _StartMenuApp(
                  icon: Icons.movie,
                  name: "Movies",
                  color: Colors.redAccent,
                ),
                _StartMenuApp(
                  icon: Icons.music_note,
                  name: "Music",
                  color: Colors.red,
                ),
              ],
            ),
          ),

          // --- Footer (User Profile) ---
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 48),
            decoration: const BoxDecoration(
              color: Color(0xFF181818),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.teal,
                  radius: 14,
                  child: Text(
                    "U",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "User",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    Icons.power_settings_new,
                    color: Colors.white,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Helper widget for apps inside the menu
class _StartMenuApp extends StatelessWidget {
  final IconData icon;
  final String name;
  final Color color;

  const _StartMenuApp({
    required this.icon,
    required this.name,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 32,
          width: 32,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(color: Colors.white, fontSize: 11),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class DesktopIcon extends StatefulWidget {
  final String iconPath; // changed from IconData
  final String label;
  final VoidCallback onTap;

  const DesktopIcon({
    super.key,
    required this.iconPath,
    required this.label,
    required this.onTap,
  });

  @override
  State<DesktopIcon> createState() => _DesktopIconState();
}

class _DesktopIconState extends State<DesktopIcon> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 85,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            // Windows 11 Hover Effect: Subtle white square
            color: _isHovered
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.transparent,
            border: Border.all(
              color: _isHovered
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.transparent,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Use Image.asset for colorful icons
              Image.asset(
                widget.iconPath,
                width: 48, // Standard Windows 11 icon size
                height: 48,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 6),
              Text(
                widget.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  height: 1.2,
                  shadows: [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 4,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
