import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:math_expressions/math_expressions.dart';

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: CalculatorLayout(),
    );
  }
}

class CalculatorLayout extends StatefulWidget {
  const CalculatorLayout({super.key});

  @override
  State<CalculatorLayout> createState() => _CalculatorLayoutState();
}

class _CalculatorLayoutState extends State<CalculatorLayout> {
  String _expression = "";
  String _result = "0";

  void _onPressed(String text) {
    setState(() {
      if (text == "C") {
        _expression = "";
        _result = "0";
      } else if (text == "=") {
        try {
          Parser p = Parser();
          Expression exp = p.parse(
            _expression.replaceAll('x', '*').replaceAll('÷', '/'),
          );
          ContextModel cm = ContextModel();
          double eval = exp.evaluate(EvaluationType.REAL, cm);

          // Remove decimal if integer
          if (eval % 1 == 0) {
            _result = eval.toInt().toString();
          } else {
            _result = eval.toString();
          }
        } catch (e) {
          _result = "Error";
        }
      } else {
        if (_expression == "0") {
          _expression = text;
        } else {
          _expression += text;
        }
      }
    });
  }

  Widget _buildButton(String text, {Color? color, Color? textColor}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        child: ElevatedButton(
          onPressed: () => _onPressed(text),
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? const Color(0xFF333333),
            foregroundColor: textColor ?? Colors.white,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20),
          ),
          child: Text(
            text,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          final String key = event.logicalKey.keyLabel;
          if ("0123456789".contains(key)) {
            _onPressed(key);
            return KeyEventResult.handled;
          } else if (key == "Period" || key == ".") {
            _onPressed(".");
            return KeyEventResult.handled;
          } else if (key == "Enter" || key == "=") {
            _onPressed("=");
            return KeyEventResult.handled;
          } else if (key == "Backspace") {
            setState(() {
              if (_expression.isNotEmpty) {
                _expression = _expression.substring(0, _expression.length - 1);
              }
            });
            return KeyEventResult.handled;
          } else if (key == "Escape" || key == "c" || key == "C") {
            _onPressed("C");
            return KeyEventResult.handled;
          } else if (key == "+" || key == "-" || key == "*" || key == "/") {
            _onPressed(key);
            return KeyEventResult.handled;
          } else if (key == "x" || key == "X") {
            _onPressed("x");
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Column(
        children: [
          // Display
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _expression,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _result,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Keypad
          Expanded(
            flex: 2, // Give keypad more space
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      _buildButton(
                        "C",
                        color: Colors.grey,
                        textColor: Colors.black,
                      ),
                      _buildButton(
                        "(",
                        color: Colors.grey,
                        textColor: Colors.black,
                      ),
                      _buildButton(
                        ")",
                        color: Colors.grey,
                        textColor: Colors.black,
                      ),
                      _buildButton("÷", color: Colors.orange),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      _buildButton("7"),
                      _buildButton("8"),
                      _buildButton("9"),
                      _buildButton("x", color: Colors.orange),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      _buildButton("4"),
                      _buildButton("5"),
                      _buildButton("6"),
                      _buildButton("-", color: Colors.orange),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      _buildButton("1"),
                      _buildButton("2"),
                      _buildButton("3"),
                      _buildButton("+", color: Colors.orange),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      _buildButton("0"),
                      _buildButton("."),
                      // Backspace
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                if (_expression.isNotEmpty) {
                                  _expression = _expression.substring(
                                    0,
                                    _expression.length - 1,
                                  );
                                }
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF333333),
                              foregroundColor: Colors.white,
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(
                                16,
                              ), // Reduced padding
                            ),
                            child: const Icon(
                              Icons.backspace_outlined,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      _buildButton("=", color: Colors.orange),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
