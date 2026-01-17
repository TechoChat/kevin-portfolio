import 'package:flutter/material.dart';
import '../../system_apps/browser/browser_app.dart';
import '../../web_portfolio/registry.dart';

class WindowsBrowserWindow extends StatefulWidget {
  final String initialUrl;
  final PortfolioApp? initialApp;

  const WindowsBrowserWindow({
    super.key,
    this.initialUrl = 'https://www.google.com',
    this.initialApp,
  });

  @override
  State<WindowsBrowserWindow> createState() => _WindowsBrowserWindowState();
}

class _WindowsBrowserWindowState extends State<WindowsBrowserWindow> {
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
          _currentApp = null; // show 404 or something
        }
      } else {
        _currentApp = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Chrome/Edge style window
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Browser Top Bar (Tabs + Address Bar area)
          Container(
            height: 80,
            color: const Color(0xFFDEE1E6),
            child: Column(
              children: [
                // Tabs area (mock)
                Container(
                  height: 40,
                  padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Tab
                      Container(
                        width: 200,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                        ),
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            Text(
                              _currentApp?.name ?? "New Tab",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 6),
                        child: Icon(Icons.add, size: 20, color: Colors.black54),
                      ),

                      const Spacer(),

                      // Window Controls
                      Row(
                        children: [
                          InkWell(
                            onTap: () => Navigator.of(
                              context,
                            ).pop(), // Minimize acts as close for now or hide?
                            child: const Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(
                                Icons.minimize,
                                size: 18,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap:
                                () {}, // Maximize (already full screen usually)
                            child: const Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(
                                Icons.crop_square,
                                size: 18,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => Navigator.of(context).pop(),

                            child: const Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(
                                Icons.close,
                                size: 18,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Address Bar area
                Expanded(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.arrow_back,
                          size: 20,
                          color: Colors.black54,
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.arrow_forward,
                          size: 20,
                          color: Colors.black38,
                        ), // Disabled
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.refresh,
                          size: 20,
                          color: Colors.black54,
                        ),
                        const SizedBox(width: 12),
                        // Address Bar
                        Expanded(
                          child: Container(
                            height: 28,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F3F4),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            alignment: Alignment.centerLeft,
                            child: TextField(
                              controller: _urlController,
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
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.star_border,
                          size: 20,
                          color: Colors.black54,
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.more_vert,
                          size: 20,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Browser Content
          Expanded(
            child: _currentApp != null
                ? Builder(builder: _currentApp!.appBuilder)
                : BrowserApp(
                    initialUrl: _currentUrl,
                    onUrlChanged: (url) {
                      // Update URL bar if iframe redirects (not always possible due to cross-origin)
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
