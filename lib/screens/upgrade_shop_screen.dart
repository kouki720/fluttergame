import 'package:flutter/material.dart';
import '../managers/game_manager.dart';
import '../managers/audio_manager.dart';
import '../widgets/animated_background_widget.dart';
import '../managers/player_stats.dart';
import '../utils/responsive_helper.dart';

class UpgradeShopScreen extends StatefulWidget {
  const UpgradeShopScreen({super.key});

  @override
  State<UpgradeShopScreen> createState() => _UpgradeShopScreenState();
}

class _UpgradeShopScreenState extends State<UpgradeShopScreen> {
  final GameManager _gameManager = GameManager();
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = ResponsiveHelper.isSmallScreen(context);
    final isPortrait = ResponsiveHelper.isPortrait(context);

    return Scaffold(
      body: AnimatedBackgroundWidget(
        colors: const [
          Color(0xFF1B5E20),
          Color(0xFF2E7D32),
          Color(0xFF4CAF50),
        ],
        child: SafeArea(
          child: Column(
            children: [
              // En-tête
              _buildHeader(context, isSmallScreen),

              // Affichage des coins
              _buildCoinsDisplay(isSmallScreen),

              // Statistiques actuelles
              _buildCurrentStats(isSmallScreen),

              // Liste des améliorations
              Expanded(
                child: _buildUpgradeList(isSmallScreen),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      child: Row(
        children: [
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
          Text(
            'AMÉLIORATIONS',
            style: TextStyle(
              fontSize: isSmallScreen ? 24 : 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: isSmallScreen ? 1 : 2,
            ),
          ),
          Spacer(),
          // Indicateur de sauvegarde simplifié
          _isSaving
              ? SizedBox(
            width: isSmallScreen ? 20 : 24,
            height: isSmallScreen ? 20 : 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.green,
            ),
          )
              : Icon(
            Icons.check_circle,
            color: Colors.green,
            size: isSmallScreen ? 20 : 24,
          ),
        ],
      ),
    );
  }

  Widget _buildCoinsDisplay(bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 16 : 20,
          vertical: isSmallScreen ? 8 : 10
      ),
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.amber, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.monetization_on,
              color: Colors.amber,
              size: isSmallScreen ? 28 : 32),
          SizedBox(width: isSmallScreen ? 8 : 12),
          Text(
            '${_gameManager.playerStats.coins}',
            style: TextStyle(
              fontSize: isSmallScreen ? 24 : 28,
              fontWeight: FontWeight.bold,
              color: Colors.amber,
            ),
          ),
          SizedBox(width: isSmallScreen ? 6 : 8),
          Text(
            'Coins',
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 18,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStats(bool isSmallScreen) {
    final stats = _gameManager.playerStats;

    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 16 : 20,
          vertical: isSmallScreen ? 8 : 10
      ),
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(
            'STATISTIQUES ACTUELLES',
            style: TextStyle(
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('❤️', '${stats.maxHealth.toInt()} PV', isSmallScreen),
              _buildStatItem('⚡', '${stats.moveSpeed.toInt()} Vit', isSmallScreen),
              _buildStatItem('🔼', '${stats.jumpPower.toInt()} Saut', isSmallScreen),
            ],
          ),
          SizedBox(height: isSmallScreen ? 6 : 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('⚔️', '${stats.swordDamage.toInt()} Dég', isSmallScreen),
              _buildStatItem('🔥', '${stats.flameType.name}', isSmallScreen),
              _buildStatItem('💰', '${stats.coins} Coins', isSmallScreen),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String icon, String value, bool isSmallScreen) {
    return Column(
      children: [
        Text(icon, style: TextStyle(fontSize: isSmallScreen ? 16 : 20)),
        SizedBox(height: isSmallScreen ? 2 : 4),
        Text(
          value,
          style: TextStyle(
            fontSize: isSmallScreen ? 10 : 14,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildUpgradeList(bool isSmallScreen) {
    final upgrades = [
      // SANTÉ
      _UpgradeItem(
        name: 'Vie Maximum +',
        description: '+20 points de vie maximum',
        icon: Icons.favorite,
        cost: 200,
        currentLevel: (_gameManager.playerStats.maxHealth - 100) ~/ 20,
        maxLevel: 5,
        isSmallScreen: isSmallScreen,
        onPurchase: () async {
          if (_gameManager.playerStats.coins >= 200) {
            setState(() => _isSaving = true);

            _gameManager.playerStats.coins -= 200;
            _gameManager.playerStats.maxHealth += 20;
            _gameManager.playerStats.currentHealth = _gameManager.playerStats.maxHealth;

            await _gameManager.saveProgress();
            setState(() => _isSaving = false);
            return true;
          }
          return false;
        },
      ),

      // MOBILITÉ
      _UpgradeItem(
        name: 'Vitesse de Course',
        description: '+10% de vitesse de déplacement',
        icon: Icons.directions_run,
        cost: 150,
        currentLevel: (_gameManager.playerStats.moveSpeed - 200) ~/ 20,
        maxLevel: 5,
        isSmallScreen: isSmallScreen,
        onPurchase: () async {
          if (_gameManager.playerStats.coins >= 150) {
            setState(() => _isSaving = true);

            _gameManager.playerStats.coins -= 150;
            _gameManager.playerStats.moveSpeed += 20;

            await _gameManager.saveProgress();
            setState(() => _isSaving = false);
            return true;
          }
          return false;
        },
      ),

      _UpgradeItem(
        name: 'Puissance de Saut',
        description: '+15% de hauteur de saut',
        icon: Icons.arrow_upward,
        cost: 120,
        currentLevel: (_gameManager.playerStats.jumpPower - 400) ~/ 60,
        maxLevel: 5,
        isSmallScreen: isSmallScreen,
        onPurchase: () async {
          if (_gameManager.playerStats.coins >= 120) {
            setState(() => _isSaving = true);

            _gameManager.playerStats.coins -= 120;
            _gameManager.playerStats.jumpPower += 60;

            await _gameManager.saveProgress();
            setState(() => _isSaving = false);
            return true;
          }
          return false;
        },
      ),

      // ATTAQUES
      _UpgradeItem(
        name: 'Épée Affûtée',
        description: '+20% de dégâts à l\'épée',
        icon: Icons.architecture,
        cost: 180,
        currentLevel: (_gameManager.playerStats.swordDamage - 20) ~/ 4,
        maxLevel: 5,
        isSmallScreen: isSmallScreen,
        onPurchase: () async {
          if (_gameManager.playerStats.coins >= 180) {
            setState(() => _isSaving = true);

            _gameManager.playerStats.coins -= 180;
            _gameManager.playerStats.swordDamage += 4;

            await _gameManager.saveProgress();
            setState(() => _isSaving = false);
            return true;
          }
          return false;
        },
      ),

      _UpgradeItem(
        name: 'Flamme Bleue',
        description: 'Flamme bleue plus puissante (25 dégâts)',
        icon: Icons.local_fire_department,
        iconColor: Colors.blue,
        cost: 300,
        currentLevel: _gameManager.playerStats.flameType == FlameType.blue ||
            _gameManager.playerStats.flameType == FlameType.purple ? 1 : 0,
        maxLevel: 1,
        isSmallScreen: isSmallScreen,
        onPurchase: () async {
          if (_gameManager.playerStats.coins >= 300) {
            setState(() => _isSaving = true);

            _gameManager.playerStats.coins -= 300;
            _gameManager.playerStats.flameType = FlameType.blue;
            _gameManager.playerStats.flameDamage = 25;

            await _gameManager.saveProgress();
            setState(() => _isSaving = false);
            return true;
          }
          return false;
        },
      ),

      _UpgradeItem(
        name: 'Flamme Mauve',
        description: 'Flamme mauve ultime (40 dégâts)',
        icon: Icons.local_fire_department,
        iconColor: Colors.purple,
        cost: 500,
        currentLevel: _gameManager.playerStats.flameType == FlameType.purple ? 1 : 0,
        maxLevel: 1,
        isSmallScreen: isSmallScreen,
        onPurchase: () async {
          if (_gameManager.playerStats.coins >= 500) {
            setState(() => _isSaving = true);

            _gameManager.playerStats.coins -= 500;
            _gameManager.playerStats.flameType = FlameType.purple;
            _gameManager.playerStats.flameDamage = 40;

            await _gameManager.saveProgress();
            setState(() => _isSaving = false);
            return true;
          }
          return false;
        },
      ),
    ];

    return ListView.builder(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      itemCount: upgrades.length,
      itemBuilder: (context, index) => upgrades[index],
    );
  }
}

class _UpgradeItem extends StatelessWidget {
  final String name;
  final String description;
  final IconData icon;
  final Color iconColor;
  final int cost;
  final int currentLevel;
  final int maxLevel;
  final bool isSmallScreen;
  final Future<bool> Function() onPurchase;

  const _UpgradeItem({
    required this.name,
    required this.description,
    required this.icon,
    this.iconColor = Colors.white,
    required this.cost,
    required this.currentLevel,
    required this.maxLevel,
    required this.isSmallScreen,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    final gameManager = GameManager();
    final canAfford = gameManager.playerStats.coins >= cost;
    final isMaxLevel = currentLevel >= maxLevel;

    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 8 : 12),
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMaxLevel ? Colors.green : Colors.white.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          // Icône
          Icon(icon, color: iconColor, size: isSmallScreen ? 32 : 40),
          SizedBox(width: isSmallScreen ? 12 : 16),

          // Informations
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 2 : 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                SizedBox(height: isSmallScreen ? 6 : 8),
                Row(
                  children: [
                    Icon(Icons.monetization_on,
                        color: canAfford ? Colors.amber : Colors.red,
                        size: isSmallScreen ? 14 : 16),
                    SizedBox(width: isSmallScreen ? 2 : 4),
                    Text(
                      '$cost Coins',
                      style: TextStyle(
                        color: canAfford ? Colors.amber : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 12 : 14,
                      ),
                    ),
                    Spacer(),
                    Text(
                      'Niveau $currentLevel/$maxLevel',
                      style: TextStyle(
                        color: isMaxLevel ? Colors.green : Colors.white70,
                        fontSize: isSmallScreen ? 10 : 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Bouton d'achat
          SizedBox(width: isSmallScreen ? 8 : 12),
          ElevatedButton(
            onPressed: isMaxLevel ? null : () async {
              AudioManager().playSfx('button_click.mp3');
              final success = await onPurchase();

              if (success) {
                AudioManager().playSfx('power_up.mp3');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$name acheté !'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Pas assez de coins !'),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isMaxLevel ? Colors.green :
              canAfford ? Color(0xFF2196F3) : Colors.grey,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 12 : 16,
                  vertical: isSmallScreen ? 8 : 12
              ),
            ),
            child: Text(
              isMaxLevel ? 'MAX' : 'ACHETER',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 12 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}