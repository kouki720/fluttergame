import 'package:flutter/material.dart';
import '../managers/audio_manager.dart';
import '../models/stage_data.dart';

class GameplayScreen extends StatelessWidget {
  final StageData stage;

  const GameplayScreen({super.key, required this.stage});

  @override
  Widget build(BuildContext context) {
    // Changer la musique pour le gameplay
    AudioManager().playMusic('stage1_music.mp3');

    return Scaffold(
      backgroundColor: Colors.blue[900],
      body: Stack(
        children: [
          // Fond temporaire
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue.shade800,
                  Colors.blue.shade600,
                  const Color(0xFF1B5E20),
                ],
              ),
            ),
          ),

          // Contenu temporaire
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // En-tête
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          AudioManager().playSfx('button_click.mp3');
                          Navigator.pop(context);
                        },
                      ),
                      Text(
                        'STAGE ${stage.stageNumber}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.pause, color: Colors.white),
                        onPressed: () {
                          AudioManager().playSfx('button_click.mp3');
                          _showPauseMenu(context);
                        },
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Message temporaire
                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.construction,
                          size: 80,
                          color: Colors.orange,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'GAMEPLAY EN DÉVELOPPEMENT',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'Le stage "${stage.title}" sera bientôt disponible !',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 25),
                        Text(
                          '🎮 Contrôles prévus :\n'
                              '• Joystick : Déplacement\n'
                              '• Bouton A : Saut\n'
                              '• Bouton B : Attaque Épée\n'
                              '• Bouton X : Attaque Flamme\n'
                              '• Timer : 3 minutes\n'
                              '• Objectif : Battre les ennemis de pollution',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Bouton retour
                  ElevatedButton.icon(
                    onPressed: () {
                      AudioManager().playSfx('button_click.mp3');
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.exit_to_app),
                    label: const Text(
                      'RETOUR À LA SÉLECTION',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPauseMenu(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B5E20),
        title: const Row(
          children: [
            Icon(Icons.pause_circle_filled, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'JEU EN PAUSE',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Que souhaitez-vous faire ?',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          // Continuer
          TextButton(
            onPressed: () {
              AudioManager().playSfx('button_click.mp3');
              Navigator.pop(context);
            },
            child: const Text(
              'CONTINUER',
              style: TextStyle(color: Colors.white),
            ),
          ),

          // Redémarrer
          TextButton(
            onPressed: () {
              AudioManager().playSfx('button_click.mp3');
              Navigator.pop(context);
              // Ici on redémarrerait le niveau
            },
            child: const Text(
              'REDÉMARRER',
              style: TextStyle(color: Colors.orange),
            ),
          ),

          // Quitter
          TextButton(
            onPressed: () {
              AudioManager().playSfx('button_click.mp3');
              Navigator.pop(context); // Fermer la pause
              Navigator.pop(context); // Retour à la sélection
            },
            child: const Text(
              'QUITTER',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}