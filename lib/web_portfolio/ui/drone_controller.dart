import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';

class DroneController extends StatefulWidget {
  const DroneController({super.key});

  @override
  State<DroneController> createState() => _DroneControllerState();
}

class _DroneControllerState extends State<DroneController> {
  // Telemetry Simulation
  double _altitude = 0.0;
  double _speed = 0.0;
  int _battery = 100;
  Timer? _telemetryTimer;

  // Joystick state
  Offset _leftStick = Offset.zero;
  Offset _rightStick = Offset.zero;

  @override
  void initState() {
    super.initState();
    _telemetryTimer = Timer.periodic(const Duration(milliseconds: 500), (t) {
      if (mounted) {
        setState(() {
          // Drain battery slowly if flying
          if (_altitude > 0) _battery = math.max(0, _battery - 1);
          // Fluctuate altitude/speed if sticks are moved (simulated)
          if (_leftStick.dy < 0) _altitude += 0.5;
          if (_leftStick.dy > 0) _altitude = math.max(0, _altitude - 0.5);

          if (_altitude > 0) {
            _speed = (_rightStick.distance * 20).clamp(0, 50);
          } else {
            _speed = 0;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _telemetryTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Camera Feed / Background
          Positioned.fill(
            child: Container(
              color: Colors.grey[900],
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.videocam_off, size: 60, color: Colors.white24),
                    const SizedBox(height: 20),
                    Text(
                      "NO SIGNAL",
                      style: TextStyle(
                        color: Colors.white24,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. HUD Overlay (Grid)
          Positioned.fill(child: CustomPaint(painter: _HudPainter())),

          // 3. Top Telemetry Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black87, Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _TelemetryItem(
                    label: "ALT",
                    value: "${_altitude.toStringAsFixed(1)} m",
                    color: Colors.cyanAccent,
                  ),
                  _TelemetryItem(
                    label: "SPD",
                    value: "${_speed.toStringAsFixed(1)} m/s",
                    color: Colors.greenAccent,
                  ),
                  _TelemetryItem(
                    label: "BAT",
                    value: "$_battery%",
                    color: _battery < 20 ? Colors.redAccent : Colors.white,
                  ),
                  Row(
                    children: const [
                      Icon(
                        Icons.signal_cellular_alt,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        "RC LINK",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 4. Joysticks
          Positioned(
            bottom: 40,
            left: 40,
            child: _Joystick(
              onChanged: (val) => setState(() => _leftStick = val),
              label: "THROTTLE / YAW",
            ),
          ),
          Positioned(
            bottom: 40,
            right: 40,
            child: _Joystick(
              onChanged: (val) => setState(() => _rightStick = val),
              label: "PITCH / ROLL",
            ),
          ),

          // 5. Center Action Buttons
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ActionButton(icon: Icons.camera_alt, label: "PHOTO"),
                  const SizedBox(width: 20),
                  _ActionButton(
                    icon: Icons.videocam,
                    label: "VIDEO",
                    isActive: true,
                  ),
                  const SizedBox(width: 20),
                  _ActionButton(icon: Icons.map, label: "MAP"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Joystick extends StatefulWidget {
  final ValueChanged<Offset> onChanged;
  final String label;

  const _Joystick({required this.onChanged, required this.label});

  @override
  State<_Joystick> createState() => _JoystickState();
}

class _JoystickState extends State<_Joystick> {
  Offset _position = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onPanUpdate: (details) {
            final halfSize = 60.0;
            // Calculate new position limited to circle radius
            Offset newPos = _position + details.delta;
            if (newPos.distance > halfSize) {
              newPos = (newPos / newPos.distance) * halfSize;
            }
            setState(() {
              _position = newPos;
            });
            // Normalize -1 to 1
            widget.onChanged(newPos / halfSize);
          },
          onPanEnd: (details) {
            // Spring back to center
            setState(() {
              _position = Offset.zero;
            });
            widget.onChanged(Offset.zero);
          },
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white10,
              border: Border.all(color: Colors.white30, width: 2),
            ),
            child: Center(
              child: Transform.translate(
                offset: _position,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.8),
                    boxShadow: [
                      BoxShadow(color: Colors.black45, blurRadius: 4),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.label,
          style: const TextStyle(color: Colors.white54, fontSize: 10),
        ),
      ],
    );
  }
}

class _TelemetryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _TelemetryItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Courier',
          ),
        ), // Monospace look
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Colors.redAccent : Colors.grey[800],
            border: Border.all(color: Colors.white24),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 10)),
      ],
    );
  }
}

class _HudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.greenAccent.withOpacity(0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final center = Offset(size.width / 2, size.height / 2);

    // Crosshair
    canvas.drawLine(center.translate(-20, 0), center.translate(20, 0), paint);
    canvas.drawLine(center.translate(0, -20), center.translate(0, 20), paint);

    // Circular horizon hint
    canvas.drawCircle(center, 100, paint);

    // Corner brackets
    final cornerSize = 40.0;
    final padding = 20.0;
    // Top Left
    canvas.drawPath(
      Path()
        ..moveTo(padding, padding + cornerSize)
        ..lineTo(padding, padding)
        ..lineTo(padding + cornerSize, padding),
      paint,
    );
    // Top Right
    canvas.drawPath(
      Path()
        ..moveTo(size.width - padding, padding + cornerSize)
        ..lineTo(size.width - padding, padding)
        ..lineTo(size.width - padding - cornerSize, padding),
      paint,
    );
    // Bottom Left
    canvas.drawPath(
      Path()
        ..moveTo(padding, size.height - padding - cornerSize)
        ..lineTo(padding, size.height - padding)
        ..lineTo(padding + cornerSize, size.height - padding),
      paint,
    );
    // Bottom Right
    canvas.drawPath(
      Path()
        ..moveTo(size.width - padding, size.height - padding - cornerSize)
        ..lineTo(size.width - padding, size.height - padding)
        ..lineTo(size.width - padding - cornerSize, size.height - padding),
      paint,
    );
  }

  @override
  bool shouldRepaint(_HudPainter oldDelegate) => false;
}
