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
  late EcoWarriorGame game;
  bool _isPaused = false;
  bool _showGameOver = false;

  @override
  void initState() {
    super.initState();
    print('🎮 Initialisation de l\'écran de jeu pour le stage ${widget.stage.stageNumber}');
    _initializeGame();
  }

  void _initializeGame() {
    print('🔄 Initialisation du jeu...');

    // Arrêter toute musique précédente
    AudioManager().stopMusic();

    game = EcoWarriorGame();

    // Configurer les callbacks
    game.onTimeUpdate = _refreshUI;
    game.onGameOver = _showGameOverScreen;

    _playStageMusic();

    print('✅ Jeu initialisé avec succès');
  }

  void _playStageMusic() {
    final stageMusic = 'stage${widget.stage.stageNumber}_music.mp3';
    print('🎵 Lancement de la musique: $stageMusic');

    AudioManager().playMusic(stageMusic).catchError((error) {
      print('❌ Musique $stageMusic non trouvée, utilisation du fallback');
      AudioManager().playMusic('stage1_music.mp3').catchError((error2) {
        print('❌ Fallback aussi échoué, jeu sans musique');
      });
    });
  }

  void _refreshUI() {
    if (mounted) {
      setState(() {});
    }
  }

  void _showGameOverScreen() {
    if (mounted) {
      setState(() {
        _showGameOver = true;
        _isPaused = true;
      });
      print('💀 Écran Game Over affiché');
    }
  }

  @override
  void dispose() {
    print('🗑️ Nettoyage de l\'écran de jeu');
    AudioManager().stopMusic();
    super.dispose();
  }

  void _togglePause() {
    print('⏸️ Bouton pause pressé - État actuel: $_isPaused');
    AudioManager().playSfx('button_click.mp3');
    setState(() {
      _isPaused = !_isPaused;
    });

    if (_isPaused) {
      game.pauseGame();
      AudioManager().pauseMusic();
    } else {
      game.resumeGame();
      AudioManager().resumeMusic();
    }
  }

  void _restartGame() {
    print('🔄 Redémarrage du jeu demandé');
    AudioManager().playSfx('button_click.mp3');

    setState(() {
      _isPaused = false;
      _showGameOver = false;
    });

    game.resetGame();
    _playStageMusic();

    print('✅ Jeu redémarré');
  }

  void _exitToMenu() {
    print('🚪 Retour au menu principal');
    AudioManager().playSfx('button_click.mp3');
    AudioManager().stopMusic();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Jeu Flame
          GameWidget(
            game: game,
            overlayBuilderMap: {
              'pauseOverlay': (context, game) => _isPaused ? _buildPauseMenu() : const SizedBox.shrink(),
              'hudOverlay': (context, game) => _buildHUD(),
              'gameOverOverlay': (context, game) => _showGameOver ? _buildGameOverMenu() : const SizedBox.shrink(),
            },
          ),

          // Bouton pause
          Positioned(
            top: 20,
            right: 20,
            child: IconButton(
              icon: Icon(
                _isPaused ? Icons.play_arrow : Icons.pause,
                color: Colors.white,
                size: 32,
              ),
              onPressed: _togglePause,
            ),
          ),

          // Bouton retour
          Positioned(
            top: 20,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
              onPressed: _exitToMenu,
            ),
          ),

          // Overlay de débogage temporaire (vous pouvez le retirer plus tard)
          Positioned(
            top: 70,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Débogage:',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'Stage: ${widget.stage.stageNumber}',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  Text(
                    'Score: ${game.score}',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  Text(
                    'Timer: ${game.timer}s',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  Text(
                    'Pause: $_isPaused',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  Text(
                    'GameOver: $_showGameOver',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHUD() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHudItem(
                icon: Icons.star,
                value: 'Score: ${game.score}',
                iconColor: Colors.amber,
              ),
              _buildHudItem(
                icon: Icons.timer,
                value: '${(game.timer ~/ 60).toString().padLeft(2, '0')}:${(game.timer % 60).toString().padLeft(2, '0')}',
                iconColor: game.timer < 30 ? Colors.red : Colors.white,
                valueColor: game.timer < 30 ? Colors.red : Colors.white,
              ),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildHudItem({
    required IconData icon,
    required String value,
    required Color iconColor,
    Color valueColor = Colors.white,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPauseMenu() {
    return Container(
      color: Colors.black.withOpacity(0.9),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'JEU EN PAUSE',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Stage ${widget.stage.stageNumber}: ${widget.stage.title}',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 30),

            _buildPauseButton(
              icon: Icons.play_arrow,
              text: 'REPRENDRE',
              color: Colors.green,
              onPressed: _togglePause,
            ),
            const SizedBox(height: 15),

            _buildPauseButton(
              icon: Icons.refresh,
              text: 'REDÉMARRER',
              color: Colors.blue,
              onPressed: _restartGame,
            ),
            const SizedBox(height: 15),

            _buildPauseButton(
              icon: Icons.exit_to_app,
              text: 'QUITTER',
              color: Colors.red,
              onPressed: _exitToMenu,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameOverMenu() {
    return Container(
      color: Colors.black.withOpacity(0.9),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'GAME OVER',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Score Final: ${game.score}',
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Stage: ${widget.stage.title}',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 30),
            _buildPauseButton(
              icon: Icons.refresh,
              text: 'REESSAYER',
              color: Colors.blue,
              onPressed: _restartGame,
            ),
            const SizedBox(height: 15),
            _buildPauseButton(
              icon: Icons.exit_to_app,
              text: 'MENU',
              color: Colors.red,
              onPressed: _exitToMenu,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPauseButton({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 220,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 24),
        label: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}