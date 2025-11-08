// components/player/player.dart
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:eco_warrior_tunisia1/managers/audio_manager.dart';
import 'package:eco_warrior_tunisia1/managers/game_manager.dart';
import '../attacks/flame_attack.dart';

enum PlayerState { idle, running, jumping, attacking, hurt }

class Player extends SpriteAnimationGroupComponent<PlayerState> with HasGameRef {
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

  // ✅ CORRECTION: Taille augmentée encore (192x192)
  Player({Vector2? position}) : super(
      position: position ?? Vector2(100, 300),
      size: Vector2(192, 192) // ✅ Taille augmentée à 192x192
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    anchor = Anchor.bottomCenter;

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

    print('🎮 Joueur initialisé à la position: $position, taille: $size');
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
      print('✅ Animation idle chargée');

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
      print('✅ Animation run chargée');

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
      print('✅ Animation jump chargée');

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
      print('✅ Animation attack chargée');

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
      print('✅ Animation hurt chargée');

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
  }

  void _applyPhysics(double dt) {
    if (!isOnGround) {
      // Appliquer la gravité
      _jumpVelocity += _gravity * dt;
      position.y += _jumpVelocity * dt;
    }
  }

  void _checkGroundCollision() {
    // ✅ CORRECTION: Ajusté pour la nouvelle taille
    final groundLevel = gameRef.size.y - 0; // Sol à 250 pixels du bas

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

    print('🦘 Joueur saute! Force: $_jumpForce, Position: $position');
  }

  void swordAttack() {
    if (_isAttacking) return;

    _isAttacking = true;
    current = PlayerState.attacking;
    AudioManager().playSwordAttackSfx();

    print('⚔️ Attaque épée! Position: $position');

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

    print('🎯 Début attaque flamme... Position: $position, Direction: ${isFacingRight ? "droite" : "gauche"}');

    // Créer la flamme rouge
    _spawnFlameAttack();

    print('🔥 Attaque flamme lancée!');

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
    // ✅ CORRECTION: Position ajustée pour la nouvelle taille (192x192)
    final flamePosition = Vector2(
      position.x + (isFacingRight ? size.x / 2.5 : -size.x / 2.5),
      position.y - size.y / 3, // Au niveau du torse du joueur
    );

    final flame = FlameAttack(
      position: flamePosition,
      direction: isFacingRight ? 1 : -1,
    );

    gameRef.add(flame);
    print('🔥 Flamme créée à: $flamePosition, Direction: ${isFacingRight ? "droite" : "gauche"}');
  }

  void takeDamage(int damage) {
    _gameManager.playerStats.currentHealth -= damage.toDouble();
    current = PlayerState.hurt;

    print('💥 Joueur touché! PV: ${_gameManager.playerStats.currentHealth}');

    final damageTimer = TimerComponent(
      period: 0.5,
      removeOnFinish: true,
      onTick: () {
        if (_gameManager.playerStats.currentHealth > 0) {
          _updatePlayerState();
        }
      },
    );
    add(damageTimer);
  }

  // Getters pour les statistiques
  double get currentHealth => _gameManager.playerStats.currentHealth;
  double get maxHealth => _gameManager.playerStats.maxHealth;
  int get coins => _gameManager.playerStats.coins;

  @override
  void onRemove() {
    _attackCooldownTimer?.removeFromParent();
    print('🗑️ Joueur démonté');
    super.onRemove();
  }
}