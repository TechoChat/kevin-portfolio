import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../components/weather_service.dart';
import 'apps/android_chrome.dart';
import '../../components/made_with_flutter.dart';
import 'apps/android_contact.dart';
import 'apps/android_calculator.dart';
import 'android_status_bar.dart';

// --- DATA MODEL FOR APPS ---
class _AppModel {
  final String name;
  final String asset;
  final String? url;
  final WidgetBuilder? pageRoute;
  final bool isTerminal;
  final IconData? iconData;
  final Color bgColor;

  _AppModel({
    required this.name,
    required this.asset,
    this.url,
    this.pageRoute,
    this.isTerminal = false,
    this.iconData,
    this.bgColor = Colors.white,
  });
}

class AndroidHome extends StatefulWidget {
  final ValueChanged<TargetPlatform> onPlatformSwitch;

  const AndroidHome({super.key, required this.onPlatformSwitch});

  @override
  State<AndroidHome> createState() => _AndroidHomeState();
}

class _AndroidHomeState extends State<AndroidHome>
    with SingleTickerProviderStateMixin {
  late Timer _clockTimer;
  DateTime _currentTime = DateTime.now();

  // Weather State
  final WeatherService _weatherService = WeatherService();
  String _weatherTemp = "--";
  IconData _weatherIcon = Icons.cloud_sync;
  String _weatherCity = "";
  bool _isLoadingWeather = true;

  // Drawer State
  bool _isDrawerOpen = false;
  final TextEditingController _drawerSearchController = TextEditingController();

  // App Data & Filtering
  late List<_AppModel> _allApps;
  late List<_AppModel> _filteredApps;

  @override
  void initState() {
    super.initState();
    _initWeather();
    _initApps(); // Initialize app list

    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _currentTime = DateTime.now());
    });
  }

  // --- INITIALIZE APPS LIST ---
  void _initApps() {
    _allApps = [
      _AppModel(
        name: "Gmail",
        asset: "gmail",
        url: "mailto:kevinstech0@gmail.com",
      ),
      _AppModel(
        name: "Maps",
        asset: "maps",
        url: "http://maps.google.com",
      ),
      _AppModel(
        name: "GitHub",
        asset: "github",
        url: "https://github.com/TechoChat",
      ),
      _AppModel(
        name: "YouTube",
        asset: "youtube",
        url: "https://youtube.com",
      ),
      _AppModel(
        name: "Acrobat",
        asset: "pdf",
        url:
            "https://drive.google.com/file/d/1_YtPDqTXcC_eBlAPqsHSq3G1n_2_MJPs/view?usp=sharing",
      ),
      _AppModel(
        name: "Chrome",
        asset: "chrome",
        pageRoute: (_) => const AndroidChrome(),
      ),
      _AppModel(
        name: "Contacts",
        asset: "google_contacts",
        iconData: Icons.person,
        pageRoute: (_) => const AndroidContact(),
      ),
      _AppModel(
        name: "LinkedIn",
        asset: "linkedin",
        url: "https://linkedin.com/in/techochat",
      ),
      _AppModel(
        name: "Calculator",
        asset: "calculator",
        iconData: Icons.calculate,
        pageRoute: (_) => const AndroidCalculator(),
      ),
      _AppModel(
        name: "Terminal",
        asset: "terminal",
        isTerminal: true,
      ),
      _AppModel(
        name: "Settings",
        asset: "settings",
        bgColor: Colors.grey,
        url: "", // Dummy
      ),
    ];
    _filteredApps = List.from(_allApps);
  }

  // --- SEARCH FUNCTIONALITY ---
  void _runFilter(String enteredKeyword) {
    List<_AppModel> results = [];
    if (enteredKeyword.isEmpty) {
      results = List.from(_allApps);
    } else {
      results =
          _allApps
              .where(
                (app) => app.name.toLowerCase().contains(
                  enteredKeyword.toLowerCase(),
                ),
              )
              .toList();
    }

    setState(() {
      _filteredApps = results;
    });
  }

  // --- OPEN SEARCH PAGE ---
  void _openSearchPage() {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                const GoogleSearchPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  // --- OPEN TERMINAL ---
  void _openTerminal() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, anim, secAnim) => const AndroidTerminal(),
        transitionsBuilder: (context, anim, secAnim, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: anim, curve: Curves.easeOutQuart),
            ),
            child: child,
          );
        },
      ),
    );
  }

  void _toggleDrawer(bool open) {
    setState(() {
      _isDrawerOpen = open;
      if (!open) {
        // Clear search when closing drawer
        _drawerSearchController.clear();
        _runFilter("");
        FocusScope.of(context).unfocus(); // Hide keyboard
      }
    });
  }

  Future<void> _launchUrl(String url) async {
    if (url.isEmpty) return;
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _initWeather() async {
    final weather = await _weatherService.getWeather();
    if (mounted && weather != null) {
      setState(() {
        _weatherTemp = weather.temperature;
        _weatherIcon = _weatherService.getWeatherIcon(weather.iconCode);
        _weatherCity = weather.cityName;
        _isLoadingWeather = false;
      });
    } else if (mounted) {
      setState(() {
        _weatherTemp = "24";
        _isLoadingWeather = false;
      });
    }
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    _drawerSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // -----------------------------------------------------------
            // 1. HOME SCREEN LAYER
            // -----------------------------------------------------------
            Positioned.fill(
              child: GestureDetector(
                onVerticalDragEnd: (details) {
                  // Swipe UP to open drawer
                  if (details.primaryVelocity! < -300 && !_isDrawerOpen) {
                    _toggleDrawer(true);
                  }
                },
                child: Stack(
                  children: [
                    // Wallpaper
                    Positioned.fill(
                      child: Image.asset(
                        'assets/img/android/android.webp',
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                        opacity: const AlwaysStoppedAnimation(0.7),
                      ),
                    ),
                    // Gradient Overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.3),
                              Colors.transparent,
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.4),
                            ],
                            stops: const [0.0, 0.2, 0.8, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // Main Content
                    SafeArea(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            child: AndroidStatusBar(iconColor: Colors.white),
                          ),
                          // "At A Glance"
                          Padding(
                            padding: const EdgeInsets.only(top: 10, left: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat('E, MMM d').format(_currentTime),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Roboto',
                                    shadows: [
                                      Shadow(
                                        color: Colors.black38,
                                        blurRadius: 4,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    if (_isLoadingWeather)
                                      const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    else
                                      Icon(
                                        _weatherIcon,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "$_weatherTemp°C in $_weatherCity",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),

                          // Home Grid (Static Favorites)
                          SizedBox(
                            height: 290,
                            child: GridView.count(
                              crossAxisCount: 4,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              mainAxisSpacing: 20,
                              crossAxisSpacing: 10,
                              childAspectRatio: 0.75,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                // Standard Shortcuts
                                GestureDetector(
                                  onTap:
                                      () => _launchUrl(
                                        "mailto:kevinstech0@gmail.com",
                                      ),
                                  child: const _AndroidAppIcon(
                                    name: "Gmail",
                                    asset: "gmail",
                                    bgColor: Colors.white,
                                  ),
                                ),
                                GestureDetector(
                                  onTap:
                                      () => _launchUrl(
                                        "http://maps.google.com",
                                      ),
                                  child: const _AndroidAppIcon(
                                    name: "Maps",
                                    asset: "maps",
                                    bgColor: Colors.white,
                                  ),
                                ),
                                GestureDetector(
                                  onTap:
                                      () => _launchUrl(
                                        "https://github.com/TechoChat",
                                      ),
                                  child: const _AndroidAppIcon(
                                    name: "github",
                                    asset: "github",
                                    bgColor: Colors.white,
                                  ),
                                ),
                                GestureDetector(
                                  onTap:
                                      () => _launchUrl("https://youtube.com"),
                                  child: const _AndroidAppIcon(
                                    name: "YouTube",
                                    asset: "youtube",
                                    bgColor: Colors.white,
                                  ),
                                ),
                                GestureDetector(
                                  onTap:
                                      () => _launchUrl(
                                        "https://drive.google.com/file/d/1_YtPDqTXcC_eBlAPqsHSq3G1n_2_MJPs/view?usp=sharing",
                                      ),
                                  child: const _AndroidAppIcon(
                                    name: "Acrobat",
                                    asset: "pdf",
                                    bgColor: Colors.white,
                                  ),
                                ),
                                const _AndroidAppIcon(
                                  name: "Settings",
                                  asset: "settings",
                                  bgColor: Colors.grey,
                                ),
                                // Switch Platform Icon
                                GestureDetector(
                                  onTap:
                                      () => widget.onPlatformSwitch(
                                        TargetPlatform.iOS,
                                      ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 52,
                                        height: 52,
                                        decoration: const BoxDecoration(
                                          color: Colors.black,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.apple,
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      const Text(
                                        "Move to iOS",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Dock Area
                          Container(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // --- MOUSE/DESKTOP DRAWER TRIGGER ---
                                // A visual handle that can be clicked to open drawer
                                GestureDetector(
                                  onTap: () => _toggleDrawer(true),
                                  onVerticalDragEnd: (details) {
                                    if (details.primaryVelocity! < 0) {
                                      _toggleDrawer(true);
                                    }
                                  },
                                  child: Container(
                                    color: Colors
                                        .transparent, // Hit test area boost
                                    padding: const EdgeInsets.only(
                                      bottom: 10,
                                      top: 10,
                                    ),
                                    child: Column(
                                      children: [
                                        const Icon(
                                          Icons.keyboard_arrow_up,
                                          color: Colors.white70,
                                          size: 20,
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          width: 32,
                                          height: 4,
                                          decoration: BoxDecoration(
                                            color: Colors.white24,
                                            borderRadius: BorderRadius.circular(
                                              2,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Dock Icons
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    GestureDetector(
                                      onTap:
                                          () => Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder:
                                                  (_) => const AndroidContact(),
                                            ),
                                          ),
                                      child: const _AndroidAppIcon(
                                        name: "",
                                        asset: "google_contacts",
                                        iconData: Icons.person,
                                        showLabel: false,
                                        bgColor: Color(0xFFE8F0FE),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap:
                                          () => _launchUrl(
                                            "https://linkedin.com/in/techochat",
                                          ),
                                      child: const _AndroidAppIcon(
                                        name: "",
                                        asset: "linkedin",
                                        showLabel: false,
                                        bgColor: Color(0xFFE8F0FE),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap:
                                          () => Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder:
                                                  (_) => const AndroidChrome(),
                                            ),
                                          ),
                                      child: const _AndroidAppIcon(
                                        name: "",
                                        asset: "chrome",
                                        showLabel: false,
                                        bgColor: Colors.transparent,
                                      ),
                                    ),
                                    const _AndroidAppIcon(
                                      name: "",
                                      asset: "camera",
                                      showLabel: false,
                                      bgColor: Color(0xFFEFEFEF),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),

                                // Google Search Bar (Home)
                                GestureDetector(
                                  onTap: _openSearchPage,
                                  child: Hero(
                                    tag: 'search_bar_hero',
                                    child: Material(
                                      color: Colors.transparent,
                                      child: Container(
                                        height: 52,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF0F1F5),
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        child: Row(
                                          children: [
                                            Image.asset(
                                              'assets/img/android/icons/google_g.webp',
                                              width: 26,
                                            ),
                                            const SizedBox(width: 14),
                                            Expanded(
                                              child: Text(
                                                "Search...",
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ),
                                            Image.asset(
                                              'assets/img/android/icons/google_mic.png',
                                              width: 24,
                                            ),
                                            const SizedBox(width: 18),
                                            Image.asset(
                                              'assets/img/android/icons/google_lens.png',
                                              width: 24,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                // Bottom Navigation Bar Indicator
                                Container(
                                  width: 48,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[400],
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // -----------------------------------------------------------
            // 2. APP DRAWER OVERLAY (With Functional Search & Grid)
            // -----------------------------------------------------------
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutQuart,
              top: _isDrawerOpen ? 0 : size.height,
              bottom: _isDrawerOpen ? 0 : -size.height,
              left: 0,
              right: 0,
              child: GestureDetector(
                onVerticalDragEnd: (details) {
                  // Swipe DOWN to close drawer
                  if (details.primaryVelocity! > 300 && _isDrawerOpen) {
                    _toggleDrawer(false);
                  }
                },
                child: Container(
                  color: Colors.white.withValues(alpha: 0.95),
                  child: SafeArea(
                    child: Column(
                      children: [
                        // Search Bar in Drawer (Functional)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: TextField(
                            controller: _drawerSearchController,
                            onChanged: _runFilter,
                            autofocus: false,
                            decoration: InputDecoration(
                              hintText: "Search apps...",
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Colors.grey,
                              ),
                              suffixIcon:
                                  _drawerSearchController.text.isNotEmpty
                                      ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () {
                                          _drawerSearchController.clear();
                                          _runFilter("");
                                        },
                                      )
                                      : null,
                              filled: true,
                              fillColor: const Color(0xFFF0F1F5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 0,
                              ),
                            ),
                          ),
                        ),

                        // Filtered Apps Grid
                        Expanded(
                          child:
                              _filteredApps.isEmpty
                                  ? const Center(
                                    child: Text("No apps found"),
                                  )
                                  : GridView.builder(
                                    padding: const EdgeInsets.all(16),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 5,
                                          mainAxisSpacing: 20,
                                          crossAxisSpacing: 10,
                                          childAspectRatio: 0.75,
                                        ),
                                    itemCount: _filteredApps.length,
                                    physics: const BouncingScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      final app = _filteredApps[index];
                                      return GestureDetector(
                                        onTap: () {
                                          _toggleDrawer(
                                            false,
                                          ); // Close drawer
                                          if (app.isTerminal) {
                                            _openTerminal();
                                          } else if (app.pageRoute != null) {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: app.pageRoute!,
                                              ),
                                            );
                                          } else if (app.url != null &&
                                              app.url!.isNotEmpty) {
                                            _launchUrl(app.url!);
                                          }
                                        },
                                        child: _AndroidAppIcon(
                                          name: app.name,
                                          asset: app.asset,
                                          bgColor: app.bgColor,
                                          showLabel: true,
                                          appDrawer: true,
                                          isTerminal: app.isTerminal,
                                          iconData: app.iconData,
                                        ),
                                      );
                                    },
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// ANDROID TERMINAL, TYPEWRITER, ICONS, SEARCH PAGE
// (Keep existing classes below unmodified)
// ---------------------------------------------------------
// ... [The rest of your file: AndroidTerminal, TypewriterText, _AndroidAppIcon, GoogleSearchPage] ...
// ... [Paste the remaining classes from your original file here] ...

// Note: For completeness in copy-pasting, ensure you keep the original 
// AndroidTerminal, TypewriterText, _AndroidAppIcon, and GoogleSearchPage classes 
// at the bottom of the file as they were in your upload.

// ---------------------------------------------------------
// ✅ ANDROID TERMINAL (Full Features + ASCII Art)
// ---------------------------------------------------------
class AndroidTerminal extends StatefulWidget {
  const AndroidTerminal({super.key});

  @override
  State<AndroidTerminal> createState() => _AndroidTerminalState();
}

class _AndroidTerminalState extends State<AndroidTerminal> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final List<Widget> _consoleOutput = [];
  bool _isBooting = true;

  @override
  void initState() {
    super.initState();
    _runBootSequence();
  }

  Future<void> _runBootSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));

    const bootLogs = [
      "[0.000000] Linux version 5.15.0-kevin-os (gcc version 11.2.0)",
      "[0.234120] CPU: ARMv8 Processor [410fd034] revision 4",
      "[0.455112] Memory: 32GB available",
      "[0.612000] Regulating core voltage... [ OK ]",
      "[0.899000] Initializing DSPWorks Firmware modules... [ OK ]",
      "[1.000223] Mounting /dev/root on /... [ OK ]",
      "---------------------------------------------------",
      " Welcome to KevinOS Mobile Term",
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
              fontFamily: 'monospace',
              fontSize: 13,
            ),
          ),
        );
      });
      _scrollToBottom();
    }

    setState(() => _isBooting = false);
    Future.delayed(
      const Duration(milliseconds: 100),
      () => _focusNode.requestFocus(),
    );
  }

  void _handleCommand(String input) {
    if (input.trim().isEmpty) return;

    setState(() {
      // Echo user command
      _consoleOutput.add(
        RichText(
          text: TextSpan(
            children: [
              const TextSpan(
                text: "kevin@mobile:~\$ ",
                style: TextStyle(
                  color: Color(0xFF00FF00),
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
              TextSpan(
                text: input,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      );

      final command = input.toLowerCase().trim();

      switch (command) {
        case 'help':
          _addAnimatedResponse(_asciiHelp, Colors.yellowAccent);
          break;
        case 'about':
          _addAnimatedResponse(_asciiAbout, Colors.yellowAccent);
          _addAnimatedSection("BIO", [
            "Kevin Shah - Masters in AI & ML Student",
            "Passionate about Agentic AI, RAG, and Embedded Systems.",
            "Origins: Gujarat, India 🇮🇳 -> Now: Adelaide, SA 🇦🇺",
          ]);
          break;
        case 'experience':
          _addAnimatedResponse(_asciiExp, Colors.yellowAccent);
          _addAnimatedSection("DSPWORKS", [
            "Embedded Firmware Developer",
            "Optimized hardware-software integration.",
          ]);
          _addAnimatedSection("WIZARD INFOSYS", [
            "Backend Web Developer",
            "Built AI-powered WordPress automation.",
          ]);
          break;
        case 'skills':
          _addAnimatedResponse(_asciiSkills, Colors.yellowAccent);
          _addAnimatedSection("TECH STACK", [
            "Flutter, Dart, Python, C++",
            "RAG Pipelines, Agentic Systems",
            "IoT & Embedded Security",
          ]);
          break;
        case 'education':
          _addAnimatedResponse(_asciiEdu, Colors.yellowAccent);
          _addAnimatedSection("MASTERS IN AI & ML", [
            "University of Adelaide, Australia",
          ]);
          _addAnimatedSection("BACHELOR OF COMPUTER SCIENCE", [
            "Babaria Institute of Technology",
          ]);
          break;
        case 'contact':
          _addAnimatedSection("CONTACT", [
            "Email: kevinstech0@gmail.com",
            "LinkedIn: /in/techochat",
            "GitHub: /TechoChat",
          ]);
          break;
        case 'clear':
          _consoleOutput.clear();
          break;
        case 'exit':
          Navigator.of(context).pop();
          break;
        default:
          _addAnimatedResponse(
            "Command '$command' not found. Try 'help'.",
            Colors.redAccent,
          );
      }

      _consoleOutput.add(const SizedBox(height: 10));
    });

    _inputController.clear();
    _scrollToBottom();
    _focusNode.requestFocus();
  }

  // Helper for single line animated text
  void _addAnimatedResponse(String text, Color color) {
    _consoleOutput.add(
      TypewriterText(
        text: text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
          height: 1.2,
        ),
      ),
    );
  }

  // Helper for sections
  void _addAnimatedSection(String title, List<String> lines) {
    _consoleOutput.add(
      TypewriterText(
        text: "➜ $title",
        speed: const Duration(milliseconds: 10),
        style: const TextStyle(
          color: Colors.cyanAccent,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      ),
    );
    String fullContent = lines.map((l) => "  $l").join("\n");
    _consoleOutput.add(
      TypewriterText(
        text: fullContent,
        speed: const Duration(milliseconds: 5),
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'monospace',
          height: 1.2,
        ),
      ),
    );
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
    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFF202020),
              child: Row(
                children: [
                  const Icon(
                    Icons.terminal,
                    color: Colors.greenAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "KevinOS Mobile",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.redAccent),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Console
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: _consoleOutput.length,
                        itemBuilder: (c, i) => _consoleOutput[i],
                      ),
                    ),
                    if (!_isBooting)
                      Row(
                        children: [
                          const Text(
                            "kevin@mobile:~\$ ",
                            style: TextStyle(
                              color: Color(0xFF00FF00),
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _inputController,
                              focusNode: _focusNode,
                              onSubmitted: _handleCommand,
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'monospace',
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              cursorColor: Colors.greenAccent,
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
    );
  }
}

// -----------------------------------------------------------------------------
// ✅ ASCII ART & TypewriterText (Copied from Windows)
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
    _    ____   ___  _   _ 
   / \\  | __ ) / _ \\| | | |
  / _ \\ |  _ \\| | | | | | |
 / ___ \\| |_) | |_| | |_| |
/_/   \\_\\____/ \\___/ \\___/ 
""";

const String _asciiSkills = """
 ____  _  _____ _     _   
/ ___|| |/ /_ _| |   | |  
\\___ \\| ' / | || |   | |  
 ___) | . \\ | || |___| |___
|____/|_|\\_\\___|_____|_____|
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
""";

class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration speed;
  const TypewriterText({
    super.key,
    required this.text,
    required this.style,
    this.speed = const Duration(milliseconds: 15),
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
    _timer = Timer.periodic(widget.speed, (timer) {
      if (_charIndex < widget.text.length) {
        if (mounted) {
          setState(() => _displayedText += widget.text[_charIndex++]);
        }
      } else {
        _timer.cancel();
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
    return Text(_displayedText, style: widget.style);
  }
}

// ---------------------------------------------------------
// ✅ HELPERS (App Icon, Status Bar, Search Page)
// ---------------------------------------------------------
class _AndroidAppIcon extends StatelessWidget {
  final String name;
  final String asset;
  final bool showLabel;
  final Color bgColor;
  final bool isTerminal;
  final bool appDrawer;
  final IconData? iconData;

  const _AndroidAppIcon({
    required this.name,
    required this.asset,
    this.showLabel = true,
    this.bgColor = Colors.transparent,
    this.isTerminal = false,
    this.appDrawer = false,
    this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bgColor,
            boxShadow: bgColor != Colors.transparent
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          padding: (bgColor != Colors.transparent && iconData == null)
              ? const EdgeInsets.all(10)
              : EdgeInsets.zero,
          child: iconData != null
              ? Center(
                  child: Icon(iconData, color: Colors.blue.shade700, size: 28),
                )
              : (isTerminal
                    ? const Icon(
                        Icons.terminal,
                        color: Colors.greenAccent,
                        size: 28,
                      )
                    : Image.asset(
                        'assets/img/android/icons/$asset.png',
                        fit: BoxFit.contain,
                        errorBuilder: (c, e, s) =>
                            const Icon(Icons.android, color: Colors.green),
                      )),
        ),
        if (showLabel) ...[
          const SizedBox(height: 6),
          Flexible(
            child: Text(
              name,
              style: appDrawer
                  ? TextStyle(
                      // app_drwawwer then black else white
                      color: Colors.black,
                      fontSize: 12,
                      fontFamily: 'Roboto',
                    )
                  : TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'Roboto',
                    ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }
}

class GoogleSearchPage extends StatefulWidget {
  const GoogleSearchPage({super.key});
  @override
  State<GoogleSearchPage> createState() => _GoogleSearchPageState();
}

class _GoogleSearchPageState extends State<GoogleSearchPage> {
  final TextEditingController _controller = TextEditingController();
  Future<void> _launchGoogleSearch(String query) async {
    if (query.trim().isEmpty) return;
    final Uri url = Uri.https('www.google.com', '/search', {'q': query});
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F1F5),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: AndroidStatusBar(iconColor: Colors.black),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: "Search Google...",
                        border: InputBorder.none,
                      ),
                      onSubmitted: _launchGoogleSearch,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => _controller.clear(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
