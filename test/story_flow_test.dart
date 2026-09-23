import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_bible_adventure/app.dart';
import 'package:my_bible_adventure/data/book_loader.dart';
import 'package:my_bible_adventure/data/stories_data.dart';
import 'package:my_bible_adventure/providers/progress_provider.dart';

/// Narration (flutter_tts, audioplayers) has no platform implementation in
/// the widget-test VM. On a real device/web these plugin calls succeed and
/// the app never notices; here, mocking their channels to no-op keeps the
/// golden path test from failing on MissingPluginException instead of
/// exercising the plugins for real.
void _mockNarrationChannels() {
  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  const noOpStream = MockStreamHandler.inline(onListen: _noOpOnListen);

  messenger.setMockMethodCallHandler(const MethodChannel('flutter_tts'), (call) async => null);
  messenger.setMockMethodCallHandler(
      const MethodChannel('com.llfbandit.record/messages'), (call) async => null);
  messenger.setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers.global'), (call) async => null);
  messenger.setMockStreamHandler(
      const EventChannel('xyz.luan/audioplayers.global/events'), noOpStream);

  // Each AudioPlayer gets its own randomly-generated playerId and its own
  // per-player event channel, so that channel can't be mocked up front by
  // name - register it reactively the moment we see the 'create' call that
  // names it.
  messenger.setMockMethodCallHandler(const MethodChannel('xyz.luan/audioplayers'),
      (call) async {
    if (call.method == 'create') {
      final playerId = (call.arguments as Map)['playerId'] as String;
      messenger.setMockStreamHandler(
          EventChannel('xyz.luan/audioplayers/events/$playerId'), noOpStream);
    }
    return null;
  });
}

void _noOpOnListen(Object? arguments, MockStreamHandlerEventSink events) {}

Future<void> _tapButtonWithText(WidgetTester tester, String text) async {
  final finder = find.widgetWithText(FilledButton, text);
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// The coloring canvas decodes its image via dart:ui's real (engine-thread)
/// codec, which doesn't progress under flutter_test's fake-async pumping,
/// and shows an (infinitely-animating) CircularProgressIndicator while it
/// waits - something pumpAndSettle() would never consider "settled" even
/// if the decode did complete. runAsync() steps outside the fake-async
/// zone so the real decode can actually finish, then a pump flushes the
/// resulting setState.
Future<void> _waitForColoringPageToLoad(WidgetTester tester) async {
  for (var i = 0; i < 50; i++) {
    // Give the real (engine-thread) decode work an actual chance to run,
    // then flush the resulting setState, before checking whether the
    // coloring screen has finished loading.
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump();
    final onColoringScreen = find.text('Coloring Time!').evaluate().isNotEmpty;
    final stillLoading = find.byType(CircularProgressIndicator).evaluate().isNotEmpty;
    if (onColoringScreen && !stillLoading) return;
  }
}

void main() {
  testWidgets(
      'Full golden path: intro -> scenes -> speak -> game -> complete -> next story',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    _mockNarrationChannels();

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
      final nextFinder = find.widgetWithText(FilledButton, isLast ? 'See Results' : 'Next');
      await tester.ensureVisible(nextFinder);
      await tester.tap(nextFinder);
      if (isLast) {
        // Lands on the coloring screen, which loads its image asynchronously.
        await tester.pump();
        await _waitForColoringPageToLoad(tester);
      }
      await tester.pumpAndSettle();
    }

    // Coloring screen: pick a color, tap a spot near the top of the canvas
    // (blank sky in the sample artwork, well clear of any line art) to
    // flood-fill it, then finish. Uses a fraction of the rendered canvas
    // box rather than a fixed pixel, since the underlying image's own
    // resolution isn't known here.
    expect(find.text('Coloring Time!'), findsOneWidget);
    final canvasFinder = find.byType(GestureDetector).first;
    final canvasTopLeft = tester.getTopLeft(canvasFinder);
    final canvasSize = tester.getSize(canvasFinder);
    await tester.tapAt(canvasTopLeft + Offset(canvasSize.width * 0.5, canvasSize.height * 0.03));
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
