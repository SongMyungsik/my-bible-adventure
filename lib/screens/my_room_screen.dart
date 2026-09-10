import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/badges_data.dart';
import '../providers/progress_provider.dart';
import 'parent_dashboard_screen.dart';
import 'vocab_book_screen.dart';

class MyRoomScreen extends StatelessWidget {
  const MyRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FF),
      appBar: AppBar(title: const Text('내 방')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _RoomCard(
            emoji: '📖',
            title: '내 단어장',
            subtitle: '지금까지 배운 영어 단어를 모아봐요',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const VocabBookScreen()),
            ),
          ),
          const SizedBox(height: 16),
          _RoomCard(
            emoji: '👨‍👩‍👧',
            title: '부모님',
            subtitle: '이번 주 학습 현황을 확인해보세요',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ParentDashboardScreen()),
            ),
          ),
          const SizedBox(height: 28),
          const Text('획득한 배지', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: allBadges
                .map((badge) => _BadgeTile(badge: badge, earned: progress.badgeIds.contains(badge.id)))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  const _RoomCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 40)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.badge, required this.earned});

  final BadgeInfo badge;
  final bool earned;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: earned ? 1 : 0.35,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: earned ? Colors.amber : Colors.grey.shade300, width: 2),
        ),
        padding: const EdgeInsets.all(6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(badge.emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 2),
            Text(
              badge.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
