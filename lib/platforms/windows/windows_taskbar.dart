import 'dart:async';
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:universal_html/html.dart' as html;
import '../../components/weather_service.dart';
import 'package:url_launcher/url_launcher.dart';

class WindowsTaskbar extends StatefulWidget {
  final VoidCallback onStartMenuTap;

  const WindowsTaskbar({super.key, required this.onStartMenuTap});

  @override
  State<WindowsTaskbar> createState() => _WindowsTaskbarState();
}

class _WindowsTaskbarState extends State<WindowsTaskbar> {
  // --- Battery State ---
  final Battery _battery = Battery();
  BatteryState _batteryState = BatteryState.unknown;
  int _batteryLevel = 100;
  StreamSubscription<BatteryState>? _batteryStateSubscription;

  // --- Network State ---
  final Connectivity _connectivity = Connectivity();
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  // --- ✅ Weather State ---
  final WeatherService _weatherService = WeatherService();
  String _weatherTemp = "--";
  String _weatherCondition = "Loading";
  IconData _weatherIcon = Icons.wb_sunny;
  bool _isLoadingWeather = true;

  @override
  void initState() {
    super.initState();
    _initBattery();
    _initConnectivity();
    _initWeather(); // Start fetching

    _batteryStateSubscription = _battery.onBatteryStateChanged.listen((
      BatteryState state,
    ) {
      setState(() => _batteryState = state);
    });

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> result,
    ) {
      setState(() => _connectionStatus = result);
    });
  }

  // ✅ Fetch Weather Logic
  Future<void> _initWeather() async {
    final weather = await _weatherService.getWeather();
    if (mounted && weather != null) {
      setState(() {
        _weatherTemp = weather.temperature;
        _weatherCondition = weather.condition;
        _weatherIcon = _weatherService.getWeatherIcon(weather.iconCode);
        _isLoadingWeather = false;
      });
    }
  }

  Future<void> _initBattery() async {
    try {
      final level = await _battery.batteryLevel;
      setState(() => _batteryLevel = level);
    } catch (_) {}
  }

  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      setState(() => _connectionStatus = result);
    } catch (_) {}
  }

  Future<void> _openMail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'kevinstech0@gmail.com',
      query: 'subject=Inquiry&body=Hello, I would like to reach out...',
    );

    if (!await launchUrl(emailLaunchUri)) {
      debugPrint("Could not launch email client");
    }
  }

  void _openSearchWindow() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Close",
      pageBuilder: (context, _, _) => const WindowsBrowser(),
      transitionDuration: const Duration(milliseconds: 200),
      // Simple scale animation to look like a window opening
      transitionBuilder: (context, anim, _, child) {
        return Transform.scale(
          scale: anim.value,
          child: Opacity(opacity: anim.value, child: child),
        );
      },
    );
  }

  void _openTerminalWindow() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Close",
      pageBuilder: (context, _, _) => const WindowsTerminal(),
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (context, anim, _, child) {
        return Transform.scale(
          scale: anim.value,
          child: Opacity(opacity: anim.value, child: child),
        );
      },
    );
  }

  @override
  void dispose() {
    _batteryStateSubscription?.cancel();
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  IconData _getBatteryIcon() {
    if (_batteryState == BatteryState.charging)
      return Icons.battery_charging_full;
    if (_batteryLevel >= 95) return Icons.battery_full;
    if (_batteryLevel >= 80) return Icons.battery_6_bar;
    if (_batteryLevel >= 60) return Icons.battery_5_bar;
    if (_batteryLevel >= 40) return Icons.battery_4_bar;
    if (_batteryLevel >= 20) return Icons.battery_2_bar;
    return Icons.battery_alert;
  }

  IconData _getNetworkIcon() {
    if (_connectionStatus.contains(ConnectivityResult.ethernet))
      return Icons.settings_ethernet;
    if (_connectionStatus.contains(ConnectivityResult.wifi)) return Icons.wifi;
    if (_connectionStatus.contains(ConnectivityResult.mobile))
      return Icons.signal_cellular_4_bar;
    return Icons.public_off;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF202020).withValues(alpha: 0.85),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          // ✅ 1. LEFT SIDE: Weather Widget
          // We wrap it in a container with a fixed width or just let it sit there.
          if (!_isLoadingWeather)
            _TaskbarWeather(
              temp: _weatherTemp,
              condition: _weatherCondition,
              icon: _weatherIcon,
            ),

          const Spacer(),

          // 2. CENTER: Start Button, Search & Outlook
          // 2. CENTER: Start Button, Search, Terminal & Outlook
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _TaskbarIcon(
                icon: Icons.window,
                color: Colors.blueAccent,
                onTap: widget.onStartMenuTap,
              ),
              const SizedBox(width: 8),
              _TaskbarIcon(
                icon: Icons.search,
                color: Colors.white,
                onTap: _openSearchWindow,
              ),
              const SizedBox(width: 8), 
              
              // ✅ NEW: Terminal Icon
              _TaskbarIcon(
                icon: Icons.terminal, // or Icons.code
                color: Colors.grey,   // Classic terminal grey
                onTap: _openTerminalWindow,
              ),
              
              const SizedBox(width: 8), 
              _TaskbarIcon(
                icon: Icons.email_outlined,
                color: const Color(0xFF0078D4),
                onTap: _openMail,
              ),
            ],
          ),

          const Spacer(),

          // 3. RIGHT SIDE: System Tray
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.expand_less, color: Colors.white70, size: 20),
              const SizedBox(width: 12),

              Tooltip(
                message: _connectionStatus.contains(ConnectivityResult.none)
                    ? "Not Connected"
                    : "Connected",
                child: Icon(_getNetworkIcon(), color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.volume_up, color: Colors.white, size: 20),
              const SizedBox(width: 12),

              Tooltip(
                message:
                    "$_batteryLevel% ${_batteryState == BatteryState.charging ? '(Charging)' : ''}",
                child: Icon(_getBatteryIcon(), color: Colors.white, size: 20),
              ),

              const SizedBox(width: 16),
              const WindowsClock(),
              const SizedBox(width: 10),
              Container(width: 5, color: Colors.white12),
            ],
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// ✅ NEW WIDGET: Windows 11 Style Weather Widget (Left Taskbar)
// -----------------------------------------------------------------------------
class _TaskbarWeather extends StatefulWidget {
  final String temp;
  final String condition;
  final IconData icon;

