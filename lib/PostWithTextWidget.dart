import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:famewall/profile/HomeRoutes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart' as loc;
import 'package:rich_text_controller/rich_text_controller.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'PrefUtils.dart';
import 'TagWidget.dart';
import 'api/ApiResponse.dart';
import 'api/BaseApiService.dart';
import 'api/LoadingUtils.dart';
import 'api/NetworkApiService.dart';
import 'package:path/path.dart' as Path;
import 'package:async/async.dart';
import 'package:http/http.dart' as http;

import 'helper/sizeConfig.dart';

class PostWithMessageWidget extends StatefulWidget {
  File? imageFile;
  bool? isVideoUpload;
  List<File>? selectedFiles = [];
  PostWithMessageWidget({this.imageFile, this.isVideoUpload,this.selectedFiles});

  @override
  State<StatefulWidget> createState() {
    return PostWithMessageWidgetState();
  }
}

class PostWithMessageWidgetState extends State<PostWithMessageWidget> {
  TextEditingController emailAddress = new TextEditingController();
  BaseApiService baseApiService = NetworkApiService();
  StreamSubscription? streamSubscription = null;
  loc.Location location = new loc.Location();
  String locationData = "";
  bool? _serviceEnabled = false;
  loc.PermissionStatus? _permissionGranted;
  loc.LocationData? _locationData;
  bool isImageUpload = false;
  var uint8list = null;
  bool isVideoUpload = false;
  int apiCount=0;
  List<OffSetObject> offSetList = [];
  List words = [];
  String str = '';

      List<SearchObject> coments=[];

  void postMessageApi() {
    List<String> hashTag = [];
    int start = 0;
    RegExp highlightRegex=RegExp(r"\B#[a-zA-Z0-9]+\b");
    while (true) {
      final String? highlight =
      highlightRegex.stringMatch(ctrl!.text.toString().substring(start));
      if (highlight == null) {
        // no highlight
        break;
      }

      final int indexOfHighlight = ctrl!.text.toString().indexOf(highlight, start);

      if (indexOfHighlight == start) {
        // starts with highlight
        hashTag.add(highlight);
        start += highlight.length;
      } else {
        // normal + highlight
        //spans.add(_normalSpan(text.substring(start, indexOfHighlight)));
        hashTag.add(highlight);
        start = indexOfHighlight + highlight.length;
      }
    }
    for (int i=coments.length-1;i>=0;i--) {
      if(!ctrl!.text.contains("@"+coments[i].username!)){
        coments.removeAt(i);
      }
    }
    List list=[];
    for(int i=0;i<coments.length;i++){
      var req={
        "taggeduserid":coments[i].userid,
        "tagkey":coments[i].username,
      };
      list.add(jsonEncode(req));
    }
    isImageUpload = false;
    var request = {
      'message': ctrl!.text,
      'location': locationData,
      'hash_list': hashTag.toString(),
      'tagged_msg_users':list.toString()
    };
    log(request.toString());
    log("Postrequest");
    LoadingUtils.instance.showLoadingIndicator("Please wait...");
    baseApiService.postResponse("post/add", request, Status.POST_MESSAGE);
  }

