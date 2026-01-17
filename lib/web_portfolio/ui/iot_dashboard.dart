import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class IotDashboard extends StatefulWidget {
  const IotDashboard({super.key});

  @override
  State<IotDashboard> createState() => _IotDashboardState();
}

class _IotDashboardState extends State<IotDashboard> {
  // Simulating sensor data
  double _mancaveTemp = 18.4;
  double _outsideTemp = 16.0;
  double _fanSpeed = 31.0;
  bool _mancaveLight = true;
  bool _hallwayLamp = false;

  // Chart Data
  List<double> _chartData = List.generate(
    20,
    (index) => 18.0 + math.Random().nextDouble(),
  );

  late Timer _timer;
  final math.Random _rng = math.Random();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        setState(() {
          // Subtle fluctuations
          _mancaveTemp = (_mancaveTemp + (_rng.nextDouble() - 0.5) * 0.5).clamp(
            10.0,
            30.0,
          );
          _outsideTemp = (_outsideTemp + (_rng.nextDouble() - 0.5) * 0.2).clamp(
            -10.0,
            40.0,
          );

          // Update Chart
          _chartData.add(_mancaveTemp);
          if (_chartData.length > 20) _chartData.removeAt(0);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF141414), // Dark Background
        cardColor: const Color(0xFF1F1F1F), // Slightly lighter cards
        colorScheme: const ColorScheme.dark(
          primary: Colors.amber,
          secondary: Colors.amberAccent,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.build, size: 16, color: Colors.white70),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // We'll use a wrap or a custom column/row layout depending on width
              // For simplicity in a dashboard, let's use a Column of Rows for the specific layout in image
              // Top Row: Clock (Large), Gauge(Medium), Switches(Medium)
              // Mid Row: LinearGauge, Chart, Fan Control
              // But to make it responsive, we use a Wrap with fixed-width logic or Flex.

              // Let's try a Masonry-style GridView with set aspect ratios
              return SingleChildScrollView(
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.start,
                  children: [
                    // --- ROW 1 ---
                    _DashboardCard(
                      width: 300,
                      height: 150,
                      child: const _DigitalClock(),
                    ),
                    _DashboardCard(
                      width: 300,
                      height: 250,
                      child: _RadialGauge(
                        title: "Mancave temp",
                        value: _mancaveTemp,
                        min: -5,
                        max: 40,
                        unit: "Degrees C",
                      ),
                    ),
                    _DashboardCard(
                      width: 300,
                      height: 200,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _DeviceSwitch(
                            label: "Mancave light",
                            isOn: _mancaveLight,
                            onChanged: (v) => setState(() => _mancaveLight = v),
                          ),
                          const Divider(color: Colors.white10),
                          _DeviceSwitch(
                            label: "Hallway lamp",
                            isOn: _hallwayLamp,
                            onChanged: (v) => setState(() => _hallwayLamp = v),
                          ),
                        ],
                      ),
                    ),

                    // --- ROW 2 / Mixed ---
                    _DashboardCard(
                      width: 300,
                      height: 200,
                      child: _LinearGauge(
                        title: "Outside temperature",
                        value: _outsideTemp,
                        min: -10,
                        max: 40,
                        unit: "Degrees C",
                      ),
                    ),

                    _DashboardCard(
                      width: 300,
                      height: 250,
                      child: _LineChartWidget(
                        title: "Mancave temperature",
                        data: _chartData,
                        currentValue: _mancaveTemp,
                      ),
                    ),

                    // Fan Speed
                    _DashboardCard(
                      width: 300,
                      height: 120,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Fan Speed  ${_fanSpeed.toInt()}",
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 10),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: Colors.amber,
                              thumbColor: Colors.white,
                              inactiveTrackColor: Colors.grey[800],
                              trackHeight: 8,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 10,
                              ),
                            ),
                            child: Slider(
                              value: _fanSpeed,
                              min: 0,
                              max: 100,
                              onChanged: (v) => setState(() => _fanSpeed = v),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Status List
                    _DashboardCard(
                      width: 300,
                      height: 220,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _StatusItem(
                            label: "Luc is in",
                            isOn: true,
                            group: "Operating",
                          ),
                          const SizedBox(height: 16),
                          _StatusItem(label: "Els is out", isOn: false),
                          const SizedBox(height: 16),
                          _StatusItem(
                            label: "Functioning",
                            isOn: true,
                            group: "Thermometer",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// --- WIDGETS ---

class _DashboardCard extends StatelessWidget {
  final double width;
  final double height;
  final Widget child;

  const _DashboardCard({
    required this.width,
    required this.height,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Responsive width adjustment: If screen is small, take full width
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth < 340 ? screenWidth - 32 : width;

    return Container(
      width: cardWidth,
      height: height,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(4), // Sharp corners like dashboard
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _DigitalClock extends StatefulWidget {
  const _DigitalClock();
  @override
  State<_DigitalClock> createState() => _DigitalClockState();
}

class _DigitalClockState extends State<_DigitalClock> {
  late Timer _timer;
  String _time = "";

  @override
  void initState() {
    super.initState();
    _time = _format();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (t) => setState(() => _time = _format()),
    );
  }

  String _format() => DateFormat('HH:mm:ss').format(DateTime.now());

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "The time",
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          _time,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 42,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }
}

class _RadialGauge extends StatelessWidget {
  final String title;
  final double value;
  final double min;
  final double max;
  final String unit;

  const _RadialGauge({
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(180, 100),
                painter: _RadialPainter(value: value, min: min, max: max),
              ),
              Positioned(
                bottom: 20,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      value.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      unit,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                left: 10,
                child: Text(
                  min.toStringAsFixed(0),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 10,
                child: Text(
                  max.toStringAsFixed(0),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RadialPainter extends CustomPainter {
  final double value;
  final double min;
  final double max;

  _RadialPainter({required this.value, required this.min, required this.max});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = math.min(size.width / 2, size.height) - 10;

    // Background Arc (Grey)
    final bgPaint = Paint()
      ..color = Colors.grey[800]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 25
      ..strokeCap = StrokeCap.butt; // Flat ends

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi, // Start at 180 degrees
      math.pi, // Sweep 180 degrees
      false,
      bgPaint,
    );

    // Foreground Arc (Gradient: Orange -> White)
    // Map value to angle
    final percent = (value - min) / (max - min);
    final sweepAngle = math.pi * percent.clamp(0.0, 1.0);

    final fgPaint = Paint()
      ..shader = const SweepGradient(
        colors: [Colors.amber, Colors.white],
        startAngle: math.pi,
        endAngle: 2 * math.pi,
        tileMode: TileMode.clamp,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 25
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      sweepAngle,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_RadialPainter oldDelegate) => oldDelegate.value != value;
}

class _LinearGauge extends StatelessWidget {
  final String title;
  final double value;
  final double min;
  final double max;
  final String unit;

  const _LinearGauge({
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (value - min) / (max - min);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 20),
        Row(
          children: [
            Text(
              min.toStringAsFixed(0),
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 30,
                decoration: BoxDecoration(
                  color: Colors
                      .white, // Background track (White as per image style inverse?)
                  // Actually image shows White background, Yellow fill.
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: percent.clamp(0.0, 1.0),
                    heightFactor: 1.0,
                    child: Container(color: Colors.amber),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              max.toStringAsFixed(0),
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Center(
          child: Column(
            children: [
              Text(
                value.toStringAsFixed(0),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                unit,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DeviceSwitch extends StatelessWidget {
  final String label;
  final bool isOn;
  final ValueChanged<bool> onChanged;

  const _DeviceSwitch({
    required this.label,
    required this.isOn,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => onChanged(!isOn),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF2A2A2A),
              border: Border.all(
                color: isOn ? Colors.amber : Colors.grey[700]!,
                width: 2,
              ),
              boxShadow: isOn
                  ? [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.4),
                        blurRadius: 8,
                      ),
                    ]
                  : [],
            ),
            alignment: Alignment.center,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isOn ? Colors.amber : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              isOn ? "On" : "Off",
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }
}

class _LineChartWidget extends StatelessWidget {
  final String title;
  final List<double> data;
  final double currentValue;

  const _LineChartWidget({
    required this.title,
    required this.data,
    required this.currentValue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const Icon(Icons.menu, color: Colors.grey, size: 20),
          ],
        ),
        Expanded(
          child: Row(
            children: [
              // Y Axis Labels (Simple)
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Values",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      textBaseline: TextBaseline.alphabetic,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CustomPaint(
                  painter: _ChartPainter(data: data),
                  child: Container(),
                ),
              ),
            ],
          ),
        ),
        Center(
          child: Column(
            children: [
              Text(
                DateFormat('HH:mm:ss.S').format(DateTime.now()),
                style: const TextStyle(color: Colors.grey, fontSize: 10),
              ),
              const Text(
                "Time",
                style: TextStyle(color: Colors.grey, fontSize: 10),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.teal,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    "Series 1",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<double> data;
  _ChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = Colors.teal
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final gridPaint = Paint()
      ..color = Colors.grey[800]!
      ..strokeWidth = 1;

    // Draw Grid
    for (int i = 0; i < 5; i++) {
      double y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final path = Path();
    final double xStep = size.width / (data.length - 1);

    // Auto scale
    double minVal = data.reduce(math.min);
    double maxVal = data.reduce(math.max);
    if ((maxVal - minVal).abs() < 0.1) maxVal += 1.0; // Avoid div by zero

    for (int i = 0; i < data.length; i++) {
      double x = i * xStep;
      // Normalized height 0..1
      double n = (data[i] - minVal) / (maxVal - minVal);
      double y = size.height - (n * size.height);

      if (i == 0)
        path.moveTo(x, y);
      else
        path.lineTo(x, y);

      // Draw Point
      if (i == data.length - 1) {
        // Current value dot
        canvas.drawCircle(Offset(x, y), 4, Paint()..color = Colors.teal);
      }
    }

    canvas.drawPath(path, paint);

    // Draw Current Value Text Line
    // ... optional
  }

  @override
  bool shouldRepaint(_ChartPainter old) => true;
}

class _StatusItem extends StatelessWidget {
  final String label;
  final bool isOn;
  final String? group;

  const _StatusItem({required this.label, required this.isOn, this.group});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (group != null) ...[
          Text(
            group!,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 8),
        ],
        Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2A2A2A),
                border: Border.all(
                  color: isOn ? Colors.amber : Colors.grey[800]!,
                ),
              ),
              alignment: Alignment.center,
              child: isOn
                  ? Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }
}
