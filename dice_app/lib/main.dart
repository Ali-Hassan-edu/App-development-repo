import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(DiceGameApp());

class DiceGameApp extends StatefulWidget {
  @override
  State<DiceGameApp> createState() => _DiceGameAppState();
}

class _DiceGameAppState extends State<DiceGameApp> {
  static const List<String> fontKeys = [
    'Poppins',
    'Roboto',
    'Lato',
    'Montserrat',
    'Open Sans',
    'Nunito',
    'Merriweather',
    'Oswald',
  ];

  String _selectedFont = fontKeys[0];

  TextTheme _getSelectedTextTheme([TextTheme? base]) {
    base = base ?? ThemeData.dark().textTheme;
    switch (_selectedFont) {
      case 'Poppins':
        return GoogleFonts.poppinsTextTheme(base);
      case 'Roboto':
        return GoogleFonts.robotoTextTheme(base);
      case 'Lato':
        return GoogleFonts.latoTextTheme(base);
      case 'Montserrat':
        return GoogleFonts.montserratTextTheme(base);
      case 'Open Sans':
        return GoogleFonts.openSansTextTheme(base);
      case 'Nunito':
        return GoogleFonts.nunitoTextTheme(base);
      case 'Merriweather':
        return GoogleFonts.merriweatherTextTheme(base);
      case 'Oswald':
        return GoogleFonts.oswaldTextTheme(base);
      default:
        return GoogleFonts.poppinsTextTheme(base);
    }
  }

  void _onFontChanged(String newFont) {
    setState(() {
      _selectedFont = newFont;
    });
  }

  @override
  Widget build(BuildContext context) {
    final baseDark = ThemeData.dark();
    final textTheme = _getSelectedTextTheme(baseDark.textTheme);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '🎲 Neon Dice Game',
      theme: baseDark.copyWith(
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: Colors.pinkAccent,
          secondary: Colors.pinkAccent,
          background: Color(0xFF1B002B),
        ),
        scaffoldBackgroundColor: const Color(0xFF1B002B),
        textTheme: textTheme,
      ),
      home: DiceGameHome(
        selectedFont: _selectedFont,
        onFontChanged: _onFontChanged,
        fontOptions: fontKeys,
      ),
    );
  }
}

class DiceGameHome extends StatefulWidget {
  final String selectedFont;
  final void Function(String) onFontChanged;
  final List<String> fontOptions;

  DiceGameHome({
    required this.selectedFont,
    required this.onFontChanged,
    required this.fontOptions,
  });

  @override
  State<DiceGameHome> createState() => _DiceGameHomeState();
}

