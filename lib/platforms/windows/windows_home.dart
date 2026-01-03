import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kevins_tech/platforms/windows/file_explorer_window.dart';
import 'package:kevins_tech/platforms/windows/windows_taskbar.dart';
import 'package:kevins_tech/platforms/windows/windows_start_menu.dart';
import 'package:kevins_tech/platforms/windows/windows_icon.dart';
import 'package:kevins_tech/platforms/windows/windows_terminal.dart';
import 'package:url_launcher/url_launcher.dart';

class WindowsHome extends StatefulWidget {
  final ValueChanged<TargetPlatform> onPlatformSwitch;

  const WindowsHome({super.key, required this.onPlatformSwitch});

  @override
  State<WindowsHome> createState() => _WindowsHomeState();
}

class _WindowsHomeState extends State<WindowsHome> {
  bool _isStartMenuOpen = false;

  // --- Scrolling Text Variables ---
  late PageController _pageController;
  Timer? _timer;
  final List<String> _words = ["Passion", "Care", "Love", "Flutter"];
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Initialize the controller
    _pageController = PageController(initialPage: 0);

    // Timer: Scrolls every 2 seconds
    _timer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
      if (_pageController.hasClients) {
        _currentPage++;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 600), // Slightly slower smooth scroll
          curve: Curves.easeOutQuart, // Smoother landing
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

  void _toggleStartMenu() {
    setState(() {
      _isStartMenuOpen = !_isStartMenuOpen;
    });
  }

  // --- Window Openers (Same as before) ---
  void _openProjects() {
    _openGenericWindow(
      title: "Projects",
      path: "This PC > Projects",
      content: [
        ExplorerItem(
          icon: Icons.folder,
          iconColor: Colors.yellowAccent,
          label: "AI Automation",
          subLabel: "OpenAI + WordPress",
          onTap: () => launchUrl(Uri.parse("https://github.com/TechoChat")),
        ),
        ExplorerItem(
          icon: Icons.folder,
          iconColor: Colors.yellowAccent,
          label: "RAG Prototype",
          subLabel: "Python + VectorDB",
          onTap: () => launchUrl(Uri.parse("https://github.com/TechoChat")),
        ),
        ExplorerItem(
          icon: Icons.folder,
          iconColor: Colors.yellowAccent,
          label: "Flutter Stock App",
          subLabel: "Dart + PHP",
          onTap: () => launchUrl(Uri.parse("https://github.com/TechoChat")),
        ),
        ExplorerItem(
          icon: Icons.memory,
          iconColor: Colors.greenAccent,
          label: "DSP Firmware",
          subLabel: "C + Embedded",
          onTap: () {},
        ),
      ],
    );
  }

  void _openThisPC() {
    _openGenericWindow(
      title: "This PC",
      path: "This PC",
      content: [
        ExplorerItem(
          icon: Icons.storage,
          iconColor: Colors.blueAccent,
          label: "Local Disk (C:)",
          subLabel: "200GB Free",
          onTap: () {},
        ),
        ExplorerItem(
          icon: Icons.storage,
          iconColor: Colors.redAccent,
          label: "Skills (D:)",
          subLabel: "Full",
          onTap: () {},
        ),
        ExplorerItem(
          icon: Icons.folder_special,
          iconColor: Colors.yellow,
          label: "Resume.pdf",
          onTap: () => launchUrl(
            Uri.parse("https://drive.google.com/file/d/1_YtPDqTXcC_eBlAPqsHSq3G1n_2_MJPs/view?usp=sharing"),
          ),
        ),
      ],
    );
  }

  void _openNetwork() {
    _openGenericWindow(
      title: "Network",
      path: "Network > Internet",
      content: [
        ExplorerItem(
          icon: Icons.public,
          iconColor: Colors.blue,
          label: "LinkedIn",
          subLabel: "Connected",
          onTap: () => launchUrl(Uri.parse("https://www.linkedin.com/in/techochat/")),
        ),
        ExplorerItem(
          icon: Icons.code,
          iconColor: Colors.white,
          label: "GitHub",
          subLabel: "Online",
          onTap: () => launchUrl(Uri.parse("https://github.com/TechoChat")),
        ),
      ],
    );
  }

