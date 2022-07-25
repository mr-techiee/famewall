
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:famewall/api/ApiResponse.dart';
import 'package:famewall/notification/NotificationWidget.dart';
import '../PrefUtils.dart';
import 'AppException.dart';
import 'BaseApiService.dart';
import 'package:http/http.dart' as http;

import 'LoadingUtils.dart';

class NetworkApiService extends BaseApiService {
@override
  Future deleteResponse(String url, Status status)async {
  dynamic responseJson;
  try {
    print("postRequest");
    print(baseUrl + url);

    print(PreferenceUtils.getString("token",""));
    Map<String, String> requestHeaders = {
      'Accept': 'application/json',
      'auth-key': PreferenceUtils.getString("token","")
    };
    final response = await http.delete(Uri.parse(baseUrl + url),headers: requestHeaders);
    responseJson = returnResponse(response,status);
  } on SocketException {
    throw FetchDataException('No Internet Connection');
  }
  eventBus.fire(responseJson);
  return responseJson;
  }
  @override
  Future getResponse(String url,Status status) async {
    dynamic responseJson;
    try {
      print("postRequest");
      print(baseUrl + url);

      print(PreferenceUtils.getString("token",""));
      Map<String, String> requestHeaders = {
        'Accept': 'application/json',
        'auth-key': PreferenceUtils.getString("token","")
      };
      final response = await http.get(Uri.parse(baseUrl + url),headers: requestHeaders);
      responseJson = returnResponse(response,status);
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    }
    eventBus.fire(responseJson);
    return responseJson;
  }

  @override
  Future postResponse(String url, Map<String, String> jsonBody,Status status) async {
    dynamic responseJson;
    try {
      print("postRequest");
      final response;
      if(status==Status.HAST_LIST||status==Status.POST_MESSAGE||status==Status.UPDATE_PROFILE||status==Status.ADD_STORY||status==Status.SEARCH||status==Status.FOLLOW){
        print(PreferenceUtils.getString("token",""));
        Map<String, String> requestHeaders = {
          'Accept': 'application/json',
          'auth-key': PreferenceUtils.getString("token","")
        };
         response = await http.post(Uri.parse(baseUrl + url),body: jsonBody,headers: requestHeaders);
      }else{
         response = await http.post(Uri.parse(baseUrl + url),body: jsonBody);
      }
      print(baseUrl + url);
      print(jsonBody);
      print("postResponse");
      responseJson = returnResponse(response,status);
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    }
    eventBus.fire(responseJson);
    return responseJson;
  }
  dynamic returnResponse(http.Response response,Status apiName) {
    dynamic responseJson=null;
    String errorMessage="";
    Status status=Status.COMPLETED;
    print("response.statusCode");
    print(response.statusCode);
    switch (response.statusCode) {
      case 200:
         responseJson = jsonDecode(response.body);
        log(responseJson.toString());
         if(Status.LOGIN==apiName||apiName==Status.SIGNUP){
           responseJson=LoginResponse.fromJson(responseJson);
         }else if(apiName==Status.FORGOT_PASSWORD||apiName==Status.UPDATE_PROFILE||apiName==Status.FOLLOW||apiName==Status.UNFOLLOW){
           responseJson=CommonResponse.fromJson(responseJson);
         }else if(apiName==Status.POST_MESSAGE){
           responseJson=PostMessageResponse.fromJson(responseJson);
         }else if(apiName==Status.POST_DETAILS){
           responseJson=PostDetailsList.fromJson(responseJson);
         }else if(apiName==Status.HAST_LIST){
           responseJson=HashPostDetailsList.fromJson(responseJson);
         }else if(apiName==Status.ADD_STORY){
           responseJson=StoryResponse.fromJson(responseJson);
         }else if(apiName==Status.POST_LIST){
           responseJson=PostList.fromJson(responseJson);
         }else if(apiName==Status.TREND_LIST){
           responseJson=TrendList.fromJson(responseJson);
         }else if(apiName==Status.NOTIFICATION_LIST){
           responseJson=NotificationList.fromJson(responseJson);
         }else if(apiName==Status.FOLLOWER_VIDEO){
           responseJson=FollowerVideoList.fromJson(responseJson);
         }else if(apiName==Status.STORY_LIST){
           responseJson=StoryList.fromJson(responseJson);
         }else if(apiName==Status.GET_USER_STORY){
           responseJson=UserStoryList.fromJson(responseJson);
         }else if(apiName==Status.GET_USER_POST){
           responseJson=UserPostList.fromJson(responseJson);
         }else if(apiName==Status.ALL_STORY_LIST){
           responseJson=AllStoryList.fromJson(responseJson);
         }else if(apiName==Status.SEARCH){
           responseJson=SearchList.fromJson(responseJson);
         }else if(apiName==Status.FOLLOWERLIST){
           responseJson=SearchList.fromJson(responseJson);
         }else if(apiName==Status.FOLLOWING_LIST){
           responseJson=FollowingList.fromJson(responseJson);
         }else if(apiName==Status.GET_PROFILE){
           responseJson=UserResponse.fromJson(responseJson);
         }
         errorMessage="success";
         break;
      case 400:
        status=Status.ERROR;
        errorMessage= BadRequestException(response.toString()).toString();
        break;
      case 401:
      case 403:
      status=Status.ERROR;
      errorMessage=  UnauthorisedException(response.body.toString()).toString();
      break;
      case 404:
        status=Status.ERROR;
        errorMessage=  UnauthorisedException(response.body.toString()).toString();
        break;
      case 500:
      default:
      status=Status.ERROR;
      errorMessage=  FetchDataException(
          'Error occured while communication with server' +
              ' with status code : ${response.statusCode}').toString();
      break;
    }
    ApiResponse apiResponse=ApiResponse(status, responseJson, errorMessage);
    return apiResponse;
  }

}