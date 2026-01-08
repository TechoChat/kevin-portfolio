import 'dart:async';
import 'dart:ui'; // For ImageFilter
import 'package:flutter/foundation.dart'; // For defaultTargetPlatform
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class PlatformToast extends StatefulWidget {
  final TargetPlatform simulatedPlatform;

  const PlatformToast({super.key, required this.simulatedPlatform});

  @override
  State<PlatformToast> createState() => _PlatformToastState();
}

class _PlatformToastState extends State<PlatformToast>
    with SingleTickerProviderStateMixin {
  bool _isVisible = true;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    // Slide depends on platform (top or bottom) - will configure in build or listener
    // Defaulting to slide up

    // Start animation
    _controller.forward();

    // Auto-hide after 10 seconds
    Timer(const Duration(seconds: 10), () {
      if (mounted) {
        _close();
      }
    });
  }

  void _close() {
    _controller.reverse().then((_) {
      if (mounted) setState(() => _isVisible = false);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    // 1. Determine Message based on REAL Device
    final bool isRealMobile =
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
    final String message = isRealMobile
        ? "Looks great on Desktop too! 🖥️"
        : "Check it out on Mobile! 📱";
    final String subMessage = isRealMobile
        ? "Visit on a PC for the full desktop OS experience."
        : "Visit on your phone to see the adaptive mobile OS.";

    // 2. Determine Style based on SIMULATED Platform
    Widget toastContent;
    Alignment geometry;
    Offset slideBegin;

    switch (widget.simulatedPlatform) {
      case TargetPlatform.macOS:
        // MacOS: Top Right, Glassy
        geometry = Alignment.topRight;
        slideBegin = const Offset(1, 0); // Slide from right
        toastContent = _buildMacToast(message, subMessage);
        break;

      case TargetPlatform.android:
        // Android: Bottom Center, Material 3 Pill
        geometry = Alignment.bottomCenter;
        slideBegin = const Offset(0, 1); // Slide from bottom
        toastContent = _buildAndroidToast(message, subMessage);
        break;

      case TargetPlatform.iOS:
        // iOS: Top Center, Dynamic Island Style
        geometry = Alignment.topCenter;
        slideBegin = const Offset(0, -1); // Slide from top
        toastContent = _buildIosToast(message, subMessage);
        break;

      case TargetPlatform.windows:
      default:
        // Windows: Bottom Right, Acrylic
        geometry = Alignment.bottomRight;
        slideBegin = const Offset(1, 0); // Slide from right
        toastContent = _buildWindowsToast(message, subMessage);
        break;
    }

    // Re-configure slide animation if needed (generic optimization)
    // For simplicity, using a generic fade/scale/slide combo in the specific builders or wrapper

    return Positioned.fill(
      child: Align(
        alignment: geometry,
        child: Padding(
          padding: _getPadding(widget.simulatedPlatform),
          child: SlideTransition(
            position: Tween<Offset>(begin: slideBegin, end: Offset.zero)
                .animate(
                  CurvedAnimation(
                    parent: _controller,
                    curve: Curves.easeOutBack,
                  ),
                ),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Material(color: Colors.transparent, child: toastContent),
            ),
          ),
        ),
      ),
    );
  }

  EdgeInsets _getPadding(TargetPlatform platform) {
    switch (platform) {
      case TargetPlatform.iOS:
        return const EdgeInsets.only(top: 10); // Dynamic Island area
      case TargetPlatform.macOS:
        return const EdgeInsets.only(top: 40, right: 20);
      case TargetPlatform.windows:
        return const EdgeInsets.only(bottom: 60, right: 20); // Above taskbar
      case TargetPlatform.android:
        return const EdgeInsets.only(bottom: 100); // Above nav bar/dock
      default:
        return const EdgeInsets.all(20);
    }
  }

  // --- PLATFORM STYLES ---

  Widget _buildWindowsToast(String title, String body) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F).withOpacity(0.95), // Windows Dark
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 20)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: Colors.blueAccent,
                size: 16,
              ),
              const SizedBox(width: 8),
              const Text(
                "System Notification",
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const Spacer(),
              InkWell(
                onTap: _close,
                child: const Icon(Icons.close, color: Colors.white70, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildAndroidToast(String title, String body) {
    return Container(
      width: 350,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF303030), // Material Dark Surface
        borderRadius: BorderRadius.circular(30), // Pill shape
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.devices,
            color: Color(0xFFA8C7FA),
          ), // Material 3 Blue
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFFE3E3E3),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  body,
                  style: const TextStyle(
                    color: Color(0xFFC4C7C5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _close,
            icon: const Icon(Icons.close, color: Color(0xFFC4C7C5), size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildIosToast(String title, String body) {
    // Dynamic Island Expanded Look
    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: 360,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          color: Colors.black.withOpacity(0.8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.device_phone_portrait,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        decoration: null,
                        fontFamily: '.SF Pro Text',
                      ),
                    ),
                    Text(
                      body,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        decoration: null,
                        fontFamily: '.SF Pro Text',
                      ),
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

  Widget _buildMacToast(String title, String body) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7), // Glassy Light
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(CupertinoIcons.info, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "SUGGESTION",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      body,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _close,
                child: const Icon(
                  CupertinoIcons.xmark,
                  size: 16,
                  color: Colors.black45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
