import 'package:flutter/material.dart';
import 'package:kevins_tech/platforms/windows/windows_taskbar.dart';
import 'package:kevins_tech/platforms/windows/windows_start_menu.dart';
import 'package:kevins_tech/platforms/windows/windows_icon.dart';
import 'package:url_launcher/url_launcher.dart';

class WindowsHome extends StatefulWidget {
  final ValueChanged<TargetPlatform> onPlatformSwitch;

  const WindowsHome({super.key, required this.onPlatformSwitch});

  @override
  State<WindowsHome> createState() => _WindowsHomeState();
}

class _WindowsHomeState extends State<WindowsHome> {
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
                  onTap: () {},
                ),
                DesktopIcon(
                  iconPath: "assets/img/windows/icons/network.png",
                  label: "Network",
                  onTap: () {},
                ),
                DesktopIcon(
                  iconPath: "assets/img/windows/icons/explorer.png",
                  label: "File Explorer",
                  onTap: () {},
                ),
                DesktopIcon(
                  iconPath: "assets/img/windows/icons/adobe.png",
                  label: "Adobe Acrobat",
                  onTap: () async {
                    const url =
                        'https://drive.google.com/file/d/1_YtPDqTXcC_eBlAPqsHSq3G1n_2_MJPs/view?usp=sharing';
                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(
                        Uri.parse(url),
                        mode: LaunchMode.externalApplication,
                      );
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

          // 3. Start Menu (ALWAYS IN TREE, JUST HIDDEN)
          // ✅ FIX: We removed the 'if' statement. The Positioned widget is always here.
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            // We use Visibility to hide it.
            // maintainState: true keeps the menu loaded so it opens instantly.
            child: Visibility(
              visible: _isStartMenuOpen,
              maintainState: true,
              maintainAnimation: true,
              child: const Center(child: WindowsStartMenu()),
            ),
          ),

          // 4. Taskbar
          // Because the Start Menu above is never removed (only hidden),
          // this Taskbar is ALWAYS the 4th item. Flutter will never rebuild it.
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
