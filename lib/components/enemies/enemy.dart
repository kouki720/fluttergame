// components/enemies/enemy.dart
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

enum EnemyState { idle } // ✅ SUPPRIMÉ les autres états

abstract class Enemy extends SpriteAnimationGroupComponent<EnemyState>
    with HasGameRef {

  // Propriétés de base
  double health = 100.0;
  double maxHealth = 100.0;
  bool isActive = true;
  bool isFacingRight = false;

  // Référence au joueur
  Vector2? playerPosition;

  // ✅ SUPPRIMÉ les autres animations, garder seulement idle
  late SpriteAnimation idleAnimation;

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

    // ✅ SUPPRIMÉ les autres animations, garder seulement idle
    animations = {
      EnemyState.idle: idleAnimation,
    };

    // Toujours en idle
    current = EnemyState.idle;

    print('✅ ${runtimeType} chargé à la position: $position, taille: $size');
  }

  // Méthodes à implémenter par les classes enfants
  Future<void> loadAnimations();

  @override
  void update(double dt) {
    super.update(dt);

    if (!isActive) return;

    // Pas d'IA, pas de mouvement, juste l'affichage
    _updateState();
  }

  void _updateState() {
    // Toujours en idle
    if (current != EnemyState.idle) {
      current = EnemyState.idle;
    }
  }

  void updatePlayerPosition(Vector2 newPosition) {
    playerPosition = newPosition;
  }

  double get healthPercentage => health / maxHealth;
  bool get isAlive => isActive && health > 0;

  @override
  void onRemove() {
    print('🗑️ ${runtimeType} retiré du jeu');
    super.onRemove();
  }
}