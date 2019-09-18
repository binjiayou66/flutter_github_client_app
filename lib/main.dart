import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_github_client_app/routes/language.dart';
import 'package:flutter_github_client_app/routes/login.dart';
import 'package:flutter_github_client_app/routes/theme_change.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'common/global.dart';
import 'common/network.dart';
import 'l10n/index.dart';
import 'models/index.dart';
import 'states/profile_change_notifier.dart';

void main() => Global.init().then((e) {
      runApp(MultiProvider(
        providers: <SingleChildCloneableWidget>[
          ChangeNotifierProvider.value(value: ThemeModel()),
          ChangeNotifierProvider.value(value: UserModel()),
          ChangeNotifierProvider.value(value: LocaleModel()),
        ],
        child: MyApp(),
      ));
    });

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeModel, LocaleModel>(
        builder: (BuildContext context, themeModel, localeModel, Widget child) {
      return MaterialApp(
          theme: ThemeData(
            primarySwatch: themeModel.theme,
          ),
          onGenerateTitle: (context) {
            return GmLocalizations.of(context).title;
          },
          locale: localeModel
              .getLocale(), //Not use system language to chanage when is not null.
          //We only supper english and chinese language.
          supportedLocales: [
            const Locale('en', 'US'), // English
            const Locale('zh', 'CN'), // Chinese
            //Other Locales
          ],
          localizationsDelegates: [
            // Location delegate class
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GmLocalizationsDelegate()
          ],
          //Listen system language
          localeResolutionCallback:
              (Locale _locale, Iterable<Locale> supportedLocales) {
            if (localeModel.getLocale() != null) {
              //Not use system language when profile have a set locale property.
              return localeModel.getLocale();
            } else {
              Locale locale;
              //APP use system language to change.
              //Set locale is en while system language is not english or chinese.
              if (supportedLocales.contains(_locale)) {
                locale = _locale;
              } else {
                locale = Locale('en', 'US');
              }
              return locale;
            }
          },
          home: HomeRoute(), //App home entry
          routes: <String, WidgetBuilder>{
            "login": (context) => LoginRoute(),
            "themes": (context) => ThemeChangeRoute(),
            "language": (context) => LanguageRoute(),
          });
    });
  }
}

class HomeRoute extends StatefulWidget {
  @override
  _HomeRouteState createState() {
    return _HomeRouteState();
  }
}

class _HomeRouteState extends State<HomeRoute> {
  int _page = 1;
  final _pageSize = 5;
  bool _showPullUp = true;
  List<Repo> items = [];
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  void _onRefresh() async {
    var data = await Git(context).getRepos(
      refresh: true,
      queryParameters: {
        'page': 1,
        'per_page': _pageSize,
      },
    );

    print('refresh : ${data.length}');

    if (data != null) {
      _page = 1;

      //Add data to items.
      items.removeRange(0, items.length);
      items.addAll(data);

      setState(() {});

      if (data.length == _pageSize) {
        _showPullUp = true;
      } else {
        _showPullUp = false;
      }
    }

    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    var data = await Git(context).getRepos(
      refresh: true,
      queryParameters: {
        'page': _page + 1,
        'per_page': _pageSize,
      },
    );

    print('load more: ${data.length}');

    if (data.length > 0) {
      //Add data to items.
      items.addAll(data);
      setState(() {});

      _page += 1;

      if (data.length == _pageSize) {
        _showPullUp = true;
      } else {
        _showPullUp = false;
      }
    } else if (data != null) {
      _showPullUp = false;
    }

    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(GmLocalizations.of(context).home("Git")),
      ),
      body: _buildBody(),
      drawer: MyDrawer(),
    );
  }

  Widget _buildBody() {
    UserModel userModel = Provider.of<UserModel>(context);

    //Show login button when is not log in.
    if (!userModel.isLogin) {
      return Center(
        child: RaisedButton(
            child: Text(GmLocalizations.of(context).login),
            onPressed: () => Navigator.of(context).pushNamed('login')),
      );
    } else {
      return SmartRefresher(
        enablePullDown: true,
        enablePullUp: _showPullUp,
        header: WaterDropHeader(),
        footer: CustomFooter(
          builder: (BuildContext context, LoadStatus mode) {
            Widget body;
            if (mode == LoadStatus.idle) {
              body = Text("上拉加载");
            } else if (mode == LoadStatus.loading) {
              body = CupertinoActivityIndicator();
            } else if (mode == LoadStatus.failed) {
              body = Text("加载失败！点击重试！");
            } else {
              body = Text("没有更多数据了!");
            }
            return Container(
              height: 55.0,
              child: Center(child: body),
            );
          },
        ),
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: ListView.builder(
          itemBuilder: (c, i) => RepoItem(items.length > 0 ? items[i] : null),
//          itemExtent: 100.0,
          itemCount: items.length > 0 ? items.length : 1,
        ),
      );
    }
  }
}

