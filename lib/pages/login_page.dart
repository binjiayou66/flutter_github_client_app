import 'package:flutter/material.dart';
import 'package:flutter_github_client_app/common/git_service.dart';
import 'package:flutter_github_client_app/models/index.dart';
import 'package:flutter_github_client_app/states/profile_data.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('登录'),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            TextField(
              controller: _controller,
            ),
            RaisedButton(
              child: Text('登录'),
              onPressed: _login,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _login() async {
    User user;
    try {
      user = await GitService().loadUserData(_controller.text);
      Provider.of<UserData>(context, listen: false).user = user;
    } catch (e) {
      print(e);
    } finally {
      Navigator.pop(context);
    }
  }
}
