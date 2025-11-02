import 'package:flutter/material.dart';
import 'dart:async';
import '../managers/audio_manager.dart';
import '../models/stage_data.dart';
import 'gameplay_screen.dart';

class StoryScreen extends StatefulWidget {
  final StageData stage;

  const StoryScreen({super.key, required this.stage});

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  int _currentDialogue = 0;
  String _displayText = "";
  int _currentTextIndex = 0;
  bool _isTyping = false;
  bool _showContinueButton = false;
  Timer? _typingTimer;

  final List<String> _dialogues = [
    "Dans un monde écrasé par la pollution et le désespoir, un jeune homme nommé Mayo marche seul dans les rues de Tunisie. Ses cheveux noirs tombent sur son masque, qu'il porte pour se protéger de l'air toxique qui envahit la ville.",

    "Ses yeux sombres scrutent les murs couverts d'affiches alarmantes : photos d'animaux morts, taux croissant de maladies, mers polluées, forêts brûlées. Chaque pas qu'il fait lui rappelle la souffrance de la terre et des êtres vivants.",

    "Alors qu'il avance sans but, une étrange vibration traverse l'air. Devant lui, un trou noir apparaît soudainement, aspirant la lumière environnante. Un objet lumineux en jaillit : un bracelet mystérieux qui tombe juste devant ses pieds.",

    "Surpris, Mayo regarde autour de lui, hésite, puis attrape le bracelet. Dès qu'il le met à son poignet, le temps semble se figer. Une lumière verte et pure l'enveloppe.",

    "Une silhouette apparaît devant lui : un vieil homme à la barbe longue comme les racines d'un arbre millénaire, vêtu de feuilles et de fibres naturelles. Ses yeux brillent d'une sagesse ancienne.",

    "« Je suis l'Homme de la Nature, » dit-il avec une voix profonde. « La nature agonise, et elle t'a choisi… toi, Mayo. Tu es son dernier espoir. Deviens son protecteur. Rétablis l'équilibre. »",

    "Un souffle puissant traverse le corps de Mayo. Ses muscles frémissent, une énergie immense circule en lui. Ses cheveux deviennent soudain jaunes dorés, et le bracelet se transforme en épée lumineuse, vibrante de force naturelle.",

    "Pour la première fois depuis longtemps, un sentiment naît en lui… l'espoir. Mayo serre l'épée, déterminé. Une nouvelle mission l'attend : défendre la nature, apprendre ses secrets, et affronter ceux qui la détruisent.",

    "Ainsi commence l'histoire de Mayo, le Protecteur de la Nature. Son premier pas dans cette quête le mène vers la plage de Hammamet, autrefois paradis bleu, aujourd'hui défigurée par les déchets plastiques.",

    "Sous ses yeux, les vagues se déchirent et la pollution prend forme : des monstres nés des déchets, créatures visqueuses façonnées par le plastique, le pétrole et la colère des océans.",

    "Mayo lève son épée étincelante. Le vent marin fouette son visage. Ce n'est plus un simple spectateur du chaos : il devient le rempart de la nature. Aujourd'hui, il doit sauver la mer.",

    "Et la bataille pour la Terre commence…"
  ];

  @override
  void initState() {
    super.initState();

    // Changer la musique pour l'histoire
    AudioManager().playMusic('story_music.mp3');

    // Animation de fondu
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _fadeController.forward();

    // Démarrer le premier dialogue
    _startTyping();
  }

  void _startTyping() {
    if (_currentDialogue >= _dialogues.length) {
      _goToGameplay();
      return;
    }

    setState(() {
      _displayText = "";
      _currentTextIndex = 0;
      _isTyping = true;
      _showContinueButton = false;
    });

    _typingTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (_currentTextIndex < _dialogues[_currentDialogue].length) {
        setState(() {
          _displayText += _dialogues[_currentDialogue][_currentTextIndex];
          _currentTextIndex++;

          // Jouer le son de frappe au clavier (tous les 3 caractères)
          if (_currentTextIndex % 3 == 0) {
            AudioManager().playSfx('keyboard_typing.mp3');
          }
        });
      } else {
        timer.cancel();
        setState(() {
          _isTyping = false;
          _showContinueButton = true;
        });
      }
    });
  }

  void _nextDialogue() {
    AudioManager().playSfx('button_click.mp3');

    if (_currentDialogue < _dialogues.length - 1) {
      setState(() {
        _currentDialogue++;
      });
      _startTyping();
    } else {
      _goToGameplay();
    }
  }

  void _skipStory() {
    AudioManager().playSfx('button_click.mp3');
    _goToGameplay();
  }

  void _goToGameplay() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            GameplayScreen(stage: widget.stage),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 1000),
      ),
    );
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            // Curseur clignotant
            if (_isTyping)
              Positioned(
                bottom: 100,
                right: 50,
                child: AnimatedOpacity(
                  opacity: _isTyping ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: const Text(
                    "_",
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            // Contenu principal
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),

                  // Texte de l'histoire
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white30),
                    ),
                    child: Text(
                      _displayText,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        height: 1.5,
                        fontFamily: 'Courier',
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Boutons
                  Row(
                    children: [
                      // Bouton Continuer
                      if (_showContinueButton)
                        ElevatedButton.icon(
                          onPressed: _nextDialogue,
                          icon: const Icon(Icons.arrow_forward),
                          label: Text(
                            _currentDialogue < _dialogues.length - 1
                                ? 'SUIVANT'
                                : 'COMMENCER',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 15,
                            ),
                          ),
                        ),

                      const Spacer(),

                      // Bouton Passer
                      TextButton.icon(
                        onPressed: _skipStory,
                        icon: const Icon(Icons.fast_forward),
                        label: const Text(
                          'PASSER',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Indicateur de progression
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0; i < _dialogues.length; i++)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i <= _currentDialogue
                                ? Colors.green
                                : Colors.white30,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}