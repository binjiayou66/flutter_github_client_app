import 'package:dio/dio.dart';
import 'package:flutter_github_client_app/models/index.dart';

class GitService {
  static Dio dio = Dio(BaseOptions(baseUrl: 'https://api.github.com/'));

  Future<User> loadUserData(String userName) async {
    final result = await dio.get('/users/$userName');
    return User.fromJson(result.data);
  }

  Future<List<Repo>> loadRepos(
    String userName, {
    int page = 0,
    int pageSize = 20,
  }) async {
    final result = await dio.get(
      'users/$userName/repos',
      queryParameters: {'page': page, 'page_size': pageSize},
    );
    List<Repo> r = [];
    for (var item in result.data) {
      r.add(Repo.fromJson(item));
    }
    return r;
  }
}
