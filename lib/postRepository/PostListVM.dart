import 'package:famewall/api/ApiResponse.dart';
import 'package:famewall/postRepository/PostMain.dart';
import 'package:flutter/cupertino.dart';

import 'PostRepoImp.dart';

class PostListVM extends ChangeNotifier {
  final _myRepo = PostRepoImp();

  ApiResponse<PostMain> movieMain = ApiResponse.loading();

  void _setMovieMain(ApiResponse<PostMain> response) {
    print("MARAJ :: $response");
    movieMain = response;
    notifyListeners();
  }

  Future<void> fetchPost() async {
    _setMovieMain(ApiResponse.loading());
    _myRepo
        .getMoviesList()
        .then((value) => _setMovieMain(ApiResponse.completed(value)))
        .onError((error, stackTrace) => _setMovieMain(ApiResponse.error(error.toString())));
  }
}