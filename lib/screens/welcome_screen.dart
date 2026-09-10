import 'package:flutter/material.dart';

import '../shell/main_shell.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/001.png', fit: BoxFit.cover),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const MainShell()),
                    ),
                    child: const Text('시작하기'),
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
