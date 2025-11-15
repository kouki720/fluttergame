// components/player/player.dart
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:eco_warrior_tunisia1/managers/audio_manager.dart';
import 'package:eco_warrior_tunisia1/managers/game_manager.dart';
import '../attacks/flame_attack.dart';
import '../../game/eco_warrior_game.dart';

enum PlayerState { idle, running, jumping, attacking, hurt }

class Player extends SpriteAnimationGroupComponent<PlayerState> with HasGameRef<EcoWarriorGame> {
  // État et propriétés du joueur
  bool isFacingRight = true;
  double moveSpeed = 200.0;
  bool isOnGround = true;
  double _velocityX = 0.0;

  // Physique de saut
  double _jumpVelocity = 0.0;
  double _gravity = 800.0;
  double _jumpForce = -400.0;

  // Animations
  late final SpriteAnimation _idleAnimation;
  late final SpriteAnimation _runAnimation;
  late final SpriteAnimation _jumpAnimation;
  late final SpriteAnimation _attackAnimation;
  late final SpriteAnimation _hurtAnimation;

  // Gestion des attaques
  bool _isAttacking = false;
  TimerComponent? _attackCooldownTimer;

  // Référence au game manager
  final GameManager _gameManager = GameManager();

  // Système de santé et dégâts
  double _currentHealth = 100.0;
  double _maxHealth = 100.0;
  double _swordDamage = 15.0;
  double _flameDamage = 25.0;

  // Composant de la barre de santé
  late final HealthBar _healthBar;

  Player({Vector2? position}) : super(
      position: position ?? Vector2(100, 300),
      size: Vector2(192, 192)
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    anchor = Anchor.bottomCenter;

    // ✅ CORRECTION: Réinitialiser la santé à 100
    _currentHealth = 100.0;

    // Charger toutes les animations
    await _loadAnimations();

    // Définir les animations par état
    animations = {
      PlayerState.idle: _idleAnimation,
      PlayerState.running: _runAnimation,
      PlayerState.jumping: _jumpAnimation,
      PlayerState.attacking: _attackAnimation,
      PlayerState.hurt: _hurtAnimation,
    };

    current = PlayerState.idle;

    // Barre de santé
    _healthBar = HealthBar(
      player: this,
      position: Vector2(0, -size.y / 3),
    );
    await add(_healthBar);

    print('🎮 Joueur initialisé - Santé: $_currentHealth/$_maxHealth');
  }

  Future<void> _loadAnimations() async {
    try {
      // Animation Idle
      final idleImage = await gameRef.images.load('player/idle.png');
      _idleAnimation = SpriteAnimation.fromFrameData(
        idleImage,
        SpriteAnimationData.sequenced(
          amount: 14,
          textureSize: Vector2(64, 64),
          stepTime: 0.2,
        ),
      );

      // Animation Course
      final runImage = await gameRef.images.load('player/run.png');
      _runAnimation = SpriteAnimation.fromFrameData(
        runImage,
        SpriteAnimationData.sequenced(
          amount: 8,
          textureSize: Vector2(64, 64),
          stepTime: 0.1,
        ),
      );

      // Animation Saut
      final jumpImage = await gameRef.images.load('player/jump.png');
      _jumpAnimation = SpriteAnimation.fromFrameData(
        jumpImage,
        SpriteAnimationData.sequenced(
          amount: 19,
          textureSize: Vector2(64, 64),
          stepTime: 0.20,
        ),
      );

      // Animation Attaque
      final attackImage = await gameRef.images.load('player/attack.png');
      _attackAnimation = SpriteAnimation.fromFrameData(
        attackImage,
        SpriteAnimationData.sequenced(
          amount: 7,
          textureSize: Vector2(64, 64),
          stepTime: 0.1,
        ),
      );

      // Animation Dégâts
      final hurtImage = await gameRef.images.load('player/hurt.png');
      _hurtAnimation = SpriteAnimation.fromFrameData(
        hurtImage,
        SpriteAnimationData.sequenced(
          amount: 6,
          textureSize: Vector2(64, 64),
          stepTime: 0.1,
        ),
      );

      print('✅ Toutes les animations joueur chargées');

    } catch (e) {
      print('❌ Erreur chargement animations joueur: $e');
    }
  }

