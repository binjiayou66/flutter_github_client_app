import 'package:flutter/material.dart';
import 'package:flutter_github_client_app/common/git_service.dart';
import 'package:flutter_github_client_app/models/repo.dart';
import 'package:flutter_github_client_app/states/profile_data.dart';
import 'package:flutter_github_client_app/widgets/drawer.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Repo> _repos = [];
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('首页'),
      ),
      body: _body(),
      drawer: _drawer(),
    );
  }

  Widget _body() {
    UserData userData = Provider.of<UserData>(context);
    if (userData.isLogin == false) {
      return Center(
        child: RaisedButton(
          child: Text('登录'),
          onPressed: () {
            Navigator.pushNamed(context, 'login');
          },
        ),
      );
    }
    return FutureBuilder(
      future: GitService().loadRepos(userData.user.login),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        //请求完成
        if (snapshot.connectionState == ConnectionState.done) {
          //发生错误
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          if (_page == 0) _repos.clear();
          _repos.addAll(snapshot.data);
          //请求成功，通过项目信息构建用于显示项目名称的ListView
          return Container(
            color: Color(0xffe9e9e9),
            child: ListView.builder(
              itemCount: _repos.length,
              itemBuilder: (ctx, index) {
                final Repo repo = _repos[index];
                return Container(
                  color: Colors.white,
                  margin: EdgeInsets.only(bottom: 10),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                              child: Text(
                            repo.name ?? '',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff333333),
                            ),
                          )),
                          Text(
                            repo.language ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xff666666),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        repo.description ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xff333333),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '星${repo.stargazers_count}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xff999999),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }
        //请求未完成时弹出loading
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Widget _drawer() {
    return AppDrawer();
  }
}
