import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kevins_tech/system_apps/browser/browser_app.dart';

class IosSafari extends StatefulWidget {
  const IosSafari({super.key});

  @override
  State<IosSafari> createState() => _IosSafariState();
}

class _IosSafariState extends State<IosSafari> {
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

  void _goHome() {
    setState(() {
      _currentUrl = "";
      _urlController.clear();
      _showHome = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.white,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: const Color(0xFFF9F9F9).withValues(alpha: 0.9),
        border: null,
        middle: _showHome ? const Text("Safari") : null,
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _showHome
                  ? _buildFavorites()
                  : BrowserApp(initialUrl: _currentUrl, onUrlChanged: (url) {}),
            ),

            // Bottom Toolbar (Address Bar)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9).withValues(alpha: 0.9),
                border: const Border(top: BorderSide(color: Colors.black12)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: _showHome ? null : _goHome,
                        child: const Icon(CupertinoIcons.back, size: 24),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                CupertinoIcons.textformat_size,
                                size: 16,
                                color: Colors.black54,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: CupertinoTextField(
                                  controller: _urlController,
                                  placeholder: "Search or enter website name",
                                  decoration: null,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                  placeholderStyle: const TextStyle(
                                    color: Colors.black38,
                                  ),
                                  onSubmitted: _navigateTo,
                                  clearButtonMode:
                                      OverlayVisibilityMode.editing,
                                ),
                              ),
                              if (!_showHome)
                                GestureDetector(
                                  onTap: () => setState(() {
                                    // reload
                                    final u = _currentUrl;
                                    _currentUrl = "";
                                    Future.delayed(
                                      const Duration(milliseconds: 50),
                                      () {
                                        setState(() => _currentUrl = u);
                                      },
                                    );
                                  }),
                                  child: const Icon(
                                    CupertinoIcons.refresh,
                                    size: 18,
                                    color: Colors.black87,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Icon(
                          CupertinoIcons.square_on_square,
                          size: 24,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavorites() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Google Logo
          const Text(
            "Google",
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
              letterSpacing: -2,
            ),
          ),
          const SizedBox(height: 30),

          // Mimic Search Bar (visual only, since real input is at bottom)
          Container(
            width: 300,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                const SizedBox(width: 12),
                const Text(
                  "Search or enter website name",
                  style: TextStyle(color: Colors.black38, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
