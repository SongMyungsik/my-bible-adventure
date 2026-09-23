import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/progress_provider.dart';

void main() {
  // The game/vocab picture icons are Microsoft's Fluent Emoji (MIT), which
  // requires shipping its license notice.
  LicenseRegistry.addLicense(() async* {
    final text = await rootBundle.loadString('assets/emoji/LICENSE');
    yield LicenseEntryWithLineBreaks(['fluentui-emoji'], text);
  });
  runApp(
    ChangeNotifierProvider(
      create: (_) => ProgressProvider(),
      child: const MyBibleAdventureApp(),
    ),
  );
}
