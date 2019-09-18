import 'dart:async';

import 'package:flutter/widgets.dart';
import 'localizations.dart';

class GmLocalizationsDelegate extends LocalizationsDelegate<GmLocalizations> {
  const GmLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'zh'].contains(locale.languageCode);

  @override
  Future<GmLocalizations> load(Locale locale) => GmLocalizations.load(locale);

  @override
  bool shouldReload(GmLocalizationsDelegate old) => false;
}