  void _openGenericWindow({
    required String title,
    required String path,
    required List<Widget> content,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Close",
      pageBuilder: (context, _, _) =>
          FileExplorerWindow(title: title, path: path, content: content),
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (context, anim, _, child) => Transform.scale(
        scale: anim.value,
        child: Opacity(opacity: anim.value, child: child),
      ),
    );
  }

  void _openTerminalWindow() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Close",
      pageBuilder: (context, _, _) => const WindowsTerminal(),
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (context, anim, _, child) {
        return Transform.scale(
          scale: anim.value,
          child: Opacity(opacity: anim.value, child: child),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Wallpaper & Tap to Close
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                if (_isStartMenuOpen) setState(() => _isStartMenuOpen = false);
              },
              child: Image.asset(
                'assets/img/windows/windows-Light.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 2. Desktop Icons
          Positioned(
            top: 10,
            left: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DesktopIcon(
                  iconPath: "assets/img/windows/icons/computer.png",
                  label: "This PC",
                  onTap: _openThisPC,
                ),
                DesktopIcon(
                  iconPath: "assets/img/windows/icons/network.png",
                  label: "Network",
                  onTap: _openNetwork,
                ),
                DesktopIcon(
                  iconPath: "assets/img/windows/icons/explorer.png",
                  label: "File Explorer",
                  onTap: _openProjects,
                ),
                DesktopIcon(
                  iconPath: "assets/img/windows/icons/folder.png",
                  label: "Projects",
                  onTap: _openProjects,
                ),
                const SizedBox(height: 10),
                DesktopIcon(
                  iconPath: "assets/img/windows/icons/github.png",
                  label: "GitHub",
                  onTap: () => launchUrl(Uri.parse("https://github.com/TechoChat")),
                ),
                DesktopIcon(
                  iconPath: "assets/img/windows/icons/linkedin.png",
                  label: "LinkedIn",
                  onTap: () => launchUrl(Uri.parse("https://www.linkedin.com/in/techochat/")),
                ),
                const SizedBox(height: 20),
                DesktopIcon(
                  iconPath: "assets/img/windows/icons/adobe.png",
                  label: "Resume.pdf",
                  onTap: () async {
                    const url = 'https://drive.google.com/file/d/1_YtPDqTXcC_eBlAPqsHSq3G1n_2_MJPs/view?usp=sharing';
                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                    }
                  },
                ),
                const SizedBox(height: 20),
                DesktopIcon(
                  iconPath: "assets/img/windows/icons/macos.png",
                  label: "Move to Mac",
                  onTap: () => widget.onPlatformSwitch(TargetPlatform.macOS),
                ),
              ],
            ),
          ),

          // 3. "Made with..." Small Animated Capsule
          Positioned(
            bottom: 60, // Sits just above taskbar
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                // ✅ Reduced padding for a tighter look
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const FlutterLogo(size: 14),
                    const SizedBox(width: 6),
                    const Text(
                      "Made with ",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontFamily: "Segoe UI",
                      ),
                    ),
                    // ✅ FIXED: Tighter height and no-gap text style
                    SizedBox(
                      height: 18, // Tight container height to force words close
                      width: 50,
                      child: PageView.builder(
                        controller: _pageController,
                        scrollDirection: Axis.vertical,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return Container(
                            alignment: Alignment.centerLeft, // Aligns text to left
                            child: Text(
                              _words[index % _words.length],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Segoe UI",
                                height: 1.0, // ✅ CRITICAL: Removes vertical font padding
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 4. Start Menu
          if (_isStartMenuOpen)
            Positioned(
              bottom: 48,
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: WindowsStartMenu(
                  onOpenTerminal: _openTerminalWindow,
                  onOpenProjects: _openProjects,
                  onClose: () => setState(() => _isStartMenuOpen = false),
                ),
              ),
            ),

          // 5. Taskbar
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