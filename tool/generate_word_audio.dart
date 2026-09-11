// Generates one narration MP3 per vocabulary word (across every story) using
// Azure AI Speech, so the picture-match game and word book can play the same
// child-friendly voice used for story narration instead of on-device TTS.
//
// Setup: same AZURE_SPEECH_KEY / AZURE_SPEECH_REGION / AZURE_TTS_VOICE
// environment variables as tool/generate_audio.dart.
//
// Usage:
//   dart run tool/generate_word_audio.dart
//
// Output:
//   assets/audio/words/<vocab word id>.mp3 - one clip per unique VocabWord.
//   Existing files are skipped, so re-running only fills in new words.
//
// After the first run, add `- assets/audio/words/` to pubspec.yaml's
// flutter/assets list, then run `flutter pub get`.

import 'dart:io';

import 'package:my_bible_adventure/data/stories_data.dart';
import 'package:my_bible_adventure/models/vocab_word.dart';

import 'azure_tts.dart';

Future<void> main() async {
  final key = Platform.environment['AZURE_SPEECH_KEY'];
  final region = Platform.environment['AZURE_SPEECH_REGION'];
  final voice = Platform.environment['AZURE_TTS_VOICE'] ?? 'en-US-AnaNeural';

  if (key == null || key.isEmpty || region == null || region.isEmpty) {
    stderr.writeln(
      'Missing Azure credentials. Set AZURE_SPEECH_KEY and AZURE_SPEECH_REGION '
      'environment variables first (see the comment at the top of this file).',
    );
    exitCode = 1;
    return;
  }

  final words = <String, VocabWord>{};
  for (final story in bibleStories) {
    for (final word in story.vocabulary) {
      words[word.id] = word;
    }
  }

  stdout.writeln('${words.length} unique word(s) -> assets/audio/words/');
  final outDir = Directory('assets/audio/words')..createSync(recursive: true);

  final client = HttpClient();
  try {
    for (final word in words.values) {
      final outFile = File('${outDir.path}/${word.id}.mp3');
      if (outFile.existsSync()) {
        stdout.writeln('  [${word.id}] exists, skipping');
        continue;
      }
      stdout.writeln('  [${word.id}] synthesizing "${word.english}"...');
      final bytes = await synthesizeSpeech(
        client,
        key: key,
        region: region,
        voice: voice,
        text: word.english,
      );
      await outFile.writeAsBytes(bytes);
      stdout.writeln('  [${word.id}] saved (${bytes.length} bytes)');
    }
  } finally {
    client.close();
  }
  stdout.writeln('Done.');
}
