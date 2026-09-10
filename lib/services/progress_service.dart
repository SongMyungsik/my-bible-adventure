import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_progress.dart';

class ProgressService {
  static const _storageKey = 'user_progress_v1';

  Future<UserProgress> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return UserProgress();
    try {
      return UserProgress.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return UserProgress();
    }
  }

  Future<void> save(UserProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(progress.toJson()));
  }
}