  void setMovementDirection(double direction) {
    if (_isAttacking) {
      _velocityX = 0.0;
      return;
    }

    _velocityX = direction * moveSpeed;

    // Gestion de la direction
    if (direction != 0) {
      final newDirection = direction > 0;
      if (newDirection != isFacingRight) {
        isFacingRight = newDirection;
        flipHorizontallyAroundCenter();
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Appliquer la gravité et le saut
    _applyPhysics(dt);

    // Déplacement horizontal
    position.x += _velocityX * dt;

    // Vérifier les collisions avec le sol
    _checkGroundCollision();

    // Changement d'état
    _updatePlayerState();

    // Limites de l'écran
    _checkScreenBounds();

    // Mettre à jour la position de la barre de santé
    _healthBar.position = Vector2(0, -size.y / 3);
  }

  void _applyPhysics(double dt) {
    if (!isOnGround) {
      // Appliquer la gravité
      _jumpVelocity += _gravity * dt;
      position.y += _jumpVelocity * dt;
    }
  }

  void _checkGroundCollision() {
    // Position originale
    final groundLevel = gameRef.size.y - 0;

    if (position.y >= groundLevel) {
      position.y = groundLevel;
      _jumpVelocity = 0.0;
      isOnGround = true;
    } else {
      isOnGround = false;
    }
  }

  void _checkScreenBounds() {
    // Empêcher le joueur de sortir de l'écran
    if (position.x < size.x / 2) {
      position.x = size.x / 2;
    } else if (position.x > gameRef.size.x - size.x / 2) {
      position.x = gameRef.size.x - size.x / 2;
    }
  }

  void _updatePlayerState() {
    if (_isAttacking) return;

    if (!isOnGround) {
      current = PlayerState.jumping;
    } else if (_velocityX != 0) {
      current = PlayerState.running;
    } else {
      current = PlayerState.idle;
    }
  }

  void jump() {
    if (!isOnGround || _isAttacking) return;

    // Appliquer une force de saut réelle
    isOnGround = false;
    _jumpVelocity = _jumpForce;
    current = PlayerState.jumping;
    AudioManager().playJumpSfx();

    print('🦘 Joueur saute!');
  }

  void swordAttack() {
    if (_isAttacking) return;

    _isAttacking = true;
    current = PlayerState.attacking;
    AudioManager().playSwordAttackSfx();

    print('⚔️ Attaque épée! Dégâts: $_swordDamage');

    // Appliquer les dégâts de l'épée aux ennemis proches
    _applySwordDamage();

    _attackCooldownTimer = TimerComponent(
      period: 0.5,
      removeOnFinish: true,
      onTick: () {
        _isAttacking = false;
        _updatePlayerState();
      },
    );
    add(_attackCooldownTimer!);
  }

  void flameAttack() {
    if (_isAttacking) return;

    _isAttacking = true;
    AudioManager().playFlameAttackSfx();

    print('🔥 Attaque flamme! Dégâts: $_flameDamage');

    // Créer la flamme rouge avec les dégâts
    _spawnFlameAttack();

    _attackCooldownTimer = TimerComponent(
      period: 0.8,
      removeOnFinish: true,
      onTick: () {
        _isAttacking = false;
        _updatePlayerState();
      },
    );
    add(_attackCooldownTimer!);
  }

  void _spawnFlameAttack() {
    final flamePosition = Vector2(
      position.x + (isFacingRight ? size.x / 2.5 : -size.x / 2.5),
      position.y - size.y / 3,
    );

    final flame = FlameAttack(
      position: flamePosition,
      direction: isFacingRight ? 1 : -1,
    );

    gameRef.add(flame);
    print('🔥 Flamme créée');
  }

  void _applySwordDamage() {
    print('⚔️ Application des dégâts d\'épée: $_swordDamage');

    // Appeler l'EnemyManager pour appliquer les dégâts
    gameRef.enemyManager.playerAttacksEnemies(
      position,
      100.0,
      _swordDamage,
    );
  }

  void takeDamage(double damage) {
    // ✅ CORRECTION: Éviter les dégâts multiples si déjà mort
    if (_currentHealth <= 0) return;

    _currentHealth -= damage;
    _currentHealth = _currentHealth.clamp(0, _maxHealth);
    current = PlayerState.hurt;

    print('💥 Joueur touché! Dégâts: $damage, PV: $_currentHealth/$_maxHealth');

    if (_currentHealth <= 0) {
      _die();
    } else {
      final damageTimer = TimerComponent(
        period: 0.5,
        removeOnFinish: true,
        onTick: () {
          if (_currentHealth > 0) {
            _updatePlayerState();
          }
        },
      );
      add(damageTimer);
    }
  }

  void _die() {
    // ✅ CORRECTION: Vérifier que la santé est bien à 0
    if (_currentHealth > 0) return;

    print('💀 Joueur mort!');
    current = PlayerState.hurt;

    // ✅ CORRECTION: Arrêter le mouvement
    _velocityX = 0.0;
    _isAttacking = false;

    // Appeler le game over
    Future.delayed(Duration(milliseconds: 100), () {
      gameRef.onGameOver?.call();
    });
  }

  void heal(double amount) {
    _currentHealth += amount;
    _currentHealth = _currentHealth.clamp(0, _maxHealth);
    print('❤️ Soin reçu: +$amount, PV: $_currentHealth/$_maxHealth');
  }

  void increaseMaxHealth(double amount) {
    _maxHealth += amount;
    _currentHealth += amount;
    print('❤️ Santé maximale augmentée: $_maxHealth');
  }

  void upgradeSwordDamage(double increase) {
    _swordDamage += increase;
    print('⚔️ Dégâts épée améliorés: $_swordDamage');
  }

  void upgradeFlameDamage(double increase) {
    _flameDamage += increase;
    print('🔥 Dégâts flamme améliorés: $_flameDamage');
  }

  // Getters pour les statistiques
  double get currentHealth => _currentHealth;
  double get maxHealth => _maxHealth;
  double get swordDamage => _swordDamage;
  double get flameDamage => _flameDamage;
  double get healthPercentage => _currentHealth / _maxHealth;
  int get coins => _gameManager.playerStats.coins;

  // ✅ CORRECTION: Méthode pour reset la santé
  void resetHealth() {
    _currentHealth = _maxHealth;
    current = PlayerState.idle;
    _velocityX = 0.0;
    _isAttacking = false;
    print('❤️ Santé du joueur réinitialisée: $_currentHealth/$_maxHealth');
  }

  @override
  void onRemove() {
    _attackCooldownTimer?.removeFromParent();
    super.onRemove();
  }
}

// Composant pour la barre de santé
class HealthBar extends PositionComponent {
  final Player player;
  final double width = 80.0;
  final double height = 8.0;

  HealthBar({
    required this.player,
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
    final healthWidth = width * player.healthPercentage;
    final healthColor = player.healthPercentage > 0.5
        ? Colors.green
        : player.healthPercentage > 0.25
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
    position = Vector2(0, -player.size.y / 3);
  }
}