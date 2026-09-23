import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_bible_adventure/app.dart';
import 'package:my_bible_adventure/data/stories_data.dart';
import 'package:my_bible_adventure/providers/progress_provider.dart';

void main() {
  testWidgets('Home tab shows a recommended story and bottom nav has 5 tabs',
      (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ProgressProvider(),
        child: const MyBibleAdventureApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Welcome/splash screen -> main shell.
    await tester.tap(find.text('시작하기'));
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
        (widget) => widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName == 'assets/images/001.png',
      ),
      findsOneWidget,
    );
    expect(find.text(bibleStories.first.title), findsOneWidget);
    expect(find.text('시작하기'), findsOneWidget);

    expect(find.text('홈'), findsOneWidget);
    expect(find.text('이야기'), findsOneWidget);
    expect(find.text('게임'), findsOneWidget);
    expect(find.text('그리기'), findsOneWidget);
    expect(find.text('내방'), findsOneWidget);

    await tester.tap(find.text('이야기'));
    await tester.pumpAndSettle();
    expect(find.text('구약 이야기'), findsOneWidget);
    expect(find.text('신약 이야기'), findsOneWidget);
  });
}
