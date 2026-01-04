import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'mac_window.dart'; // Ensure this imports your MacWindow file

class MacTerminal extends StatefulWidget {
  const MacTerminal({super.key});

  @override
  State<MacTerminal> createState() => _MacTerminalState();
}

class _MacTerminalState extends State<MacTerminal> {
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
    await Future.delayed(const Duration(milliseconds: 500));

    // Boot logs
    const bootLogs = [
      "Last login: Today on ttys000",
      "Kevin's MacBook-Pro ~ % loading_profile...",
      "Kevin's MacBook-Pro ~ % source ~/.zshrc",
      "---------------------------------------------------",
      " Welcome to KevinOS (MacShell)",
      " Type 'help' to see available commands.",
      "---------------------------------------------------",
    ];

    for (String log in bootLogs) {
      // Typing effect for boot logs
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
      setState(() {
        _consoleOutput.add(
          Text(
            log,
            style: const TextStyle(
              color: Colors.white70,
              fontFamily: 'Courier New',
              fontSize: 13,
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
      // 1. Echo User Command (Instant)
      _consoleOutput.add(
        RichText(
          text: TextSpan(
            children: [
               const TextSpan(
                 text: "kevin@MacBook-Pro ~ % ", 
                 style: TextStyle(color: Color(0xFF34C759), fontWeight: FontWeight.bold, fontFamily: 'Courier New')
               ),
               TextSpan(
                 text: input, 
                 style: const TextStyle(color: Colors.white, fontFamily: 'Courier New')
               ),
            ]
          )
        )
      );

      final command = input.toLowerCase().trim();

      // 2. Process Response (With Typing Animation)
      switch (command) {
        case 'help':
          _addAnimatedResponse(_asciiHelp, Colors.greenAccent);
          break;
        case 'clear':
          _consoleOutput.clear();
          break;
        case 'exit':
          Navigator.of(context).pop();
          break;

        case 'about':
          _addAnimatedResponse(_asciiAbout, Colors.cyanAccent); 
          _addAnimatedSection("BIO", [
             "I am Kevin Shah, an enthusiastic Developer & Engineer.",
             "Currently pursuing Masters in AI & ML at University of Adelaide [2025-2027].",
             "Passionate about Agentic AI, Embedded Systems, and solving complex problems.",
             "Origins: Gujarat, India 🇮🇳 -> Now: Adelaide, SA 🇦🇺"
          ]);
          break;

        case 'education':
          _addAnimatedResponse(_asciiEdu, Colors.purpleAccent);
          _addAnimatedSection("MASTERS IN AI & ML (2025 - Present)", [
             "University of Adelaide, Australia",
             "Focus: Agentic AI, RAG, Machine Learning"
          ]);
          _addAnimatedSection("BACHELOR OF COMPUTER SCIENCE (2021 - 2024)", [
             "Babaria Institute of Technology",
             "CGPA: 8.65/10.0"
          ]);
          break;

        case 'skills':
          _addAnimatedResponse(_asciiSkills, Colors.orangeAccent);
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
          break;

        case 'experience':
          _addAnimatedResponse(_asciiExp, Colors.blueAccent);
          _addAnimatedSection("DSPWORKS [2024-2025]", [
            "Role: Embedded Firmware Developer",
            "• Developed firmware for microcontroller systems.",
            "• Optimized hardware-software integration."
          ]);
          _addAnimatedSection("WIZARD INFOSYS [2023-2024]", [
            "Role: Backend Web Developer",
            "• Built automated WordPress tools using ChatGPT API.",
            "• Developed Flutter Stock App with PHP backend."
          ]);
          
          _consoleOutput.add(const SizedBox(height: 10));
          _addAnimatedSection("🚀 MAJOR PROJECTS", [
            "1. AI-POWERED WORDPRESS BOT",
            "2. RAG-BASED Q&A PROTOTYPE",
            "3. AGENTIC AI EXPLORATION"
          ]);
          break;

        case 'projects':
           // Just an alias for experience/projects section
           _handleCommand('experience');
           return; // Return early to avoid double input clear

        case 'contact':
          _addAnimatedSection("CONTACT DETAILS", [
            "📧 Email: kevinstech0@gmail.com",
            "📞 Phone: +61 0485 516 100",
            "🐙 GitHub: github.com/TechoChat",
            "💼 LinkedIn: linkedin.com/in/techochat/"
          ]);
          break;

        default:
          _addAnimatedResponse("zsh: command not found: $command", Colors.redAccent);
      }
      
      _consoleOutput.add(const SizedBox(height: 10)); 
    });

    _inputController.clear();
    _scrollToBottom();
    _focusNode.requestFocus();
  }

  // Helper for single line animated text (ASCII Art)
  void _addAnimatedResponse(String text, Color color) {
    _consoleOutput.add(
      TypewriterText(
        text: text, 
        style: TextStyle(
          color: color, 
          fontWeight: FontWeight.bold, 
          fontFamily: 'Courier New', 
          height: 1.0, 
        ),
      )
    );
  }

  // Helper for sections
  void _addAnimatedSection(String title, List<String> lines) {
    _consoleOutput.add(
      TypewriterText(
        text: "➜ $title", 
        speed: const Duration(milliseconds: 10),
        style: const TextStyle(
          color: Colors.greenAccent, 
          fontWeight: FontWeight.bold, 
          fontFamily: 'Courier New'
        ),
      )
    );

    String fullContent = lines.map((l) => "  $l").join("\n");
    
    _consoleOutput.add(
      TypewriterText(
        text: fullContent, 
        speed: const Duration(milliseconds: 5),
        style: const TextStyle(
          color: Colors.white, 
          fontFamily: 'Courier New',
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
    // Note: We use the "Unified" MacWindow (passed via child)
    return MacWindow(
      onClose: () => Navigator.pop(context),
      child: Column(
        children: [
          // --- Custom Terminal Header ---
          Container(
            height: 34,
            color: const Color(0xFF282828),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                // MacTrafficLights(onClose: () => Navigator.pop(context)),
                const Expanded(
                  child: Text(
                    "kevin — -zsh — 80x24",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 50), 
              ],
            ),
          ),

          // --- Terminal Body ---
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              color: const Color(0xFF101010).withValues(alpha: 0.95), // Mac Terminal Black
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: _consoleOutput.length,
                      itemBuilder: (context, index) {
                        return _consoleOutput[index];
                      },
                    ),
                  ),
                  
                  if (!_isBooting)
                    Row(
                      children: [
                        const Text(
                          "kevin@MacBook-Pro ~ % ",
                          style: TextStyle(color: Color(0xFF34C759), fontFamily: 'Courier New', fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _inputController,
                            focusNode: _focusNode,
                            onSubmitted: _handleCommand,
                            cursorColor: Colors.grey,
                            cursorWidth: 6, // Block cursor
                            style: const TextStyle(color: Colors.white, fontFamily: 'Courier New'),
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
    );
  }
}

// -----------------------------------------------------------------------------
// 🎨 ASCII ART ASSETS (COPIED & ADAPTED FOR MAC)
// -----------------------------------------------------------------------------
const String _asciiHelp = r"""
Commands:
  [ about      ]  -  Bio & Info
  [ experience ]  -  Work History
  [ skills     ]  -  Tech Stack
  [ education  ]  -  Academics
  [ contact    ]  -  Get in touch
  [ clear      ]  -  Clear screen
""";

const String _asciiAbout = r"""
    _    ____   ___  _   _ _____ 
   / \  | __ ) / _ \| | | |_   _|
  / _ \ |  _ \| | | | | | | | |  
 / ___ \| |_) | |_| | |_| | | |  
/_/   \_\____/ \___/ \___/  |_|  
""";

const String _asciiSkills = r"""
 ____  _  _____ _     _     ____  
/ ___|| |/ /_ _| |   | |   / ___| 
\___ \| ' / | || |   | |   \___ \ 
 ___) | . \ | || |___| |___ ___) |
|____/|_|\_\___|_____|_____|____/ 
""";

const String _asciiExp = r"""
 _______  ______  
| ____\ \/ /  _ \ 
|  _|  \  /| |_) |
| |___ /  \|  __/ 
|_____/_/\_\_|    
""";

const String _asciiEdu = r"""
 _____ ____  _   _ 
| ____|  _ \| | | |
|  _| | | | | | | |
| |___| |_| | |_| |
|_____|____/ \___/ 
""";


// -----------------------------------------------------------------------------
// ✅ TYPEWRITER ANIMATION (Reuse exact logic from Windows)
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
    this.speed = const Duration(milliseconds: 5), // Very fast default
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
      softWrap: false, 
      overflow: TextOverflow.visible,
      style: widget.style,
    );
  }
}