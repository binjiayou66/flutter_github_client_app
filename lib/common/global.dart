import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_github_client_app/models/index.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _themes = [
  Colors.blue,
  Colors.cyan,
  Colors.teal,
  Colors.green,
  Colors.red,
];

class Global {
  static bool get isRelease => bool.fromEnvironment("dart.vm.product");
  static Profile profile = Profile();
  static List<MaterialColor> get themes => _themes;
  static SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    var preferenceProfile = _prefs.getString('profile');
    if (preferenceProfile != null) {
      try {
        profile = Profile.fromJson(jsonDecode(preferenceProfile));
      } catch (e) {
        print(e);
      }
    }
    profile.cache = profile.cache ?? CacheConfig()
      ..enable = true
      ..maxAge = 3600
      ..maxCount = 100;
  }

  static saveProfile() =>
      _prefs.setString('profile', jsonEncode(profile.toJson()));
}
