import 'dart:async';

import 'package:intl/intl.dart';
import 'package:flutter/widgets.dart';

import './messages_all.dart';

class GmLocalizations {
  GmLocalizations(this.locale);

  final Locale locale;

  static Future<GmLocalizations> load(Locale locale) {
    return initializeMessages(locale.toString()).then((void _) {
      return GmLocalizations(locale);
    });
  }

  static GmLocalizations of(BuildContext context) {
    return Localizations.of<GmLocalizations>(context, GmLocalizations);
  }

  String get title =>
      Intl.message('<title>', name: 'title', locale: locale.toString());
  String home(name) => Intl.message('$name',
      name: 'home',
      args: [name],
      desc: 'one desc message',
      locale: locale.toString());
  String get login => Intl.message('<login>',
      name: 'login', desc: 'login button title', locale: locale.toString());

  String theme = "换肤";
  String language = "语言";
  String logout = "登出";
  String logoutTip = "确定要登出？";
  String cancel = "取消";
  String yes = "确定";
  String get noDescription => 'noDescription';
  String get userName => "用户名";
  String get userNameOrEmail => "请输入用户名或邮箱";
  String get userNameRequired => "用户名不能为空";
  String get password => "密码";
  String get passwordRequired => "密码不能为空";
  String get userNameOrPasswordWrong => "用户名或密码错误";
}
