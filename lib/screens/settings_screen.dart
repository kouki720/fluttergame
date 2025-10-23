import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Valeurs des paramètres (à sauvegarder plus tard avec SharedPreferences)
  double _musicVolume = 0.7;
  double _sfxVolume = 0.8;
  bool _vibrationsEnabled = true;
  bool _tutorialEnabled = true;
  String _language = 'Français';
  String _difficulty = 'Normal';

  @override
  Widget build(BuildContext context) {
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
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section Audio
                      _buildSection(
                        title: '🔊 AUDIO',
                        children: [
                          _buildSliderSetting(
                            label: 'Musique',
                            value: _musicVolume,
                            onChanged: (value) {
                              setState(() => _musicVolume = value);
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildSliderSetting(
                            label: 'Effets Sonores',
                            value: _sfxVolume,
                            onChanged: (value) {
                              setState(() => _sfxVolume = value);
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Section Jeu
                      _buildSection(
                        title: '🎮 JEU',
                        children: [
                          _buildSwitchSetting(
                            label: 'Vibrations',
                            value: _vibrationsEnabled,
                            onChanged: (value) {
                              setState(() => _vibrationsEnabled = value);
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildSwitchSetting(
                            label: 'Tutoriel',
                            subtitle: 'Afficher les aides au démarrage',
                            value: _tutorialEnabled,
                            onChanged: (value) {
                              setState(() => _tutorialEnabled = value);
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildDropdownSetting(
                            label: 'Difficulté',
                            value: _difficulty,
                            items: ['Facile', 'Normal', 'Difficile'],
                            onChanged: (value) {
                              setState(() => _difficulty = value!);
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Section Langue
                      _buildSection(
                        title: '🌍 LANGUE',
                        children: [
                          _buildDropdownSetting(
                            label: 'Langue du jeu',
                            value: _language,
                            items: ['Français', 'العربية', 'English'],
                            onChanged: (value) {
                              setState(() => _language = value!);
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Section Données
                      _buildSection(
                        title: '💾 DONNÉES',
                        children: [
                          _buildActionButton(
                            label: 'Sauvegarder',
                            icon: Icons.save,
                            color: Colors.blue,
                            onPressed: () {
                              _saveSettings();
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildActionButton(
                            label: 'Réinitialiser Progression',
                            icon: Icons.restart_alt,
                            color: Colors.orange,
                            onPressed: () {
                              _showResetDialog();
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildActionButton(
                            label: 'Supprimer Toutes les Données',
                            icon: Icons.delete_forever,
                            color: Colors.red,
                            onPressed: () {
                              _showDeleteDialog();
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      // Informations
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'Eco Warrior Tunisia',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Version 1.0.0',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white54,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
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
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Bouton retour
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
            onPressed: () => Navigator.pop(context),
          ),

          const SizedBox(width: 16),

          // Titre
          const Text(
            'PARAMÈTRES',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
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
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(value * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: Colors.white,
            inactiveTrackColor: Colors.white30,
            thumbColor: Colors.white,
            overlayColor: Colors.white24,
            trackHeight: 4,
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
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
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
    required ValueChanged<String?> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButton<String>(
            value: value,
            onChanged: onChanged,
            dropdownColor: const Color(0xFF2E7D32),
            underline: const SizedBox(),
            style: const TextStyle(
              fontSize: 16,
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
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 24),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _saveSettings() {
    // TODO: Implémenter la sauvegarde avec SharedPreferences
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Paramètres sauvegardés !'),
        backgroundColor: Color(0xFF4CAF50),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Réinitialiser'),
          ],
        ),
        content: const Text(
          'Voulez-vous vraiment réinitialiser votre progression ?\n\n'
              'Cette action ne peut pas être annulée.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implémenter la réinitialisation
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Progression réinitialisée'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Réinitialiser'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.delete_forever, color: Colors.red),
            SizedBox(width: 8),
            Text('Supprimer'),
          ],
        ),
        content: const Text(
          'ATTENTION !\n\n'
              'Voulez-vous vraiment supprimer TOUTES vos données ?\n\n'
              'Cela inclut votre progression, vos scores et tous vos paramètres.\n\n'
              'Cette action est IRRÉVERSIBLE !',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implémenter la suppression totale
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Toutes les données ont été supprimées'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('SUPPRIMER TOUT'),
          ),
        ],
      ),
    );
  }
}