import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// -----------------------------------------------------------------------------
// --- WIDGETS & COMPONENTS ---
// -----------------------------------------------------------------------------

class MacWidgetContainer extends StatelessWidget {
  final double width;
  final double height;
  final Widget child;
  final Color? color;

  const MacWidgetContainer({
    required this.width,
    required this.height,
    required this.child,
    this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: width,
          height: height,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color ?? Colors.white.withValues(alpha: 0.4),
            border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
            borderRadius: BorderRadius.circular(22),
          ),
          child: child,
        ),
      ),
    );
  }
}

class BatteryRing extends StatelessWidget {
  final double percent;
  final String label;
  final IconData icon;
  final Color color;

  const BatteryRing({
    required this.percent,
    required this.label,
    required this.icon,
    this.color = const Color(0xFF52D598),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                value: percent,
                strokeWidth: 4,
                backgroundColor: Colors.black12,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Icon(icon, size: 20, color: Colors.black87),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }
}

class CalendarWidget extends StatelessWidget {
  const CalendarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthName = _getMonthName(now.month).toUpperCase();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final firstDayOfWeek = DateTime(now.year, now.month, 1).weekday;
    final offset = firstDayOfWeek == 7 ? 0 : firstDayOfWeek;

    const fontStyle = TextStyle(
      fontFamily: '.SF Pro Text',
      decoration: TextDecoration.none,
      letterSpacing: -0.2,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6, top: 2),
          child: Text(
            monthName,
            style: fontStyle.copyWith(
              color: const Color(0xFFFF3B30),
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _WeekdayText("S"), _WeekdayText("M"), _WeekdayText("T"), _WeekdayText("W"),
              _WeekdayText("T"), _WeekdayText("F"), _WeekdayText("S"),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daysInMonth + offset,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7, mainAxisSpacing: 2, crossAxisSpacing: 2, childAspectRatio: 1.1,
            ),
            itemBuilder: (context, index) {
              if (index < offset) return const SizedBox();
              final dayNum = index - offset + 1;
              final isToday = dayNum == now.day;
              return Container(
                alignment: Alignment.center,
                decoration: isToday ? const BoxDecoration(color: Color(0xFFFF3B30), shape: BoxShape.circle) : null,
                child: Text("$dayNum", style: fontStyle.copyWith(fontSize: 10, fontWeight: isToday ? FontWeight.w700 : FontWeight.w500, color: isToday ? Colors.white : Colors.black87)),
              );
            },
          ),
        ),
      ],
    );
  }

  String _getMonthName(int month) => ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"][month - 1];
}

class _WeekdayText extends StatelessWidget {
  final String text;
  const _WeekdayText(this.text);
  @override
  Widget build(BuildContext context) => SizedBox(width: 14, child: Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black45, fontSize: 8, fontWeight: FontWeight.w600, decoration: TextDecoration.none, fontFamily: '.SF Pro Text')));
}

// ✅ UPDATED Weather Widget to Accept Data
class WeatherWidget extends StatelessWidget {
  final String temp;
  final String city;
  final String condition;
  final IconData icon;
  final bool isLoading;

  const WeatherWidget({
    required this.temp,
    required this.city,
    required this.condition,
    required this.icon,
    this.isLoading = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CupertinoActivityIndicator(color: Colors.white));
    }

    // Mock High/Low based on current temp for display purposes
    final int t = int.tryParse(temp) ?? 20;
    final String highLow = "H:${t + 5}° L:${t - 4}°";

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            city, 
            style: const TextStyle(color: Colors.white, fontSize: 12, decoration: TextDecoration.none),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            "$temp°", 
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w300, decoration: TextDecoration.none)
          ),
          const SizedBox(height: 4),
          Icon(icon, color: Colors.yellowAccent, size: 20),
          const SizedBox(height: 4),
          Text(
            condition, 
            style: const TextStyle(color: Colors.white70, fontSize: 10, decoration: TextDecoration.none),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            highLow, 
            style: const TextStyle(color: Colors.white70, fontSize: 10, decoration: TextDecoration.none)
          ),
        ],
      ),
    );
  }
}