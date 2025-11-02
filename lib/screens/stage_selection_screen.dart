import 'package:flutter/material.dart';
import '../widgets/stage_card.dart';
import '../models/stage_data.dart';
import '../managers/audio_manager.dart';
import '../managers/game_manager.dart';
import '../utils/responsive_helper.dart';
import 'upgrade_shop_screen.dart';
import 'story_screen.dart';

class StageSelectionScreen extends StatefulWidget {
  const StageSelectionScreen({super.key});

  @override
  State<StageSelectionScreen> createState() => _StageSelectionScreenState();
}

class _StageSelectionScreenState extends State<StageSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  // Progression du joueur
  int currentUnlockedStage = 1;
  final GameManager _gameManager = GameManager();

  // Liste des 8 stages
  final List<StageData> stages = [
    StageData(
      stageNumber: 1,
      title: 'La Plage de Hammamet',
      description: 'Sauve la plage de la pollution plastique',
      theme: '🏖️ Pollution Plastique',
      location: 'Hammamet, Tunisie',
      difficulty: 'Facile',
      isUnlocked: true,
      backgroundColor: const Color(0xFF0277BD),
      icon: Icons.beach_access,
    ),
    StageData(
      stageNumber: 2,
      title: 'La Forêt de Aïn Draham',
      description: 'Protège la forêt et sa biodiversité',
      theme: '🌲 Déforestation',
      location: 'Aïn Draham, Tunisie',
      difficulty: 'Facile',
      isUnlocked: false,
      backgroundColor: const Color(0xFF2E7D32),
      icon: Icons.forest,
    ),
    StageData(
      stageNumber: 3,
      title: 'La Mer Méditerranée',
      description: 'Nettoie l\'écosystème marin',
      theme: '🌊 Pollution Marine',
      location: 'Côte Tunisienne',
      difficulty: 'Moyen',
      isUnlocked: false,
      backgroundColor: const Color(0xFF01579B),
      icon: Icons.water,
    ),
    StageData(
      stageNumber: 4,
      title: 'L\'Oasis de Tozeur',
      description: 'Lutte contre la désertification',
      theme: '🌴 Désertification',
      location: 'Tozeur, Tunisie',
      difficulty: 'Moyen',
      isUnlocked: false,
      backgroundColor: const Color(0xFFE65100),
      icon: Icons.wb_sunny,
    ),
    StageData(
      stageNumber: 5,
      title: 'Centre-ville de Tunis',
      description: 'Réduis la pollution urbaine',
      theme: '🏙️ Pollution de l\'Air',
      location: 'Tunis, Tunisie',
      difficulty: 'Difficile',
      isUnlocked: false,
      backgroundColor: const Color(0xFF424242),
      icon: Icons.location_city,
    ),
    StageData(
      stageNumber: 6,
      title: 'Le Lac Ichkeul',
      description: 'Protège les oiseaux migrateurs',
      theme: '🦅 Zones Humides',
      location: 'Parc National Ichkeul',
      difficulty: 'Difficile',
      isUnlocked: false,
      backgroundColor: const Color(0xFF1565C0),
      icon: Icons.park,
    ),
    StageData(
      stageNumber: 7,
      title: 'Le Désert du Sahara',
      description: 'Combat le changement climatique',
      theme: '🏜️ Climat',
      location: 'Sahara Tunisien',
      difficulty: 'Très Difficile',
      isUnlocked: false,
      backgroundColor: const Color(0xFFBF360C),
      icon: Icons.landscape,
    ),
    StageData(
      stageNumber: 8,
      title: 'Boss Final - Tunis',
      description: 'Affrontement final contre la pollution',
      theme: '⚔️ Boss Final',
      location: 'Capitale de Tunis',
      difficulty: 'BOSS',
      isUnlocked: false,
      backgroundColor: const Color(0xFFB71C1C),
      icon: Icons.shield,
    ),
  ];

  @override
  void initState() {
    super.initState();

    // Débloquer les stages selon la progression
    _unlockStages();

    // Animation d'entrée
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _animController.forward();
  }

  void _unlockStages() {
    // Débloquer les stages jusqu'au stage actuel
    for (int i = 0; i < currentUnlockedStage && i < stages.length; i++) {
      stages[i].isUnlocked = true;
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = ResponsiveHelper.isSmallScreen(context);
    final isPortrait = ResponsiveHelper.isPortrait(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1B5E20),
              const Color(0xFF388E3C),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // En-tête
              _buildHeader(context),

              // Section coins et améliorations
              _buildCoinsAndUpgradeSection(),

              // Liste des stages
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildStageGrid(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isSmallScreen = ResponsiveHelper.isSmallScreen(context);

    return Padding(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      child: Row(
        children: [
          // Bouton retour
          IconButton(
            icon: Icon(Icons.arrow_back,
                color: Colors.white,
                size: isSmallScreen ? 28 : 32),
            onPressed: () {
              AudioManager().playSfx('button_click.mp3');
              Navigator.pop(context);
            },
          ),

          SizedBox(width: isSmallScreen ? 12 : 16),

          // Titre
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SÉLECTION DU STAGE',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 24 : 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: isSmallScreen ? 1 : 2,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Progression: $currentUnlockedStage/8 stages débloqués',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // Score total
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 16,
                vertical: isSmallScreen ? 6 : 8
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.star,
                    color: Colors.amber,
                    size: isSmallScreen ? 20 : 24),
                SizedBox(width: isSmallScreen ? 6 : 8),
                Text(
                  '0',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Section coins et améliorations
  Widget _buildCoinsAndUpgradeSection() {
    final isSmallScreen = ResponsiveHelper.isSmallScreen(context);
    final isPortrait = ResponsiveHelper.isPortrait(context);

    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 16 : 20,
          vertical: isSmallScreen ? 8 : 10
      ),
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Affichage des coins
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 12 : 16,
                  vertical: isSmallScreen ? 6 : 8
              ),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.monetization_on,
                      color: Colors.amber,
                      size: isSmallScreen ? 20 : 24),
                  SizedBox(width: isSmallScreen ? 6 : 8),
                  Text(
                    '${_gameManager.playerStats.coins}',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 2 : 4),
                  Text(
                    'Coins',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(width: isSmallScreen ? 12 : 16),

          // Bouton améliorations
          ElevatedButton.icon(
            onPressed: () {
              AudioManager().playSfx('button_click.mp3');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const UpgradeShopScreen(),
                ),
              );
            },
            icon: Icon(Icons.upgrade,
                size: isSmallScreen ? 20 : 24),
            label: Text(
              'AMÉLIORATIONS',
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 12 : 20,
                  vertical: isSmallScreen ? 8 : 12
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columnCount = ResponsiveHelper.getResponsiveColumnCount(context);
        final isPortrait = ResponsiveHelper.isPortrait(context);
        final isSmallScreen = ResponsiveHelper.isSmallScreen(context);

        return GridView.builder(
          padding: EdgeInsets.all(isSmallScreen ? 8 : 16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnCount,
            crossAxisSpacing: isSmallScreen ? 8 : 16,
            mainAxisSpacing: isSmallScreen ? 8 : 16,
            childAspectRatio: isPortrait ? 0.7 : 0.85,
          ),
          itemCount: stages.length,
          itemBuilder: (context, index) {
            return _buildStageCard(stages[index], index);
          },
        );
      },
    );
  }

  Widget _buildStageCard(StageData stage, int index) {
    return StageCard(
      stage: stage,
      delay: index * 100,
      onTap: () {
        if (stage.isUnlocked) {
          _onStageSelected(stage);
        } else {
          _showLockedDialog(stage);
        }
      },
    );
  }

  void _onStageSelected(StageData stage) {
    // Lancer directement l'écran d'histoire
    AudioManager().playSfx('button_click.mp3');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StoryScreen(stage: stage),
      ),
    );
  }

  void _showLockedDialog(StageData stage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lock, color: Colors.orange),
            SizedBox(width: 8),
            Text('Stage Verrouillé'),
          ],
        ),
        content: Text(
          'Le stage ${stage.stageNumber} : "${stage.title}" est verrouillé.\n\n'
              'Complète le stage ${stage.stageNumber - 1} pour débloquer ce stage !',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }
}