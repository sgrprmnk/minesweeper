import 'dart:convert';
import 'package:minesweeper/minesweeper_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Score {
  final int timeInSeconds;
  final Difficulty? difficulty;
  final DateTime date;
  final int rows;
  final int columns;
  final int mines;

  Score({
    required this.timeInSeconds,
    required this.difficulty,
    required this.date,
    required this.rows,
    required this.columns,
    required this.mines,
  });

  Map<String, dynamic> toJson() => {
    'timeInSeconds': timeInSeconds,
    'difficulty': difficulty?.name,
    'date': date.toIso8601String(),
    'rows': rows,
    'columns': columns,
    'mines': mines,
  };

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(
      timeInSeconds: json['timeInSeconds'] as int,
      difficulty: json['difficulty'] != null
          ? Difficulty.values.byName(json['difficulty'] as String)
          : null,
      date: DateTime.parse(json['date'] as String),
      rows: json['rows'] as int,
      columns: json['columns'] as int,
      mines: json['mines'] as int,
    );
  }
}

class HighScoreManager {
  static const _highScoreKey = 'minesweeper_high_scores';

  Future<List<Score>> getHighScores() async {
    final prefs = await SharedPreferences.getInstance();
    final String? scoresString = prefs.getString(_highScoreKey);
    if (scoresString == null) {
      return [];
    }
    final List<dynamic> jsonList = jsonDecode(scoresString) as List<dynamic>;
    return jsonList
        .map((json) => Score.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> addScore(Score newScore) async {
    final prefs = await SharedPreferences.getInstance();
    List<Score> scores = await getHighScores();
    scores.add(newScore);
    scores.sort(
      (a, b) => a.timeInSeconds.compareTo(b.timeInSeconds),
    ); // Sort by time

    // Keep only the top N scores (e.g., 10)
    if (scores.length > 10) {
      scores = scores.sublist(0, 10);
    }

    final String updatedScoresString = jsonEncode(
      scores.map((score) => score.toJson()).toList(),
    );
    await prefs.setString(_highScoreKey, updatedScoresString);
  }
}
