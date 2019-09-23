import 'package:flutter/material.dart';
import 'package:flutter_github_client_app/states/profile_data.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildHeader(), //构建抽屉菜单头部
            Expanded(child: _buildMenus()), //构建功能菜单
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<UserData>(
      builder: (BuildContext context, UserData value, Widget child) {
        return GestureDetector(
          child: Container(
            color: Theme.of(context).primaryColor,
            padding: EdgeInsets.only(top: 60, bottom: 20),
            child: Container(
              height: 80,
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ClipOval(
                      // 如果已登录，则显示用户头像；若未登录，则显示默认头像
                      child: value.isLogin
                          ? Image.network(value.user.avatar_url, width: 80)
                          : Image.asset(
                              "images/defualt_avatar.jpeg",
                              width: 80,
                            ),
                    ),
                  ),
                  Text(
                    value.isLogin ? value.user.login : '登录',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),
          ),
          onTap: () {
            if (!value.isLogin) Navigator.of(context).pushNamed("login");
          },
        );
      },
    );
  }

  // 构建菜单项
  Widget _buildMenus() {
    return Consumer<UserData>(
      builder: (BuildContext context, UserData userModel, Widget child) {
        return ListView(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.color_lens),
              title: Text('换肤'),
              onTap: () => Navigator.pushNamed(context, "theme"),
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text('语言'),
              onTap: () => Navigator.pushNamed(context, "language"),
            ),
            if (userModel.isLogin)
              ListTile(
                leading: const Icon(Icons.power_settings_new),
                title: Text('登出'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) {
                      //退出账号前先弹二次确认窗
                      return AlertDialog(
                        content: Text('确认要登出？'),
                        actions: <Widget>[
                          FlatButton(
                            child: Text('取消'),
                            onPressed: () => Navigator.pop(context),
                          ),
                          FlatButton(
                            child: Text('确认'),
                            onPressed: () {
                              userModel.user = null;
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
          ],
        );
      },
    );
  }
}
