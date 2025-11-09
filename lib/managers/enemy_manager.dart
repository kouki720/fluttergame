// managers/enemy_manager.dart
import 'package:flame/components.dart';
import '../components/enemies/enemy.dart';
import '../components/enemies/plastic_monster.dart';
import '../components/enemies/toxic_slime.dart';

class EnemyManager extends Component with HasGameRef {
  final List<Enemy> _activeEnemies = [];
  Vector2? _playerPosition;

  // ✅ Éviter les doublons de spawn
  int _currentStage = -1;

  @override
  void update(double dt) {
    super.update(dt);

    // Mettre à jour la position du joueur pour tous les ennemis
    if (_playerPosition != null) {
      for (final enemy in _activeEnemies) {
        enemy.updatePlayerPosition(_playerPosition!);
      }
    }
  }

  void spawnEnemiesForStage(int stageNumber, Vector2 levelSize) {
    // ✅ Vérifier si on a déjà spawné ce stage
    if (_currentStage == stageNumber) {
      print('⚠️ Stage $stageNumber déjà spawné, skip...');
      return;
    }

    print('🎯 Génération des ennemis pour le stage $stageNumber...');

    // Nettoyer les ennemis existants d'abord
    _clearAllEnemies();

    _currentStage = stageNumber;

    switch (stageNumber) {
      case 1:
        _spawnStage1Enemies(levelSize);
        break;
      default:
        _spawnStage1Enemies(levelSize);
    }
  }

  void _spawnStage1Enemies(Vector2 levelSize) {
    print('👹 Création des ennemis Stage 1...');

    // ✅ UN SEUL Plastic Monster
    final plasticMonster = PlasticMonster(
        position: Vector2(
          400.0,
          levelSize.y - 100.0,
        )
    );
    _spawnEnemy(plasticMonster);

    // ✅ UN SEUL Toxic Slime
    final toxicSlime = ToxicSlime(
        position: Vector2(
          700.0,
          levelSize.y - 100.0,
        )
    );
    _spawnEnemy(toxicSlime);

    print('✅ Stage 1: 1 Plastic Monster et 1 Toxic Slime créés');
  }

  void _spawnEnemy(Enemy enemy) {
    gameRef.add(enemy);
    _activeEnemies.add(enemy);

    print('👹 ${enemy.runtimeType} spawné à: ${enemy.position}');
  }

  void _clearAllEnemies() {
    for (final enemy in _activeEnemies) {
      enemy.removeFromParent();
    }
    _activeEnemies.clear();
    _currentStage = -1;
    print('🗑️ Anciens ennemis nettoyés');
  }

  // Méthode pour mettre à jour la position du joueur
  void updatePlayerPosition(Vector2 position) {
    _playerPosition = position;
  }

  // Getters
  List<Enemy> get activeEnemies => List.from(_activeEnemies);
  int get enemyCount => _activeEnemies.length;
  bool get hasActiveEnemies => _activeEnemies.isNotEmpty;

  void clearAllEnemies() {
    _clearAllEnemies();
  }
}