import 'package:flutter/material.dart';
import 'dart:math' as math;

class CreditsScreen extends StatefulWidget {
  const CreditsScreen({super.key});

  @override
  State<CreditsScreen> createState() => _CreditsScreenState();
}

class _CreditsScreenState extends State<CreditsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scrollController;
  late Animation<double> _scrollAnimation;

  @override
  void initState() {
    super.initState();

    // Animation de défilement automatique (comme un générique de film)
    _scrollController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    );

    _scrollAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scrollController,
      curve: Curves.linear,
    ));

    // Démarrer l'animation
    _scrollController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0D47A1),
              const Color(0xFF1976D2),
              const Color(0xFF1B5E20),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // En-tête avec bouton retour
              _buildHeader(context),

              // Contenu défilant
              Expanded(
                child: AnimatedBuilder(
                  animation: _scrollAnimation,
                  builder: (context, child) {
                    return SingleChildScrollView(
                      controller: ScrollController(
                        initialScrollOffset: _scrollAnimation.value * 2000,
                      ),
                      child: child,
                    );
                  },
                  child: _buildCreditsContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Bouton retour
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
            onPressed: () => Navigator.pop(context),
          ),

          const SizedBox(width: 16),

          // Titre
          const Text(
            'CRÉDITS',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),

          const Spacer(),

          // Bouton pour redémarrer l'animation
          IconButton(
            icon: const Icon(Icons.replay, color: Colors.white, size: 28),
            onPressed: () {
              _scrollController.reset();
              _scrollController.forward();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCreditsContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Column(
        children: [
          const SizedBox(height: 40),

          // Logo principal
          _buildAnimatedLogo(),

          const SizedBox(height: 60),

          // Titre du jeu
          _buildSection(
            title: 'ECO WARRIOR TUNISIA',
            content: [
              'Un Jeu Éducatif sur l\'Environnement',
              'Protégeons Notre Planète 🌍',
            ],
            fontSize: 28,
            isBold: true,
          ),

          const SizedBox(height: 80),

          // Développement
          _buildSection(
            title: '💻 DÉVELOPPEMENT',
            content: [
              'Développeur Principal',
              'Votre Nom',
              '',
              'Moteur de Jeu',
              'Flutter & Flame Engine',
            ],
          ),

          const SizedBox(height: 60),

          // Design
          _buildSection(
            title: '🎨 DESIGN & ART',
            content: [
              'Direction Artistique',
              'Votre Équipe Design',
              '',
              'Illustrations',
              'À définir',
              '',
              'Animations',
              'À définir',
            ],
          ),

          const SizedBox(height: 60),

          // Contenu éducatif
          _buildSection(
            title: '📚 CONTENU ÉDUCATIF',
            content: [
              'Recherche Environnementale',
              'Experts en Écologie Tunisienne',
              '',
              'Questions Quiz',
              'Ministère de l\'Environnement - Tunisie',
              '',
              'Conseiller Pédagogique',
              'À définir',
            ],
          ),

          const SizedBox(height: 60),

          // Audio
          _buildSection(
            title: '🎵 AUDIO',
            content: [
              'Musique Originale',
              'À définir',
              '',
              'Effets Sonores',
              'À définir',
              '',
              'Conception Sonore',
              'À définir',
            ],
          ),

          const SizedBox(height: 60),

          // Remerciements spéciaux
          _buildSection(
            title: '⭐ REMERCIEMENTS SPÉCIAUX',
            content: [
              'Communauté Flutter',
              'Flame Engine Team',
              'OpenGameArt.org',
              '',
              'Partenaires Environnementaux',
              'Associations Écologiques Tunisiennes',
              'Parc National Ichkeul',
              'Ministère de l\'Environnement',
            ],
          ),

          const SizedBox(height: 60),

          // Technologies utilisées
          _buildSection(
            title: '🛠️ TECHNOLOGIES',
            content: [
              'Flutter SDK',
              'Flame Engine 1.18.0',
              'Dart Programming Language',
              '',
              'Bibliothèques',
              'Provider - Gestion d\'état',
              'Shared Preferences - Sauvegarde',
              'Flutter Animate - Animations',
            ],
          ),

          const SizedBox(height: 60),

          // Localisation
          _buildSection(
            title: '🌍 LOCALISATION',
            content: [
              'Tunisie - Tunis',
              '',
              'Inspiré par la beauté naturelle',
              'de la Tunisie et son patrimoine',
              'environnemental unique',
            ],
          ),

          const SizedBox(height: 80),

          // Message environnemental
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.eco,
                  size: 60,
                  color: Colors.white,
                ),
                const SizedBox(height: 20),
                const Text(
                  'NOTRE MISSION',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Sensibiliser les jeunes générations\n'
                      'à la protection de l\'environnement\n'
                      'et aux défis écologiques\n'
                      'de la Tunisie moderne.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 80),

          // Copyright
          _buildSection(
            title: '©️ COPYRIGHT',
            content: [
              '© 2025 Eco Warrior Tunisia',
              'Tous droits réservés',
              '',
              'Version 1.0.0',
              '',
              'Fait avec ❤️ en Tunisie',
            ],
            fontSize: 14,
          ),

          const SizedBox(height: 60),

          // Message final
          const Text(
            '🌱 Ensemble, protégeons notre planète ! 🌱',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
            ),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<String> content,
    double fontSize = 16,
    bool isBold = false,
  }) {
    return Column(
      children: [
        // Titre de section
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize + 6,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
            shadows: const [
              Shadow(
                blurRadius: 10,
                color: Colors.black45,
                offset: Offset(2, 2),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Contenu
        ...content.map((line) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            line,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: fontSize,
              color: line.isEmpty ? Colors.transparent : Colors.white70,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              height: 1.4,
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildAnimatedLogo() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(seconds: 3),
      tween: Tween(begin: 0.0, end: 2 * math.pi),
      builder: (context, angle, child) {
        return Transform.rotate(
          angle: angle,
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
        );
      },
      onEnd: () {
        // Répéter l'animation
        setState(() {});
      },
    );
  }
}