class RepoItem extends StatefulWidget {
  // 将`repo.id`作为RepoItem的默认key
  RepoItem(this.repo) : super(key: ValueKey(repo.id));

  final Repo repo;

  @override
  _RepoItemState createState() => _RepoItemState();
}

class _RepoItemState extends State<RepoItem> {
  @override
  Widget build(BuildContext context) {
    var subtitle;
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Material(
        color: Colors.white,
        shape: BorderDirectional(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: .5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 0.0, bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ListTile(
                dense: true,
                leading: Image.network(
                  widget.repo.owner.avatar_url,
                  width: 24.0,
                ),
                title: Text(
                  widget.repo.owner.login,
                  textScaleFactor: .9,
                ),
                subtitle: subtitle,
                trailing: Text(widget.repo.language ?? ""),
              ),
              // 构建项目标题和简介
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.repo.fork
                          ? widget.repo.full_name
                          : widget.repo.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        fontStyle: widget.repo.fork
                            ? FontStyle.italic
                            : FontStyle.normal,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 12),
                      child: widget.repo.description == null
                          ? Text(
                              GmLocalizations.of(context).noDescription,
                              style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey[700]),
                            )
                          : Text(
                              widget.repo.description,
                              maxLines: 3,
                              style: TextStyle(
                                height: 1.15,
                                color: Colors.blueGrey[700],
                                fontSize: 13,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              // 构建卡片底部信息
              _buildBottom()
            ],
          ),
        ),
      ),
    );
  }

  // 构建卡片底部信息
  Widget _buildBottom() {
    const paddingWidth = 10;
    return IconTheme(
      data: IconThemeData(
        color: Colors.grey,
        size: 15,
      ),
      child: DefaultTextStyle(
        style: TextStyle(color: Colors.grey, fontSize: 12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Builder(builder: (context) {
            var children = <Widget>[
              Icon(Icons.star),
              Text(" " +
                  widget.repo.stargazers_count
                      .toString()
                      .padRight(paddingWidth)),
              Icon(Icons.info_outline),
              Text(" " +
                  widget.repo.open_issues_count
                      .toString()
                      .padRight(paddingWidth)),

              Icon(Icons.play_for_work), //我们的自定义图标
              Text(widget.repo.forks_count.toString().padRight(paddingWidth)),
            ];

            if (widget.repo.fork) {
              children.add(Text("Forked".padRight(paddingWidth)));
            }

            if (widget.repo.private == true) {
              children.addAll(<Widget>[
                Icon(Icons.lock),
                Text(" private".padRight(paddingWidth))
              ]);
            }
            return Row(children: children);
          }),
        ),
      ),
    );
  }
}

class MyDrawer extends StatelessWidget {
  const MyDrawer({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      //移除顶部padding
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
    return Consumer<UserModel>(
      builder: (BuildContext context, UserModel value, Widget child) {
        return GestureDetector(
          child: Container(
            color: Theme.of(context).primaryColor,
            padding: EdgeInsets.only(top: 40, bottom: 20),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ClipOval(
                    // 如果已登录，则显示用户头像；若未登录，则显示默认头像
                    child: value.isLogin
                        ? Image.network(value.user.avatar_url, width: 80.0)
                        : Image.asset(
                            "imgs/avatar-default.png",
                            width: 80,
                          ),
                  ),
                ),
                Text(
                  value.isLogin
                      ? value.user.login
                      : GmLocalizations.of(context).login,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )
              ],
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
    return Consumer<UserModel>(
      builder: (BuildContext context, UserModel userModel, Widget child) {
        var gm = GmLocalizations.of(context);
        return ListView(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.color_lens),
              title: Text(gm.theme),
              onTap: () => Navigator.pushNamed(context, "themes"),
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(gm.language),
              onTap: () => Navigator.pushNamed(context, "language"),
            ),
            if (userModel.isLogin)
              ListTile(
                leading: const Icon(Icons.power_settings_new),
                title: Text(gm.logout),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) {
                      //退出账号前先弹二次确认窗
                      return AlertDialog(
                        content: Text(gm.logoutTip),
                        actions: <Widget>[
                          FlatButton(
                            child: Text(gm.cancel),
                            onPressed: () => Navigator.pop(context),
                          ),
                          FlatButton(
                            child: Text(gm.yes),
                            onPressed: () {
                              //该赋值语句会触发MaterialApp rebuild
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
