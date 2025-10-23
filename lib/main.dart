import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/splash_screen.dart';

void main() async {
  // Assurer l'initialisation de Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Forcer l'orientation paysage (écran à l'inverse - horizontal)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Masquer la barre de statut et la barre de navigation
  // Pour une expérience plein écran
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
    overlays: [],
  );

  runApp(const EcoWarriorTunisia());
}

class EcoWarriorTunisia extends StatelessWidget {
  const EcoWarriorTunisia({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Titre de l'application
      title: 'Eco Warrior Tunisia',

      // Désactiver le bandeau "Debug"
      debugShowCheckedModeBanner: false,

      // Thème de l'application
      theme: ThemeData(
        // Couleur principale (vert pour l'environnement)
        primarySwatch: Colors.green,
        primaryColor: const Color(0xFF1B5E20),

        // Couleur d'accentuation
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50),
          brightness: Brightness.light,
        ),

        // Police par défaut
        fontFamily: 'Roboto',

        // Style des textes
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 56,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          displayMedium: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
          ),
          bodyLarge: TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
          bodyMedium: TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),

        // Style des boutons
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF1B5E20),
            elevation: 8,
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),

        // Désactiver les animations de défilement avec effet glow
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: MaterialStateProperty.all(Colors.white30),
        ),
      ),

      // Écran de démarrage (Splash Screen)
      home: const SplashScreen(),
    );
  }
}