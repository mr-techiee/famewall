import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:famewall/PrefUtils.dart';
import 'package:famewall/api/ApiResponse.dart';
import 'package:famewall/api/BaseApiService.dart';
import 'package:famewall/api/LoadingUtils.dart';
import 'package:famewall/api/NetworkApiService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart' as loc;

import 'package:path/path.dart' as Path;
import 'package:async/async.dart';
import 'package:http/http.dart' as http;
import 'package:video_trimmer/video_trimmer.dart';

import 'TrimmerVideo.dart';

class StoryWithMessageWidget extends StatefulWidget {
  File? imageFile;
  List<File>? selectedFiles = [];

  StoryWithMessageWidget({this.imageFile, this.selectedFiles});

  @override
  State<StatefulWidget> createState() {
    return PostWithMessageWidgetState();
  }
}

class PostWithMessageWidgetState extends State<StoryWithMessageWidget> {
  TextEditingController emailAddress = new TextEditingController();
  BaseApiService baseApiService = NetworkApiService();
  StreamSubscription? streamSubscription = null;
  loc.Location location = new loc.Location();
  String locationData = "";
  bool? _serviceEnabled = false;
  loc.PermissionStatus? _permissionGranted;
  loc.LocationData? _locationData;
  bool isImageUpload = false;
  double _startValue = 0.0;
  double _endValue = 0.0;
  List<SavedFileList> savedList = [];
  bool _isPlaying = false;
  bool _progressVisibility = false;

  void postMessageApi(String fileType) {
    isImageUpload = false;
    var request = {'message': "", 'filetype': fileType};
    print(request);
    if(apiCount==0){
      LoadingUtils.instance.showLoadingIndicator("Please wait...");
    }
    baseApiService.postResponse("story/add", request, Status.ADD_STORY);
  }

  upload(File imageFile, StoryResponse postMessageResponse) async {
    var stream =
        new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    var length = await imageFile.length();
    var uri = Uri.parse("http://3.110.176.237:3000/story/uploadfile");
    Map<String, String> requestHeaders = {
      'Accept': 'application/json',
      'auth-key': PreferenceUtils.getString("token", "")
    };

    var request = new http.MultipartRequest("POST", uri);
    request.fields["storyid"] = postMessageResponse.storyId!;
    request.headers.addAll(requestHeaders);

    var multipartFile = new http.MultipartFile('story_file', stream, length,
        filename: Path.basename(imageFile.path));
    //contentType: new MediaType('image', 'png'));

    request.files.add(multipartFile);
    var response = await request.send();
    print(response.statusCode);
    response.stream.transform(utf8.decoder).listen((value) {
      apiCount++;
      if (apiCount == savedList.length) {
        streamSubscription!.cancel();
        LoadingUtils.instance.hideOpenDialog();
        print("multipartFile");
        print(value);
        if(mounted){
          Navigator.of(context).maybePop(true);
        }

        /*Navigator.pushNamedAndRemoveUntil(
            context, '/home', (Route<dynamic> route) => false);*/
      } else {
        String fileType = "Video";
        var extenstion =
        Path.extension(savedList[apiCount].file!.path.toString());
        if (extenstion == ".jpg" ||
            extenstion == ".png" ||
            extenstion == ".jpeg") {
          fileType = "Image";
        }
        postMessageApi(fileType);
      }
    });
  }

