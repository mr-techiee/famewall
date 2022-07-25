
import 'package:famewall/api/ApiResponse.dart';

abstract class BaseApiService{
  final String baseUrl = "http://3.110.176.237:3000/";
  Future<dynamic> getResponse(String endPoint,Status status);
  Future<dynamic> postResponse(String endPoint,Map<String, String> jsonBody,Status status);
  Future<dynamic> deleteResponse(String endPoint,Status status);

}