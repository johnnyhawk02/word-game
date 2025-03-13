import 'package:flutter/material.dart';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameSettings {
  static const String userNameKey = 'userName';
  static const String defaultUserName = 'Robyn';
  
  String userName;
  
  GameSettings({this.userName = defaultUserName});
  
  static Future<GameSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return GameSettings(
      userName: prefs.getString(userNameKey) ?? defaultUserName,
    );
  }
  
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userNameKey, userName);
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Word Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.aBeeZeeTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  late GameSettings settings;
  bool isSettingsLoaded = false;
  late AnimationController _dragAnimationController;

  final List<Map<String, dynamic>> items = [
    {'name': 'Apple', 'image': 'assets/apple.jpeg'},
    {'name': 'Baby', 'image': 'assets/baby.jpeg'},
    {'name': 'Bag', 'image': 'assets/bag.jpeg'},
    {'name': 'Ball', 'image': 'assets/ball.jpeg'},
    {'name': 'Banana', 'image': 'assets/banana.jpeg'},
    {'name': 'Bath', 'image': 'assets/bath.jpeg'},
    {'name': 'Bear', 'image': 'assets/bear.jpeg'},
    {'name': 'Bed', 'image': 'assets/bed.jpeg'},
    {'name': 'Bird', 'image': 'assets/bird.jpeg'},
    {'name': 'Biscuit', 'image': 'assets/biscuit.jpeg'},
    {'name': 'Blocks', 'image': 'assets/blocks.jpeg'},
    {'name': 'Book', 'image': 'assets/book.jpeg'},
    {'name': 'Brush', 'image': 'assets/brush.jpeg'},
    {'name': 'Brushing', 'image': 'assets/brushing.jpeg'},
    {'name': 'Car', 'image': 'assets/car.jpeg'},
    {'name': 'Cat', 'image': 'assets/cat.jpeg'},
    {'name': 'Chair', 'image': 'assets/chair.jpeg'},
    {'name': 'Coat', 'image': 'assets/coat.jpeg'},
    {'name': 'Cow', 'image': 'assets/cow.jpeg'},
    {'name': 'Crying', 'image': 'assets/crying.jpeg'},
    {'name': 'Cup', 'image': 'assets/cup.jpeg'},
    {'name': 'Daddy', 'image': 'assets/daddy.jpeg'},
    {'name': 'Dog', 'image': 'assets/dog.jpeg'},
    {'name': 'Doll', 'image': 'assets/doll.jpeg'},
    {'name': 'Drink', 'image': 'assets/drink.jpeg'},
    {'name': 'Drinking', 'image': 'assets/drinking.jpeg'},
    {'name': 'Duck', 'image': 'assets/duck.jpeg'},
    {'name': 'Eating', 'image': 'assets/eating.jpeg'},
    {'name': 'Eyes', 'image': 'assets/eyes.jpeg'},
    {'name': 'Fish', 'image': 'assets/fish.jpeg'},
    {'name': 'Flower', 'image': 'assets/flower.jpeg'},
    {'name': 'Hair', 'image': 'assets/hair.jpeg'},
    {'name': 'Hat', 'image': 'assets/hat.jpeg'},
    {'name': 'Keys', 'image': 'assets/keys.jpeg'},
    {'name': 'Mouth', 'image': 'assets/mouth.jpeg'},
    {'name': 'Mummy', 'image': 'assets/mummy.jpeg'},
    {'name': 'Nose', 'image': 'assets/nose.jpeg'},
    {'name': 'Phone', 'image': 'assets/phone.jpeg'},
    {'name': 'Pig', 'image': 'assets/pig.jpeg'},
    {'name': 'Sheep', 'image': 'assets/sheep.jpeg'},
    {'name': 'Shoes', 'image': 'assets/shoes.jpeg'},
    {'name': 'Sitting', 'image': 'assets/sitting.jpeg'},
    {'name': 'Sleeping', 'image': 'assets/sleeping.jpeg'},
    {'name': 'Socks', 'image': 'assets/socks.jpeg'},
    {'name': 'Spoon', 'image': 'assets/spoon.jpeg'},
    {'name': 'Table', 'image': 'assets/table.jpeg'},
    {'name': 'Walk', 'image': 'assets/walk.jpeg'},
    {'name': 'Wash', 'image': 'assets/wash.jpeg'},
  ];
  
  late List<Map<String, dynamic>> gameItems;
  String currentWord = '';
  bool isCorrect = false;
  late AnimationController _bounceController;
  final Map<String, bool> _isHovered = {};

  @override
  void initState() {
    super.initState();
    _setupNewRound();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _dragAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..repeat(reverse: true);
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    settings = await GameSettings.load();
    await _initTts();
    setState(() {
      isSettingsLoaded = true;
    });
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("en-GB");
    await flutterTts.setVoice({"name": "Karen", "locale": "en-GB"});
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String tempName = settings.userName;
        return AlertDialog(
          title: Text('Settings', style: GoogleFonts.aBeeZee()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: TextEditingController(text: tempName),
                onChanged: (value) => tempName = value,
                decoration: InputDecoration(
                  labelText: 'User Name',
                  labelStyle: GoogleFonts.aBeeZee(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.aBeeZee()),
            ),
            TextButton(
              onPressed: () async {
                settings.userName = tempName;
                await settings.save();
                Navigator.pop(context);
              },
              child: Text('Save', style: GoogleFonts.aBeeZee()),
            ),
          ],
        );
      },
    );
  }

  Future<void> _speakWord(String word) async {
    await flutterTts.speak(word);
  }

  void _showCelebrationAnimation(BuildContext context) {
    flutterTts.speak("Well done ${settings.userName}!");
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: TweenAnimationBuilder(
            duration: const Duration(milliseconds: 2000),
            tween: Tween<double>(begin: 0, end: 1),
            curve: Curves.easeInOut,
            builder: (context, double value, child) {
              return Transform.scale(
                scale: value < 0.5 ? value * 2 : 1.0,
                child: Opacity(
                  opacity: value < 0.8 ? 1.0 : (1.0 - ((value - 0.8) * 5)),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SparkleAnimation(
                          child: TweenAnimationBuilder<double>(
                            tween: Tween<double>(
                              begin: 1.0,
                              end: 1.2,
                            ),
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                            builder: (context, scale, child) {
                              return Transform.scale(
                                scale: scale,
                                child: const Icon(
                                  Icons.star,
                                  color: Colors.yellow,
                                  size: 120,
                                ),
                              );
                            },
                          ),
                        ),
                        const Text(
                          'Well Done!',
                          style: TextStyle(
                            fontSize: 30,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            onEnd: () {
              Future.delayed(const Duration(milliseconds: 200), () {
                Navigator.of(context).pop();
                setState(() {
                  _setupNewRound();
                });
              });
            },
          ),
        );
      },
    );
  }

  void _setupNewRound() {
    // Randomly select 3 items for this round
    items.shuffle();
    gameItems = items.take(3).toList();
    gameItems.shuffle();
    // Randomly select one of the three items as the target word
    currentWord = gameItems[Random().nextInt(3)]['name'];
    isCorrect = false;
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _dragAnimationController.dispose();
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isSettingsLoaded) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Match the Word', style: GoogleFonts.aBeeZee()),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettingsDialog,
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: gameItems.map((item) {
              return DragTarget<String>(
                builder: (context, candidateData, rejectedData) {
                  return MouseRegion(
                    onEnter: (_) => setState(() => _isHovered[item['name']] = true),
                    onExit: (_) => setState(() => _isHovered[item['name']] = false),
                    child: GestureDetector(
                      onTap: () => _speakWord(item['name']),
                      child: AnimatedScale(
                        scale: _isHovered[item['name']] == true ? 1.1 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Column(
                          children: [
                            Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: candidateData.isNotEmpty ? Colors.green : Colors.grey,
                                  width: 3,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  item['image'],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              item['name'],
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                onWillAccept: (data) => true,
                onAccept: (data) {
                  if (data == item['name']) {
                    setState(() {
                      isCorrect = true;
                    });
                    _showCelebrationAnimation(context);
                    Future.delayed(const Duration(milliseconds: 1500), () {
                      setState(() {
                        _setupNewRound();
                      });
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Try again!'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              );
            }).toList(),
          ),

          // Bouncing draggable word
          SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.05),
              end: const Offset(0, 0.05),
            ).animate(CurvedAnimation(
              parent: _bounceController,
              curve: Curves.easeInOut,
            )),
            child: GestureDetector(
              onTap: () => _speakWord(currentWord),
              child: Draggable<String>(
                data: currentWord,
                feedback: AnimatedBuilder(
                  animation: _dragAnimationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_dragAnimationController.value * 0.2),
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            currentWord,
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                childWhenDragging: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.5),
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    currentWord,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SparkleAnimation extends StatefulWidget {
  final Widget child;
  final bool isRepeating;

  const SparkleAnimation({
    super.key, 
    required this.child,
    this.isRepeating = true,
  });

  @override
  State<SparkleAnimation> createState() => _SparkleAnimationState();
}

class _SparkleAnimationState extends State<SparkleAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed && widget.isRepeating) {
        _controller.reset();
        _controller.forward();
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        ...List.generate(12, (index) => _buildSparkle(index)),
      ],
    );
  }

  Widget _buildSparkle(int index) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = _controller.value;
        return Positioned(
          left: cos(index * 30 * pi / 180) * 100 * value,
          top: sin(index * 30 * pi / 180) * 100 * value,
          child: Opacity(
            opacity: max(0, 1 - value),
            child: Transform.rotate(
              angle: value * 4 * pi,
              child: Icon(
                Icons.star,
                color: Colors.yellow,
                size: 20 * (1 - value * 0.7),
              ),
            ),
          ),
        );
      },
    );
  }
}