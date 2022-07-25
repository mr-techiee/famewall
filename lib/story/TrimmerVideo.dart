
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:famewall/api/ApiResponse.dart';
import 'package:famewall/api/BaseApiService.dart';
import 'package:famewall/api/LoadingUtils.dart';
import 'package:famewall/api/NetworkApiService.dart';
import 'package:flutter/material.dart';
import 'package:video_trimmer/video_trimmer.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as Path;
import 'package:async/async.dart';

import '../PrefUtils.dart';

class TrimmerView extends StatefulWidget {
  final File? file;
   bool? isTrim=false;
  final Function(File)? savedFile;

  TrimmerView({Key? key,this.file,this.isTrim, this.savedFile}): super(key: key);

  @override
  _TrimmerViewState createState() => _TrimmerViewState();
}

class _TrimmerViewState extends State<TrimmerView> {
  final Trimmer _trimmer = Trimmer();

  double _startValue = 0.0;
  double _endValue = 0.0;

  bool _isPlaying = false;
  bool _progressVisibility = false;

  Future<String?> _saveVideo() async {
    setState(() {
      _progressVisibility = true;
    });

    String? _value;

    await _trimmer
        .saveTrimmedVideo(startValue: _startValue, endValue: _endValue, onSave: (String? outputPath) {
      setState(() {
        _progressVisibility = false;
        _value = outputPath;
        _imageFile=File(outputPath!);
        postMessageApi();
        print(outputPath);
      });
    });

     print("_value");
     print(_value);
    return _value;
  }
  Future<String?> _saveVideo1() async {
    String? _value;

    await _trimmer
        .saveTrimmedVideo(startValue: _startValue, endValue: _endValue, onSave: (String? outputPath) {
      setState(() {
        _value = outputPath;
        _imageFile=File(outputPath!);
        widget.savedFile!(_imageFile!);
      });
    });

    print("_value");
    print(_value);
    return _value;
  }
  void _loadVideo() {
    _trimmer.loadVideo(videoFile: widget.file!);
    if(widget.isTrim!){
      _saveVideo1();
    }

  }
  BaseApiService baseApiService = NetworkApiService();
  StreamSubscription? streamSubscription = null;
  bool isImageUpload = false;
  File? _imageFile=null;
  @override
  void initState() {
    super.initState();

    _loadVideo();
    LoadingUtils.instance.setContext(context);
    if(widget.isTrim!){
      streamSubscription = eventBus.on<ApiResponse>().listen((event) {
        if (event.status == Status.COMPLETED) {
          if (event.data is StoryResponse) {
            var loginResponse = event.data as StoryResponse;
            if (!loginResponse.iserror!) {
              upload(_imageFile!, loginResponse);
            } else {
              LoadingUtils.instance.hideOpenDialog();
              LoadingUtils.instance.showToast(loginResponse.message);
            }
          }
        } else {
          LoadingUtils.instance.hideOpenDialog();
        }
      });
    }

  }

  void postMessageApi() {
    isImageUpload = false;
    var request = {
      'message':"My New look",
      'filetype':"Video"
    };
    print(request);
    LoadingUtils.instance.showLoadingIndicator("Please wait...");
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
      streamSubscription!.cancel();
      LoadingUtils.instance.hideOpenDialog();
      print("multipartFile");
      print(value);
      Navigator.of(context).maybePop(true);
      /*Navigator.pushNamedAndRemoveUntil(
          context, '/home', (Route<dynamic> route) => false);*/
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.isTrim!?AppBar(
        title: Text("Add Story"),backgroundColor: Colors.white,titleTextStyle: TextStyle(color: Colors.black,fontSize: 18,fontWeight: FontWeight.bold),leading: Icon(Icons.arrow_back,color: Colors.black,),actions: [
        IconButton(
          icon: Icon(
            Icons.check,
            color: Colors.black,
          ),
          onPressed: () async {
            _saveVideo();/*.then((outputPath) {
              print('OUTPUT PATH: $outputPath');
              *//*  final snackBar = SnackBar(
                          content: Text('Video Saved successfully'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        snackBar,
                      );*//*
            });*/
            //postMessageApi();
          },
        )
      ],
      ):null,
      body: Builder(
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
                      if(!widget.isTrim!){
                        _saveVideo1();
                      }
                    },
                    onChangeEnd: (value) {
                      _endValue = value;
                      if(!widget.isTrim!){
                        _saveVideo1();
                      }
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
      ),
    );
  }
}