import 'package:flutter/material.dart';
import '../models/stage_data.dart';

class StageCard extends StatefulWidget {
  final StageData stage;
  final int delay;
  final VoidCallback onTap;

  const StageCard({
    super.key,
    required this.stage,
    required this.delay,
    required this.onTap,
  });

  @override
  State<StageCard> createState() => _StageCardState();
}

class _StageCardState extends State<StageCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    // Animation d'entrée avec délai
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _isHovered = true),
          onTapUp: (_) => setState(() => _isHovered = false),
          onTapCancel: () => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: widget.stage.isUnlocked
                    ? [
                  widget.stage.backgroundColor,
                  widget.stage.backgroundColor.withOpacity(0.7),
                ]
                    : [
                  Colors.grey.shade700,
                  Colors.grey.shade800,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isHovered
                    ? Colors.white
                    : Colors.white.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.stage.isUnlocked
                      ? widget.stage.backgroundColor.withOpacity(0.5)
                      : Colors.black38,
                  blurRadius: _isHovered ? 20 : 10,
                  spreadRadius: _isHovered ? 2 : 0,
                  offset: Offset(0, _isHovered ? 6 : 3),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Contenu principal
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icône
                      Icon(
                        widget.stage.isUnlocked
                            ? widget.stage.icon
                            : Icons.lock,
                        size: 48,
                        color: widget.stage.isUnlocked
                            ? Colors.white
                            : Colors.white54,
                      ),

                      const SizedBox(height: 12),

                      // Numéro du stage
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'STAGE ${widget.stage.stageNumber}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Titre
                      Text(
                        widget.stage.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: widget.stage.isUnlocked
                              ? Colors.white
                              : Colors.white54,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Difficulté
                      Text(
                        widget.stage.difficulty,
                        style: TextStyle(
                          fontSize: 11,
                          color: widget.stage.isUnlocked
                              ? Colors.white70
                              : Colors.white38,
                        ),
                      ),

                      const Spacer(),

                      // Indicateur de complétion (si débloqué)
                      if (widget.stage.isUnlocked) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (index) {
                            return Icon(
                              index < widget.stage.stars
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 16,
                              color: Colors.amber,
                            );
                          }),
                        ),
                      ],
                    ],
                  ),
                ),

                // Badge "NOUVEAU" pour le prochain stage débloqué
                if (!widget.stage.isUnlocked &&
                    widget.stage.stageNumber == 1) ...[
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'NOUVEAU',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}