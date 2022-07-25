import 'dart:io';

import 'package:famewall/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as Path;
import 'package:photo_manager/photo_manager.dart';

class ApiResponse<T> {
  Status? status;
  T? data;
  String? message;

  ApiResponse(this.status, this.data, this.message);

  ApiResponse.loading() : status = Status.LOADING;

  ApiResponse.completed(this.data) : status = Status.COMPLETED;

  ApiResponse.error(this.message) : status = Status.ERROR;

  @override
  String toString() {
    return "Status : $status \n Message : $message \n Data : $data";
  }
}

enum Status {
  LOADING,
  COMPLETED,
  ERROR,
  LOGIN,
  SIGNUP,
  FORGOT_PASSWORD,
  Success,
  POST_MESSAGE,
  Error,
  Cancelled,
  POST_LIST,
  GET_PROFILE,
  UPDATE_PROFILE,
  ADD_STORY,
  STORY_LIST,
  ALL_STORY_LIST,
  SEARCH,
  FOLLOW,
  UNFOLLOW,
  GET_USER_STORY,
  GET_USER_POST,
  FOLLOWERLIST,
  FOLLOWING_LIST,
  POST_DETAILS,TREND_LIST,FOLLOWER_VIDEO,NOTIFICATION_LIST,HAST_LIST,
  REFRESH
}

class StoryResponse {
  bool? iserror = false;
  String? message = "";
  String? storyId = "";

  StoryResponse.fromJson(Map<String, dynamic> json) {
    iserror = json["iserror"];
    message = json["message"];
    if (!iserror!) {
      storyId = json["data"]["storyId"];
    }
  }
}

class PostMessageResponse {
  bool? iserror = false;
  String? message = "";
  String? postId = "";

  PostMessageResponse.fromJson(Map<String, dynamic> json) {
    iserror = json["iserror"];
    message = json["message"];
    if (!iserror!) {
      postId = json["data"]["postId"];
    }
  }
}

class LoginResponse {
  bool? iserror = false;
  String? message = "";
  String? userToken = "";
  String? userid = "";
  String? firstname = "";
  String? lastname = "";
  String? username = "";
  String? email = "";
  String? mobileno = "";
  String? profileimage = "";

  LoginResponse.fromJson(Map<String, dynamic> json) {
    iserror = json["iserror"];
    message = json["message"];
    if (!iserror!) {
      userToken = json["data"]["userToken"];
      userid = json["data"]["userid"];
      firstname = json["data"]["firstname"];
      lastname = json["data"]["lastname"];
      email = json["data"]["email"];
      mobileno = json["data"]["mobileno"];
      profileimage = json["data"]["profileimage"];
      username = json["data"]["username"];
    }
  }
}

class SavedFileList {
  File? file;
  File? savedFile;
}
class TrendList {
  bool? iserror = false;
  String? message = "";
  List<PostObject> postList = [];

