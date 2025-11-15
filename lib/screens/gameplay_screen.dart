// screens/gameplay_screen.dart
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../game/eco_warrior_game.dart';
import '../models/stage_data.dart';
import '../managers/audio_manager.dart';

class GameplayScreen extends StatefulWidget {
  final StageData stage;

  const GameplayScreen({super.key, required this.stage});

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen> {
  late final EcoWarriorGame game;
  bool _isPaused = false;
  bool _showGameOver = false;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    game = EcoWarriorGame();

    // Configuration des callbacks
    game.onTimeUpdate = _refreshUI;
    game.onGameOver = _showGameOverScreen;
    game.onScoreUpdate = _onScoreUpdate;

    _playStageMusic();
  }

  void _playStageMusic() {
    AudioManager().playMusic('stage${widget.stage.stageNumber}_music.mp3')
        .catchError((_) => AudioManager().playMusic('stage1_music.mp3'));
  }

  void _refreshUI() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onScoreUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  void _showGameOverScreen() {
    if (mounted) {
      // ✅ CORRECTION: Utiliser un délai pour éviter setState pendant le build
      Future.delayed(Duration.zero, () {
        if (mounted) {
          setState(() {
            _showGameOver = true;
            _isPaused = true;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    AudioManager().stopMusic();
    super.dispose();
  }

  void _togglePause() {
    AudioManager().playSfx('button_click.mp3');
    if (mounted) {
      setState(() => _isPaused = !_isPaused);
    }

    _isPaused ? game.pauseGame() : game.resumeGame();
    _isPaused ? AudioManager().pauseMusic() : AudioManager().resumeMusic();
  }

  void _restartGame() {
    AudioManager().playSfx('button_click.mp3');
    if (mounted) {
      setState(() {
        _isPaused = false;
        _showGameOver = false;
      });
    }
    game.resetGame();
    _playStageMusic();
  }

  void _exitToMenu() {
    AudioManager().playSfx('button_click.mp3');
    AudioManager().stopMusic();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Jeu principal
          GameWidget(
            game: game,
            overlayBuilderMap: {
              'pauseOverlay': _buildPauseOverlay,
              'hudOverlay': _buildHUDOverlay,
              'gameOverOverlay': _buildGameOverOverlay,
            },
          ),

          // Boutons UI
          _buildUIButtons(),
        ],
      ),
    );
  }

  Widget _buildUIButtons() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Bouton retour
            _buildIconButton(
              icon: Icons.arrow_back,
              onPressed: _exitToMenu,
              color: Colors.white,
            ),

            // Bouton pause
            _buildIconButton(
              icon: _isPaused ? Icons.play_arrow : Icons.pause,
              onPressed: _togglePause,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildHUDOverlay(BuildContext context, EcoWarriorGame game) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Score et Timer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _HUDItem(
                icon: Icons.star,
                value: '${game.currentScore}',
                color: Colors.amber,
              ),
              _HUDItem(
                icon: Icons.timer,
                value: '${(game.gameTimer ~/ 60).toString().padLeft(2, '0')}:${(game.gameTimer % 60).toString().padLeft(2, '0')}',
                color: game.gameTimer < 30 ? Colors.red : Colors.white,
              ),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildPauseOverlay(BuildContext context, EcoWarriorGame game) {
    return _MenuOverlay(
      title: 'JEU EN PAUSE',
      subtitle: widget.stage.title,
      buttons: [
        _MenuButton(
          icon: Icons.play_arrow,
          text: 'REPRENDRE',
          color: Colors.green,
          onPressed: _togglePause,
        ),
        _MenuButton(
          icon: Icons.refresh,
          text: 'REDÉMARRER',
          color: Colors.blue,
          onPressed: _restartGame,
        ),
        _MenuButton(
          icon: Icons.exit_to_app,
          text: 'QUITTER',
          color: Colors.red,
          onPressed: _exitToMenu,
        ),
      ],
    );
  }

  Widget _buildGameOverOverlay(BuildContext context, EcoWarriorGame game) {
    return _MenuOverlay(
      title: 'GAME OVER',
      subtitle: 'Score: ${game.currentScore}',
      buttons: [
        _MenuButton(
          icon: Icons.refresh,
          text: 'REESSAYER',
          color: Colors.blue,
          onPressed: _restartGame,
        ),
        _MenuButton(
          icon: Icons.exit_to_app,
          text: 'MENU',
          color: Colors.red,
          onPressed: _exitToMenu,
        ),
      ],
    );
  }
}

class _HUDItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _HUDItem({required this.icon, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _MenuOverlay extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> buttons;

  const _MenuOverlay({required this.title, required this.subtitle, required this.buttons});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.9),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 10),
            Text(subtitle, style: const TextStyle(fontSize: 18, color: Colors.white70)),
            const SizedBox(height: 30),
            ...buttons,
          ],
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final VoidCallback onPressed;

  const _MenuButton({required this.icon, required this.text, required this.color, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 24),
          label: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}