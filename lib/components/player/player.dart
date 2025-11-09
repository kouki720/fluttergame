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

  // Système de santé et dégâts
  double _currentHealth = 100.0;
  double _maxHealth = 100.0;
  double _swordDamage = 15.0;
  double _flameDamage = 25.0;

  // Composant de la barre de santé
  late final HealthBar _healthBar;

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

    // ✅ CORRECTION: Position de la barre de santé ajustée - PLUS BASSE
    _healthBar = HealthBar(
      player: this,
      position: Vector2(0, -size.y / 3), // ✅ Beaucoup plus bas
    );
    await add(_healthBar);

    print('🎮 Joueur initialisé à la position: $position, taille: $size');
    print('❤️ Santé: $_currentHealth/$_maxHealth');
    print('⚔️ Dégâts épée: $_swordDamage, 🔥 Dégâts flamme: $_flameDamage');
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

    // ✅ CORRECTION: Mettre à jour la position avec la nouvelle valeur
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

    print('⚔️ Attaque épée! Dégâts: $_swordDamage, Position: $position');

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

    print('🎯 Début attaque flamme... Dégâts: $_flameDamage, Position: $position, Direction: ${isFacingRight ? "droite" : "gauche"}');

    // Créer la flamme rouge avec les dégâts
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
      // ✅ CORRECTION: Retirer le paramètre damage qui n'existe pas
    );

    gameRef.add(flame);
    print('🔥 Flamme créée à: $flamePosition, Dégâts: $_flameDamage, Direction: ${isFacingRight ? "droite" : "gauche"}');
  }

  void _applySwordDamage() {
    // TODO: Implémenter la détection des ennemis proches pour l'attaque à l'épée
    // Pour l'instant, on loggue seulement l'action
    print('⚔️ Application des dégâts d\'épée: $_swordDamage');

    // Exemple de détection d'ennemis dans une zone
    final attackRange = isFacingRight ?
    Vector2(position.x + size.x / 2, position.y - size.y / 2) :
    Vector2(position.x - size.x / 2, position.y - size.y / 2);

    print('🎯 Zone d\'attaque épée: $attackRange');
  }

  void takeDamage(double damage) {
    _currentHealth -= damage;
    _currentHealth = _currentHealth.clamp(0, _maxHealth);
    current = PlayerState.hurt;

    print('💥 Joueur touché! Dégâts: $damage, PV: $_currentHealth/$_maxHealth');

    // Effet visuel de dégâts
    _showDamageEffect(damage);

    // Vérifier si le joueur est mort
    if (_currentHealth <= 0) {
      _die();
    }

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

  void _showDamageEffect(double damage) {
    // TODO: Ajouter un effet visuel pour les dégâts reçus
    // Par exemple, faire clignoter le joueur en rouge
    print('💢 Effet de dégâts: $damage points');
  }

  void _die() {
    print('💀 Joueur mort!');
    current = PlayerState.hurt;
    // TODO: Implémenter la logique de mort (game over, etc.)
  }

  void heal(double amount) {
    _currentHealth += amount;
    _currentHealth = _currentHealth.clamp(0, _maxHealth);
    print('❤️ Soin reçu: +$amount, PV: $_currentHealth/$_maxHealth');
  }

  void increaseMaxHealth(double amount) {
    _maxHealth += amount;
    _currentHealth += amount;
    print('❤️ Santé maximale augmentée: $_maxHealth, PV: $_currentHealth/$_maxHealth');
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

  @override
  void onRemove() {
    _attackCooldownTimer?.removeFromParent();
    print('🗑️ Joueur démonté');
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

    // Texte des PV (optionnel)
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${player.currentHealth.toInt()}/${player.maxHealth.toInt()}',
        style: TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -height - 12),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    // ✅ CORRECTION: Suivre le joueur avec la nouvelle position
    position = Vector2(0, -player.size.y / 3);
  }
}