// components/player/player.dart
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:eco_warrior_tunisia1/managers/audio_manager.dart';
import 'package:eco_warrior_tunisia1/managers/game_manager.dart';
import '../attacks/flame_attack.dart';
import '../../game/eco_warrior_game.dart';

enum PlayerState { idle, running, jumping, attacking, hurt, dead }

class Player extends SpriteAnimationGroupComponent<PlayerState> with HasGameRef<EcoWarriorGame> {
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
  late final SpriteAnimation _deadAnimation;

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

  // Timer d'invulnérabilité après dégâts
  bool _isInvulnerable = false;
  TimerComponent? _invulnerabilityTimer;
  TimerComponent? _hurtAnimationTimer;

  Player({Vector2? position}) : super(
      position: position ?? Vector2(100, 300),
      size: Vector2(192, 192)
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    anchor = Anchor.bottomCenter;

    _currentHealth = 100.0;

    await _loadAnimations();

    animations = {
      PlayerState.idle: _idleAnimation,
      PlayerState.running: _runAnimation,
      PlayerState.jumping: _jumpAnimation,
      PlayerState.attacking: _attackAnimation,
      PlayerState.hurt: _hurtAnimation,
      PlayerState.dead: _deadAnimation,
    };

    current = PlayerState.idle;

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

      // Animation Mort
      final deadImage = await gameRef.images.load('player/dead.png');
      _deadAnimation = SpriteAnimation.fromFrameData(
        deadImage,
        SpriteAnimationData.sequenced(
          amount: 6,
          textureSize: Vector2(64, 64),
          stepTime: 0.15,
          loop: false, // IMPORTANT: ne pas boucler l'animation de mort
        ),
      );

      print('✅ Toutes les animations joueur chargées');

    } catch (e) {
      print('❌ Erreur chargement animations joueur: $e');
      // Fallback pour l'animation de mort
      _deadAnimation = _hurtAnimation;
    }
  }

  void setMovementDirection(double direction) {
    if (_isAttacking || current == PlayerState.hurt || current == PlayerState.dead) {
      _velocityX = 0.0;
      return;
    }

    _velocityX = direction * moveSpeed;

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

    // Si mort, ne rien faire
    if (current == PlayerState.dead) {
      _velocityX = 0.0;
      return;
    }

    _applyPhysics(dt);
    position.x += _velocityX * dt;
    _checkGroundCollision();

    // CORRECTION: Mettre à jour l'état seulement si pas en train de prendre des dégâts
    if (current != PlayerState.hurt) {
      _updatePlayerState();
    }

    _checkScreenBounds();
    _healthBar.position = Vector2(0, -size.y / 3);
  }

  void _applyPhysics(double dt) {
    if (!isOnGround) {
      _jumpVelocity += _gravity * dt;
      position.y += _jumpVelocity * dt;
    }
  }

  void _checkGroundCollision() {
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
    if (position.x < size.x / 2) {
      position.x = size.x / 2;
    } else if (position.x > gameRef.size.x - size.x / 2) {
      position.x = gameRef.size.x - size.x / 2;
    }
  }

  void _updatePlayerState() {
    if (_isAttacking || current == PlayerState.hurt || current == PlayerState.dead) {
      return;
    }

    if (!isOnGround) {
      current = PlayerState.jumping;
    } else if (_velocityX != 0) {
      current = PlayerState.running;
    } else {
      current = PlayerState.idle;
    }
  }

  void jump() {
    if (!isOnGround || _isAttacking || current == PlayerState.hurt || current == PlayerState.dead) {
      return;
    }

    isOnGround = false;
    _jumpVelocity = _jumpForce;
    current = PlayerState.jumping;
    AudioManager().playJumpSfx();
  }

  void swordAttack() {
    if (_isAttacking || current == PlayerState.hurt || current == PlayerState.dead) {
      return;
    }

    _isAttacking = true;
    current = PlayerState.attacking;
    AudioManager().playSwordAttackSfx();

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
    if (_isAttacking || current == PlayerState.hurt || current == PlayerState.dead) {
      return;
    }

    _isAttacking = true;
    AudioManager().playFlameAttackSfx();

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
  }

  void _applySwordDamage() {
    gameRef.enemyManager.playerAttacksEnemies(
      position,
      100.0,
      _swordDamage,
    );
  }

  // CORRECTION COMPLÈTE: Prendre des dégâts
  void takeDamage(double damage) {
    if (_currentHealth <= 0 || _isInvulnerable || current == PlayerState.dead) {
      return;
    }

    _currentHealth -= damage;
    _currentHealth = _currentHealth.clamp(0, _maxHealth);

    print('💥 Joueur touché! Dégâts: $damage, PV: $_currentHealth/$_maxHealth');

    if (_currentHealth <= 0) {
      _die();
    } else {
      // Animation de dégâts
      current = PlayerState.hurt;
      _isInvulnerable = true;

      // Timer pour l'animation de dégâts (court)
      _hurtAnimationTimer = TimerComponent(
        period: 0.6, // Durée de l'animation hurt
        removeOnFinish: true,
        onTick: () {
          current = PlayerState.idle;
        },
      );
      add(_hurtAnimationTimer!);

      // Timer d'invulnérabilité (plus long)
      _invulnerabilityTimer = TimerComponent(
        period: 1.5,
        removeOnFinish: true,
        onTick: () {
          _isInvulnerable = false;
        },
      );
      add(_invulnerabilityTimer!);
    }
  }

  // CORRECTION COMPLÈTE: Mort du joueur
  void _die() {
    if (_currentHealth > 0) {
      return;
    }

    print('💀 Joueur mort! Animation de mort déclenchée');
    current = PlayerState.dead;
    _velocityX = 0.0;
    _isAttacking = false;
    _isInvulnerable = true;

    // Arrêter tous les timers
    _attackCooldownTimer?.removeFromParent();
    _invulnerabilityTimer?.removeFromParent();
    _hurtAnimationTimer?.removeFromParent();

    // Jouer l'animation de mort complètement avant game over
    Future.delayed(const Duration(milliseconds: 1000), () {
      print('🎮 Game Over déclenché après animation de mort');
      gameRef.onGameOver?.call();
    });
  }

  void heal(double amount) {
    _currentHealth += amount;
    _currentHealth = _currentHealth.clamp(0, _maxHealth);
  }

  void increaseMaxHealth(double amount) {
    _maxHealth += amount;
    _currentHealth += amount;
  }

  void upgradeSwordDamage(double increase) {
    _swordDamage += increase;
  }

  void upgradeFlameDamage(double increase) {
    _flameDamage += increase;
  }

  // Getters pour les statistiques
  double get currentHealth => _currentHealth;
  double get maxHealth => _maxHealth;
  double get swordDamage => _swordDamage;
  double get flameDamage => _flameDamage;
  double get healthPercentage => _currentHealth / _maxHealth;
  int get coins => _gameManager.playerStats.coins;

  void resetHealth() {
    _currentHealth = _maxHealth;
    current = PlayerState.idle;
    _velocityX = 0.0;
    _isAttacking = false;
    _isInvulnerable = false;

    // Nettoyer les timers
    _attackCooldownTimer?.removeFromParent();
    _invulnerabilityTimer?.removeFromParent();
    _hurtAnimationTimer?.removeFromParent();
  }

  @override
  void onRemove() {
    _attackCooldownTimer?.removeFromParent();
    _invulnerabilityTimer?.removeFromParent();
    _hurtAnimationTimer?.removeFromParent();
    super.onRemove();
  }
}

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

    final backgroundRect = Rect.fromLTWH(-width / 2, -height / 2, width, height);
    canvas.drawRect(
      backgroundRect,
      Paint()..color = Colors.black.withOpacity(0.8),
    );

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