  TrendList.fromJson(Map<String, dynamic> json) {
    iserror = json["iserror"];
    message = json["message"];
    if (!iserror!) {
      if (json["data"] != null && json["data"].length > 0) {
        var list = json["data"];
        for (int i = 0; i < list.length; i++) {
          PostObject postObject = PostObject();
          postObject._id = list[i]["_id"];
          postObject.postid = list[i]["postid"];
          postObject.message = list[i]["message"];
          postObject.filepath = list[i]["filepath"];
          postObject.is_liked = list[i]["is_liked"]!=null?list[i]["is_liked"]:"";
          postObject.liketype = list[i]["liketype"]!=null?list[i]["liketype"]:"";
          final extension = Path.extension(list[i]["filepath"]);
          if (extension.contains(".jpg") ||
              extension.contains(".png") ||
              extension.contains(".jpeg")) {
            postObject.isImage = true;
          }
          if(list[i]["liked_users"]!=null&&list[i]["liked_users"].length>0){
            List<LikeUserObject>likeUserList=[];
            for(int j=0;j<list[i]["liked_users"].length;j++){
              LikeUserObject likeUserObject=new LikeUserObject();
              likeUserObject.firstname=list[i]["liked_users"][j]["firstname"];
              likeUserObject.userName=list[i]["liked_users"][j]["username"];
              likeUserObject.userid=list[i]["liked_users"][j]["userid"];
              likeUserObject.profileimage=list[i]["liked_users"][j]["profileimage"];
              likeUserList.add(likeUserObject);
            }
            postObject.liked_users=likeUserList;
          }
          List<ImageObject> imageList = [];
          for (int k = 0; k < list[i]["file_details"].length; k++) {
            ImageObject imageObject = ImageObject();
            List<TaggedObject>tList=[];
            if(list[i]["file_details"][k]["tags"]!=null&&list[i]["file_details"][k]["tags"].length>0){
              for(int tag=0;tag<list[i]["file_details"][k]["tags"].length;tag++){
                var tagObject=list[i]["file_details"][k]["tags"][tag];
                TaggedObject taggedObject=new TaggedObject();
                taggedObject.postid=tagObject["postid"];
                taggedObject._id=tagObject["_id"];
                taggedObject.taggedtext=tagObject["taggedtext"];
                taggedObject.imageposition=tagObject["imageposition"];
                taggedObject.postfileid=tagObject["postfileid"];
                if(tagObject["taggeduserid"]!=null){
                  TaggedUserObject taggedUserObject=new TaggedUserObject();
                  taggedUserObject.email=tagObject["taggeduserid"]["email"];
                  taggedUserObject.lastname=tagObject["taggeduserid"]["lastname"];
                  taggedUserObject.firstname=tagObject["taggeduserid"]["firstname"];
                  taggedUserObject.profileimage=tagObject["taggeduserid"]["profileimage"];
                  taggedUserObject.username=tagObject["taggeduserid"]["username"];
                  taggedUserObject._id=tagObject["taggeduserid"]["_id"];
                  taggedObject.taggeduserid=taggedUserObject;
                }

                tList.add(taggedObject);
              }
            }
            imageObject.taggedList=tList;
            final extension =
            Path.extension(list[i]["file_details"][k]["filepath"]);
            print(extension);
            imageObject.liked = list[i]["file_details"][k]["liked"].toString();
            imageObject.favourite =
                list[i]["file_details"][k]["favourite"].toString();
            imageObject.starred =
                list[i]["file_details"][k]["starred"].toString();
            imageObject.shared =
                list[i]["file_details"][k]["shared"].toString();
            imageObject.status =
                list[i]["file_details"][k]["status"].toString();
            imageObject.createdby =
                list[i]["file_details"][k]["createdby"].toString();
            if (extension == ".jpg" ||
                extension == ".png" ||
                extension == ".jpeg") {
              imageObject.isImage = true;
            }
            imageObject.filePath = list[i]["file_details"][k]["filepath"];
            imageList.add(imageObject);
            print("moreVideos");
            print(imageObject.filePath);
            print("dateTime");
            print(list[i]["file_details"][k]["createdon"]);
            var dateTime=DateFormat("yyyy-MM-ddTHH:mm:sssZ").parse(list[i]["file_details"][k]["createdon"],true);
            var outputFormat = DateFormat('yyyy-MM-dd HH:mm.ss');
            var outputDate = outputFormat.format(dateTime.toLocal());
            postObject.createdOn=Utils.calculateTimeDifferenceBetween(startDate: outputFormat.parse(outputDate), endDate: DateFormat("yyyy-MM-dd HH:mm.ss").parse(DateFormat("yyyy-MM-dd HH:mm.ss").format(DateTime.now()))).replaceAll("-", "");
          }
          postObject.imageList = imageList;
          print("imageSize");
          print(postObject.imageList!.length.toString());
          postObject.liked = list[i]["like_normal"]==null?"0":list[i]["like_normal"].toString();
          postObject.favourite =  list[i]["like_heart"]==null?"0":list[i]["like_heart"].toString();
          postObject.starred = list[i]["like_star"]==null?"0":list[i]["like_star"].toString();
          postObject.shared = list[i]["shared"]==null?"":list[i]["shared"].toString();
          postObject.status = list[i]["status"].toString();
          postObject.createdby = list[i]["createdby"].toString();
          postObject.__v = list[i]["__v"].toString();
          num tLikedCount = 0;
         if(list[i]["like_normal"]!=null){
          tLikedCount=tLikedCount + list[i]["like_normal"];
          }
          if(list[i]["like_heart"]!=null){
          tLikedCount=tLikedCount+list[i]["like_heart"];
          }
          if(list[i]["like_star"]!=null){
          tLikedCount=tLikedCount+list[i]["like_star"];
           }
          postObject.totalLikedCount = tLikedCount.toInt();
          postObject.location =
          list[i]["location"] == null ? "" : list[i]["location"].toString();
          postObject.bio =
          list[i]["bio"] == null ? "" : list[i]["bio"].toString();
          postObject.website =
          list[i]["website"] == null ? "" : list[i]["website"].toString();
          if (list[i]["userdetail"] != null) {
            postObject.firstname = list[i]["userdetail"]["firstname"];
            postObject.lastname = list[i]["userdetail"]["lastname"];
            postObject.email = list[i]["userdetail"]["email"];
            postObject.profileimage = list[i]["userdetail"]["profileimage"];
            postObject.username = list[i]["userdetail"]["username"];
            postObject.follower = list[i]["userdetail"]["follower"].toString();
            postObject.following =
                list[i]["userdetail"]["following"].toString();
            postObject.userid = list[i]["userdetail"]["userid"];
            postObject.is_followed = list[i]["userdetail"]["is_followed"];
          }
          if (imageList.length > 0) {
            postList.add(postObject);
          }
        }
      }
    }
  }
}
class FollowerVideoObject{
  String filepath="";
  String _id="";
  String firstname="";
  String username="";
  String email="";
  String profileimage="";
}
class FollowerVideoList {
  bool? iserror = false;
  String? message = "";
  List<FollowerVideoObject> followerVideoList = [];

  FollowerVideoList.fromJson(Map<String, dynamic> json) {
    iserror = json["iserror"];
    message = json["message"];
    if (!iserror!) {
      if (json["data"] != null && json["data"].length > 0) {
        var list = json["data"];
        for (int i = 0; i < list.length; i++) {
          FollowerVideoObject postObject = FollowerVideoObject();
          postObject._id = list[i]["_id"];
          postObject.filepath = list[i]["filepath"];
          postObject.firstname = list[i]["createdby"]["firstname"];
          postObject.username = list[i]["createdby"]["username"];
          postObject.email = list[i]["createdby"]["email"];
          postObject.profileimage = list[i]["createdby"]["profileimage"];
          followerVideoList.add(postObject);

        }
      }
    }
  }
}
class HashPostDetailsList {
  bool? iserror = false;
  String? message = "";
  List<PostObject> postList = [];

