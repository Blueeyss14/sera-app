import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/patient_models.dart';

class SessionService extends GetxService {
  static SessionService get to => Get.find<SessionService>();

  final RxnString token = RxnString();
  final Rxn<AuthUser> user = Rxn<AuthUser>();

  bool get isLoggedIn => token.value != null && token.value!.isNotEmpty;

  static const String _keyToken = 'sera_auth_token';
  static const String _keyUser = 'sera_auth_user';

  Future<SessionService> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString(_keyToken);
    final savedUserJson = prefs.getString(_keyUser);

    if (savedToken != null && savedToken.isNotEmpty) {
      token.value = savedToken;
    }
    if (savedUserJson != null && savedUserJson.isNotEmpty) {
      try {
        final decoded = jsonDecode(savedUserJson) as Map<String, dynamic>;
        user.value = AuthUser.fromJson(decoded);
      } catch (_) {}
    }

    return this;
  }

  Future<void> saveSession(AuthUser authUser, String authToken) async {
    final prefs = await SharedPreferences.getInstance();
    token.value = authToken;
    user.value = authUser;

    await prefs.setString(_keyToken, authToken);
    await prefs.setString(_keyUser, jsonEncode(authUser.toJson()));
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    token.value = null;
    user.value = null;

    await prefs.remove(_keyToken);
    await prefs.remove(_keyUser);
  }
}

