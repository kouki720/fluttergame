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
  bool _enemiesStopped = false;

  @override
  void update(double dt) {
    super.update(dt);

    if (_playerPosition == null || _enemiesStopped) return;

    for (final enemy in _activeEnemies) {
      enemy.updatePlayerPosition(_playerPosition!);
    }

    _cleanupDeadEnemies();
  }

  // Arrêter tous les ennemis (seulement quand le joueur meurt)
  void stopAllEnemies() {
    _enemiesStopped = true;
    print('🛑 Tous les ennemis arrêtés');

    for (final enemy in _activeEnemies) {
      enemy.isActive = false;
      enemy.current = EnemyState.idle;
    }
  }

  // Redémarrer les ennemis
  void restartAllEnemies() {
    _enemiesStopped = false;
    print('▶️ Ennemis redémarrés');

    for (final enemy in _activeEnemies) {
      enemy.isActive = true;
    }
  }

  void spawnEnemiesForStage(int stageNumber, Vector2 levelSize) {
    if (_currentStage == stageNumber) return;

    print('🎯 Génération ennemis stage $stageNumber...');
    _clearAllEnemies();
    _currentStage = stageNumber;
    _enemiesStopped = false;

    switch (stageNumber) {
      case 1:
        _spawnStage1Enemies(levelSize);
        break;
      default:
        _spawnStage1Enemies(levelSize);
    }
  }

  void _spawnStage1Enemies(Vector2 levelSize) {
    // ✅ CORRECTION: Positions plus proches du joueur pour qu'ils l'attaquent dès le début
    final plasticMonster = PlasticMonster(
        position: Vector2(levelSize.x * 0.6, levelSize.y - 30.0) // Plus proche
    );
    _spawnEnemy(plasticMonster);

    final toxicSlime = ToxicSlime(
        position: Vector2(levelSize.x * 0.4, levelSize.y - 30.0) // Plus proche
    );
    _spawnEnemy(toxicSlime);

    print('✅ Stage 1: 1 Plastic Monster et 1 Toxic Slime créés - Prêts à attaquer!');
  }

  void _spawnEnemy(Enemy enemy) {
    gameRef.add(enemy);
    _activeEnemies.add(enemy);
  }

  void _clearAllEnemies() {
    for (final enemy in _activeEnemies) {
      enemy.removeFromParent();
    }
    _activeEnemies.clear();
    _currentStage = -1;
    _enemiesStopped = false;
  }

  void _cleanupDeadEnemies() {
    final deadEnemies = _activeEnemies.where((enemy) => !enemy.isAlive).toList();
    for (final enemy in deadEnemies) {
      _activeEnemies.remove(enemy);
    }
  }

  void playerAttacksEnemies(Vector2 attackPosition, double attackRange, double damage) {
    if (_enemiesStopped) return;

    int enemiesHit = 0;

    for (final enemy in _activeEnemies) {
      final distance = (enemy.position - attackPosition).length;
      if (distance <= attackRange && enemy.isAlive) {
        enemy.takeDamage(damage);
        enemiesHit++;
      }
    }

    if (enemiesHit > 0) {
      print('🎯 $enemiesHit ennemi(s) touché(s)');
    }
  }

  void updatePlayerPosition(Vector2 position) {
    if (!_enemiesStopped) {
      _playerPosition = position;
    }
  }

  List<Enemy> get activeEnemies => List.from(_activeEnemies);
  int get enemyCount => _activeEnemies.length;
  bool get hasActiveEnemies => _activeEnemies.isNotEmpty;

  void clearAllEnemies() {
    _clearAllEnemies();
  }

  void resetEnemies(Vector2 levelSize) {
    _clearAllEnemies();
    spawnEnemiesForStage(1, levelSize);
  }
}