class _DiceGameHomeState extends State<DiceGameHome>
    with TickerProviderStateMixin {
  final List<TextEditingController> _controllers =
  List.generate(4, (_) => TextEditingController());
  int _playerCount = 2;
  final int _maxRounds = 4;
  bool _gameStarted = false;
  bool _gameOver = false;
  int _round = 1;
  int _currentPlayer = 0;
  int _diceNumber = 1;
  Map<String, int> _totals = {};
  final List<Map<String, int>> _roundHistory = [];

  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  bool _faceChangedDuringAnim = false;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 2.0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeOut),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1)
        .animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOut));

    _rotationController.addListener(() {
      if (_rotationController.value >= 0.5 && !_faceChangedDuringAnim) {
        _faceChangedDuringAnim = true;
        final newFace = Random().nextInt(6) + 1;
        setState(() => _diceNumber = newFace);
      }
    });

    _rotationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _rotationController.reset();
        _faceChangedDuringAnim = false;
      }
    });
  }

  @override
  void dispose() {
    for (var c in _controllers) c.dispose();
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _startGame() {
    final Map<String, int> totals = {};
    for (int i = 0; i < _playerCount; i++) {
      final name = _controllers[i].text.trim().isEmpty
          ? 'Player ${i + 1}'
          : _controllers[i].text.trim();
      totals[name] = 0;
    }
    setState(() {
      _totals = totals;
      _roundHistory.clear();
      _round = 1;
      _currentPlayer = 0;
      _diceNumber = 1;
      _gameStarted = true;
      _gameOver = false;
    });
  }

  Future<void> _rollDice() async {
    if (!_gameStarted || _gameOver) return;
    await _scaleController.forward();
    _scaleController.reverse();
    _rotationController.forward();
    await Future.delayed(const Duration(milliseconds: 700));

    setState(() {
      final playerName = _totals.keys.elementAt(_currentPlayer);
      _totals[playerName] = (_totals[playerName] ?? 0) + _diceNumber;

      final lastIndex = _totals.length - 1;
      if (_currentPlayer == lastIndex) {
        final snapshot = Map<String, int>.from(_totals);
        _roundHistory.add(snapshot);

        if (_round >= _maxRounds) {
          _gameOver = true;
        } else {
          _round++;
          _currentPlayer = 0;
        }
      } else {
        _currentPlayer++;
      }
    });
  }

  void _restartGame() {
    setState(() {
      _gameStarted = false;
      _gameOver = false;
      _round = 1;
      _currentPlayer = 0;
      _diceNumber = 1;
      _totals.clear();
      _roundHistory.clear();
    });
  }

  String _getWinnerString() {
    if (_totals.isEmpty) return '';
    final winner =
    _totals.entries.reduce((a, b) => a.value >= b.value ? a : b);
    return '${winner.key} (Score: ${winner.value})';
  }

  Widget _buildSetupScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          const SizedBox(height: 30),
          Text(
            '🎮 Neon Dice Game Setup',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: Colors.pinkAccent),
          ),
          const SizedBox(height: 16),
          DropdownButton<int>(
            value: _playerCount,
            dropdownColor: Colors.pink[900],
            items: [2, 3, 4].map((num) {
              return DropdownMenuItem<int>(
                value: num,
                child: Text('$num Players'),
              );
            }).toList(),
            onChanged: (val) => setState(() => _playerCount = val!),
          ),
          const SizedBox(height: 10),
          for (int i = 0; i < _playerCount; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: TextField(
                controller: _controllers[i],
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.pink.shade900.withOpacity(0.3),
                  labelText: 'Enter Player ${i + 1} Name',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          const SizedBox(height: 10),
          DropdownButton<String>(
            value: widget.selectedFont,
            dropdownColor: Colors.pink[900],
            items: widget.fontOptions
                .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                .toList(),
            onChanged: (font) =>
                widget.onFontChanged(font ?? widget.selectedFont),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _startGame,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent,
              foregroundColor: Colors.white,
              padding:
              const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Start Game'),
          ),
        ],
      ),
    );
  }

  Widget _buildGameScreen() {
    final players = _totals.keys.toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text('Round $_round of $_maxRounds',
              style: const TextStyle(color: Colors.pinkAccent, fontSize: 20)),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _rollDice,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      color: Colors.pinkAccent.withOpacity(0.7),
                      blurRadius: 20,
                      spreadRadius: 4)
                ],
              ),
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: RotationTransition(
                  turns: _rotationAnimation,
                  child: Image.asset('assets/dice$_diceNumber.png',
                      height: 120, width: 120),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (!_gameOver)
            Text(
              "🎯 ${players[_currentPlayer]}'s turn",
              style: const TextStyle(color: Colors.pinkAccent),
            ),
          const SizedBox(height: 20),
          if (!_gameOver)
            ElevatedButton.icon(
              onPressed: _rollDice,
              icon: const Icon(Icons.casino),
              label: const Text('Roll Dice'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 25, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          if (_gameOver) ...[
            const SizedBox(height: 20),
            Text(
              "🏆 Winner: ${_getWinnerString()}",
              style: const TextStyle(
                  color: Colors.amber, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _restartGame,
              child: const Text('Restart'),
            ),
          ],
          const SizedBox(height: 25),
          Text("Scoreboard",
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.pinkAccent)),
          const SizedBox(height: 10),
          Column(
            children: _totals.entries
                .map((e) => Card(
              color: Colors.pink.shade900.withOpacity(0.3),
              child: ListTile(
                title: Text(e.key,
                    style: const TextStyle(color: Colors.white)),
                trailing: Text('${e.value}',
                    style: const TextStyle(color: Colors.white)),
              ),
            ))
                .toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _gameStarted ? _buildGameScreen() : _buildSetupScreen(),
    );
  }
}
