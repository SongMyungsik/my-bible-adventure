// Generates narration MP3s from assets/book/book_*.json using Azure AI
// Speech (Text-to-Speech), one clip per line (title or body sentence),
// matching the per-line pages used by lib/data/book_loader.dart.
//
// Setup (once):
//   1. Create/locate an Azure Speech resource in the Azure Portal.
//   2. Set these environment variables in your shell (never commit them):
//        AZURE_SPEECH_KEY=<your key>
//        AZURE_SPEECH_REGION=<e.g. eastus>
//      Optional:
//        AZURE_TTS_VOICE=en-US-AnaNeural   (child-friendly voice, default)
//
// Usage:
//   dart run tool/generate_audio.dart                # all assets/book/book_*.json
//   dart run tool/generate_audio.dart assets/book/book_001.json   # just one file
//
// Output:
//   assets/audio/<book file stem>/001.mp3, 002.mp3, ... - one clip per
//   line (title and each body sentence), numbered sequentially through the
//   whole book (matching lib/data/book_loader.dart's line numbering, not
//   the scene/image numbering). Existing files are skipped, so re-running
//   only fills in new/missing lines.
//
// After generating files for a book the first time, add its folder to
// pubspec.yaml's flutter/assets list, e.g.:
//   assets:
//     - assets/audio/book_001/
// then run `flutter pub get`.

import 'dart:convert';
import 'dart:io';

final _sceneMarker = RegExp(r'^Scene\s*\d+$', caseSensitive: false);

Future<void> main(List<String> args) async {
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

  final bookFiles = args.isNotEmpty
      ? args.map((p) => File(p)).toList()
      : (Directory('assets/book').existsSync()
          ? Directory('assets/book')
              .listSync()
              .whereType<File>()
              .where((f) => f.path.toLowerCase().endsWith('.json'))
              .toList()
          : <File>[]);

  if (bookFiles.isEmpty) {
    stderr.writeln('No book JSON files found. Pass a path or add files under assets/book/.');
    exitCode = 1;
    return;
  }

  final client = HttpClient();
  try {
    for (final file in bookFiles) {
      await _processBook(client, file, key: key, region: region, voice: voice);
    }
  } finally {
    client.close();
  }
  stdout.writeln('Done.');
}

Future<void> _processBook(
  HttpClient client,
  File file, {
  required String key,
  required String region,
  required String voice,
}) async {
  final bookStem = file.uri.pathSegments.last.replaceFirst(RegExp(r'\.json$'), '');
  final lines = _parseLines(jsonDecode(await file.readAsString()) as List);

  stdout.writeln('${file.path} -> ${lines.length} line(s) -> assets/audio/$bookStem/');
  final outDir = Directory('assets/audio/$bookStem')..createSync(recursive: true);

  for (var i = 0; i < lines.length; i++) {
    final number = (i + 1).toString().padLeft(3, '0');
    final outFile = File('${outDir.path}/$number.mp3');
    if (outFile.existsSync()) {
      stdout.writeln('  [$number] exists, skipping');
      continue;
    }
    stdout.writeln('  [$number] synthesizing "${lines[i]}"...');
    final bytes = await _synthesize(
      client,
      key: key,
      region: region,
      voice: voice,
      text: lines[i],
    );
    await outFile.writeAsBytes(bytes);
    stdout.writeln('  [$number] saved (${bytes.length} bytes)');
  }
}

/// Extracts each {"영어", ...} line (skipping "Scene N" markers) in order,
/// mirroring lib/data/book_loader.dart's per-line numbering.
List<String> _parseLines(List<dynamic> entries) {
  final lines = <String>[];
  for (final entry in entries.cast<Map<String, dynamic>>()) {
    final en = (entry['영어'] as String).trim();
    if (_sceneMarker.hasMatch(en)) continue;
    lines.add(en);
  }
  return lines;
}

Future<List<int>> _synthesize(
  HttpClient client, {
  required String key,
  required String region,
  required String voice,
  required String text,
}) async {
  final escaped = text
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&apos;');

  final ssml =
      '<speak version="1.0" xml:lang="en-US">'
      '<voice xml:lang="en-US" name="$voice">$escaped</voice>'
      '</speak>';

  final uri = Uri.parse('https://$region.tts.speech.microsoft.com/cognitiveservices/v1');
  final request = await client.postUrl(uri);
  request.headers.set('Ocp-Apim-Subscription-Key', key);
  request.headers.set('Content-Type', 'application/ssml+xml; charset=utf-8');
  request.headers.set('X-Microsoft-OutputFormat', 'audio-16khz-128kbitrate-mono-mp3');
  request.headers.set('User-Agent', 'my_bible_adventure');
  request.add(utf8.encode(ssml));

  final response = await request.close();
  if (response.statusCode != 200) {
    final body = await response.transform(utf8.decoder).join();
    throw Exception('Azure TTS request failed (${response.statusCode}): $body');
  }

  final bytes = <int>[];
  await for (final chunk in response) {
    bytes.addAll(chunk);
  }
  return bytes;
}
