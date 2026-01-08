import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;

class BrowserView extends StatefulWidget {
  final String initialUrl;
  final Function(String) onUrlChanged;

  const BrowserView({
    super.key,
    this.initialUrl = '',
    required this.onUrlChanged,
  });

  @override
  State<BrowserView> createState() => _BrowserViewState();
}

class _BrowserViewState extends State<BrowserView> {
  late String _currentUrl;

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.initialUrl;
  }

  @override
  void didUpdateWidget(covariant BrowserView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialUrl != oldWidget.initialUrl) {
      _currentUrl = widget.initialUrl;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUrl.isEmpty) {
      return const Center(child: Text("No URL loaded"));
    }

    // Unique view ID for each URL loaded to ensure refresh
    final viewId =
        'iframe-view-${_currentUrl.hashCode}-${DateTime.now().millisecondsSinceEpoch}';

    // Register the view factory
    // Note: In production, consider registering once and updating src,
    // but for simple recreation this works.
    try {
      ui_web.platformViewRegistry.registerViewFactory(viewId, (int viewId) {
        final iframe = html.IFrameElement();
        iframe.src = _currentUrl;
        iframe.style.height = '100%';
        iframe.style.width = '100%';
        iframe.style.border = 'none';
        iframe.allow = "autoplay; fullscreen; microphone; camera";
        return iframe;
      });
    } catch (e) {
      // Ignore registration errors (duplicate registration)
      debugPrint("BrowserView Error: $e");
    }

    return HtmlElementView(key: ValueKey(viewId), viewType: viewId);
  }
}
