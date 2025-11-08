import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import '../components/ui/joystick.dart';

class ParallaxBackground extends Component {
  late final ParallaxComponent _parallax;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _parallax = await ParallaxComponent.load(
      [
        // Utilisez vos images existantes dans l'ordre de profondeur
        ParallaxImageData('backgrounds/stage1/1.png'),    // Nuages lointains
        ParallaxImageData('backgrounds/stage1/4.png'),    // Nuages moyens
        ParallaxImageData('backgrounds/stage1/3.png'),    // Nuages proches
        ParallaxImageData('backgrounds/stage1/2.png'),    // Mer et sable (premier plan)
      ],
      baseVelocity: Vector2(0, 0),
      // Ajustez les multiplicateurs de vitesse pour l'effet parallax
      velocityMultiplierDelta: Vector2(1.5, 0), // Les images se déplacent à différentes vitesses
    );

    await add(_parallax);
  }

  void updateParallax(GameJoystickDirection direction) {
    switch (direction) {
      case GameJoystickDirection.left:
        _parallax.parallax?.baseVelocity = Vector2(30, 0); // Vitesse réduite pour mieux voir
        break;
      case GameJoystickDirection.right:
        _parallax.parallax?.baseVelocity = Vector2(-30, 0);
        break;
      case GameJoystickDirection.idle:
      case GameJoystickDirection.jump:
        _parallax.parallax?.baseVelocity = Vector2(0, 0);
        break;
    }
  }
}