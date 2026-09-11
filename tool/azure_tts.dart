// Shared Azure AI Speech (Text-to-Speech) helper used by the various
// tool/generate_*.dart scripts.

import 'dart:convert';
import 'dart:io';

Future<List<int>> synthesizeSpeech(
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