  Future<void> getLocationData() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled!) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled!) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == loc.PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted == loc.PermissionStatus.granted) {
        _locationData = await location.getLocation();
        if (_locationData != null) {
          List<Placemark> placemarks = await placemarkFromCoordinates(
              _locationData!.latitude!, _locationData!.longitude!);
          if (placemarks.length > 0) {
            locationData = placemarks[0].locality! +
                ", " +
                placemarks[0].administrativeArea!;
            print(locationData);
            print("locationData");
          }
        }
      }
    } else {
      _locationData = await location.getLocation();
      if (_locationData != null) {
        List<Placemark> placemarks = await placemarkFromCoordinates(
            _locationData!.latitude!, _locationData!.longitude!);
        if (placemarks.length > 0) {
          locationData =
              placemarks[0].locality! + ", " + placemarks[0].administrativeArea!;
          print(locationData);
          print("locationData");
        }
      }
    }
  }

  void getThumnail() async {
    uint8list = await VideoThumbnail.thumbnailData(
      video: widget.imageFile!.path,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 128,
      // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 25,
    );
    setState(() {

    });
  }
  RichTextController? ctrl;
  List<SearchObject> searchList = [];
  Map<RegExp, TextStyle> patternUser = {
    RegExp(r"\B@[a-zA-Z0-9]+\b"):
    TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)
  };
  @override
  void initState() {
    super.initState();
    ctrl = RichTextController(
      patternMatchMap: patternUser, onMatch: (List<String> match) {
        print("match.toString()");
        print(match.toString());
    },deleteOnBack: true);

    //ctrl = TextEditingController();
    widget.imageFile=widget.selectedFiles![0];
    final extension = Path.extension( widget.imageFile!.path.toString());
    print(extension);
    if (extension.contains(".jpg") || extension.contains(".png")||extension.contains(".jpeg")) {
      isVideoUpload = false;
    }else{
      isVideoUpload = true;
      getThumnail();
    }
    setState(() {

    });
    getLocationData();
    LoadingUtils.instance.setContext(context);
    streamSubscription = eventBus.on<ApiResponse>().listen((event) {
      if (event.status == Status.COMPLETED) {
        if (event.data is PostMessageResponse) {
          var loginResponse = event.data as PostMessageResponse;
          if (!loginResponse.iserror!) {
            List listRequest=[];
            List<File> listFileRequest=[];
            for(int i=0;i<widget.selectedFiles!.length;i++){
              log(i.toString());
              log("selectedFilePos");
              var taggedList=offSetList.where((element) => element.currentPageValue==i).toList();
              List list=[];
              if(taggedList.length>0){
                for(int i=0;i<taggedList.length;i++){
                  var req={
                    "taggeduserid":taggedList[i].tagUserId,
                    "taggedtext":taggedList[i].tagName,
                    "imageposition":taggedList[i].x+","+taggedList[i].y
                  };
                  list.add(jsonEncode(req));
                }
                listRequest.add(list);
                log(list.toString());
                log("list.toString()");
              }else{
                listRequest.add(list);
              }
              log("upload");
              listFileRequest.add(widget.selectedFiles![i]);
            }
            upload(listFileRequest, loginResponse,listRequest);
          } else {
            LoadingUtils.instance.hideOpenDialog();
            LoadingUtils.instance.showToast(loginResponse.message);
          }
        }else  if (event.data is SearchList) {
          //isLoading = false;

          var postList = event.data as SearchList;
          if (!postList.iserror!) {
            searchList=[];
            searchList.addAll(postList.storyList);
            if(mounted){
              setState(() {});
            }
          } else {
            LoadingUtils.instance.showToast(postList.message);
          }
        }
      } else {
        LoadingUtils.instance.hideOpenDialog();
      }
    });
  }
  getSearchList(String text) {
    var request = {'search_username': text};
    print("request");

    baseApiService.postResponse(
        "follower/search?perpage=10&page=" + 1.toString(),
        request,
        Status.SEARCH);
  }

  Future<List<http.MultipartFile>> getMultiFile(List<File> imageFile) async{
    List<http.MultipartFile>files=[];
    for(int i=0;i<imageFile.length;i++){
      var stream =
      new http.ByteStream(DelegatingStream.typed(imageFile[i].openRead()));
      var length = await imageFile[i].length();
      var multipartFile = new http.MultipartFile('post_file', stream, length,
          filename: Path.basename(imageFile[i].path));
      files.add(multipartFile);
    }
    return files;
  }

  upload(List<File> imageFile, PostMessageResponse postMessageResponse,List list) async {

    var multipartFile= await getMultiFile(imageFile);
    var uri = Uri.parse("http://3.110.176.237:3000/post/uploadfiles");
    Map<String, String> requestHeaders = {
      'Accept': 'application/json',
      'auth-key': PreferenceUtils.getString("token", "")
    };

    var request = new http.MultipartRequest("POST", uri);
    request.fields["postid"] = postMessageResponse.postId!;
    if(list.length>0){
      print(list.toString());
      request.fields["tags"] = list.toString();
    }
    request.headers.addAll(requestHeaders);


    //contentType: new MediaType('image', 'png'));

    request.files.addAll(multipartFile);
    var response = await request.send();
    print(response.statusCode);
    response.stream.transform(utf8.decoder).listen((value) {

      print("multipartFile");
      print(value);
      streamSubscription!.cancel();
      LoadingUtils.instance.hideOpenDialog();
      print("hidingProgressbar");
      /*Navigator.pushNamedAndRemoveUntil(
            context, HomeWidgetRoutes.screen5, (Route<dynamic> route) => false);*/
      if(mounted){
        Navigator.of(context).maybePop(true);
      }

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          "New Post",
          style: TextStyle(color: Colors.black, fontFamily: "Poppins-medium"),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.check,
              color: Colors.black,
            ),
            onPressed: () async {
              postMessageApi();
            },
          )
        ],
      ),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  Container(
                    child: !isVideoUpload? Image.file(
                            widget.selectedFiles![0],
                            height: 70,
                            width: 70,
                          )
                        : uint8list != null
                            ? Image.memory(
                                uint8list,
                                height: 70,
                                width: 70,
                              )
                            : Container(),
                  ),
                  Expanded(
                      child: Container(
                          padding: EdgeInsets.all(20),
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            TextField(maxLines: null,
                                controller: ctrl,
                                decoration: InputDecoration(  border: InputBorder.none,
                                  hintText: 'Write a caption',
                                  hintStyle: TextStyle(color: Colors.black)
                                ),
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                                onChanged: (val) {
                                  log("dadahdhaghagh");
                                  setState(() {
                                    words = val.split(' ');
                                    str = words.length > 0 &&
                                        words[words.length - 1].startsWith('@')
                                        ? words[words.length - 1]
                                        : '';
                                    if(str.length>1){
                                      var input=str.replaceAll('@', "");
                                      getSearchList(input);
                                    }

                                  });
                                }),

                            SizedBox(height:25),
                          ]))/*Container(
                          margin: EdgeInsets.only(left: 10),
                          child: TextField(
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            controller: emailAddress,
                            decoration: InputDecoration(
                              hintText: "Write a caption",
                              border: InputBorder.none,
                            ),
                          ))*/),
                ],
              ),
            ),
            str.length > 1
                ? Expanded(child: ListView(
                shrinkWrap: true,
                children: searchList.map((s){
                  if(('@' + s.username!).contains(str))
                    return
                      ListTile(
                          title:postDetails(s),
                          onTap:(){

                            String tmp = str.substring(1,str.length);
                            setState((){
                              str ='';
                              coments.add(s);
                              ctrl!.text += s.username!.substring(s.username!.indexOf(tmp)+tmp.length,s.username!.length).replaceAll(' ','_');
                              ctrl!.selection=TextSelection.fromPosition(TextPosition(offset: ctrl!.text.length));
                            });
                          });
                  else return SizedBox();
                }).toList()

            )):SizedBox(),
            Divider(),
            InkWell(child: Container(
              padding: EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
              child: Row(children: [
                Expanded(child: Text(
                  "Tag People",
                  style: TextStyle(
                      color: Colors.black, fontFamily: "Poppins-medium"),
                )),
                offSetList.length>0?Text(
                  offSetList.length.toString()+" People",
                  style: TextStyle(
                      color: Colors.black, fontFamily: "Poppins-medium"),
                ):Container()
              ],),
            ),onTap: () async {
              dynamic v = await Navigator.of(context)
                  .pushNamed(HomeWidgetRoutes.screen12, arguments: {
                "selectedFiles": widget.selectedFiles,
              });
              if(v!=null){
                offSetList=v["tagList"];
                LoadingUtils.instance.setContext(context);
                setState(() {

                });
              }
            },),
            Divider(),
            Container(
              padding: EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
              child: Text(
                "Add Location",
                style: TextStyle(
                    color: Colors.black, fontFamily: "Poppins-medium"),
              ),
            ),
            Divider(),
          ],
        ),
      ),
    );
  }
  Widget example() {
    return new DropdownButton(
        isExpanded: true,
        items: [
          new DropdownMenuItem(child: new Text("Abc")),
          new DropdownMenuItem(child: new Text("Xyz")),
        ],
        hint: new Text("Select City"),
        onChanged: null
    );
  }
  Widget postDetails(SearchObject? document) {
    return Container(child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 10, top: 5),
          child: Row(
            children: <Widget>[
              document!.profileimage!.length > 0
                  ? CircleAvatar(
                radius: 24,
                child: CircleAvatar(
                  backgroundImage: NetworkImage(document.profileimage!),
                  radius: 22,
                ),
              )
                  : Container(
                child: CircleAvatar(
                  child: CircleAvatar(
                    backgroundImage:
                    AssetImage('assets/images/name.jpg'),
                    radius: 22,
                  ),
                ),
              ),
              SizedBox(
                width: SizeConfig.blockSizeHorizontal! * 4,
              ),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
                Container(
                  child: Text(
                    document.firstname!,

                    style: TextStyle(
                        fontSize:
                        SizeConfig.safeBlockHorizontal! * 4,
                        fontFamily: "Poppins-Medium",
                        color: Colors.black),
                  ),

                ),
                Container(
                  child: Text(
                    document.username!,
                    style: TextStyle(
                        fontSize: SizeConfig.safeBlockHorizontal! * 3,
                        fontFamily: "Poppins-Medium",
                        color: Colors.grey),
                  ),
                ),
              /*  Container(
                  child: Text(
                    document.email!,

                    style: TextStyle(
                        fontSize:
                        SizeConfig.safeBlockHorizontal! * 3,
                        fontFamily: "Poppins-Medium",
                        color: Colors.grey),
                  ),

                )*/
              ],)),
            ],
          ),
        ),
        Divider(),
        Container(
          height: 2,
        ),
      ],
    ),margin: EdgeInsets.only(top: 5),);
  }
}
