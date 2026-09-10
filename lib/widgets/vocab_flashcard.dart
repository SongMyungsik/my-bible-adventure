import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/vocab_word.dart';

class VocabFlashcard extends StatefulWidget {
  const VocabFlashcard({
    super.key,
    required this.word,
    required this.onSpeak,
  });

  final VocabWord word;
  final VoidCallback onSpeak;

  @override
  State<VocabFlashcard> createState() => _VocabFlashcardState();
}

class _VocabFlashcardState extends State<VocabFlashcard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
  );
  bool _showingBack = false;

  @override
  void didUpdateWidget(covariant VocabFlashcard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.word.id != widget.word.id) {
      _showingBack = false;
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    if (_showingBack) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() => _showingBack = !_showingBack);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flip,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final angle = _controller.value * math.pi;
          final isBack = angle > math.pi / 2;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: isBack
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: _cardFace(back: true),
                  )
                : _cardFace(back: false),
          );
        },
      ),
    );
  }

  Widget _cardFace({required bool back}) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 260),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: back
              ? [Colors.orange.shade200, Colors.orange.shade400]
              : [Colors.lightBlue.shade200, Colors.lightBlue.shade400],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Center(
        child: back
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.word.korean,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.word.exampleSentence,
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.word.emoji, style: const TextStyle(fontSize: 64)),
                  const SizedBox(height: 12),
                  Text(
                    widget.word.english,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  IconButton(
                    onPressed: widget.onSpeak,
                    icon: const Icon(
                      Icons.volume_up_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
