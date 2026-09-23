import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_bible_adventure/app.dart';
import 'package:my_bible_adventure/data/book_loader.dart';
import 'package:my_bible_adventure/data/stories_data.dart';
import 'package:my_bible_adventure/providers/progress_provider.dart';

Future<void> _tapButtonWithText(WidgetTester tester, String text) async {
  final finder = find.widgetWithText(FilledButton, text);
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
      'Full golden path: intro -> scenes -> speak -> game -> complete -> next story',
      (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ProgressProvider(),
        child: const MyBibleAdventureApp(),
      ),
    );
    await tester.pumpAndSettle();

    final story = bibleStories.first; // "오늘의 이야기" recommendation
    final scenes = await resolveStoryScenes(story);

    // Welcome/splash screen -> main shell.
    await tester.tap(find.text('시작하기'));
    await tester.pumpAndSettle();

    // Home -> story intro.
    await tester.tap(find.text('시작하기'));
    await tester.pumpAndSettle();
    expect(find.text("Let's Begin!"), findsOneWidget);

    // Intro -> scene viewer.
    await _tapButtonWithText(tester, "Let's Begin!");

    // Walk through every scene.
    for (var i = 0; i < scenes.length - 1; i++) {
      await _tapButtonWithText(tester, 'Next');
    }
    await _tapButtonWithText(tester, 'Next: Speak');

    // Speak practice: skip recording, just walk through sentences.
    expect(find.text('따라 말하기'), findsOneWidget);
    for (var i = 0; i < scenes.length - 1; i++) {
      await _tapButtonWithText(tester, 'Next Sentence');
    }
    await _tapButtonWithText(tester, 'Next: Game');

    // Picture-match game: answer every round correctly by matching the
    // target word's emoji among the four options.
    expect(find.text('그림 맞추기'), findsOneWidget);
    const roundCount = 5;
    for (var round = 0; round < roundCount; round++) {
      final promptText = tester
          .widget<Text>(
            find.descendant(of: find.byType(Chip), matching: find.byType(Text)).first,
          )
          .data!;
      final targetWord = story.vocabulary.firstWhere((w) => w.english == promptText);

      final emojiFinder = find.text(targetWord.emoji).first;
      await tester.ensureVisible(emojiFinder);
      await tester.tap(emojiFinder);
      await tester.pumpAndSettle();

      final isLast = round == roundCount - 1;
      await _tapButtonWithText(tester, isLast ? 'See Results' : 'Next');
    }

    // Coloring screen: pick a color, tap inside a known-safe spot of the
    // house body region (avoiding the windows/door rects nested inside
    // it), then finish.
    expect(find.text('Coloring Time!'), findsOneWidget);
    final canvasFinder = find.byType(GestureDetector).first;
    final canvasTopLeft = tester.getTopLeft(canvasFinder);
    final canvasScale = tester.getSize(canvasFinder).width / 320;
    await tester.tapAt(canvasTopLeft + const Offset(100, 250) * canvasScale);
    await tester.pumpAndSettle();
    await _tapButtonWithText(tester, '완료');

    // Complete screen: perfect score, checklist, badges.
    expect(find.text('Great Job!'), findsOneWidget);
    expect(find.text('읽기 완료'), findsOneWidget);
    expect(find.text('듣기 완료'), findsOneWidget);
    expect(find.text('따라 말하기 완료'), findsOneWidget);
    expect(find.text('게임 완료'), findsOneWidget);
    expect(find.text('색칠 완료'), findsOneWidget);
    expect(find.text('New badge unlocked!'), findsOneWidget);
    expect(find.text('Story Explorer'), findsOneWidget);
    expect(find.text('Game Champion'), findsOneWidget);

    // Next story -> lands on the next intro screen.
    await _tapButtonWithText(tester, '다음 이야기로');
    final nextStory = bibleStories[1];
    expect(find.text(nextStory.description), findsOneWidget);
  });
}
