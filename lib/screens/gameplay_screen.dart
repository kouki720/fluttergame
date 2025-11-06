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

  @override
  void initState() {
    super.initState();

    // Initialiser le jeu
    game = EcoWarriorGame();

    // Changer la musique pour le gameplay
    AudioManager().playMusic('stage1_music.mp3');
  }

  @override
  void dispose() {
    // Nettoyer si nécessaire
    super.dispose();
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });

    if (_isPaused) {
      AudioManager().pauseMusic();
    } else {
      AudioManager().resumeMusic();
    }
  }

  void _exitGame() {
    AudioManager().playSfx('button_click.mp3');
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
              'pauseMenu': (context, game) => _buildPauseMenu(),
            },
          ),

          // En-tête du stage
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: _buildStageHeader(),
          ),

          // Bouton pause en haut à droite
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

          // Bouton retour en haut à gauche
          Positioned(
            top: 20,
            left: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 32,
              ),
              onPressed: _exitGame,
            ),
          ),

          // Indicateurs de contrôle (pour aider le joueur)
          Positioned(
            bottom: 20,
            left: 20,
            child: _buildControlHints(),
          ),
        ],
      ),
    );
  }

  Widget _buildStageHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 60), // Centrer
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            widget.stage.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            widget.stage.location,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlHints() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildControlHint('⬅️ Zone gauche', 'Déplacement gauche'),
          const SizedBox(height: 6),
          _buildControlHint('➡️ Zone droite', 'Déplacement droite'),
          const SizedBox(height: 6),
          _buildControlHint('🔼 Zone haut', 'Sauter'),
        ],
      ),
    );
  }

  Widget _buildControlHint(String icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildPauseMenu() {
    if (!_isPaused) return const SizedBox.shrink();

    return Container(
      color: Colors.black.withOpacity(0.7),
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
            ElevatedButton.icon(
              onPressed: _togglePause,
              icon: const Icon(Icons.play_arrow),
              label: const Text('REPRENDRE'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: _exitGame,
              icon: const Icon(Icons.exit_to_app),
              label: const Text('QUITTER LE STAGE'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}