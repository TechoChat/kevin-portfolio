import 'package:flutter/material.dart';
import '../../../components/apps/browser_view.dart';

class AndroidChrome extends StatefulWidget {
  const AndroidChrome({super.key});

  @override
  State<AndroidChrome> createState() => _AndroidChromeState();
}

class _AndroidChromeState extends State<AndroidChrome> {
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
    return PopScope(
      canPop: _showHome, // Only pop if on Home screen
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _goHome();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF202124), // Dark mode chrome
        body: SafeArea(
          child: Column(
            children: [
              // Top Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                color: const Color(0xFF35363A),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white70),
                      onPressed: () {
                        if (!_showHome) {
                          _goHome();
                        } else {
                          Navigator.pop(context); // Close App
                        }
                      },
                    ),
                    Expanded(
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF202124),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(
                          children: [
                            if (_currentUrl.startsWith('https'))
                              const Icon(
                                Icons.lock,
                                size: 14,
                                color: Colors.green,
                              )
                            else
                              const Icon(
                                Icons.search,
                                size: 16,
                                color: Colors.white54,
                              ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _urlController,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Search or type URL",
                                  hintStyle: TextStyle(color: Colors.white38),
                                  isDense: true,
                                ),
                                onSubmitted: _navigateTo,
                              ),
                            ),
                            if (!_showHome)
                              IconButton(
                                constraints: const BoxConstraints(maxWidth: 24),
                                padding: EdgeInsets.zero,
                                icon: const Icon(
                                  Icons.refresh,
                                  size: 18,
                                  color: Colors.white70,
                                ),
                                onPressed: () {
                                  setState(() {
                                    // Refresh hack
                                    final u = _currentUrl;
                                    _currentUrl = "";
                                    Future.delayed(
                                      const Duration(milliseconds: 50),
                                      () {
                                        setState(() => _currentUrl = u);
                                      },
                                    );
                                  });
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white70, width: 2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        "1",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.more_vert, color: Colors.white70),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: _showHome
                    ? _buildHome()
                    : BrowserView(
                        initialUrl: _currentUrl,
                        onUrlChanged: (u) {},
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHome() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Google",
          style: TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 30),
        Wrap(
          spacing: 20,
          children: [
            _shortcut(
              "YouTube",
              Icons.play_arrow,
              Colors.red,
              "https://youtube.com",
            ),
            _shortcut("GitHub", Icons.code, Colors.white, "https://github.com"),
            _shortcut(
              "LinkedIn",
              Icons.business,
              Colors.blue,
              "https://linkedin.com",
            ),
            _shortcut(
              "News",
              Icons.newspaper,
              Colors.pink,
              "https://news.google.com",
            ),
          ],
        ),
      ],
    );
  }

  Widget _shortcut(String label, IconData icon, Color color, String url) {
    return GestureDetector(
      onTap: () => _navigateTo(url),
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF35363A),
            radius: 24,
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
