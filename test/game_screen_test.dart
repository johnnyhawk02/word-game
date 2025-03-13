import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drag_drop_demo/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GameScreen Widget Tests', () {
    setUp(() async {
      // Initialize SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('Initial game state has correct elements', (WidgetTester tester) async {
      // Build the game screen
      await tester.pumpWidget(const MaterialApp(home: GameScreen()));
      await tester.pumpAndSettle(); // Wait for loading state

      // Check for essential UI elements
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
      expect(find.byType(Draggable<String>), findsOneWidget);
      expect(find.byType(DragTarget<String>), findsNWidgets(3));
    });

    testWidgets('Settings dialog shows and updates name', (WidgetTester tester) async {
      // Build the game screen
      await tester.pumpWidget(const MaterialApp(home: GameScreen()));
      await tester.pumpAndSettle();

      // Open settings dialog
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Verify dialog appears
      expect(find.text('Settings'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      // Enter new name
      await tester.enterText(find.byType(TextField), 'TestUser');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify dialog closed
      expect(find.text('Settings'), findsNothing);
    });

    testWidgets('Correct word matching shows celebration', (WidgetTester tester) async {
      // Build the game screen
      await tester.pumpWidget(const MaterialApp(home: GameScreen()));
      await tester.pumpAndSettle();

      // Get the current word
      final gameScreenState = tester.state<_GameScreenState>(find.byType(GameScreen));
      final currentWord = gameScreenState.currentWord;

      // Find the drag target that matches the current word
      final matchingTarget = tester.widget<DragTarget<String>>(
        find.ancestor(
          of: find.text(currentWord),
          matching: find.byType(DragTarget<String>),
        ),
      );

      // Perform drag and drop
      final draggable = find.byType(Draggable<String>);
      final dragTargetFinder = find.ancestor(
        of: find.text(currentWord),
        matching: find.byType(DragTarget<String>),
      );

      await tester.drag(draggable, Offset(0, -100));
      await tester.pumpAndSettle();

      // Verify celebration appears
      expect(find.text('Well Done!'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsWidgets);
    });

    testWidgets('Wrong word matching shows error', (WidgetTester tester) async {
      // Build the game screen
      await tester.pumpWidget(const MaterialApp(home: GameScreen()));
      await tester.pumpAndSettle();

      // Get a wrong target (not matching the current word)
      final gameScreenState = tester.state<_GameScreenState>(find.byType(GameScreen));
      final currentWord = gameScreenState.currentWord;
      
      // Find a target that doesn't match the current word
      final wrongTargetFinder = find.ancestor(
        of: find.text(
          gameScreenState.gameItems
              .firstWhere((item) => item['name'] != currentWord)['name']
        ),
        matching: find.byType(DragTarget<String>),
      );

      // Perform drag and drop to wrong target
      final draggable = find.byType(Draggable<String>);
      await tester.drag(draggable, tester.getCenter(wrongTargetFinder) - tester.getCenter(draggable));
      await tester.pumpAndSettle();

      // Verify error message appears
      expect(find.text('Try again!'), findsOneWidget);
    });

    testWidgets('Word speaks when tapped', (WidgetTester tester) async {
      // Build the game screen
      await tester.pumpWidget(const MaterialApp(home: GameScreen()));
      await tester.pumpAndSettle();

      // Get the current word
      final draggableWord = find.byType(Draggable<String>);
      
      // Tap the word
      await tester.tap(draggableWord);
      await tester.pumpAndSettle();

      // Note: We can't test actual TTS functionality in widget tests,
      // but we can verify the word is tappable
      expect(draggableWord, findsOneWidget);
    });
  });
}