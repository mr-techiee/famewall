import 'package:famewall/api/ApiResponse.dart';
import 'package:famewall/api/BaseApiService.dart';
import 'package:famewall/api/NetworkApiService.dart';
import 'package:famewall/postRepository/PostMain.dart';
import 'package:famewall/postRepository/PostRepository.dart';

class PostRepoImp implements PosRepo{

  BaseApiService _apiService = NetworkApiService();

  @override
  Future<PostMain?> getMoviesList() async {
    try {
      dynamic response = await _apiService.getResponse("",Status.Success);
      print("MARAJ $response");
      final jsonData = PostMain.fromJson(response);
      return jsonData;
    } catch (e) {
      throw e;
      print("MARAJ-E $e}");
    }
  }

}