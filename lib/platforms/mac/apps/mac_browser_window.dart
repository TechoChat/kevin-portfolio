import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../system_apps/browser/browser_app.dart';
import '../../../web_portfolio/registry.dart';

class MacBrowserWindow extends StatefulWidget {
  final String initialUrl;
  final PortfolioApp? initialApp;

  const MacBrowserWindow({
    super.key,
    this.initialUrl = 'https://www.google.com',
    this.initialApp,
  });

  @override
  State<MacBrowserWindow> createState() => _MacBrowserWindowState();
}

class _MacBrowserWindowState extends State<MacBrowserWindow> {
  late TextEditingController _urlController;
  PortfolioApp? _currentApp;
  String _currentUrl = "";

  @override
  void initState() {
    super.initState();
    if (widget.initialApp != null) {
      _currentApp = widget.initialApp;
      _currentUrl = "internal://${widget.initialApp!.id}";
    } else {
      _currentUrl = widget.initialUrl;
    }
    _urlController = TextEditingController(text: _currentUrl);
  }

  void _navigateTo(String url) {
    setState(() {
      _currentUrl = url;
      if (url.startsWith("internal://")) {
        String appId = url.replaceAll("internal://", "");
        try {
          _currentApp = PortfolioRegistry.apps.firstWhere(
            (app) => app.id == appId,
          );
        } catch (e) {
          _currentApp = null;
        }
      } else {
        _currentApp = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Safari Style Window
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // Safari Top Bar
            Container(
              height: 52,
              color: const Color(0xFFF3F3F3), // Safari Grey
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Window Controls (Traffic Lights)
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: _MacTrafficLight(
                          color: Color(0xFFFF5F57),
                          icon: CupertinoIcons.xmark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const _MacTrafficLight(
                        color: Color(0xFFFFBD2E),
                        icon: CupertinoIcons.minus,
                      ),
                      const SizedBox(width: 8),
                      const _MacTrafficLight(
                        color: Color(0xFF28C840),
                        icon: CupertinoIcons.arrow_up_left_arrow_down_right,
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),

                  // Navigation Controls
                  const Icon(
                    CupertinoIcons.back,
                    size: 20,
                    color: Colors.black54,
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    CupertinoIcons.forward,
                    size: 20,
                    color: Colors.black38,
                  ), // Disabled
                  const SizedBox(width: 16),
                  const Icon(
                    CupertinoIcons.square_on_square,
                    size: 18,
                    color: Colors.black54,
                  ), // Tabs

                  const SizedBox(width: 16),

                  // Address Bar
                  Expanded(
                    child: Container(
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          const Icon(
                            CupertinoIcons.lock_fill,
                            size: 12,
                            color: Colors.black54,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _urlController,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.only(bottom: 12),
                              ),
                              onSubmitted: (value) {
                                if (!value.startsWith("http") &&
                                    !value.startsWith("internal://")) {
                                  _navigateTo("https://$value");
                                } else {
                                  _navigateTo(value);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            CupertinoIcons.refresh,
                            size: 14,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),
                  const Icon(
                    CupertinoIcons.share,
                    size: 20,
                    color: Colors.black54,
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    CupertinoIcons.add,
                    size: 20,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),

            // Browser Content
            Expanded(
              child: _currentApp != null
                  ? Builder(builder: _currentApp!.appBuilder)
                  : BrowserApp(initialUrl: _currentUrl, onUrlChanged: (url) {}),
            ),
          ],
        ),
      ),
    );
  }
}

class _MacTrafficLight extends StatelessWidget {
  final Color color;
  final IconData icon;

  const _MacTrafficLight({required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black.withOpacity(0.1), width: 0.5),
      ),
      // On hover we could show the icon, but for now just plain circle
    );
  }
}
