import 'package:flutter/material.dart';
import 'package:flutter_github_client_app/common/global.dart';
import 'package:flutter_github_client_app/states/profile_data.dart';
import 'package:provider/provider.dart';

class ChangeThemePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('主题选择'),
      ),
      body: ListView(
        //显示主题色块
        children: Global.themes.map<Widget>((e) {
          return GestureDetector(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
              child: Container(
                color: e,
                height: 40,
              ),
            ),
            onTap: () {
              //主题更新后，MaterialApp会重新build
              Provider.of<AppThemeData>(context).theme = e;
            },
          );
        }).toList(),
      ),
    );
  }
}
