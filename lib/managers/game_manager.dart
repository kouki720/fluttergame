import 'package:shared_preferences/shared_preferences.dart';
import 'player_stats.dart';
import 'dart:convert';

class GameManager {
  static final GameManager _instance = GameManager._internal();
  factory GameManager() => _instance;
  GameManager._internal();

  PlayerStats playerStats = PlayerStats();
  final String _saveKey = 'player_stats';

  // Initialisation
  Future<void> init() async {
    await _loadProgress();
  }

  // Charger la progression
  Future<void> _loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString(_saveKey);

      if (savedData != null) {
        final map = Map<String, dynamic>.from(json.decode(savedData));
        playerStats = PlayerStats.fromMap(map);
      }
    } catch (e) {
      print('Erreur chargement progression: $e');
    }
  }

  // Sauvegarder la progression
  Future<void> saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = json.encode(playerStats.toMap());
      await prefs.setString(_saveKey, data);
    } catch (e) {
      print('Erreur sauvegarde: $e');
    }
  }

  // Ajouter des coins
  void addCoins(int amount) {
    playerStats.coins += amount;
    saveProgress();
  }

  // Acheter une amélioration
  bool purchaseUpgrade(int cost) {
    if (playerStats.coins >= cost) {
      playerStats.coins -= cost;
      saveProgress();
      return true;
    }
    return false;
  }

  // Réinitialiser la progression
  Future<void> resetProgress() async {
    playerStats = PlayerStats();
    await saveProgress();
  }
}