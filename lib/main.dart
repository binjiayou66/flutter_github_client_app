import 'package:flutter/material.dart';
import 'package:flutter_github_client_app/common/global.dart';
import 'package:flutter_github_client_app/pages/change_locale_page.dart';
import 'package:flutter_github_client_app/pages/change_theme_page.dart';
import 'package:flutter_github_client_app/pages/home_page.dart';
import 'package:flutter_github_client_app/pages/login_page.dart';
import 'package:provider/provider.dart';

import 'states/profile_data.dart';

Future main() async {
  await Global.init();
  runApp(MultiProvider(
    providers: <SingleChildCloneableWidget>[
      ChangeNotifierProvider.value(value: AppThemeData()),
      ChangeNotifierProvider.value(value: UserData()),
      ChangeNotifierProvider.value(value: AppLocaleData()),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<AppThemeData, AppLocaleData>(
      builder: (BuildContext context, AppThemeData appThemeData,
          AppLocaleData appLocaleData, Widget child) {
        return MaterialApp(
          home: HomePage(), //App home entry
          routes: <String, WidgetBuilder>{
            "login": (context) => LoginPage(),
            "theme": (context) => ChangeThemePage(),
            "language": (context) => ChangeLocalePage(),
          },
          theme: ThemeData(
            primarySwatch: appThemeData.theme,
          ),
        );
      },
    );
  }
}
