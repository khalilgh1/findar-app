import 'dart:convert';

import 'package:findar/core/repositories/auth_repository.dart' show User;
import 'package:shared_preferences/shared_preferences.dart';

/// Simple local user cache backed by SharedPreferences.
/// Stores the current user plus saved listing IDs
/// so the app can recover state while offline.
class LocalUserStore {
  static const _userKey = 'local_user';
  static const _savedIdsKey = 'saved_listing_ids';
  static const _currentUserIdKey = 'current_user_id';

  LocalUserStore();

  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    await prefs.setInt(_currentUserIdKey, user.id);
  }

  Future<User?> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userKey);
    if (raw == null) return null;
    try {
      return User.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      // Corrupted prefs
      return null;
    }
  }

  Future<int?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_currentUserIdKey);
  }

  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_currentUserIdKey);
  }

  /// Quickly seeds a cached user for offline testing without
  /// going through login. Safe to call multiple times; values are replaced.
  Future<User> seedDebugUser({
    int id = 9999,
    String name = 'Debug Tester',
    String email = 'debug.tester@findar.app',
    String phone = '+10000000000',
    String? profilePic = 'https://i.pravatar.cc/150?img=12',
    String accountType = 'seller',
    int credits = 120,
    Set<int> savedIds = const {1, 2, 3},
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // If a user already exists in prefs, keep it and don't overwrite saved IDs
    final existingRaw = prefs.getString(_userKey);
    if (existingRaw != null) {
      try {
        final existingUser =
            User.fromJson(jsonDecode(existingRaw) as Map<String, dynamic>);
        return existingUser;
      } catch (_) {
        // fall through to re-seed if corrupted
      }
    }

    final user = User(
      id: id,
      username: name,
      email: email,
      phone: phone,
      profilePic: profilePic,
      accountType: accountType,
      credits: credits,
    );

    // Persist user in SharedPreferences
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    await prefs.setInt(_currentUserIdKey, user.id);

    // Seed saved listings so UI has data to show offline
    await saveSavedIds(savedIds);

    return user;
  }

  Future<Set<int>> loadSavedIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_savedIdsKey) ?? <String>[];
    return list.map(int.parse).toSet();
  }

  Future<void> saveSavedIds(Set<int> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _savedIdsKey,
      ids.map((e) => e.toString()).toList(),
    );
  }
}
