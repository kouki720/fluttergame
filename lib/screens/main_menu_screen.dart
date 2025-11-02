import 'package:flutter/material.dart';
import '../widgets/menu_button.dart';
import 'stage_selection_screen.dart';
import 'settings_screen.dart';
import 'credits_screen.dart';
import '../widgets/animated_background_widget.dart';
import '../managers/audio_manager.dart';
import '../utils/responsive_helper.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Démarrer la musique du menu
    AudioManager().playMusic('menu_music.mp3');

    // Contrôleur d'animation principal
    _animController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Animation de glissement vers le haut
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    // Animation de fondu
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeIn,
      ),
    );

    // Démarrer l'animation
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onButtonPressed(VoidCallback action) {
    // Jouer le son du bouton
    AudioManager().playSfx('button_click.mp3');
    // Exécuter l'action
    action();
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = ResponsiveHelper.isSmallScreen(context);
    final isPortrait = ResponsiveHelper.isPortrait(context);

    return Scaffold(
      body: AnimatedBackgroundWidget(
        colors: const [
          Color(0xFF1B5E20), // Vert foncé
          Color(0xFF2E7D32), // Vert moyen
          Color(0xFF4CAF50), // Vert clair
        ],
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: isSmallScreen ? 10 : 20),

                      // Logo du jeu avec cercle
                      Container(
                        width: isSmallScreen ? 80 : 120,
                        height: isSmallScreen ? 80 : 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.eco,
                          size: isSmallScreen ? 40 : 70,
                          color: Colors.white,
                        ),
                      ),

                      SizedBox(height: isSmallScreen ? 20 : 30),

                      // Titre principal
                      Text(
                        'ECO WARRIOR',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 36 : 56,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: isSmallScreen ? 3 : 5,
                          shadows: const [
                            Shadow(
                              blurRadius: 15,
                              color: Colors.black45,
                              offset: Offset(3, 3),
                            ),
                          ],
                        ),
                      ),

                      // Sous-titre
                      Text(
                        'TUNISIA',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 24 : 36,
                          fontWeight: FontWeight.w400,
                          color: Colors.white70,
                          letterSpacing: isSmallScreen ? 2 : 3,
                        ),
                      ),

                      SizedBox(height: isSmallScreen ? 8 : 10),

                      // Slogan
                      Text(
                        '🌍 Protégeons notre environnement 🌍',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 16,
                          color: Colors.white60,
                          fontStyle: FontStyle.italic,
                        ),
                      ),

                      SizedBox(height: isSmallScreen ? 30 : 50),

                      // Bouton: Nouvelle Partie
                      MenuButton(
                        icon: Icons.play_arrow_rounded,
                        label: 'NOUVELLE PARTIE',
                        width: isSmallScreen ? 260 : 320,
                        height: isSmallScreen ? 60 : 70,
                        onPressed: () {
                          _onButtonPressed(() {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const StageSelectionScreen(),
                              ),
                            );
                          });
                        },
                      ),

                      SizedBox(height: isSmallScreen ? 16 : 20),

                      // Bouton: Continuer
                      MenuButton(
                        icon: Icons.refresh_rounded,
                        label: 'CONTINUER',
                        width: isSmallScreen ? 260 : 320,
                        height: isSmallScreen ? 60 : 70,
                        onPressed: () {
                          _onButtonPressed(() {
                            // TODO: Implémenter la sauvegarde plus tard
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Aucune sauvegarde trouvée'),
                                duration: Duration(seconds: 2),
                                backgroundColor: Color(0xFF2E7D32),
                              ),
                            );
                          });
                        },
                      ),

                      SizedBox(height: isSmallScreen ? 16 : 20),

                      // Bouton: Paramètres
                      MenuButton(
                        icon: Icons.settings_rounded,
                        label: 'PARAMÈTRES',
                        width: isSmallScreen ? 260 : 320,
                        height: isSmallScreen ? 60 : 70,
                        onPressed: () {
                          _onButtonPressed(() {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SettingsScreen(),
                              ),
                            );
                          });
                        },
                      ),

                      SizedBox(height: isSmallScreen ? 16 : 20),

                      // Bouton: Crédits
                      MenuButton(
                        icon: Icons.info_rounded,
                        label: 'CRÉDITS',
                        width: isSmallScreen ? 260 : 320,
                        height: isSmallScreen ? 60 : 70,
                        onPressed: () {
                          _onButtonPressed(() {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CreditsScreen(),
                              ),
                            );
                          });
                        },
                      ),

                      SizedBox(height: isSmallScreen ? 30 : 40),

                      // Numéro de version
                      Text(
                        'Version 1.0.0',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 10 : 12,
                          color: Colors.white38,
                          letterSpacing: isSmallScreen ? 0.5 : 1,
                        ),
                      ),

                      SizedBox(height: isSmallScreen ? 10 : 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}