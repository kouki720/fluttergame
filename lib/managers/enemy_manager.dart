// managers/enemy_manager.dart
import 'package:flame/components.dart';
import '../components/enemies/enemy.dart';
import '../components/enemies/plastic_monster.dart';
import '../components/enemies/toxic_slime.dart';
import '../game/eco_warrior_game.dart';

class EnemyManager extends Component with HasGameRef<EcoWarriorGame> {
  final List<Enemy> _activeEnemies = [];
  Vector2? _playerPosition;

  int _currentStage = -1;

  @override
  void update(double dt) {
    super.update(dt);

    if (_playerPosition == null) return;

    for (final enemy in _activeEnemies) {
      enemy.updatePlayerPosition(_playerPosition!);

      // ✅ CORRECTION: Vérifier si l'ennemi attaque ET si le joueur est proche
      if (enemy.current == EnemyState.attacking) {
        _checkPlayerCollision(enemy);
      }
    }

    // ✅ CORRECTION: Nettoyer les ennemis morts
    _cleanupDeadEnemies();
  }

  void _checkPlayerCollision(Enemy enemy) {
    if (_playerPosition == null) return;

    final distance = (_playerPosition! - enemy.position).length;
    if (distance <= enemy.attackRange) {
      // Le joueur prend des dégâts
      gameRef.player.takeDamage(enemy.damage);
    }
  }

  void spawnEnemiesForStage(int stageNumber, Vector2 levelSize) {
    if (_currentStage == stageNumber) {
      return;
    }

    print('🎯 Génération des ennemis pour le stage $stageNumber...');
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

    // ✅ POSITIONS ORIGINALES
    final plasticMonster = PlasticMonster(
        position: Vector2(
          10.0,
          levelSize.y - 30.0,
        )
    );
    _spawnEnemy(plasticMonster);

    final toxicSlime = ToxicSlime(
        position: Vector2(
          10.0,
          levelSize.y - 30.0,
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
    print('🗑️ Tous les ennemis nettoyés');
  }

  // ✅ CORRECTION: Nettoyer les ennemis morts
  void _cleanupDeadEnemies() {
    final deadEnemies = _activeEnemies.where((enemy) => !enemy.isAlive).toList();

    for (final enemy in deadEnemies) {
      _activeEnemies.remove(enemy);
    }

    if (deadEnemies.isNotEmpty) {
      print('🧹 ${deadEnemies.length} ennemi(s) mort(s) nettoyé(s)');
    }
  }

  // Méthode pour que le joueur attaque les ennemis
  void playerAttacksEnemies(Vector2 attackPosition, double attackRange, double damage) {
    int enemiesHit = 0;

    for (final enemy in _activeEnemies) {
      final distance = (enemy.position - attackPosition).length;
      if (distance <= attackRange && enemy.isAlive) {
        enemy.takeDamage(damage);
        enemiesHit++;
      }
    }

    if (enemiesHit > 0) {
      print('🎯 $enemiesHit ennemi(s) touché(s) par l\'attaque');
    }
  }

  void updatePlayerPosition(Vector2 position) {
    _playerPosition = position;
  }

  List<Enemy> get activeEnemies => List.from(_activeEnemies);
  int get enemyCount => _activeEnemies.length;
  bool get hasActiveEnemies => _activeEnemies.isNotEmpty;

  void clearAllEnemies() {
    _clearAllEnemies();
  }

  // ✅ CORRECTION: Méthode pour reset tous les ennemis
  void resetEnemies(Vector2 levelSize) {
    _clearAllEnemies();
    spawnEnemiesForStage(1, levelSize);
    print('🔄 Ennemis réinitialisés');
  }
}