import 'package:flutter/material.dart';
import 'package:minesweeper/minesweeper_engine.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({
    super.key,
    required this.soundEnabled,
    required this.onSoundToggle,
    required this.currentDifficulty,
    required this.onDifficultyChanged,
  });

  final bool soundEnabled;
  final ValueChanged<bool> onSoundToggle;
  final Difficulty currentDifficulty;
  final Function(Difficulty, int?, int?, int?) onDifficultyChanged;

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late Difficulty _selectedDifficulty;
  late TextEditingController _rowsController;
  late TextEditingController _columnsController;
  late TextEditingController _minesController;

  @override
  void initState() {
    super.initState();
    _selectedDifficulty = widget.currentDifficulty;
    _rowsController = TextEditingController();
    _columnsController = TextEditingController();
    _minesController = TextEditingController();
  }

  @override
  void dispose() {
    _rowsController.dispose();
    _columnsController.dispose();
    _minesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Settings'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SwitchListTile(
            title: const Text('Sound'),
            value: widget.soundEnabled,
            onChanged: widget.onSoundToggle,
          ),
          ListTile(
            title: const Text('Difficulty'),
            trailing: DropdownButton<Difficulty>(
              value: _selectedDifficulty,
              onChanged: (Difficulty? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedDifficulty = newValue;
                  });
                  // If not custom, immediately notify the change
                  if (newValue != Difficulty.custom) {
                    widget.onDifficultyChanged(newValue, null, null, null);
                  }
                }
              },
              items: Difficulty.values
                  .map<DropdownMenuItem<Difficulty>>((Difficulty value) {
                return DropdownMenuItem<Difficulty>(
                  value: value,
                  child: Text(value.toString().split('.').last),
                );
              }).toList(),
            ),
          ),
          if (_selectedDifficulty == Difficulty.custom) ...[
            TextField(
              controller: _rowsController,
              decoration: const InputDecoration(labelText: 'Rows'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _columnsController,
              decoration: const InputDecoration(labelText: 'Columns'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _minesController,
              decoration: const InputDecoration(labelText: 'Mines'),
              keyboardType: TextInputType.number,
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (_selectedDifficulty == Difficulty.custom) {
              final rows = int.tryParse(_rowsController.text);
              final columns = int.tryParse(_columnsController.text);
              final mines = int.tryParse(_minesController.text);
              widget.onDifficultyChanged(_selectedDifficulty, rows, columns, mines);
            }
            Navigator.of(context).pop();
          },
          child: const Text('Done'),
        ),
      ],
    );
  }
}
