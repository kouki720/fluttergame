// components/enemies/enemy.dart
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

enum EnemyState { idle, moving, attacking, hurt, dying }

abstract class Enemy extends SpriteAnimationGroupComponent<EnemyState>
    with HasGameRef {

  // Propriétés de base
  double health = 100.0;
  double maxHealth = 100.0;
  double damage = 10.0;
  double moveSpeed = 50.0;
  double attackRange = 100.0;
  double detectionRange = 200.0;

  bool isActive = true;
  bool isFacingRight = false;

  // Référence au joueur
  Vector2? playerPosition;

  // Animations
  late SpriteAnimation idleAnimation;
  late SpriteAnimation moveAnimation;
  late SpriteAnimation attackAnimation;
  late SpriteAnimation hurtAnimation;
  late SpriteAnimation dyingAnimation;

  // Barre de santé
  late final HealthBar _healthBar;

  // Timer pour éviter les attaques continues
  TimerComponent? _attackTimer;
  bool _canAttack = true;

  Enemy({
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size) {
    anchor = Anchor.bottomCenter;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Charger les animations spécifiques à l'ennemi
    await loadAnimations();

    // Définir les animations
    animations = {
      EnemyState.idle: idleAnimation,
      EnemyState.moving: moveAnimation,
      EnemyState.attacking: attackAnimation,
      EnemyState.hurt: hurtAnimation,
      EnemyState.dying: dyingAnimation,
    };

    current = EnemyState.idle;

    // ✅ CORRECTION: Position de la barre de santé ajustée (plus bas)
    _healthBar = HealthBar(
      enemy: this,
      position: Vector2(0, -size.y - 5), // Plus proche du monstre
    );
    await add(_healthBar);

    print('✅ ${runtimeType} chargé à la position: $position');
  }

  // Méthodes à implémenter par les classes enfants
  Future<void> loadAnimations();

  @override
  void update(double dt) {
    super.update(dt);

    if (!isActive) return;

    // IA pour attaquer le joueur
    _updateAI(dt);
    _updateState();
  }

  void _updateAI(double dt) {
    if (playerPosition == null) return;

    final distanceToPlayer = (playerPosition! - position).length;

    if (distanceToPlayer <= attackRange && _canAttack) {
      // Attaquer le joueur
      current = EnemyState.attacking;
      _attackPlayer();
    } else if (distanceToPlayer <= detectionRange) {
      // Se déplacer vers le joueur
      current = EnemyState.moving;
      _moveTowardsPlayer(dt);
    } else {
      // Rester en idle
      current = EnemyState.idle;
    }
  }

  void _moveTowardsPlayer(double dt) {
    if (playerPosition == null) return;

    final direction = (playerPosition! - position).normalized();
    position += direction * moveSpeed * dt;

    // Gestion de la direction
    if (direction.x != 0) {
      final newDirection = direction.x > 0;
      if (newDirection != isFacingRight) {
        isFacingRight = newDirection;
        flipHorizontallyAroundCenter();
      }
    }
  }

  void _attackPlayer() {
    if (!_canAttack) return;

    _canAttack = false;
    print('⚔️ ${runtimeType} attaque le joueur!');

    // Cooldown d'attaque
    _attackTimer = TimerComponent(
      period: 1.5,
      removeOnFinish: true,
      onTick: () {
        _canAttack = true;
      },
    );
    add(_attackTimer!);
  }

  void _updateState() {
    // Mise à jour automatique de l'état par l'IA
  }

  void updatePlayerPosition(Vector2 newPosition) {
    playerPosition = newPosition;
  }

  // Méthode pour prendre des dégâts
  void takeDamage(double damage) {
    if (!isActive) return;

    health -= damage;
    current = EnemyState.hurt;

    print('💥 ${runtimeType} touché! Dégâts: $damage, PV: $health/$maxHealth');

    if (health <= 0) {
      _die();
    } else {
      // Retour à l'état normal après un moment
      Future.delayed(Duration(milliseconds: 500), () {
        if (isActive && health > 0) {
          current = EnemyState.idle;
        }
      });
    }
  }

  void _die() {
    isActive = false;
    current = EnemyState.dying;

    print('💀 ${runtimeType} vaincu!');

    // Supprimer après l'animation de mort
    Future.delayed(Duration(milliseconds: 1000), () {
      removeFromParent();
    });
  }

  double get healthPercentage => health / maxHealth;
  bool get isAlive => isActive && health > 0;

  @override
  void onRemove() {
    _attackTimer?.removeFromParent();
    super.onRemove();
  }
}

// Barre de santé pour les ennemis
class HealthBar extends PositionComponent {
  final Enemy enemy;
  final double width = 60.0;
  final double height = 6.0;

  HealthBar({
    required this.enemy,
    required Vector2 position,
  }) : super(position: position);

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Barre de fond (noire)
    final backgroundRect = Rect.fromLTWH(-width / 2, -height / 2, width, height);
    canvas.drawRect(
      backgroundRect,
      Paint()..color = Colors.black.withOpacity(0.8),
    );

    // Barre de santé (verte/rouge selon les PV)
    final healthWidth = width * enemy.healthPercentage;
    final healthColor = enemy.healthPercentage > 0.5
        ? Colors.green
        : enemy.healthPercentage > 0.25
        ? Colors.orange
        : Colors.red;

    final healthRect = Rect.fromLTWH(-width / 2, -height / 2, healthWidth, height);
    canvas.drawRect(
      healthRect,
      Paint()..color = healthColor,
    );

    // Bordure
    final borderRect = Rect.fromLTWH(-width / 2, -height / 2, width, height);
    canvas.drawRect(
      borderRect,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    // ✅ CORRECTION: Position ajustée (plus bas)
    position = Vector2(0, -enemy.size.y - 5);
  }
}