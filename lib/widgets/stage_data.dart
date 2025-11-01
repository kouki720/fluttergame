import 'package:flutter/material.dart';

class StageData {
  final int stageNumber;
  final String title;
  final String description;
  final String theme;
  final String location;
  final String difficulty;
  bool isUnlocked;
  final Color backgroundColor;
  final IconData icon;

  // Scores (à implémenter plus tard)
  int highScore;
  int stars;
  bool isCompleted;

  StageData({
    required this.stageNumber,
    required this.title,
    required this.description,
    required this.theme,
    required this.location,
    required this.difficulty,
    this.isUnlocked = false,
    required this.backgroundColor,
    required this.icon,
    this.highScore = 0,
    this.stars = 0,
    this.isCompleted = false,
  });

  // Conversion en Map pour sauvegarde
  Map<String, dynamic> toMap() {
    return {
      'stageNumber': stageNumber,
      'title': title,
      'description': description,
      'theme': theme,
      'location': location,
      'difficulty': difficulty,
      'isUnlocked': isUnlocked,
      'backgroundColor': backgroundColor.value,
      'highScore': highScore,
      'stars': stars,
      'isCompleted': isCompleted,
    };
  }

  // Création depuis Map (chargement)
  factory StageData.fromMap(Map<String, dynamic> map, IconData icon) {
    return StageData(
      stageNumber: map['stageNumber'],
      title: map['title'],
      description: map['description'],
      theme: map['theme'],
      location: map['location'],
      difficulty: map['difficulty'],
      isUnlocked: map['isUnlocked'] ?? false,
      backgroundColor: Color(map['backgroundColor']),
      icon: icon,
      highScore: map['highScore'] ?? 0,
      stars: map['stars'] ?? 0,
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}