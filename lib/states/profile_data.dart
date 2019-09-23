import 'package:flutter/material.dart';
import 'package:flutter_github_client_app/common/global.dart';
import 'package:flutter_github_client_app/models/index.dart';
import 'package:flutter_github_client_app/models/profile.dart';

class ProfileData extends ChangeNotifier {
  Profile get _profile => Global.profile;

  @override
  void notifyListeners() {
    Global.saveProfile();
    super.notifyListeners();
  }
}

class UserData extends ProfileData {
  User get user => _profile.user;

  bool get isLogin => user != null;

  set user(User user) {
    if (user?.login != _profile.user?.login) {
      _profile.lastLogin = _profile.user?.login;
      _profile.user = user;

      notifyListeners();
    }
  }
}

class AppThemeData extends ProfileData {
  ColorSwatch get theme => Global.themes
      .firstWhere((e) => e.value == _profile.theme, orElse: () => Colors.blue);

  set theme(ColorSwatch color) {
    if (color != theme) {
      _profile.theme = color[500].value;
      notifyListeners();
    }
  }
}

class AppLocaleData extends ProfileData {
  String get locale => _profile.locale;

  Locale getLocale() {
    if (_profile.locale == null) return null;
    var t = _profile.locale.split('_');
    if (t.length < 2) return null;
    return Locale(t[0], t[1]);
  }

  set locale(String locale) {
    if (locale != _profile.locale) {
      _profile.locale = locale;
      notifyListeners();
    }
  }
}