  HashPostDetailsList.fromJson(Map<String, dynamic> json) {
    iserror = json["iserror"];
    message = json["message"];
    if (!iserror!) {
      if (json["data"] != null && json["data"].length > 0) {
        var list = json["data"];
        for (int i = 0; i < list.length; i++) {
          var postJsonObject=list[i]["postdetails"];
          PostObject postObject = PostObject();
          postObject._id = list[i]["_id"];
          postObject.postid = postJsonObject["postid"];
          postObject.message = postJsonObject["message"];
          postObject.filepath = postJsonObject["filepath"];
          postObject.is_liked =postJsonObject["is_liked"];
          postObject.liketype =postJsonObject["liketype"];
          final extension = Path.extension(postJsonObject["filepath"]);
          if (extension.contains(".jpg") ||
              extension.contains(".png") ||
              extension.contains(".jpeg")) {
            postObject.isImage = true;
          }
          if(postJsonObject["liked_users"].length>0){
            List<LikeUserObject>likeUserList=[];
            for(int j=0;j<postJsonObject["liked_users"].length;j++){
              LikeUserObject likeUserObject=new LikeUserObject();
              likeUserObject.firstname=postJsonObject["liked_users"][j]["firstname"];
              likeUserObject.userName=postJsonObject["liked_users"][j]["username"];
              likeUserObject.userid=postJsonObject["liked_users"][j]["userid"];
              likeUserObject.profileimage=postJsonObject["liked_users"][j]["profileimage"];
              likeUserList.add(likeUserObject);
            }
            postObject.liked_users=likeUserList;
          }
          List<ImageObject> imageList = [];
          for (int k = 0; k < postJsonObject["file_details"].length; k++) {
            ImageObject imageObject = ImageObject();
            List<TaggedObject>tList=[];
            if(postJsonObject["file_details"][k]["tags"].length>0){
              for(int tag=0;tag<postJsonObject["file_details"][k]["tags"].length;tag++){
                var tagObject=postJsonObject["file_details"][k]["tags"][tag];
                TaggedObject taggedObject=new TaggedObject();
                taggedObject.postid=tagObject["postid"];
                taggedObject._id=tagObject["_id"];
                taggedObject.taggedtext=tagObject["taggedtext"];
                taggedObject.imageposition=tagObject["imageposition"];
                taggedObject.postfileid=tagObject["postfileid"];
                if(tagObject["taggeduserid"]!=null&&tagObject["taggeduserid"].toString().contains("}")){
                  TaggedUserObject taggedUserObject=new TaggedUserObject();
                  taggedUserObject.email=tagObject["taggeduserid"]["email"];
                  taggedUserObject.lastname=tagObject["taggeduserid"]["lastname"];
                  taggedUserObject.firstname=tagObject["taggeduserid"]["firstname"];
                  taggedUserObject.profileimage=tagObject["taggeduserid"]["profileimage"];
                  taggedUserObject.username=tagObject["taggeduserid"]["username"];
                  taggedUserObject._id=tagObject["taggeduserid"]["_id"];
                  taggedObject.taggeduserid=taggedUserObject;
                }
                tList.add(taggedObject);
              }
            }
            if(k==0){
              postObject.taggedList=tList;
            }
            imageObject.taggedList=tList;
            final extension =
            Path.extension(postJsonObject["file_details"][k]["filepath"]);
            print(extension);
            imageObject.liked = postJsonObject["file_details"][k]["liked"].toString();
            imageObject.favourite =
                postJsonObject["file_details"][k]["favourite"].toString();
            imageObject.starred =
                postJsonObject["file_details"][k]["starred"].toString();
            imageObject.shared =
                postJsonObject["file_details"][k]["shared"].toString();
            imageObject.status =
                postJsonObject["file_details"][k]["status"].toString();
            imageObject.createdby =
                postJsonObject["file_details"][k]["createdby"].toString();
            if (extension == ".jpg" ||
                extension == ".png" ||
                extension == ".jpeg") {
              imageObject.isImage = true;
            }
            imageObject.filePath = postJsonObject["file_details"][k]["filepath"];
            imageList.add(imageObject);
            print("moreVideos");
            print(imageObject.filePath);
            var dateTime=DateFormat("yyyy-MM-ddTHH:mm:sssZ").parse(postJsonObject["file_details"][k]["createdon"],true);
            var outputFormat = DateFormat('yyyy-MM-dd HH:mm.ss');
            var outputDate = outputFormat.format(dateTime.toLocal());
            postObject.createdOn=Utils.calculateTimeDifferenceBetween(startDate: outputFormat.parse(outputDate), endDate: DateFormat("yyyy-MM-dd HH:mm.ss").parse(DateFormat("yyyy-MM-dd HH:mm.ss").format(DateTime.now()))).replaceAll("-", "");

          }
          postObject.imageList = imageList;
          print("imageSize");
          print(postObject.imageList!.length.toString());
          postObject.liked =postJsonObject["like_normal"].toString();
          print(postObject.liked);
          num tLikedCount = 0;
          //if(!Utils.isEmpty(list[i]["like_normal"])){
          tLikedCount=tLikedCount + postJsonObject["like_normal"];
          //}
          //if(!Utils.isEmpty(list[i]["like_heart"])){
          tLikedCount=tLikedCount+postJsonObject["like_heart"];
          //}
          //if(!Utils.isEmpty(list[i]["like_star"])){
          tLikedCount=tLikedCount+postJsonObject["like_star"];
          // }
          postObject.totalLikedCount = tLikedCount.toInt();
          postObject.favourite = postJsonObject["like_heart"].toString();
          postObject.starred = postJsonObject["like_star"].toString();
          postObject.shared =postJsonObject["shared"].toString();
          postObject.status = postJsonObject["status"].toString();
          postObject.createdby = postJsonObject["createdby"].toString();
          postObject.__v =postJsonObject["__v"].toString();
          postObject.location =
          postJsonObject["location"] == null ? "" : postJsonObject["location"].toString();
          postObject.bio =
          postJsonObject["bio"] == null ? "" : postJsonObject["bio"].toString();
          postObject.website =
          postJsonObject["website"] == null ? "" : postJsonObject["website"].toString();
          if (postJsonObject["userdetail"] != null) {
            postObject.firstname = postJsonObject["userdetail"]["firstname"];
            postObject.lastname =postJsonObject["userdetail"]["lastname"];
            postObject.email = postJsonObject["userdetail"]["email"];
            postObject.profileimage = postJsonObject["userdetail"]["profileimage"];
            postObject.username = postJsonObject["userdetail"]["username"];
            postObject.follower = postJsonObject["userdetail"]["follower"].toString();
            postObject.following =
                postJsonObject["userdetail"]["following"].toString();
            postObject.userid = postJsonObject["userdetail"]["userid"];
            postObject.is_followed = postJsonObject["userdetail"]["is_followed"];
          }
          if (imageList.length > 0) {
            print("postObject.postid");
            print(postObject.postid);
            postList.add(postObject);
          }
        }
      }
    }
  }
}

class PostDetailsList {
  bool? iserror = false;
  String? message = "";
  List<PostObject> postList = [];

