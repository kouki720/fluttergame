import 'package:flutter/material.dart';
import '../managers/audio_manager.dart';
import '../utils/responsive_helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Valeurs des paramètres
  double _musicVolume = 0.7;
  double _sfxVolume = 0.8;
  bool _vibrationsEnabled = true;
  bool _tutorialEnabled = true;
  String _language = 'Français';
  String _difficulty = 'Normal';

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = ResponsiveHelper.isSmallScreen(context);
    final isPortrait = ResponsiveHelper.isPortrait(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1B5E20),
              const Color(0xFF388E3C),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // En-tête
              _buildHeader(context),

              // Contenu des paramètres
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section Audio
                      _buildSection(
                        title: '🔊 AUDIO',
                        isSmallScreen: isSmallScreen,
                        children: [
                          _buildSliderSetting(
                            label: 'Musique',
                            value: _musicVolume,
                            isSmallScreen: isSmallScreen,
                            onChanged: (value) {
                              setState(() => _musicVolume = value);
                              AudioManager().setMusicVolume(value);
                            },
                          ),
                          SizedBox(height: isSmallScreen ? 12 : 16),
                          _buildSliderSetting(
                            label: 'Effets Sonores',
                            value: _sfxVolume,
                            isSmallScreen: isSmallScreen,
                            onChanged: (value) {
                              setState(() => _sfxVolume = value);
                              AudioManager().setSfxVolume(value);
                            },
                          ),
                        ],
                      ),

                      SizedBox(height: isSmallScreen ? 24 : 32),

                      // Section Jeu
                      _buildSection(
                        title: '🎮 JEU',
                        isSmallScreen: isSmallScreen,
                        children: [
                          _buildSwitchSetting(
                            label: 'Vibrations',
                            value: _vibrationsEnabled,
                            isSmallScreen: isSmallScreen,
                            onChanged: (value) {
                              setState(() => _vibrationsEnabled = value);
                            },
                          ),
                          SizedBox(height: isSmallScreen ? 12 : 16),
                          _buildSwitchSetting(
                            label: 'Tutoriel',
                            subtitle: 'Afficher les aides au démarrage',
                            value: _tutorialEnabled,
                            isSmallScreen: isSmallScreen,
                            onChanged: (value) {
                              setState(() => _tutorialEnabled = value);
                            },
                          ),
                          SizedBox(height: isSmallScreen ? 12 : 16),
                          _buildDropdownSetting(
                            label: 'Difficulté',
                            value: _difficulty,
                            items: ['Facile', 'Normal', 'Difficile'],
                            isSmallScreen: isSmallScreen,
                            onChanged: (value) {
                              setState(() => _difficulty = value!);
                            },
                          ),
                        ],
                      ),

                      SizedBox(height: isSmallScreen ? 24 : 32),

                      // Section Langue
                      _buildSection(
                        title: '🌍 LANGUE',
                        isSmallScreen: isSmallScreen,
                        children: [
                          _buildDropdownSetting(
                            label: 'Langue du jeu',
                            value: _language,
                            items: ['Français', 'العربية', 'English'],
                            isSmallScreen: isSmallScreen,
                            onChanged: (value) {
                              setState(() => _language = value!);
                            },
                          ),
                        ],
                      ),

                      SizedBox(height: isSmallScreen ? 24 : 32),

                      // Section Données
                      _buildSection(
                        title: '💾 DONNÉES',
                        isSmallScreen: isSmallScreen,
                        children: [
                          _buildActionButton(
                            label: 'Sauvegarder',
                            icon: Icons.save,
                            color: Colors.blue,
                            isSmallScreen: isSmallScreen,
                            onPressed: () {
                              _saveSettings();
                            },
                          ),
                          SizedBox(height: isSmallScreen ? 12 : 16),
                          _buildActionButton(
                            label: 'Réinitialiser Progression',
                            icon: Icons.restart_alt,
                            color: Colors.orange,
                            isSmallScreen: isSmallScreen,
                            onPressed: () {
                              _showResetDialog();
                            },
                          ),
                          SizedBox(height: isSmallScreen ? 12 : 16),
                          _buildActionButton(
                            label: 'Supprimer Toutes les Données',
                            icon: Icons.delete_forever,
                            color: Colors.red,
                            isSmallScreen: isSmallScreen,
                            onPressed: () {
                              _showDeleteDialog();
                            },
                          ),
                        ],
                      ),

                      SizedBox(height: isSmallScreen ? 30 : 40),

                      // Informations
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'Eco Warrior Tunisia',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 14 : 16,
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Version 1.0.0',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 10 : 12,
                                color: Colors.white54,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: isSmallScreen ? 10 : 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isSmallScreen = ResponsiveHelper.isSmallScreen(context);

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      child: Row(
        children: [
          // Bouton retour
          IconButton(
            icon: Icon(Icons.arrow_back,
                color: Colors.white,
                size: isSmallScreen ? 28 : 32),
            onPressed: () {
              AudioManager().playSfx('button_click.mp3');
              Navigator.pop(context);
            },
          ),

          SizedBox(width: isSmallScreen ? 12 : 16),

          // Titre
          Text(
            'PARAMÈTRES',
            style: TextStyle(
              fontSize: isSmallScreen ? 24 : 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: isSmallScreen ? 1 : 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
    required bool isSmallScreen,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isSmallScreen ? 16 : 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: isSmallScreen ? 12 : 16),
        Container(
          padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSliderSetting({
    required String label,
    required double value,
    required bool isSmallScreen,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(value * 100).toInt()}%',
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: Colors.white,
            inactiveTrackColor: Colors.white30,
            thumbColor: Colors.white,
            overlayColor: Colors.white24,
            trackHeight: isSmallScreen ? 3 : 4,
          ),
          child: Slider(
            value: value,
            onChanged: onChanged,
            min: 0.0,
            max: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchSetting({
    required String label,
    String? subtitle,
    required bool value,
    required bool isSmallScreen,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (subtitle != null) ...[
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 10 : 12,
                    color: Colors.white60,
                  ),
                ),
              ],
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.white,
          activeTrackColor: Colors.white38,
          inactiveThumbColor: Colors.white54,
          inactiveTrackColor: Colors.white24,
        ),
      ],
    );
  }

  Widget _buildDropdownSetting({
    required String label,
    required String value,
    required List<String> items,
    required bool isSmallScreen,
    required ValueChanged<String?> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12 : 16,
              vertical: isSmallScreen ? 6 : 8
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButton<String>(
            value: value,
            onChanged: onChanged,
            dropdownColor: const Color(0xFF2E7D32),
            underline: const SizedBox(),
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required bool isSmallScreen,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: isSmallScreen ? 20 : 24),
        label: Text(
          label,
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Paramètres sauvegardés !'),
        backgroundColor: const Color(0xFF4CAF50),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Réinitialiser'),
          ],
        ),
        content: Text(
          'Voulez-vous vraiment réinitialiser votre progression ?\n\n'
              'Cette action ne peut pas être annulée.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Progression réinitialisée'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: Text('Réinitialiser'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.delete_forever, color: Colors.red),
            SizedBox(width: 8),
            Text('Supprimer'),
          ],
        ),
        content: Text(
          'ATTENTION !\n\n'
              'Voulez-vous vraiment supprimer TOUTES vos données ?\n\n'
              'Cela inclut votre progression, vos scores et tous vos paramètres.\n\n'
              'Cette action est IRRÉVERSIBLE !',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Toutes les données ont été supprimées'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('SUPPRIMER TOUT'),
          ),
        ],
      ),
    );
  }
}