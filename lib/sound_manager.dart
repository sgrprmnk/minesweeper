import 'package:audioplayers/audioplayers.dart';

class SoundManager {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> playSound(String soundPath) async {
    await _audioPlayer.play(AssetSource(soundPath));
  }

  void playMineExplosion() {
    playSound('sounds/mine_explosion.mp3');
  }

  void playSquareClick() {
    playSound('sounds/click.mp3');
  }

  void playFlagToggle() {
    playSound('sounds/flag_toggle.mp3');
  }

  void playWin() {
    playSound('sounds/win.mp3');
  }

  void playLose() {
    playSound('sounds/lose.mp3');
  }

  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}
