import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kevins_tech/system_apps/browser/browser_app.dart';
import '../mac_window.dart';

class MacSafari extends StatefulWidget {
  const MacSafari({super.key});

  @override
  State<MacSafari> createState() => _MacSafariState();
}

class _MacSafariState extends State<MacSafari> {
  final TextEditingController _urlController = TextEditingController();
  String _currentUrl = "";
  bool _showHome = true;

  void _navigateTo(String url) {
    if (url.trim().isEmpty) return;
    String finalUrl = url;
    if (!url.startsWith('http')) {
      if (url.contains('.')) {
        finalUrl = 'https://$url';
      } else {
        finalUrl = 'https://www.google.com/search?q=$url&igu=1';
      }
    }

    setState(() {
      _currentUrl = finalUrl;
      _urlController.text = finalUrl;
      _showHome = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MacWindow(
      onClose: () => Navigator.pop(context),
      onMinimize: () => Navigator.pop(context),
      child: Container(
        color: const Color(0xFFF5F5F5),
        child: Column(
          children: [
            // Toolbar
            Container(
              height: 52, // Standard Mac Toolbar Height
              color: const Color(0xFFEBEBEB),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  // Space for MacWindow Traffic Lights (Overlay)
                  const SizedBox(width: 70),

                  // Sidebar Toggle
                  const Icon(
                    CupertinoIcons.sidebar_left,
                    color: Colors.black54,
                    size: 20,
                  ),
                  const SizedBox(width: 20),

                  // Back/Forward
                  const Icon(
                    CupertinoIcons.chevron_back,
                    color: Colors.black54,
                    size: 20,
                  ),
                  const SizedBox(width: 15),
                  const Icon(
                    CupertinoIcons.chevron_forward,
                    color: Colors.black26,
                    size: 20,
                  ),

                  const Spacer(),

                  // Address Bar
                  Container(
                    width: 400,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock, size: 12, color: Colors.black54),
                        const SizedBox(width: 6),
                        Expanded(
                          child: TextField(
                            controller: _urlController,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.only(bottom: 12),
                              hintText: "Search or enter website name",
                              hintStyle: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black,
                            ),
                            onSubmitted: _navigateTo,
                          ),
                        ),
                        if (!_showHome)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                // refresh
                                final u = _currentUrl;
                                _currentUrl = "";
                                Future.delayed(
                                  const Duration(milliseconds: 50),
                                  () => setState(() => _currentUrl = u),
                                );
                              });
                            },
                            child: const Icon(
                              CupertinoIcons.refresh,
                              size: 14,
                              color: Colors.black54,
                            ),
                          ),
                      ],
                    ),
                  ),

                  const Spacer(),
                  const SizedBox(width: 100), // Balance left side
                ],
              ),
            ),

            Expanded(
              child: _showHome
                  ? _buildHome()
                  : BrowserApp(initialUrl: _currentUrl, onUrlChanged: (u) {}),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHome() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Google Logo
          const Text(
            "Google",
            style: TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
              letterSpacing: -2,
            ),
          ),
          const SizedBox(height: 30),

          // Search Bar Visual (Visual only, functional bar is top toolbar)
          Container(
            width: 460,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.black12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  CupertinoIcons.search,
                  color: Colors.black38,
                  size: 20,
                ),
                const SizedBox(width: 16),
                const Text(
                  "Search or enter website name",
                  style: TextStyle(color: Colors.black38, fontSize: 16),
                ),
                const Spacer(),
                // Mic Icon (Visual)
                const Icon(
                  CupertinoIcons.mic_fill,
                  color: Colors.blueAccent,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
