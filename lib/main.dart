import 'package:flutter/material.dart';
import 'package:minesweeper/minesweeper_engine.dart';
import 'package:minesweeper/score_manager.dart';
import 'package:minesweeper/theme_notifier.dart';
import 'package:minesweeper/widgets/game_board.dart';
import 'package:provider/provider.dart';

import 'package:minesweeper/sound_manager.dart';
import 'package:minesweeper/widgets/dialogs.dart';
import 'package:minesweeper/widgets/settings_dialog.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, theme, _) => MaterialApp(
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: theme.themeMode,
        home: const MinesweeperPage(),
      ),
    );
  }
}

class MinesweeperPage extends StatefulWidget {
  const MinesweeperPage({super.key});

  @override
  State<MinesweeperPage> createState() => _MinesweeperPageState();
}

class _MinesweeperPageState extends State<MinesweeperPage> {
  late MinesweeperEngine engine;
  late SoundManager soundManager;
  Difficulty _currentDifficulty = Difficulty.easy;
  int? _customRows = 10; // Default custom values
  int? _customColumns = 10;
  int? _customMines = 15;

  @override
  void initState() {
    super.initState();
    soundManager = SoundManager();
    _initializeEngine();
  }

  void _initializeEngine() {
    late int rows, columns, mines;

    if (_currentDifficulty == Difficulty.custom) {
      rows = _customRows ?? 10;
      columns = _customColumns ?? 10;
      mines = _customMines ?? 15;
    } else {
      final preset = switch (_currentDifficulty) {
        Difficulty.easy => (rows: 9, columns: 9, mines: 10),
        Difficulty.medium => (rows: 16, columns: 16, mines: 40),
        Difficulty.hard => (rows: 16, columns: 30, mines: 99),
        _ => (rows: 10, columns: 10, mines: 15), // Should not happen with current enums
      };
      rows = preset.rows;
      columns = preset.columns;
      mines = preset.mines;
    }

    engine = MinesweeperEngine.custom(
      rows: rows,
      columns: columns,
      numMines: mines,
      soundManager: soundManager,
    );
    engine.addListener(_onEngineChange);
  }

  @override
  void dispose() {
    engine.removeListener(_onEngineChange);
    engine.dispose();
    soundManager.dispose();
    super.dispose();
  }

  void _onEngineChange() {
    if (engine.gameState == GameState.won ||
        engine.gameState == GameState.lost) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (ModalRoute.of(context)?.isCurrent != true) {
          return;
        }

        if (engine.gameState == GameState.won) {
          HighScoreManager().addScore(
            Score(
              timeInSeconds: engine.stopwatch.elapsed.inSeconds,
              difficulty: engine.difficulty,
              date: DateTime.now(),
              rows: engine.rows,
              columns: engine.columns,
              mines: engine.mineLocations.length,
            ),
          );
        }

        showDialog(
          context: context,
          builder: (context) {
            return GameResultDialog(
              engine: engine,
              onPlayAgain: () {
                Navigator.of(context).pop();
                engine.reset();
              },
            );
          },
        );
      });
    }
    // setState(() {}); // This is already outside the if block.
  }

  void _onDifficultyChanged(
      Difficulty newDifficulty, int? rows, int? columns, int? mines) {
    setState(() {
      _currentDifficulty = newDifficulty;
      if (newDifficulty == Difficulty.custom) {
        _customRows = rows;
        _customColumns = columns;
        _customMines = mines;
      }
      engine.removeListener(_onEngineChange);
      engine.dispose();
      _initializeEngine();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minesweeper'),
        actions: [
          IconButton(
            onPressed: () {
              themeNotifier.toggleTheme();
            },
            icon: Icon(
              themeNotifier.themeMode == ThemeMode.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Mines: ${engine.mineLocations.length - engine.flaggedLocations.length}',
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('Time: ${engine.stopwatch.elapsed.inSeconds}'),
            ),
          ),
          IconButton(
            onPressed: () async {
              final HighScoreManager manager = HighScoreManager();
              final scores = await manager.getHighScores();
              showDialog(
                context: context,
                builder: (context) {
                  return HighScoresDialog(scores: scores);
                },
              );
            },
            icon: const Icon(Icons.leaderboard),
          ),
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return SettingsDialog(
                    soundEnabled: engine.soundEnabled,
                    onSoundToggle: (value) {
                      setState(() {
                        engine.soundEnabled = value;
                      });
                    },
                    currentDifficulty: _currentDifficulty,
                    onDifficultyChanged: _onDifficultyChanged,
                  );
                },
              );
            },
            icon: const Icon(Icons.settings),
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'new_game') {
                engine.reset();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'new_game',
                child: Text('New Game'),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Center(
          child: GameBoard(
            rows: engine.rows,
            columns: engine.columns,
            engine: engine,
          ),
        ),
      ),
    );
  }
}
