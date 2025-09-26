// lib/main.dart
import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dart Calculator',
      theme: ThemeData(useMaterial3: true),
      home: const CalculatorPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});
  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _display = '0';
  String? _operator;
  double? _firstOperand;
  bool _waitingForSecond = false;

  void _updateDisplay(String value) {
    setState(() {
      if (_waitingForSecond) {
        _display = value == '.' ? '0.' : value;
        _waitingForSecond = false;
      } else {
        if (_display == '0' && value != '.') {
          _display = value;
        } else if (value == '.' && _display.contains('.')) {
          // ignore
        } else {
          _display = _display + value;
        }
      }
    });
  }

  void _setOperator(String op) {
    setState(() {
      final current = double.tryParse(_display) ?? 0.0;
      if (_firstOperand == null) {
        _firstOperand = current;
      } else if (_operator != null && !_waitingForSecond) {
        _firstOperand = _calculate(_firstOperand!, _operator!, current);
        _display = _format(_firstOperand!);
      }
      _operator = op;
      _waitingForSecond = true;
    });
  }

  String _format(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toString();
  }

  double _calculate(double a, String op, double b) {
    switch (op) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case '×':
        return a * b;
      case '÷':
        return b == 0 ? double.nan : a / b;
      case '%':
        return b == 0 ? double.nan : a % b;
      default:
        return b;
    }
  }

  void _allClear() {
    setState(() {
      _display = '0';
      _operator = null;
      _firstOperand = null;
      _waitingForSecond = false;
    });
  }

  void _backspace() {
    setState(() {
      if (_waitingForSecond) return;
      if (_display.length <= 1) {
        _display = '0';
      } else {
        _display = _display.substring(0, _display.length - 1);
      }
    });
  }

  void _percent() {
    setState(() {
      final val = double.tryParse(_display) ?? 0.0;
      final res = val / 100.0;
      _display = _format(res);
      if (_waitingForSecond) _waitingForSecond = false;
    });
  }

  void _equals() {
    setState(() {
      if (_operator == null || _firstOperand == null) return;
      final second = double.tryParse(_display) ?? 0.0;
      final result = _calculate(_firstOperand!, _operator!, second);
      if (result.isNaN || result.isInfinite) {
        _display = 'Error';
      } else {
        _display = _format(result);
      }
      _operator = null;
      _firstOperand = null;
      _waitingForSecond = false;
    });
  }

  Widget _button(String label,
      {Color? textColor, double height = 72, required VoidCallback onTap}) {
    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
          backgroundColor: Colors.grey[200],
          foregroundColor: textColor ?? Colors.black87,
        ),
        child: Text(label, style: const TextStyle(fontSize: 24)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final buttonHeight = 80.0;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  alignment: Alignment.bottomRight,
                  padding: const EdgeInsets.only(right: 16, left: 16),
                  child: Text(
                    _display,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _button('AC', onTap: _allClear, textColor: Colors.red),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _button('⌫', onTap: _backspace),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _button('%', onTap: _percent),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _button('÷', onTap: () => _setOperator('÷')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _button('7', onTap: () => _updateDisplay('7'))),
                      const SizedBox(width: 8),
                      Expanded(child: _button('8', onTap: () => _updateDisplay('8'))),
                      const SizedBox(width: 8),
                      Expanded(child: _button('9', onTap: () => _updateDisplay('9'))),
                      const SizedBox(width: 8),
                      Expanded(child: _button('×', onTap: () => _setOperator('×'))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _button('4', onTap: () => _updateDisplay('4'))),
                      const SizedBox(width: 8),
                      Expanded(child: _button('5', onTap: () => _updateDisplay('5'))),
                      const SizedBox(width: 8),
                      Expanded(child: _button('6', onTap: () => _updateDisplay('6'))),
                      const SizedBox(width: 8),
                      Expanded(child: _button('-', onTap: () => _setOperator('-'))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _button('1', onTap: () => _updateDisplay('1'))),
                      const SizedBox(width: 8),
                      Expanded(child: _button('2', onTap: () => _updateDisplay('2'))),
                      const SizedBox(width: 8),
                      Expanded(child: _button('3', onTap: () => _updateDisplay('3'))),
                      const SizedBox(width: 8),
                      Expanded(child: _button('+', onTap: () => _setOperator('+'))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _button('0', onTap: () => _updateDisplay('0')),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: _button('.', onTap: () => _updateDisplay('.'))),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _equals,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            minimumSize: Size.fromHeight(buttonHeight),
                          ),
                          child: const Text('=', style: TextStyle(fontSize: 28)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