  const _TaskbarWeather({
    required this.temp,
    required this.condition,
    required this.icon,
  });

  @override
  State<_TaskbarWeather> createState() => _TaskbarWeatherState();
}

class _TaskbarWeatherState extends State<_TaskbarWeather> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        height: 40, // Matches taskbar height mostly
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: _isHovered
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Weather Icon (Sun/Cloud)
            Icon(widget.icon, color: Colors.orangeAccent, size: 24),
            const SizedBox(width: 8),

            // Text Column (Temp & Condition)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${widget.temp}°C",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.condition, // e.g., "Sunny"
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// --- UNCHANGED HELPERS ---
// -----------------------------------------------------------------------------

class _TaskbarIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _TaskbarIcon({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_TaskbarIcon> createState() => _TaskbarIconState();
}

class _TaskbarIconState extends State<_TaskbarIcon> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _isHovered
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(widget.icon, color: widget.color, size: 26),
        ),
      ),
    );
  }
}

class WindowsClock extends StatefulWidget {
  const WindowsClock({super.key});

  @override
  State<WindowsClock> createState() => _WindowsClockState();
}

class _WindowsClockState extends State<WindowsClock> {
  late Timer _timer;
  late DateTime _currentTime;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String minute = _currentTime.minute.toString().padLeft(2, '0');
    String day = _currentTime.day.toString().padLeft(2, '0');
    String month = _currentTime.month.toString().padLeft(2, '0');
    String year = _currentTime.year.toString();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          "${_currentTime.hour >= 12 ? _currentTime.hour - 12 : _currentTime.hour}:$minute ${_currentTime.hour >= 12 ? 'PM' : 'AM'}",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          "$day-$month-$year",
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// ✅ NEW: Windows Style Browser Window (Dialog)
// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------
// ✅ UPDATED: Windows Browser with Maximize, Minimize & Reload
// -----------------------------------------------------------------------------
class WindowsBrowser extends StatefulWidget {
  const WindowsBrowser({super.key});

  @override
  State<WindowsBrowser> createState() => _WindowsBrowserState();
}

class _WindowsBrowserState extends State<WindowsBrowser> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _urlFocusNode = FocusNode(); // ✅ Track focus state

  // State for Window UI
  bool _isMaximized = false;
  bool _isUrlFocused = false; // ✅ Track if address bar is active
  String? _currentUrl;
  Key _key = UniqueKey();

