import 'dart:convert';
import 'package:flutter/material.dart';

class PlayerStats {
  double maxHealth = 100.0;
  double currentHealth = 100.0;

  // Mobilité
  double moveSpeed = 200.0;
  double jumpPower = 400.0;

  // Attaques
  double swordDamage = 20.0;
  double attackSpeed = 1.0;

  // Flamme
  FlameType flameType = FlameType.red;
  double flameDamage = 15.0;
  double flameRange = 100.0;

  // Points
  int coins = 0;

  PlayerStats();

  Map<String, dynamic> toMap() {
    return {
      'maxHealth': maxHealth,
      'currentHealth': currentHealth,
      'moveSpeed': moveSpeed,
      'jumpPower': jumpPower,
      'swordDamage': swordDamage,
      'attackSpeed': attackSpeed,
      'flameType': flameType.index,
      'flameDamage': flameDamage,
      'flameRange': flameRange,
      'coins': coins,
    };
  }

  factory PlayerStats.fromMap(Map<String, dynamic> map) {
    final stats = PlayerStats();
    stats.maxHealth = map['maxHealth'] ?? 100.0;
    stats.currentHealth = map['currentHealth'] ?? 100.0;
    stats.moveSpeed = map['moveSpeed'] ?? 200.0;
    stats.jumpPower = map['jumpPower'] ?? 400.0;
    stats.swordDamage = map['swordDamage'] ?? 20.0;
    stats.attackSpeed = map['attackSpeed'] ?? 1.0;

    // Correction pour flameType
    final flameIndex = map['flameType'] ?? 0;
    stats.flameType = FlameType.values[flameIndex is int ? flameIndex : 0];

    stats.flameDamage = map['flameDamage'] ?? 15.0;
    stats.flameRange = map['flameRange'] ?? 100.0;
    stats.coins = map['coins'] ?? 0;
    return stats;
  }
}

enum FlameType {
  red('Rouge', 15, 'assets/images/attacks/flame_red.png'),
  blue('Bleue', 25, 'assets/images/attacks/flame_blue.png'),
  purple('Mauve', 40, 'assets/images/attacks/flame_purple.png');

  final String name;
  final int damage;
  final String assetPath;

  const FlameType(this.name, this.damage, this.assetPath);

  // Méthode utilitaire pour obtenir la couleur
  Color get color {
    switch (this) {
      case FlameType.red:
        return Colors.red;
      case FlameType.blue:
        return Colors.blue;
      case FlameType.purple:
        return Colors.purple;
    }
  }
}