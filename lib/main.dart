import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/progress_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ProgressProvider(),
      child: const MyBibleAdventureApp(),
    ),
  );
}
