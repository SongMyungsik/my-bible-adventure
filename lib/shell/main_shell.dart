import 'package:flutter/material.dart';

import '../screens/games_screen.dart';
import '../screens/home_screen.dart';
import '../screens/my_room_screen.dart';
import '../screens/stories_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tabIndex = 0;

  static const _tabs = [
    HomeScreen(),
    StoriesScreen(),
    GamesScreen(),
    MyRoomScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _tabIndex, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (index) => setState(() => _tabIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: '홈'),
          NavigationDestination(icon: Icon(Icons.menu_book_rounded), label: '이야기'),
          NavigationDestination(icon: Icon(Icons.videogame_asset_rounded), label: '게임'),
          NavigationDestination(icon: Icon(Icons.emoji_people_rounded), label: '내방'),
        ],
      ),
    );
  }
}
