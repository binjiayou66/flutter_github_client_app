import 'package:flutter/material.dart';
import 'package:flutter_github_client_app/states/profile_data.dart';
import 'package:provider/provider.dart';

class ChangeLocalePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var color = Theme.of(context).primaryColor;
    var localeModel = Provider.of<AppLocaleData>(context);
    //var gm = GmLocalizations.of(context);
    //构建语言选择项
    Widget _buildLanguageItem(String lan, value) {
      return ListTile(
        title: Text(
          lan,
          // 对APP当前语言进行高亮显示
          style: TextStyle(color: localeModel.locale == value ? color : null),
        ),
        trailing:
            localeModel.locale == value ? Icon(Icons.done, color: color) : null,
        onTap: () {
          // 更新locale后MaterialApp会重新build
          localeModel.locale = value;
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('语言设置'),
      ),
      body: ListView(
        children: <Widget>[
          _buildLanguageItem("中文简体", "zh_CN"),
          _buildLanguageItem("English", "en_US"),
        ],
      ),
    );
  }
}