  List<Widget> getPageView() {
    List<Widget> list = [];
    for (int i = 0; i < widget.selectedFiles!.length; i++) {
      var extenstion = Path.extension(widget.selectedFiles![i].path.toString());
      if (extenstion == ".jpg" ||
          extenstion == ".png" ||
          extenstion == ".jpeg") {
        list.add(Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: Container(
                margin: EdgeInsets.only(top: 10),
                constraints: BoxConstraints(
                    maxHeight: 500,
                    minWidth: double.infinity,
                    maxWidth: double.infinity),
                child: Image.file(
                  widget.selectedFiles![i],
                  fit: BoxFit.cover,
                ),
              )),
              /*  Container(height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  postMessageApi();
                },
                child: Text(
                  "Share",
                  style: TextStyle(color: Colors.white, fontSize: 14,fontFamily: "Poppins-medium"),
                ),
                style: ElevatedButton.styleFrom(
                    primary: Color(0xFFC4861A)),
              ),
              width: double.infinity,
              margin: EdgeInsets.only(left: 30, right: 30, top: 30,bottom: 30),
            )*/
            ],
          ),
        ));
      } else {
        list.add(TrimmerView(
          file: widget.selectedFiles![i],
          isTrim: false,
          savedFile: (file) =>
              {print(file.path), savedList[i].savedFile = file, print("file_path")},
        ));
      }
    }
    return list;
  }

  Widget getTrimmedVideo(File file, int pos) {
    final Trimmer _trimmer = Trimmer();
    _trimmer.loadVideo(videoFile: file);
    return Builder(
      builder: (context) => Center(
        child: Container(
          padding: EdgeInsets.only(bottom: 30.0),
          color: Colors.black,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Visibility(
                visible: _progressVisibility,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.red,
                ),
              ),
              Expanded(
                child: VideoViewer(trimmer: _trimmer),
              ),
              Center(
                child: TrimEditor(
                  trimmer: _trimmer,
                  viewerHeight: 50.0,
                  viewerWidth: MediaQuery.of(context).size.width,
                  maxVideoLength: Duration(seconds: 30),
                  onChangeStart: (value) {
                    _startValue = value;
                  },
                  onChangeEnd: (value) {
                    _endValue = value;
                  },
                  onChangePlaybackState: (value) {
                    setState(() {
                      _isPlaying = value;
                    });
                  },
                ),
              ),
              TextButton(
                child: _isPlaying
                    ? Icon(
                        Icons.pause,
                        size: 80.0,
                        color: Colors.white,
                      )
                    : Icon(
                        Icons.play_arrow,
                        size: 80.0,
                        color: Colors.white,
                      ),
                onPressed: () async {
                  bool playbackState = await _trimmer.videPlaybackControl(
                    startValue: _startValue,
                    endValue: _endValue,
                  );
                  setState(() {
                    _isPlaying = playbackState;
                  });
                },
              )
            ],
          ),
        ),
      ),
    );
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
                "," +
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
              placemarks[0].locality! + "," + placemarks[0].administrativeArea!;
          print(locationData);
          print("locationData");
        }
      }
    }
  }

  int apiCount = 0;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.selectedFiles!.length; i++) {
      SavedFileList savedFileList = new SavedFileList();
      savedFileList.file = widget.selectedFiles![i];
      savedList.add(savedFileList);
    }
    //  getLocationData();
    LoadingUtils.instance.setContext(context);
    streamSubscription = eventBus.on<ApiResponse>().listen((event) {
      if (event.status == Status.COMPLETED) {
        if (event.data is StoryResponse) {
          var loginResponse = event.data as StoryResponse;
          print(apiCount);
          print("apiCount");
          if (!loginResponse.iserror!) {
            var extenstion =
                Path.extension(savedList[apiCount].file!.path.toString());
            if (extenstion == ".jpg" ||
                extenstion == ".png" ||
                extenstion == ".jpeg") {
              upload(savedList[apiCount].file!, loginResponse);
            } else {
              upload(savedList[apiCount].savedFile!, loginResponse);
            }
          } else {
            if (apiCount == savedList.length) {
              LoadingUtils.instance.hideOpenDialog();
            }
            LoadingUtils.instance.showToast(loginResponse.message);
          }
        }
      } else {
        LoadingUtils.instance.hideOpenDialog();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add Story",
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
              String fileType = "Video";
              var extenstion =
                  Path.extension(savedList[apiCount].file!.path.toString());
              if (extenstion == ".jpg" ||
                  extenstion == ".png" ||
                  extenstion == ".jpeg") {
                fileType = "Image";
              }
              postMessageApi(fileType);
            },
          )
        ],
      ),
      body: PageView(
        children: getPageView(),allowImplicitScrolling: true,
      ),
    );
  }
}
