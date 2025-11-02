import 'package:flutter/material.dart';

class MenuButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double width;
  final double height; // NOUVEAU PARAMÈTRE

  const MenuButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.width = 320,
    this.height = 70, // VALEUR PAR DÉFAUT
  });

  @override
  State<MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<MenuButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calcul des tailles responsives basées sur la hauteur
    final iconSize = widget.height * 0.45; // 45% de la hauteur du bouton
    final textSize = widget.height * 0.3;   // 30% de la hauteur du bouton
    final iconSpacing = widget.height * 0.2; // 20% de la hauteur du bouton

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.width,
          height: widget.height, // UTILISATION DE LA HAUTEUR
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.backgroundColor ?? Colors.white,
                (widget.backgroundColor ?? Colors.white).withOpacity(0.9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: _isPressed ? 5 : 15,
                offset: Offset(0, _isPressed ? 2 : 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                size: iconSize, // TAILLE DYNAMIQUE
                color: widget.foregroundColor ?? const Color(0xFF1B5E20),
              ),
              SizedBox(width: iconSpacing), // ESPACEMENT DYNAMIQUE
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: textSize, // TAILLE DE TEXTE DYNAMIQUE
                  fontWeight: FontWeight.bold,
                  color: widget.foregroundColor ?? const Color(0xFF1B5E20),
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}