import 'package:flutter/material.dart';
import 'package:minesweeper/game_board_builder.dart';
import 'package:minesweeper/minesweeper_engine.dart';
import 'package:minesweeper/widgets/square_widgets.dart';

class GameBoard extends StatelessWidget {
  const GameBoard({
    required this.rows,
    required this.columns,
    required this.engine,
    super.key,
  });

  final int rows;
  final int columns;
  final MinesweeperEngine engine;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxSquareWidth = constraints.maxWidth / columns;
        final maxSquareHeight = constraints.maxHeight / rows;
        final squareSize = maxSquareWidth < maxSquareHeight
            ? maxSquareWidth
            : maxSquareHeight;
        final builder = GameBoardBuilder(
          squareSize: squareSize,
          constraints: Size(squareSize * columns, squareSize * rows),
          rows: rows,
          columns: columns,
        );

        return Center(
          child: SizedBox.fromSize(
            size: builder.constraints,
            child: _GameBoardInner(
              builder: builder,
              engine: engine,
            ),
          ),
        );
      },
    );
  }
}

class _GameBoardInner extends StatelessWidget {
  const _GameBoardInner({
    required this.builder,
    required this.engine,
  });

  final GameBoardBuilder builder;
  final MinesweeperEngine engine;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: engine,
      builder: (context, _) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (details) {
            final coords = builder.getRowColumnForCoordinates(
              details.localPosition,
            );
            engine.clickedCoordinates(coords);
          },
          onLongPressStart: (details) {
            final coords = builder.getRowColumnForCoordinates(
              details.localPosition,
            );
            engine.flagCoordinates(coords);
          },
          child: Stack(
            children: <Widget>[
              ..._buildGrid(context, builder),
              ..._buildSquares(context, builder, engine),
            ],
          ),
        );
      },
    );
  }

  Iterable<Widget> _buildGrid(
    BuildContext context,
    GameBoardBuilder builder,
  ) sync* {
    for (int i = 0; i < builder.rows; i++) {
      for (int j = 0; j < builder.columns; j++) {
        yield BeveledSquare(
          builder: builder,
          coord: Coords(row: i, column: j),
        );
      }
    }
    for (int i = 0; i < builder.rows; i++) {
      yield builder
          .horizontalLinePosition(i)
          .toWidget(
            Container(color: Colors.grey[700]),
          );
    }
    for (int i = 0; i < builder.columns; i++) {
      yield builder
          .verticalLinePosition(i)
          .toWidget(
            Container(color: Colors.grey[700]),
          );
    }
    yield builder.leftBorderPosition().toWidget(
      Container(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
      ),
    );
    yield builder.topBorderPosition().toWidget(
      Container(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
      ),
    );
    yield builder.bottomBorderPosition().toWidget(
      Container(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
      ),
    );
    yield builder.rightBorderPosition().toWidget(
      Container(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
      ),
    );
  }

  Iterable<Widget> _buildSquares(
    BuildContext context,
    GameBoardBuilder builder,
    MinesweeperEngine engine,
  ) sync* {
    for (final coord in engine.revealLocations) {
      if (engine.mineLocations.contains(coord)) {
        yield Mine(
          builder: builder,
          coord: coord,
        );
      } else {
        yield RevealedSquare(
          builder: builder,
          engine: engine,
          coord: coord,
        );
      }
    }
    for (final coord in engine.flaggedLocations) {
      yield Flag(
        builder: builder,
        coord: coord,
      );
    }
  }
}
