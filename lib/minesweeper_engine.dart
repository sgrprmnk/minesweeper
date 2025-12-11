import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:minesweeper/game_board_builder.dart';
// position.dart not required here
import 'package:minesweeper/sound_manager.dart';

enum Difficulty {
  easy,
  medium,
  hard,
  custom,
}

enum GameState {
  playing,
  won,
  lost,
}

class MinesweeperEngine extends ChangeNotifier {
  MinesweeperEngine({
    required this.rows,
    required this.columns,
    required this.difficulty,
    required this.soundManager,
    this.soundEnabled = true,
  }) {
    _seedMines();
  }

  MinesweeperEngine.custom({
    required this.rows,
    required this.columns,
    required int numMines,
    required this.soundManager,
    this.soundEnabled = true,
  }) : difficulty = null {
    _seedMines(numMines: numMines);
  }

  final int rows;
  final int columns;
  final Difficulty? difficulty;
  final SoundManager soundManager;
  bool soundEnabled;
  GameState gameState = GameState.playing;

  final stopwatch = Stopwatch();
  Timer? _timer;

  final revealLocations = <Coords>{};
  final mineLocations = <Coords>{};
  final flaggedLocations = <Coords>{};
  final adjacentMineCounts = <Coords, int>{};

  void _seedMines({int? numMines}) {
    final numSquares = rows * columns;

    final int mines = numMines ??
        switch (difficulty!) {
          Difficulty.easy => (numSquares * 0.25).floor(),
          Difficulty.medium => (numSquares * 0.32).floor(),
          Difficulty.hard => (numSquares * 0.4).floor(),
          // TODO: Handle this case.
          Difficulty.custom => throw UnimplementedError(),
        };

    final coordsToHoldMines = allCoords.toList()..shuffle();

    mineLocations.addAll(coordsToHoldMines.sublist(0, mines));

    for (final coords in allCoords) {
      adjacentMineCounts[coords] = getAdjacentMines(coords);
    }
  }

  void clickedCoordinates(Coords coords) {
    if (gameState != GameState.playing) {
      return;
    }
    if (flaggedLocations.contains(coords)) {
      return;
    }

    if (!stopwatch.isRunning) {
      stopwatch.start();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        notifyListeners();
      });
    }

    if (mineLocations.contains(coords)) {
      gameState = GameState.lost;
      stopwatch.stop();
      revealLocations.addAll(mineLocations);
    } else {
      _reveal(coords);
    }
    notifyListeners();
  }

  void flagCoordinates(Coords coords) {
    if (gameState != GameState.playing) {
      return;
    }
    if (revealLocations.contains(coords)) {
      return;
    }

    if (flaggedLocations.contains(coords)) {
      flaggedLocations.remove(coords);
    } else {
      flaggedLocations.add(coords);
    }
    notifyListeners();
  }

  void _reveal(Coords coords) {
    if (revealLocations.contains(coords)) {
      return;
    }
    revealLocations.add(coords);

    if (getAdjacentMines(coords) == 0) {
      for (int rowDelta in rowAdjacencyIterator) {
        for (int columnDelta in columnAdjacencyIterator) {
          final adjacentCoords = Coords(
            row: coords.row + rowDelta,
            column: coords.column + columnDelta,
          );
          if (adjacentCoords == coords) {
            continue;
          }

          if (adjacentCoords.row < 0 ||
              adjacentCoords.row >= rows ||
              adjacentCoords.column < 0 ||
              adjacentCoords.column >= columns) {
            continue;
          }

          _reveal(adjacentCoords);
        }
      }
    }
    _checkWinCondition();
  }

  void _checkWinCondition() {
    final nonMineSquares = allCoords.length - mineLocations.length;
    if (revealLocations.length == nonMineSquares) {
      gameState = GameState.won;
      stopwatch.stop();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void reset() {
    stopwatch.stop();
    stopwatch.reset();
    _timer?.cancel();
    revealLocations.clear();
    mineLocations.clear();
    flaggedLocations.clear();
    gameState = GameState.playing;
    _seedMines();
    notifyListeners();
  }

  Iterable<Coords> get allCoords sync* {
    for (int row = 0; row < rows; row++) {
      for (int column = 0; column < columns; column++) {
        yield Coords(row: row, column: column);
      }
    }
  }

  int getAdjacentMines(Coords coords) {
    int adjacentMines = 0;
    for (int rowDelta in rowAdjacencyIterator) {
      for (int columnDelta in columnAdjacencyIterator) {
        final adjacentCoords = Coords(
          row: coords.row + rowDelta,
          column: coords.column + columnDelta,
        );
        if (adjacentCoords == coords) {
          continue;
        }

        if (mineLocations.contains(
          adjacentCoords,
        )) {
          adjacentMines++;
        }
      }
    }

    return adjacentMines;
  }
  //  Position getFillSquarePosition(Coords coords)=>Position();

  Iterable<int> get rowAdjacencyIterator sync* {
    yield -1;
    yield 0;
    yield 1;
  }

  Iterable<int> get columnAdjacencyIterator sync* {
    yield -1;
    yield 0;
    yield 1;
  }
}