  PostDetailsList.fromJson(Map<String, dynamic> json) {
    iserror = json["iserror"];
    message = json["message"];
    if (!iserror!) {
      if (json["data"] != null && json["data"].length > 0) {
        var list = json["data"];
        for (int i = 0; i < list.length; i++) {
          PostObject postObject = PostObject();
          postObject._id = list[i]["_id"];
          postObject.postid = list[i]["postid"];
          postObject.message = list[i]["message"];
          postObject.filepath = list[i]["filepath"];
          postObject.is_liked = list[i]["is_liked"];
          postObject.liketype = list[i]["liketype"];
          final extension = Path.extension(list[i]["filepath"]);
          if (extension.contains(".jpg") ||
              extension.contains(".png") ||
              extension.contains(".jpeg")) {
            postObject.isImage = true;
          }
          if(list[i]["liked_users"].length>0){
            List<LikeUserObject>likeUserList=[];
            for(int j=0;j<list[i]["liked_users"].length;j++){
              LikeUserObject likeUserObject=new LikeUserObject();
              likeUserObject.firstname=list[i]["liked_users"][j]["firstname"];
              likeUserObject.userName=list[i]["liked_users"][j]["username"];
              likeUserObject.userid=list[i]["liked_users"][j]["userid"];
              likeUserObject.profileimage=list[i]["liked_users"][j]["profileimage"];
              likeUserList.add(likeUserObject);
            }
            postObject.liked_users=likeUserList;
          }
          List<ImageObject> imageList = [];
          for (int k = 0; k < list[i]["file_details"].length; k++) {
            ImageObject imageObject = ImageObject();
            List<TaggedObject>tList=[];
            if(list[i]["file_details"][k]["tags"].length>0){
              for(int tag=0;tag<list[i]["file_details"][k]["tags"].length;tag++){
                var tagObject=list[i]["file_details"][k]["tags"][tag];
                TaggedObject taggedObject=new TaggedObject();
                taggedObject.postid=tagObject["postid"];
                taggedObject._id=tagObject["_id"];
                taggedObject.taggedtext=tagObject["taggedtext"];
                taggedObject.imageposition=tagObject["imageposition"];
                taggedObject.postfileid=tagObject["postfileid"];
                if(tagObject["taggeduserid"]!=null&&tagObject["taggeduserid"].toString().contains("}")){
                  TaggedUserObject taggedUserObject=new TaggedUserObject();
                  taggedUserObject.email=tagObject["taggeduserid"]["email"];
                  taggedUserObject.lastname=tagObject["taggeduserid"]["lastname"];
                  taggedUserObject.firstname=tagObject["taggeduserid"]["firstname"];
                  taggedUserObject.profileimage=tagObject["taggeduserid"]["profileimage"];
                  taggedUserObject.username=tagObject["taggeduserid"]["username"];
                  taggedUserObject._id=tagObject["taggeduserid"]["_id"];
                  taggedObject.taggeduserid=taggedUserObject;
                }
                tList.add(taggedObject);
              }
            }
            if(k==0){
              postObject.taggedList=tList;
            }
            imageObject.taggedList=tList;
            final extension =
            Path.extension(list[i]["file_details"][k]["filepath"]);
            print(extension);
            imageObject.liked = list[i]["file_details"][k]["liked"].toString();
            imageObject.favourite =
                list[i]["file_details"][k]["favourite"].toString();
            imageObject.starred =
                list[i]["file_details"][k]["starred"].toString();
            imageObject.shared =
                list[i]["file_details"][k]["shared"].toString();
            imageObject.status =
                list[i]["file_details"][k]["status"].toString();
            imageObject.createdby =
                list[i]["file_details"][k]["createdby"].toString();
            if (extension == ".jpg" ||
                extension == ".png" ||
                extension == ".jpeg") {
              imageObject.isImage = true;
            }
            imageObject.filePath = list[i]["file_details"][k]["filepath"];
            imageList.add(imageObject);
            print("moreVideos");
            print(imageObject.filePath);
            var dateTime=DateFormat("yyyy-MM-ddTHH:mm:sssZ").parse(list[i]["file_details"][k]["createdon"],true);
            var outputFormat = DateFormat('yyyy-MM-dd HH:mm.ss');
            var outputDate = outputFormat.format(dateTime.toLocal());
            postObject.createdOn=Utils.calculateTimeDifferenceBetween(startDate: outputFormat.parse(outputDate), endDate: DateFormat("yyyy-MM-dd HH:mm.ss").parse(DateFormat("yyyy-MM-dd HH:mm.ss").format(DateTime.now()))).replaceAll("-", "");

          }
          postObject.imageList = imageList;
          print("imageSize");
          print(postObject.imageList!.length.toString());
          postObject.liked = list[i]["like_normal"].toString();
          print(postObject.liked);
          num tLikedCount = 0;
          //if(!Utils.isEmpty(list[i]["like_normal"])){
          tLikedCount=tLikedCount + list[i]["like_normal"];
          //}
          //if(!Utils.isEmpty(list[i]["like_heart"])){
          tLikedCount=tLikedCount+list[i]["like_heart"];
          //}
          //if(!Utils.isEmpty(list[i]["like_star"])){
          tLikedCount=tLikedCount+list[i]["like_star"];
          // }
          postObject.totalLikedCount = tLikedCount.toInt();
          postObject.favourite = list[i]["like_heart"].toString();
          postObject.starred = list[i]["like_star"].toString();
          postObject.shared = list[i]["shared"].toString();
          postObject.status = list[i]["status"].toString();
          postObject.createdby = list[i]["createdby"].toString();
          postObject.__v = list[i]["__v"].toString();
          postObject.location =
          list[i]["location"] == null ? "" : list[i]["location"].toString();
          postObject.bio =
          list[i]["bio"] == null ? "" : list[i]["bio"].toString();
          postObject.website =
          list[i]["website"] == null ? "" : list[i]["website"].toString();
          if (list[i]["userdetail"] != null) {
            postObject.firstname = list[i]["userdetail"]["firstname"];
            postObject.lastname = list[i]["userdetail"]["lastname"];
            postObject.email = list[i]["userdetail"]["email"];
            postObject.profileimage = list[i]["userdetail"]["profileimage"];
            postObject.username = list[i]["userdetail"]["username"];
            postObject.follower = list[i]["userdetail"]["follower"].toString();
            postObject.following =
                list[i]["userdetail"]["following"].toString();
            postObject.userid = list[i]["userdetail"]["userid"];
            postObject.is_followed = list[i]["userdetail"]["is_followed"];
          }
          if (imageList.length > 0) {
            print("postObject.postid");
            print(postObject.postid);
            postList.add(postObject);
          }
        }
      }
    }
  }
}
class PostList {
  bool? iserror = false;
  String? message = "";
  List<PostObject> postList = [];

