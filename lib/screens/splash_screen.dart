import 'package:flutter/material.dart';
import 'dart:async';
import 'main_menu_screen.dart';
import '../widgets/animated_background_widget.dart';
import '../managers/audio_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _progressController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _progressAnimation;

  double _loadingProgress = 0.0;
  String _loadingText = 'Chargement...';
  bool _isLoadingComplete = false;

  @override
  void initState() {
    super.initState();

    // Initialiser les contrôleurs d'animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    // Animation de scale (pulse)
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    // Animation de la barre de progression
    _progressController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOut),
    )..addListener(() {
      setState(() {
        _loadingProgress = _progressAnimation.value;
        _updateLoadingText(_loadingProgress);
      });
    });

    // Démarrer le chargement
    _startLoading();
  }

  void _startLoading() async {
    // Démarrer la musique du menu (elle continuera après le splash)
    AudioManager().playMusic('menu_music.mp3');

    // Démarrer les animations
    _fadeController.forward();

    // Simuler le chargement des ressources
    await Future.delayed(const Duration(milliseconds: 500));
    _progressController.forward();

    // Attendre la fin du chargement
    await Future.delayed(const Duration(milliseconds: 3500));

    if (mounted) {
      setState(() {
        _isLoadingComplete = true;
      });

      // Navigation vers le menu principal
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
            const MainMenuScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    }
  }

  void _updateLoadingText(double progress) {
    if (progress < 0.3) {
      _loadingText = 'Chargement des ressources...';
    } else if (progress < 0.6) {
      _loadingText = 'Préparation de l\'aventure...';
    } else if (progress < 0.9) {
      _loadingText = 'Protection de l\'environnement...';
    } else {
      _loadingText = 'C\'est parti !';
    }
  }

  @override
  void dispose() {
    // IMPORTANT: NE PAS arrêter la musique ici !
    // Elle doit continuer dans le menu principal

    _fadeController.dispose();
    _scaleController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackgroundWidget(
        colors: const [
          Color(0xFF1B5E20), // Vert foncé
          Color(0xFF2E7D32), // Vert moyen
          Color(0xFF4CAF50), // Vert clair
        ],
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo animé
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 150,
                    height: 150,
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
                    child: const Icon(
                      Icons.eco,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Titre du jeu
                AnimatedOpacity(
                  opacity: _loadingProgress > 0.2 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: const Text(
                    'ECO WARRIOR',
                    style: TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 6,
                      shadows: [
                        Shadow(
                          blurRadius: 15,
                          color: Colors.black45,
                          offset: Offset(3, 3),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                AnimatedOpacity(
                  opacity: _loadingProgress > 0.3 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: const Text(
                    'TUNISIA',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w400,
                      color: Colors.white70,
                      letterSpacing: 4,
                    ),
                  ),
                ),

                const SizedBox(height: 80),

                // Barre de progression
                AnimatedOpacity(
                  opacity: _loadingProgress > 0.1 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    width: 300,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: _loadingProgress,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _isLoadingComplete ? Colors.green : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Texte de chargement
                AnimatedOpacity(
                  opacity: _loadingProgress > 0.1 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _loadingText,
                    style: TextStyle(
                      fontSize: 18,
                      color: _isLoadingComplete ? Colors.green : Colors.white70,
                      letterSpacing: 1,
                      fontWeight: _isLoadingComplete ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Pourcentage
                AnimatedOpacity(
                  opacity: _loadingProgress > 0.1 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    '${(_loadingProgress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 16,
                      color: _isLoadingComplete ? Colors.green : Colors.white54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 50),

                // Message environnemental
                AnimatedOpacity(
                  opacity: _loadingProgress > 0.5 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      '🌱 Ensemble, protégeons notre belle Tunisie ! 🌱',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white60,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),

                // Indicateur de chargement complet
                if (_isLoadingComplete) ...[
                  const SizedBox(height: 30),
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    strokeWidth: 2,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Redirection...',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}