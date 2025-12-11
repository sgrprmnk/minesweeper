import 'package:flutter/material.dart';
import 'package:minesweeper/minesweeper_engine.dart';
import 'package:minesweeper/score_manager.dart';

class DifficultyDialog extends StatelessWidget {
  const DifficultyDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Difficulty'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final difficulty in Difficulty.values)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(difficulty);
              },
              child: Text(difficulty.name),
            ),
          TextButton(
            onPressed: () {
              // Open custom dialog and return its result to the caller.
              showDialog(
                context: context,
                builder: (context) {
                  return const CustomBoardDialog();
                },
              ).then((result) {
                Navigator.of(context).pop(result);
              });
            },
            child: const Text('Custom'),
          ),
        ],
      ),
    );
  }
}

class CustomBoardDialog extends StatefulWidget {
  const CustomBoardDialog({super.key});

  @override
  State<CustomBoardDialog> createState() => _CustomBoardDialogState();
}

class _CustomBoardDialogState extends State<CustomBoardDialog> {
  final _rowsController = TextEditingController();
  final _columnsController = TextEditingController();
  final _minesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Custom Board'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _rowsController,
            decoration: const InputDecoration(labelText: 'Rows'),
            keyboardType: TextInputType.number,
          ),
          TextFormField(
            controller: _columnsController,
            decoration: const InputDecoration(labelText: 'Columns'),
            keyboardType: TextInputType.number,
          ),
          TextFormField(
            controller: _minesController,
            decoration: const InputDecoration(labelText: 'Mines'),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            final rows = int.tryParse(_rowsController.text);
            final columns = int.tryParse(_columnsController.text);
            final mines = int.tryParse(_minesController.text);
            if (rows != null && columns != null && mines != null) {
              Navigator.of(context).pop((rows, columns, mines));
            }
          },
          child: const Text('Start'),
        ),
      ],
    );
  }
}

class HighScoresDialog extends StatelessWidget {
  const HighScoresDialog({super.key, required this.scores});

  final List<Score> scores;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('High Scores'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: scores.length,
          itemBuilder: (context, index) {
            final score = scores[index];
            return ListTile(
              title: Text(
                '${score.difficulty?.name ?? 'Custom'} - ${score.rows}x${score.columns} - ${score.mines} mines',
              ),
              subtitle: Text(
                '${score.timeInSeconds} seconds - ${score.date.toLocal().toString().split(' ')[0]}',
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class GameResultDialog extends StatelessWidget {
  const GameResultDialog({
    super.key,
    required this.engine,
    required this.onPlayAgain,
  });

  final MinesweeperEngine engine;
  final VoidCallback onPlayAgain;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(engine.gameState == GameState.won ? 'You Won!' : 'You Lost!'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('You took ${engine.stopwatch.elapsed.inSeconds} seconds.'),
          Text('Difficulty: ${engine.difficulty?.name ?? 'Custom'}'),
          Text('Board: ${engine.rows}x${engine.columns}'),
          Text('Mines: ${engine.mineLocations.length}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            onPlayAgain();
            Navigator.of(context).pop();
          },
          child: const Text('Play Again'),
        ),
      ],
    );
  }
}
