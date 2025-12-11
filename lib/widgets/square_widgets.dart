import 'package:flutter/material.dart';
import 'package:minesweeper/game_board_builder.dart';
import 'package:minesweeper/minesweeper_engine.dart';

class RevealedSquare extends StatelessWidget {
  const RevealedSquare({
    super.key,
    required this.builder,
    required this.engine,
    required this.coord,
  });

  final GameBoardBuilder builder;
  final MinesweeperEngine engine;
  final Coords coord;

  @override
  Widget build(BuildContext context) {
    final mineCount = engine.adjacentMineCounts[coord]!;
    return builder
        .getCoordsContentsPosition(coord)
        .toWidget(
          AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Center(
                child: Text(
                  mineCount == 0 ? '' : '$mineCount',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
        );
  }
}

class Flag extends StatelessWidget {
  const Flag({
    super.key,
    required this.builder,
    required this.coord,
  });

  final GameBoardBuilder builder;
  final Coords coord;

  @override
  Widget build(BuildContext context) {
    final flagSize = builder.squareSize * 0.6;
    return builder
        .getCoordsContentsPosition(coord)
        .toWidget(
          Center(
            child: Icon(
              Icons.flag,
              color: Theme.of(context).colorScheme.error,
              size: flagSize,
            ),
          ),
        );
  }
}

class Mine extends StatelessWidget {
  const Mine({
    super.key,
    required this.builder,
    required this.coord,
  });

  final GameBoardBuilder builder;
  final Coords coord;

  @override
  Widget build(BuildContext context) {
    final mineSize = builder.squareSize * 0.5;
    return builder
        .getCoordsContentsPosition(coord)
        .toWidget(
          AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(milliseconds: 300),
            child: Center(
              child: Container(
                width: mineSize,
                height: mineSize,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        );
  }
}

class BeveledSquare extends StatelessWidget {
  const BeveledSquare({
    super.key,
    required this.builder,
    required this.coord,
  });

  final GameBoardBuilder builder;
  final Coords coord;

  @override
  Widget build(BuildContext context) {
    return builder
        .getFillSquarePosition(coord)
        .toWidget(
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.surface,
                  Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                ],
              ),
            ),
          ),
        );
  }
}
