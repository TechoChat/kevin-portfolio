import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kevins_tech/platforms/windows/window_control.dart';


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
                    WindowControl(icon: Icons.minimize, onTap: () => Navigator.pop(context)),
                    WindowControl(
                      icon: _isMaximized ? Icons.filter_none : Icons.crop_square, 
                      onTap: () => setState(() => _isMaximized = !_isMaximized)
                    ),
                    WindowControl(icon: Icons.close, color: Colors.redAccent, onTap: () => Navigator.pop(context)),
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