  @override
  void initState() {
    super.initState();
    // Listen to focus changes to update the border color
    _urlFocusNode.addListener(() {
      setState(() {
        _isUrlFocused = _urlFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _urlFocusNode.dispose();
    super.dispose();
  }

  void _navigateTo(String query) {
    if (query.trim().isEmpty) return;

    String url;
    if (query.startsWith('http')) {
      url = query;
    } else {
      url = "https://www.google.com/search?q=$query&igu=1";
    }

    setState(() {
      _currentUrl = url;
      _searchController.text = url;
      _key = UniqueKey();
    });
    // Unfocus after searching to hide the cursor/keyboard
    _urlFocusNode.unfocus(); 
  }

  void _goHome() {
    setState(() {
      _currentUrl = null;
      _searchController.clear();
    });
  }

  void _reloadPage() {
    if (_currentUrl != null) {
      setState(() => _key = UniqueKey());
    }
  }

  void _toggleMaximize() {
    setState(() {
      _isMaximized = !_isMaximized;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: _isMaximized ? size.width : 900,
          height: _isMaximized ? size.height : 600,
          decoration: BoxDecoration(
            color: const Color(0xFF202020),
            borderRadius: _isMaximized ? BorderRadius.zero : BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 20,
              ),
            ],
            border: Border.all(
              color: Colors.white24,
              width: _isMaximized ? 0 : 1,
            ),
          ),
          child: Column(
            children: [
              // --- 1. Browser Title/Address Bar ---
              Container(
                height: 45,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: const BoxDecoration(
                  color: Color(0xFF2B2B2B),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                ),
                child: Row(
                  children: [
                    _WindowControl(icon: Icons.arrow_back, onTap: _goHome),
                    _WindowControl(icon: Icons.refresh, onTap: _reloadPage),
                    const SizedBox(width: 8),

                    // ✅ Address Bar (Updated with Focus & Cursor Color)
                    Expanded(
                      child: Container(
                        height: 30,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            // Show blue border when clicked, otherwise subtle white
                            color: _isUrlFocused ? Colors.blueAccent : Colors.white12, 
                            width: 1.5,
                          ),
                        ),
                        child: TextField(
                          controller: _searchController,
                          focusNode: _urlFocusNode, // Hook up the focus node
                          cursorColor: Colors.white, // ✅ Cursor is now White!
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(Icons.lock_outline, color: Colors.green, size: 14),
                            hintText: "Search Google or type a URL",
                            hintStyle: TextStyle(color: Colors.white24),
                            contentPadding: EdgeInsets.only(bottom: 14),
                          ),
                          onSubmitted: _navigateTo,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Window Actions
                    _WindowControl(
                      icon: Icons.minimize,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    _WindowControl(
                      icon: _isMaximized ? Icons.filter_none : Icons.crop_square,
                      onTap: _toggleMaximize,
                    ),
                    _WindowControl(
                      icon: Icons.close,
                      color: Colors.redAccent,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // --- 2. Browser Body ---
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(_isMaximized ? 0 : 8),
                  ),
                  child: _currentUrl == null
                      ? _buildHomeScreen()
                      : _buildWebView(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helpers ---
  
  Widget _buildHomeScreen() {
    return Container(
      color: const Color(0xFF202020),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Google",
            style: TextStyle(
              color: Colors.white,
              fontSize: 56,
              fontWeight: FontWeight.bold,
              letterSpacing: -2,
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: 500,
            child: TextField(
              controller: _searchController,
              cursorColor: Colors.white, // ✅ Added here too
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF303030),
                hintText: "Search Google or type a URL",
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: _navigateTo,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebView() {
    final viewId = 'iframe-view-${_currentUrl.hashCode}';
    
    // Use 'try-catch' purely to ignore "re-registration" errors during hot reload
    try {
      ui_web.platformViewRegistry.registerViewFactory(
        viewId,
        (int viewId) {
          final iframe = html.IFrameElement();
          iframe.src = _currentUrl!;
          iframe.style.height = '100%';
          iframe.style.width = '100%';
          iframe.style.border = 'none';
          return iframe;
        },
      );
    } catch (_) {}

    return HtmlElementView(
      key: _key,
      viewType: viewId,
    );
  }
}

// Helper for window buttons
class _WindowControl extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _WindowControl({
    required this.icon,
    this.color = Colors.white70,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}


// -----------------------------------------------------------------------------
// ✅ NEW: Windows Terminal (CLI Portfolio)
// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------
// ✅ FIXED: Windows Terminal (Working Controls + Visible Text)
// -----------------------------------------------------------------------------
class WindowsTerminal extends StatefulWidget {
  const WindowsTerminal({super.key});

  @override
  State<WindowsTerminal> createState() => _WindowsTerminalState();
}

class _WindowsTerminalState extends State<WindowsTerminal> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  final List<Widget> _consoleOutput = [];
  
  bool _isMaximized = false;
  bool _isBooting = true; 

  @override
  void initState() {
    super.initState();
    _runBootSequence();
  }

  Future<void> _runBootSequence() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Boot logs don't need typing animation (they usually scroll fast)
    // keeping them as static Text for the "boot" feel, but updating font.
    const bootLogs = [
      "[0.000000] Linux version 5.15.0-kevin-os (gcc version 11.2.0)",
      "[0.234120] CPU: ARMv8 Processor [410fd034] revision 4",
      "[0.245000] Machine model: Kevin's Portfolio Board",
      "[0.455112] Memory: 32GB available",
      "[0.612000] Regulating core voltage... [ OK ]",
      "[0.899000] Initializing DSPWorks Firmware modules... [ OK ]",
      "[1.000223] Mounting /dev/root on /... [ OK ]",
      "[1.150000] Starting Network Manager... [ OK ]",
      "---------------------------------------------------",
      " Welcome to KevinOS v1.0.0 LTS",
      " Type 'help' to see available commands.",
      "---------------------------------------------------",
    ];

    for (String log in bootLogs) {
      await Future.delayed(Duration(milliseconds: 50 + (log.length * 2)));
      if (!mounted) return;
      
      setState(() {
        _consoleOutput.add(
          Text(
            log,
            style: const TextStyle(
              color: Colors.grey, 
              fontFamily: 'monospace', // ✅ FIXED FONT
              fontSize: 13
            ),
          ),
        );
      });
      _scrollToBottom();
    }

    setState(() => _isBooting = false);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _focusNode.requestFocus();
    });
  }

  void _handleCommand(String input) {
    if (input.trim().isEmpty) return;
    
    setState(() {
      // 1. Echo User Command (Instant, no animation needed here)
      _consoleOutput.add(
        RichText(
          text: TextSpan(
            children: [
               const TextSpan(
                 text: "kevin@portfolio:~\$ ", 
                 style: TextStyle(color: Color(0xFF00FF00), fontWeight: FontWeight.bold, fontFamily: 'monospace')
               ),
               TextSpan(
                 text: input, 
                 style: const TextStyle(color: Colors.white, fontFamily: 'monospace')
               ),
            ]
          )
        )
      );

      final command = input.toLowerCase().trim();

      // 2. Process Response (With Typing Animation)
      switch (command) {
        case 'help':
          _addAnimatedResponse(_asciiHelp, Colors.yellowAccent);
          break;
        case 'clear':
          _consoleOutput.clear();
          break;
        case 'exit':
          Navigator.of(context).pop();
          break;

        case 'about':
          _addAnimatedResponse(_asciiAbout, Colors.yellowAccent); 
          _addAnimatedSection("BIO", [
             "I am Kevin Shah, an enthusiastic Developer & Engineer.",
             "Currently pursuing Masters in AI & ML at University of Adelaide [2025-2027].",
             "Passionate about Agentic AI, Embedded Systems, and solving complex problems.",
             "Origins: Gujarat, India 🇮🇳 -> Now: Adelaide, SA 🇦🇺"
          ]);
          break;

        case 'education':
          _addAnimatedResponse(_asciiEdu, Colors.yellowAccent);
          _addAnimatedSection("MASTERS IN AI & ML (2025 - Present)", [
             "University of Adelaide, Australia",
             "Focus: Agentic AI, RAG, Machine Learning"
          ]);
          _addAnimatedSection("BACHELOR OF COMPUTER SCIENCE (2021 - 2024)", [
             "Babaria Institute of Technology",
             "CGPA: 8.65/10.0"
          ]);
          _addAnimatedSection("DIPLOMA IN MECHATRONICS (2018 - 2021)", [
             "ITM Vocational University",
             "CGPA: 9.21/10.0"
          ]);
          break;

        case 'skills':
          _addAnimatedResponse(_asciiSkills, Colors.yellowAccent);
          _addAnimatedSection("AI & MACHINE LEARNING", [
             "Python, RAG Pipelines, Agentic Systems, LLMs",
             "Data Processing, Automation"
          ]);
          _addAnimatedSection("WEB & BACKEND", [
             "PHP, Laravel, REST APIs, WordPress Automation",
             "Google Cloud, Firebase, MySQL"
          ]);
          _addAnimatedSection("MOBILE & EMBEDDED", [
             "Flutter (App Dev), C Programming, Microcontrollers",
             "IoT Security, Firmware Development"
          ]);
          _addAnimatedSection("TOOLS", ["Git, VS Code, SAP Cloud Analytics"]);
          break;

        case 'experience':
          _addAnimatedResponse(_asciiExp, Colors.yellowAccent);
          
          _addAnimatedSection("DSPWORKS [2024-2025]", [
            "Role: Embedded Firmware Developer",
            "• Developed firmware for microcontroller systems.",
            "• Optimized hardware-software integration & PCB schematics."
          ]);
          _addAnimatedSection("WIZARD INFOSYS [2023-2024]", [
            "Role: Backend Web Developer",
            "• Built automated WordPress page creation tools using ChatGPT API.",
            "• Developed Flutter Stock Management App with PHP backend."
          ]);
          _addAnimatedSection("EDUNET FOUNDATION [2023]", [
            "Role: Cyber Security Intern",
            "• Researched Zero-day vulnerabilities & IoT Security.",
            "• Explored SAP Cloud Analytics & Industry 4.0."
          ]);

          _consoleOutput.add(const SizedBox(height: 10));
          _addAnimatedSection("🚀 FREELANCE & MAJOR PROJECTS", [
            "1. AI-POWERED WORDPRESS BOT",
            "   • Integrated OpenAI GPT to auto-generate & publish content.",
            "",
            "2. RAG-BASED Q&A PROTOTYPE",
            "   • Python pipeline using Vector Databases for document retrieval.",
            "",
            "3. AGENTIC AI EXPLORATION",
            "   • Experiments with LangChain for multi-step reasoning tasks.",
            "",
            "4. JSF WORLD PRODUCTIONS (Freelance)",
            "   • Full-stack web dev & graphic design for fashion events.",
            "",
            "5. ENGINEERING PROJECT MAKER",
            "   • Built AGVs (Automated Guided Vehicles), Drones, and",
            "     Smart Farming systems for university students.",
            "   • Custom IoT solutions using ESP32 & Raspberry Pi."
          ]);
          break;

        case 'contact':
          _addAnimatedSection("CONTACT DETAILS", [
            "📧 Email: kevinstech0@gmail.com",
            "📞 Phone: +61 0485 516 100",
            "🐙 GitHub: github.com/TechoChat",
            "💼 LinkedIn: linkedin.com/in/techochat/"
          ]);
          break;

        default:
          _addAnimatedResponse("Command '$command' not found. Try 'help'.", Colors.redAccent);
      }
      
      _consoleOutput.add(const SizedBox(height: 10)); 
    });

    _inputController.clear();
    _scrollToBottom();
    _focusNode.requestFocus();
  }

  // ✅ Helper for single line animated text
  void _addAnimatedResponse(String text, Color color) {
    _consoleOutput.add(
      TypewriterText(
        text: text, 
        style: TextStyle(
          color: color, 
          fontWeight: FontWeight.bold, 
          // ❌ WAS: fontFamily: 'Areal'
          // ✅ CHANGE TO:
          fontFamily: 'Courier New', // or 'monospace'
          height: 1.2, // Helps distinct lines
        ),
      )
    );
  }

  // ✅ Helper for sections
  void _addAnimatedSection(String title, List<String> lines) {
    // 1. Add Title
    _consoleOutput.add(
      TypewriterText(
        text: "➜ $title", 
        speed: const Duration(milliseconds: 10), // Fast title
        style: const TextStyle(
          color: Colors.cyanAccent, 
          fontWeight: FontWeight.bold, 
          fontFamily: 'monospace'
        ),
      )
    );

    // 2. Add Content Lines
    // We combine lines into one block or separate them. 
    // Combining them ensures they don't type "over" each other visually if they load instant.
    String fullContent = lines.map((l) => "  $l").join("\n");
    
    _consoleOutput.add(
      TypewriterText(
        text: fullContent, 
        speed: const Duration(milliseconds: 5), // Super fast content typing
        style: const TextStyle(
          color: Colors.white, 
          fontFamily: 'monospace',
          height: 1.2,
        ),
      )
    );
    _consoleOutput.add(const SizedBox(height: 5));
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: _isMaximized ? size.width : 850,
          height: _isMaximized ? size.height : 600,
          decoration: BoxDecoration(
            color: const Color(0xFF0C0C0C),
            borderRadius: _isMaximized ? BorderRadius.zero : BorderRadius.circular(6),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 30)],
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            children: [
              // --- TITLE BAR ---
              Container(
                height: 32,
                color: const Color(0xFF1F1F1F),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    const Icon(Icons.terminal, color: Colors.greenAccent, size: 16),
                    const SizedBox(width: 8),
                    const Text("KevinOS - /bin/bash", style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const Spacer(),
                    _WindowControl(icon: Icons.minimize, onTap: () => Navigator.pop(context)),
                    _WindowControl(
                      icon: _isMaximized ? Icons.filter_none : Icons.crop_square, 
                      onTap: () => setState(() => _isMaximized = !_isMaximized)
                    ),
                    _WindowControl(icon: Icons.close, color: Colors.redAccent, onTap: () => Navigator.pop(context)),
                  ],
                ),
              ),

              // --- BODY ---
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  color: const Color(0xFF0C0C0C).withOpacity(0.95),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✅ List Output
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: _consoleOutput.length,
                          itemBuilder: (context, index) {
                            return _consoleOutput[index];
                          },
                        ),
                      ),
                      
                      // Input Line
                      if (!_isBooting)
                        Row(
                          children: [
                            const Text(
                              "kevin@portfolio:~\$ ",
                              style: TextStyle(color: Color(0xFF00FF00), fontFamily: 'monospace', fontWeight: FontWeight.bold),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _inputController,
                                focusNode: _focusNode,
                                onSubmitted: _handleCommand,
                                cursorColor: Colors.white,
                                cursorWidth: 2,
                                style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
                                decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 🎨 ASCII ART ASSETS 
// -----------------------------------------------------------------------------
const String _asciiHelp = """
Commands:
  [ about      ]  -  Bio & Info
  [ experience ]  -  Work History
  [ skills     ]  -  Tech Stack
  [ education  ]  -  Academics
  [ contact    ]  -  Get in touch
  [ clear      ]  -  Clear screen
""";

const String _asciiAbout = """
    _    ____   ___  _   _ _____ 
   / \\  | __ ) / _ \\| | | |_   _|
  / _ \\ |  _ \\| | | | | | | | |  
 / ___ \\| |_) | |_| | |_| | | |  
/_/   \\_\\____/ \\___/ \\___/  |_|  
""";

const String _asciiSkills = """
 ____  _  _____ _     _     ____  
/ ___|| |/ /_ _| |   | |   / ___| 
\\___ \\| ' / | || |   | |   \\___ \\ 
 ___) | . \\ | || |___| |___ ___) |
|____/|_|\\_\\___|_____|_____|____/ 
""";

const String _asciiExp = """
 _______  ______  
| ____\\ \\/ /  _ \\ 
|  _|  \\  /| |_) |
| |___ /  \\|  __/ 
|_____/_/\\_\\_|    
""";

const String _asciiEdu = """
 _____ ____  _   _ 
| ____|  _ \\| | | |
|  _| | | | | | | |
| |___| |_| | |_| |
|_____|____/ \\___/ 
""";


// -----------------------------------------------------------------------------
// ✅ NEW: Typewriter Animation Widget
// -----------------------------------------------------------------------------
class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration speed;
  final VoidCallback? onComplete;

  const TypewriterText({
    super.key, 
    required this.text, 
    required this.style, 
    this.speed = const Duration(milliseconds: 15), // Faster for smoother CLI feel
    this.onComplete,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  String _displayedText = "";
  late Timer _timer;
  int _charIndex = 0;

  @override
  void initState() {
    super.initState();
    // Start typing immediately when the widget is built
    _timer = Timer.periodic(widget.speed, (timer) {
      if (_charIndex < widget.text.length) {
        if (mounted) {
          setState(() {
            _displayedText += widget.text[_charIndex];
            _charIndex++;
          });
        }
      } else {
        _timer.cancel();
        widget.onComplete?.call();
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
    return Text(
      _displayedText,
      softWrap: false, // Prevents wrapping which breaks ASCII art
      overflow: TextOverflow.visible,
      style: widget.style,
    );
  }
}