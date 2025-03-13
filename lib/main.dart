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
  WidgetsFlutterBinding.ensureInitialized();
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
  late AnimationController _bounceController;
  bool _isDisposed = false;

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
  final Map<String, bool> _isHovered = {};

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    if (_isDisposed) return;
    await _loadSettings();
    if (!_isDisposed) {
      _setupNewRound();
    }
  }

  Future<void> _loadSettings() async {
    if (_isDisposed) return;

    settings = await GameSettings.load();
    await _initTts();
    if (!_isDisposed) {
      setState(() {
        isSettingsLoaded = true;
      });
    }
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
    _setupNewRound();
  }

  void _setupNewRound() {
    setState(() {
      items.shuffle();
      gameItems = items.take(3).toList();
      gameItems.shuffle();
      currentWord = gameItems[Random().nextInt(3)]['name'];
      _isHovered.clear();
    });
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
      body: RepaintBoundary(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: gameItems.map((item) {
                return RepaintBoundary(
                  child: DragTarget<String>(
                    onWillAccept: (data) => data != null,
                    onAccept: (data) {
                      if (data == item['name']) {
                        _showCelebrationAnimation(context);
                      }
                    },
                    builder: (context, candidateData, rejectedData) {
                      return MouseRegion(
                        onEnter: (_) => setState(() => _isHovered[item['name']] = true),
                        onExit: (_) => setState(() => _isHovered[item['name']] = false),
                        child: RepaintBoundary(
                          child: GestureDetector(
                            onTap: () => _speakWord(item['name']),
                            child: AnimatedScale(
                              scale: _isHovered[item['name']] == true ? 1.1 : 1.0,
                              duration: const Duration(milliseconds: 150),
                              curve: Curves.easeOutCubic,
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
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            ),

            // Bouncing draggable word
            RepaintBoundary(
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -0.03),
                  end: const Offset(0, 0.03),
                ).animate(CurvedAnimation(
                  parent: _bounceController,
                  curve: Curves.easeInOut,
                )),
                child: GestureDetector(
                  onTap: () => _speakWord(currentWord),
                  child: Draggable<String>(
                    data: currentWord,
                    maxSimultaneousDrags: 1,
                    hitTestBehavior: HitTestBehavior.translucent,
                    feedback: RepaintBoundary(
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.7),
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
                    childWhenDragging: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        currentWord,
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withOpacity(0.5),
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
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _bounceController.dispose();
    flutterTts.stop();
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    _initializeGame();
  }
}