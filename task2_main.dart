import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const SproutMiniApp());
}

class SproutMiniApp extends StatelessWidget {
  const SproutMiniApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sprout Mini Interactive',
      theme: ThemeData(primarySwatch: Colors.purple),
      home: const InteractiveHatchScreen(),
    );
  }
}

class InteractiveHatchScreen extends StatefulWidget {
  const InteractiveHatchScreen({Key? key}) : super(key: key);

  @override
  State<InteractiveHatchScreen> createState() => _InteractiveHatchScreenState();
}

class _InteractiveHatchScreenState extends State<InteractiveHatchScreen>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  int _tapCount = 0;
  bool _isHatched = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticIn),
    );
  }

  void _handleTap() async {
    if (_isHatched) return;

    try {
      await _audioPlayer.play(AssetSource('pop.mp3'));
    } catch (e) {
      debugPrint("Audio play error: $e");
    }

    _animationController.forward().then((_) => _animationController.reverse());

    setState(() {
      _tapCount++;
      if (_tapCount >= 5) {
        _isHatched = true;
      }
    });
  }

  void _resetGame() {
    setState(() {
      _tapCount = 0;
      _isHatched = false;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0F7FA), Color(0xFFE8EAF6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 40.0),
                  child: Text(
                    _isHatched ? "Yay! You did it! 🎉" : "Tap the Magic Egg! ✨",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                ),
              ),
              Center(
                child: GestureDetector(
                  onTap: _handleTap,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: _isHatched
                          ? Column(
                              key: const ValueKey('hatched'),
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star, size: 160, color: Colors.amber),
                                const SizedBox(height: 20),
                                const Text(
                                  "Baby Star hatched!",
                                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange),
                                ),
                                const SizedBox(height: 30),
                                ElevatedButton(
                                  onPressed: _resetGame,
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                                  child: const Text("Play Again", style: TextStyle(color: Colors.white)),
                                )
                              ],
                            )
                          : Container(
                              key: const ValueKey('egg'),
                              width: 160,
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.orangeAccent,
                                borderRadius: const BorderRadius.all(Radius.elliptical(80, 100)),
                                border: Border.all(color: Colors.white, width: 4),
                              ),
                              child: Center(
                                child: Text(
                                  "${5 - _tapCount} left!",
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
