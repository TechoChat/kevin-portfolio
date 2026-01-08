import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class IosTerminal extends StatefulWidget {
  const IosTerminal({super.key});

  @override
  State<IosTerminal> createState() => _IosTerminalState();
}

class _IosTerminalState extends State<IosTerminal> {
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

    const bootLogs = [
      "[0.000000] Darwin Kernel Version 21.0.0: KevinOS-iOS",
      "[0.234120] CPU: Apple A16 Bionic [ARM64]",
      "[0.245000] Machine model: iPhone 14 Pro Max",
      "[0.455112] Memory: 6GB LPDDR5",
      "[0.612000] Initializing SpringBoard... [ OK ]",
      "[0.899000] Loading Kevin's Profile... [ OK ]",
      "[1.000223] Mounting /var/mobile... [ OK ]",
      "[1.150000] Establishing Safe Connection... [ OK ]",
      "---------------------------------------------------",
      " Welcome to KevinOS Mobile Terminal",
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
              fontFamily: 'Courier',
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
      _consoleOutput.add(
        RichText(
          text: TextSpan(
            children: [
              const TextSpan(
                text: "kevin@iphone:~\$ ",
                style: TextStyle(
                  color: CupertinoColors.activeBlue,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Courier',
                ),
              ),
              TextSpan(
                text: input,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Courier',
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
        case 'clear':
          _consoleOutput.clear();
          break;
        case 'exit':
          Navigator.of(context).pop();
          break;
        case 'about':
          _addAnimatedResponse(_asciiAbout, Colors.greenAccent);
          _addAnimatedSection("BIO", [
            "I am Kevin Shah, an enthusiastic Developer & Engineer.",
            "Currently pursuing Masters in AI & ML at University of Adelaide [2025-2027].",
            "Passionate about Agentic AI, Embedded Systems, and solving complex problems.",
          ]);
          break;

        case 'skills':
          _addAnimatedResponse(_asciiSkills, Colors.cyanAccent);
          _addAnimatedSection("AI & MACHINE LEARNING", [
            "Python, RAG Pipelines, Agentic Systems, LLMs",
            "Data Processing, Automation",
          ]);
          _addAnimatedSection("WEB & BACKEND", [
            "PHP, Laravel, REST APIs, WordPress Automation",
            "Google Cloud, Firebase, MySQL",
          ]);
          _addAnimatedSection("MOBILE & EMBEDDED", [
            "Flutter (App Dev), C Programming, Microcontrollers",
            "IoT Security, Firmware Development",
          ]);
          break;

        case 'contact':
          _addAnimatedSection("CONTACT DETAILS", [
            "📧 Email: kevinstech0@gmail.com",
            "📞 Phone: +61 0485 516 100",
            "🐙 GitHub: github.com/TechoChat",
            "💼 LinkedIn: linkedin.com/in/techochat/",
          ]);
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

  void _addAnimatedResponse(String text, Color color) {
    _consoleOutput.add(
      TypewriterText(
        text: text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontFamily: 'Courier',
          height: 1.2,
        ),
      ),
    );
  }

  void _addAnimatedSection(String title, List<String> lines) {
    _consoleOutput.add(
      TypewriterText(
        text: "➜ $title",
        speed: const Duration(milliseconds: 10),
        style: const TextStyle(
          color: CupertinoColors.systemPink,
          fontWeight: FontWeight.bold,
          fontFamily: 'Courier',
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
          fontFamily: 'Courier',
          height: 1.2,
        ),
      ),
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
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Terminal"),
        backgroundColor: Color(0xFF1F1F1F),
      ),
      backgroundColor: const Color(0xFF0C0C0C),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                controller: _scrollController,
                itemCount: _consoleOutput.length,
                itemBuilder: (context, index) {
                  return _consoleOutput[index];
                },
              ),
            ),
            if (!_isBooting)
              Container(
                color: const Color(0xFF1F1F1F),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    const Text(
                      "\$ ",
                      style: TextStyle(
                        color: CupertinoColors.activeBlue,
                        fontFamily: 'Courier',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Expanded(
                      child: CupertinoTextField(
                        controller: _inputController,
                        focusNode: _focusNode,
                        onSubmitted: _handleCommand,
                        cursorColor: CupertinoColors.activeBlue,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Courier',
                        ),
                        decoration: null,
                        placeholder: "Type a command...",
                        placeholderStyle: const TextStyle(
                          color: Colors.grey,
                          fontFamily: 'Courier',
                        ),
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Icon(CupertinoIcons.arrow_right_circle_fill),
                      onPressed: () => _handleCommand(_inputController.text),
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

// ASCII ART and Typewriter Widget
const String _asciiHelp = """
Commands:
  [ about      ]  -  Bio & Info
  [ skills     ]  -  Tech Stack
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

class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration speed;
  final VoidCallback? onComplete;

  const TypewriterText({
    super.key,
    required this.text,
    required this.style,
    this.speed = const Duration(milliseconds: 15),
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
