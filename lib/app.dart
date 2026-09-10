import 'package:flutter/material.dart';

import 'screens/welcome_screen.dart';

class MyBibleAdventureApp extends StatelessWidget {
  const MyBibleAdventureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Bible Adventure',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2F6FED)),
        textTheme: const TextTheme().apply(fontSizeFactor: 1.05),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}