  PostList.fromJson(Map<String, dynamic> json) {
    iserror = json["iserror"];
    message = json["message"];
    if (!iserror!) {
      if (json["data"] != null && json["data"].length > 0) {
        var list = json["data"];
        for (int i = 0; i < list.length; i++) {
          PostObject postObject = PostObject();
          postObject._id = list[i]["_id"];
          postObject.postid = list[i]["postid"];
          postObject.message = list[i]["message"];
          postObject.filepath = list[i]["filepath"];
          postObject.is_liked = list[i]["is_liked"];
          postObject.liketype = list[i]["liketype"];
          final extension = Path.extension(list[i]["filepath"]);
          if (extension.contains(".jpg") ||
              extension.contains(".png") ||
              extension.contains(".jpeg")) {
            postObject.isImage = true;
          }
          if(list[i]["liked_users"].length>0){
            List<LikeUserObject>likeUserList=[];
            for(int j=0;j<list[i]["liked_users"].length;j++){
              LikeUserObject likeUserObject=new LikeUserObject();
              likeUserObject.firstname=list[i]["liked_users"][j]["firstname"];
              likeUserObject.userName=list[i]["liked_users"][j]["username"];
              likeUserObject.userid=list[i]["liked_users"][j]["userid"];
              likeUserObject.profileimage=list[i]["liked_users"][j]["profileimage"];
              likeUserList.add(likeUserObject);
            }
            postObject.liked_users=likeUserList;
          }
          List<ImageObject> imageList = [];
          for (int k = 0; k < list[i]["file_details"].length; k++) {
            ImageObject imageObject = ImageObject();
            List<TaggedObject>tList=[];
            if(list[i]["file_details"][k]["tags"].length>0){
              for(int tag=0;tag<list[i]["file_details"][k]["tags"].length;tag++){
                var tagObject=list[i]["file_details"][k]["tags"][tag];
                TaggedObject taggedObject=new TaggedObject();
                taggedObject.postid=tagObject["postid"];
                taggedObject._id=tagObject["_id"];
                taggedObject.taggedtext=tagObject["taggedtext"];
                taggedObject.imageposition=tagObject["imageposition"];
                taggedObject.postfileid=tagObject["postfileid"];
                if(tagObject["taggeduserid"]!=null&&tagObject["taggeduserid"].toString().contains("}")){
                  TaggedUserObject taggedUserObject=new TaggedUserObject();
                  taggedUserObject.email=tagObject["taggeduserid"]["email"];
                  taggedUserObject.lastname=tagObject["taggeduserid"]["lastname"];
                  taggedUserObject.firstname=tagObject["taggeduserid"]["firstname"];
                  taggedUserObject.profileimage=tagObject["taggeduserid"]["profileimage"];
                  taggedUserObject.username=tagObject["taggeduserid"]["username"];
                  taggedUserObject._id=tagObject["taggeduserid"]["_id"];
                  taggedObject.taggeduserid=taggedUserObject;
                }
                tList.add(taggedObject);
              }
            }
            if(k==0){
              postObject.taggedList=tList;

            }
            print("dateTime");
            print(list[i]["file_details"][k]["createdon"]);
            var dateTime=DateFormat("yyyy-MM-ddTHH:mm:sssZ").parse(list[i]["file_details"][k]["createdon"],true);
            var outputFormat = DateFormat('yyyy-MM-dd HH:mm.ss');
            var outputDate = outputFormat.format(dateTime.toLocal());
            postObject.createdOn=Utils.calculateTimeDifferenceBetween(startDate: outputFormat.parse(outputDate), endDate: DateFormat("yyyy-MM-dd HH:mm.ss").parse(DateFormat("yyyy-MM-dd HH:mm.ss").format(DateTime.now()))).replaceAll("-", "");

            print(postObject.createdOn);
            imageObject.taggedList=tList;
            final extension =
                Path.extension(list[i]["file_details"][k]["filepath"]);
            print(extension);
            imageObject.liked = list[i]["file_details"][k]["liked"].toString();
            imageObject.favourite =
                list[i]["file_details"][k]["favourite"].toString();
            imageObject.starred =
                list[i]["file_details"][k]["starred"].toString();
            imageObject.shared =
                list[i]["file_details"][k]["shared"].toString();
            imageObject.status =
                list[i]["file_details"][k]["status"].toString();
            imageObject.createdby =
                list[i]["file_details"][k]["createdby"].toString();
            if (extension == ".jpg" ||
                extension == ".png" ||
                extension == ".jpeg") {
              imageObject.isImage = true;
            }
            imageObject.filePath = list[i]["file_details"][k]["filepath"];
            imageList.add(imageObject);
            print("moreVideos");
            print(imageObject.filePath);
          }
          postObject.imageList = imageList;
          print("imageSize");
          print(postObject.imageList!.length.toString());
          postObject.liked = list[i]["like_normal"].toString();
          num tLikedCount = 0;
          //if(!Utils.isEmpty(list[i]["like_normal"])){
            tLikedCount=tLikedCount + list[i]["like_normal"];
          //}
          //if(!Utils.isEmpty(list[i]["like_heart"])){
            tLikedCount=tLikedCount+list[i]["like_heart"];
          //}
          //if(!Utils.isEmpty(list[i]["like_star"])){
            tLikedCount=tLikedCount+list[i]["like_star"];
         // }
          postObject.totalLikedCount = tLikedCount.toInt();
          print(postObject.liked);
          postObject.favourite = list[i]["like_heart"].toString();
          postObject.starred = list[i]["like_star"].toString();
          postObject.shared = list[i]["shared"].toString();
          postObject.status = list[i]["status"].toString();
          postObject.createdby = list[i]["createdby"].toString();
          postObject.__v = list[i]["__v"].toString();
          postObject.location =
              list[i]["location"] == null ? "" : list[i]["location"].toString();
          postObject.bio =
              list[i]["bio"] == null ? "" : list[i]["bio"].toString();
          postObject.website =
              list[i]["website"] == null ? "" : list[i]["website"].toString();
          if (list[i]["userdetail"] != null) {
            postObject.firstname = list[i]["userdetail"]["firstname"];
            postObject.lastname = list[i]["userdetail"]["lastname"];
            postObject.email = list[i]["userdetail"]["email"];
            postObject.profileimage = list[i]["userdetail"]["profileimage"];
            postObject.username = list[i]["userdetail"]["username"];
            postObject.follower = list[i]["userdetail"]["follower"].toString();
            postObject.following =
                list[i]["userdetail"]["following"].toString();
            postObject.userid = list[i]["userdetail"]["userid"];
            postObject.is_followed = list[i]["userdetail"]["is_followed"];
          }
          if (imageList.length > 0) {
            print("postObject.postid");
            print(postObject.postid);
            postList.add(postObject);
          }
        }
      }
    }
  }
}

