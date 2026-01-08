import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// -----------------------------------------------------------------------------
// --- iOS WIDGET HELPERS ---
// -----------------------------------------------------------------------------

// 1. App Icon (Unchanged)
class AppIcon extends StatelessWidget {
  final String name;
  final Color color;
  final IconData icon;
  final bool showLabel;
  final bool isWhite;
  final Color? iconColor;
  final VoidCallback? onTap;

  const AppIcon({
    required this.name,
    required this.color,
    required this.icon,
    this.showLabel = true,
    this.isWhite = false,
    this.iconColor,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(14),
                border: isWhite
                    ? Border.all(color: Colors.black12, width: 1)
                    : null,
                gradient: !isWhite
                    ? LinearGradient(
                        colors: [color, color.withValues(alpha: 0.8)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )
                    : null,
              ),
              child: Icon(
                icon,
                size: 32,
                color: iconColor ?? (isWhite ? Colors.black : Colors.white),
              ),
            ),
            if (showLabel) ...[
              const SizedBox(height: 5),
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.none,
                  fontFamily: '.SF Pro Text',
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// 2. Large Widget Container (Unchanged)
class IosWidgetContainer extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final Widget child;

  const IosWidgetContainer({
    required this.width,
    required this.height,
    required this.color,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

// 3. ✅ UPDATED Weather Widget Content
class WeatherWidget extends StatelessWidget {
  final String temp;
  final String city;
  final String condition;
  final String highLow;
  final bool isLoading;

  const WeatherWidget({
    required this.temp,
    required this.city,
    required this.condition,
    required this.highLow,
    this.isLoading = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CupertinoActivityIndicator(color: Colors.white),
      );
    }

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            city,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              decoration: TextDecoration.none,
            ),
          ),
          Text(
            "$temp°",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.w300,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: 15),
          const Icon(
            CupertinoIcons.cloud_sun_fill,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            condition,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.none,
            ),
          ),
          Text(
            highLow,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}

// 4. ✅ UPDATED Map Widget Content
class MapWidget extends StatelessWidget {
  final String city;
  const MapWidget({required this.city, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFE5F0D9), // Map green color
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(
                CupertinoIcons.location_solid,
                color: Colors.blue,
                size: 30,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Current Location",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.black,
                      decoration: TextDecoration.none,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    city, // Uses the city name from Weather API
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      decoration: TextDecoration.none,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
