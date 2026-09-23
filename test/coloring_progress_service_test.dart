import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_bible_adventure/services/coloring_progress_service.dart';

void main() {
  const page = 'assets/coloring/book_001.png';

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('saved fills load back in order, per page', () async {
    final service = ColoringProgressService();
    await service.save(page, [
      (x: 10, y: 20, color: 0xFFFF0000),
      (x: 30, y: 40, color: 0xFF2196F3),
    ]);

    expect(await service.load(page), [
      (x: 10, y: 20, color: 0xFFFF0000),
      (x: 30, y: 40, color: 0xFF2196F3),
    ]);
    expect(await service.load('assets/coloring/book_002.png'), isEmpty);
    expect(await service.startedPages(), {page});
  });

  test('saving no fills forgets the page', () async {
    final service = ColoringProgressService();
    await service.save(page, [(x: 1, y: 1, color: 0xFF000000)]);
    await service.save(page, []);

    expect(await service.load(page), isEmpty);
    expect(await service.startedPages(), isEmpty);
  });
}