class PostDetailObject {
  String? _id;
  String? message;
  String? filepath;
  String? liked;
  String? favourite;
  String? starred;
  String? shared;
  String? status;
  String? createdby;
  String? __v;
  String? firstname = "";
  String? lastname = "";
  String? email = "";
  String? profileimage = "";
  String? username = "";
  String? location = "";
  String? userid = "";
  String? follower = "";
  String following = "";
  String is_followed = "";
  String website = "";
  String bio = "";
  bool? isImage = false;
  bool? isMute = false;
  List<ImageObject>? imageList = [];
  bool? iserror = false;

  PostDetailObject.fromJson(Map<String, dynamic> json) {
    iserror = json["iserror"];
    message = json["message"];
    if (!iserror!) {
      if (json["data"] != null && json["data"].length > 0) {
        var list = json["data"];
        _id = list["_id"];
        message = list["message"];
        filepath = list["filepath"];
        final extension = Path.extension(list["filepath"]);
        if (extension.contains(".jpg") ||
            extension.contains(".png") ||
            extension.contains(".jpeg")) {
          isImage = true;
        }
        List<ImageObject> imgList = [];
        for (int k = 0; k < list["file_details"].length; k++) {
          ImageObject imageObject = ImageObject();
          List<TaggedObject>tList=[];
          if(list["file_details"][k]["tags"]!=null&&list["file_details"][k]["tags"].length>0){
            for(int tag=0;tag<list["file_details"][k]["tags"].length;tag++){
              var tagObject=list["file_details"][k]["tags"][tag];
              TaggedObject taggedObject=new TaggedObject();
              taggedObject.postid=tagObject["postid"];
              taggedObject._id=tagObject["_id"];
              taggedObject.taggedtext=tagObject["taggedtext"];
              taggedObject.imageposition=tagObject["imageposition"];
              taggedObject.postfileid=tagObject["postfileid"];
              taggedObject.taggeduserid=tagObject["taggeduserid"];
              if(tagObject["taggeduserid"]!=null){
                TaggedUserObject taggedUserObject=new TaggedUserObject();
                taggedUserObject.email=tagObject["taggeduserid"]["email"];
                taggedUserObject.lastname=tagObject["taggeduserid"]["lastname"];
                taggedUserObject.firstname=tagObject["taggeduserid"]["firstname"];
                taggedUserObject.profileimage=tagObject["taggeduserid"]["profileimage"];
                taggedUserObject.username=tagObject["taggeduserid"]["username"];
                taggedUserObject._id=tagObject["taggeduserid"]["_id"];
                taggedObject.taggeduserid=taggedUserObject;
              }
              tList.add(taggedObject);
            }
          }
          imageObject.taggedList=tList;
          final extension = Path.extension(list["file_details"][k]["filepath"]);
          print(extension);
          imageObject.liked = list["file_details"][k]["liked"].toString();
          imageObject.favourite =
              list["file_details"][k]["favourite"].toString();
          imageObject.starred = list["file_details"][k]["starred"].toString();
          imageObject.shared = list["file_details"][k]["shared"].toString();
          imageObject.status = list["file_details"][k]["status"].toString();
          imageObject.createdby =
              list["file_details"][k]["createdby"].toString();
          if (extension == ".jpg" ||
              extension == ".png" ||
              extension == ".jpeg") {
            imageObject.isImage = true;
          }
          imageObject.filePath = list["file_details"][k]["filepath"];
          imgList.add(imageObject);
          print("moreVideos");
          print(imageObject.filePath);
        }
        imageList = imgList;
        liked = list["liked"].toString();
        favourite = list["favourite"].toString();
        starred = list["starred"].toString();
        shared = list["shared"].toString();
        status = list["status"].toString();
        createdby = list["createdby"].toString();
        __v = list["__v"].toString();
        location = list["location"] == null ? "" : list["location"].toString();
        bio = list["bio"] == null ? "" : list["bio"].toString();
        website = list["website"] == null ? "" : list["website"].toString();
        if (list["userdetail"] != null) {
          firstname = list["userdetail"]["firstname"];
          lastname = list["userdetail"]["lastname"];
          email = list["userdetail"]["email"];
          profileimage = list["userdetail"]["profileimage"];
          username = list["userdetail"]["username"];
          follower = list["userdetail"]["follower"].toString();
          following = list["userdetail"]["following"].toString();
          userid = list["userdetail"]["userid"];
          is_followed = list["userdetail"]["is_followed"];
        }
      }
    }
  }
}

