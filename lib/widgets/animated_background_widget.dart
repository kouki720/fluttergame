import 'package:flutter/material.dart';
import 'package:animated_background/animated_background.dart';

class AnimatedBackgroundWidget extends StatefulWidget {
  final Widget child;
  final ParticleOptions? particleOptions;
  final List<Color> colors;

  const AnimatedBackgroundWidget({
    super.key,
    required this.child,
    this.particleOptions,
    this.colors = const [
      Color(0xFF1B5E20),
      Color(0xFF2E7D32),
      Color(0xFF4CAF50),
    ],
  });

  @override
  State<AnimatedBackgroundWidget> createState() => _AnimatedBackgroundWidgetState();
}

class _AnimatedBackgroundWidgetState extends State<AnimatedBackgroundWidget>
    with TickerProviderStateMixin {

  ParticleOptions get _particleOptions {
    return widget.particleOptions ?? ParticleOptions(
      image: const Image(image: AssetImage('assets/images/ui/eco_particle.png')),
      baseColor: Colors.white.withOpacity(0.3),
      spawnOpacity: 0.0,
      opacityChangeRate: 0.25,
      minOpacity: 0.1,
      maxOpacity: 0.4,
      particleCount: 35,
      spawnMinSpeed: 20.0,
      spawnMaxSpeed: 50.0,
      spawnMinRadius: 1.5,
      spawnMaxRadius: 4.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      behaviour: RandomParticleBehaviour(
        options: _particleOptions,
      ),
      vsync: this,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: widget.colors,
          ),
        ),
        child: widget.child,
      ),
    );
  }
}