class PostObject {
  String? _id;
  String postid="";
  String? message;
  String? filepath;
  String liked="";
  String? favourite;
  String? starred;
  String? shared;
  String? status;
  String? createdby;
  String? __v;
  String? firstname = "";
  String? lastname = "";
  String? email = "";
  String? profileimage = "";
  String? username = "";
  String? location = "";
  String? userid = "";
  String? follower = "";
  String following = "";
  String is_followed = "";
  String is_liked = "";
  String liketype = "";
  String website = "";
  String bio = "";
  bool? isImage = false;
  bool? isMute = false;
  String createdOn = "";
  int totalLikedCount=0;
  List<TaggedObject>taggedList=[];

  List<ImageObject>? imageList = [];
  List<LikeUserObject>liked_users=[];
}
class LikeUserObject{
  String userid="";
  String firstname="";
  String userName="";
  String profileimage="";
}
class ImageObject {
  String filePath = "";
  bool? isImage = false;
  String? liked;
  String? favourite;
  String? starred;
  String? shared;
  String? status;
  String? createdby;
  bool isShowTagged=false;
  List<TaggedObject>taggedList=[];
}
class TaggedObject{
  TaggedUserObject? taggeduserid;
  String _id="";
  String taggedtext="";
  String imageposition="";
  String postid="";
  String postfileid="";
  String profileimage="";
}
class TaggedUserObject{
  String firstname="";
  String lastname="";
  String email="";
  String profileimage="";
  String username="";
  String _id="";
}
class CommonResponse {
  bool? iserror = false;
  String? message = "";

  CommonResponse.fromJson(Map<String, dynamic> json) {
    iserror = json["iserror"];
    message = json["message"];
    if (json["data"] != null&&json["data"]["errors"]!=null) {
      message = "";
      List location = [];
      if (json["data"]["errors"]["location"] != null) {
        location = json["data"]["errors"]["location"];
        if (message != "") {
          message = message! +
              "," +
              location.toString().replaceAll("[", "").replaceAll("]", "");
        } else {
          message = location.toString().replaceAll("[", "").replaceAll("]", "");
        }
      }
      if (json["data"]["errors"]["bio"] != null) {
        location = json["data"]["errors"]["bio"];
        if (message != "") {
          message = message! +
              "," +
              location.toString().replaceAll("[", "").replaceAll("]", "");
        } else {
          message = location.toString().replaceAll("[", "").replaceAll("]", "");
        }
      }
      if (json["data"]["errors"]["username"] != null) {
        location = json["data"]["errors"]["username"];
        if (message != "") {
          message = message! +
              "," +
              location.toString().replaceAll("[", "").replaceAll("]", "");
        } else {
          message = location.toString().replaceAll("[", "").replaceAll("]", "");
        }
      }
    }
  }
}

class UserResponse {
  bool? iserror = false;
  String? message = "";
  String? userId = "";
  String? firstname = "";
  String? lastname = "";
  String? email = "";
  String? mobileno = "";
  String? profileimage = "";
  String? bio = "";
  String? gender = "";
  String? location = "";
  String? username = "";
  String? website = "";
  String? followercount = "";
  String? followingcount = "";

  UserResponse.fromJson(Map<String, dynamic> json) {
    iserror = json["iserror"];
    message = json["message"];
    if (!iserror!) {
      firstname = json["data"]["firstname"];
      userId = json["data"]["_id"];
      lastname = json["data"]["lastname"];
      email = json["data"]["email"];
      mobileno = json["data"]["mobileno"];
      profileimage = json["data"]["profileimage"];
      bio = json["data"]["bio"]!=null?json["data"]["bio"]:"";
      gender = json["data"]["gender"];
      location = json["data"]["location"];
      username = json["data"]["username"];
      website = json["data"]["website"]!=null?json["data"]["website"]:"";
      followingcount = json["data"]["followingcount"]==null?"":json["data"]["followingcount"].toString();
      followercount = json["data"]["followercount"]==null?"":json["data"]["followercount"].toString();
    }
  }
}

class StoryList {
  bool? iserror = false;
  String? message = "";
  List<StoryObject> storyList = [];

  StoryList.fromJson(Map<String, dynamic> json) {
    iserror = json["iserror"];
    message = json["message"];
    if (!iserror!) {
      if (json["data"] != null && json["data"].length > 0) {
        var list = json["data"];
        for (int i = 0; i < list.length; i++) {
          StoryObject postObject = StoryObject();
          postObject._id = list[i]["_id"];
          postObject.message = list[i]["message"];
          postObject.filepath = list[i]["filepath"];
          postObject.status = list[i]["status"];
          postObject.seen = list[i]["seen"].toString();
          postObject.createdon = list[i]["createdon"].toString();
          storyList.add(postObject);
        }
      }
    }
  }
}

class StoryObject {
  String? _id;
  String? message;
  String? filepath;
  String? filetype;
  String? status;
  String? seen;
  String? createdon;
  bool? isImage = false;
}

class AllStoryList {
  bool? iserror = false;
  String? message = "";
  List<AllStoryMainObject> storyMainList = [];

  AllStoryList.fromJson(Map<String, dynamic> json) {
    iserror = json["iserror"];
    message = json["message"];
    if (!iserror!) {
      if (json["data"] != null && json["data"].length > 0) {
        for (int k = 0; k < json["data"].length; k++) {
          var list = json["data"][k]["story_detail"];
          print(list.length);
          print("list.length");
          List<StoryObject> storyList = [];
          AllStoryMainObject allStoryMainObject = new AllStoryMainObject();
          for (int i = 0; i < list.length; i++) {
            StoryObject postObject = StoryObject();
            postObject._id = list[i]["_id"];
            postObject.message = list[i]["message"];
            postObject.filepath = list[i]["filepath"];
            postObject.status = list[i]["status"];
            postObject.seen = list[i]["seen"].toString();
            postObject.createdon = list[i]["createdon"].toString();
            storyList.add(postObject);
          }
          print(storyList.length);
          allStoryMainObject.firstname = json["data"][k]["firstname"];
          allStoryMainObject.userName = json["data"][k]["username"];
          allStoryMainObject.lastname = json["data"][k]["lastname"];
          allStoryMainObject.userid = json["data"][k]["userid"];
          allStoryMainObject.profileimage = json["data"][k]["profileimage"];
          allStoryMainObject.storyList = storyList;
          storyMainList.add(allStoryMainObject);
        }
      }
    }
  }
}

class AllStoryMainObject {
  String? userid;
  String? firstname;
  String? userName;
  String? lastname;
  String? profileimage;
  List<StoryObject> storyList = [];
}

class SearchList {
  bool? iserror = false;
  String? message = "";
  List<SearchObject> storyList = [];

  SearchList.fromJson(Map<String, dynamic> json) {
    iserror = json["iserror"];
    message = json["message"];
    if (!iserror!) {
      if (json["data"] != null && json["data"].length > 0) {
        var list = json["data"];
        for (int i = 0; i < list.length; i++) {
          SearchObject postObject = SearchObject();
          postObject._id = list[i]["_id"];
          postObject.userid = list[i]["userid"];
          postObject.firstname = list[i]["firstname"];
          postObject.lastname = list[i]["lastname"];
          postObject.username = list[i]["username"];
          postObject.is_followed = list[i]["is_followed"].toString();
          postObject.profileimage = list[i]["profileimage"].toString();
          postObject.email = list[i]["email"].toString();
          postObject.is_followed = list[i]["is_followed"].toString();
          postObject.follower = list[i]["follower"]!=null?list[i]["follower"].toString():"";
          postObject.following = list[i]["following"]!=null?list[i]["following"].toString():"";
          postObject.bio = list[i]["bio"]==null?"":list[i]["bio"].toString();
          postObject.website = list[i]["website"]==null?"":list[i]["website"].toString();
          storyList.add(postObject);
        }
      }
    }
  }
}

class FollowingList {
  bool? iserror = false;
  String? message = "";
  List<SearchObject> storyList = [];

  FollowingList.fromJson(Map<String, dynamic> json) {
    iserror = json["iserror"];
    message = json["message"];
    if (!iserror!) {
      if (json["data"] != null && json["data"].length > 0) {
        var list = json["data"];
        for (int i = 0; i < list.length; i++) {
          SearchObject postObject = SearchObject();
          postObject._id = list[i]["_id"];
          postObject.userid = list[i]["userid"];
          postObject.firstname = list[i]["firstname"];
          postObject.lastname = list[i]["lastname"];
          postObject.username = list[i]["username"];
          postObject.is_followed = list[i]["is_followed"].toString();
          postObject.profileimage = list[i]["profileimage"].toString();
          postObject.email = list[i]["email"].toString();
          postObject.is_followed = list[i]["is_followed"].toString();
          postObject.follower = list[i]["follower"]==null?"":list[i]["follower"].toString();
          postObject.following = list[i]["following"]==null?"":list[i]["following"].toString();
          postObject.bio = list[i]["bio"]!=null?list[i]["bio"].toString():"";
          postObject.website = list[i]["website"]!=null?list[i]["website"].toString():"";
          storyList.add(postObject);
        }
      }
    }
  }
}

class SearchObject {
  String? _id;
  String? userid;
  String? firstname;
  String? lastname;
  String? username;
  String? is_followed = "";
  String? profileimage;
  String? email;
  String? bio;
  String? website;
  String? follower;
  String? following;
}

class UserStoryList {
  bool? iserror = false;
  String? message = "";
  List<UserStory> storyList = [];

  UserStoryList.fromJson(Map<String, dynamic> json) {
    iserror = json["iserror"];
    message = json["message"];
    if (!iserror!) {
      if (json["data"] != null && json["data"].length > 0) {
        var list = json["data"];
        for (int i = 0; i < list.length; i++) {
          UserStory postObject = UserStory();
          postObject.id = list[i]["id"];
          postObject.filepath = list[i]["filepath"];
          postObject.filefrom = list[i]["filefrom"];
          final extension = Path.extension(list[i]["filepath"]);
          if (extension.contains(".jpg") ||
              extension.contains(".png") ||
              extension.contains(".jpeg")) {
            postObject.isImage = true;
          }
          storyList.add(postObject);
        }
      }
    }
  }
}

class UserPostList {
  bool? iserror = false;
  String? message = "";
  List<UserStory> storyList = [];
  List<UserStory> videoStoryList = [];

  UserPostList.fromJson(Map<String, dynamic> json) {
    iserror = json["iserror"];
    message = json["message"];
    if (!iserror!) {
      if (json["data"] != null && json["data"].length > 0) {
        var list = json["data"];
        for (int i = 0; i < list.length; i++) {
          UserStory postObject = UserStory();
          bool isHave = false;
          postObject.id = list[i]["id"];
          postObject.filepath = list[i]["filepath"];
          postObject.filefrom = list[i]["filefrom"];
          final extension = Path.extension(list[i]["filepath"]);
          if (extension.contains(".jpg") ||
              extension.contains(".png") ||
              extension.contains(".jpeg")) {
            postObject.isImage = true;
          }
          if (storyList.length > 0) {
            var alist = storyList
                .indexWhere((element) => element.id == list[i]["id"]);
            if (alist>=0) {
              isHave = true;
              storyList[alist].isMultiple=true;
            }
          }
          if(!postObject.isImage!){
            videoStoryList.add(postObject);
          }
          if (!isHave) {
            storyList.add(postObject);
          }
        }
      }
    }
  }
}

class UserStory {
  String? id;
  String? filefrom;
  String? filepath;
  bool? isImage = false;
  bool? isMultiple=false;
}

class MultiSelection {
  AssetEntity? assetEntity;
  bool isSelect = false;
}
