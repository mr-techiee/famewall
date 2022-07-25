import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as p;
import 'package:famewall/PrefUtils.dart';
import 'package:famewall/api/ApiResponse.dart';
import 'package:famewall/api/BaseApiService.dart';
import 'package:famewall/api/LoadingUtils.dart';
import 'package:famewall/api/NetworkApiService.dart';
import 'package:famewall/story/TrimmerVideo.dart';
import 'package:famewall/story/VideoView.dart';
import 'package:famewall/videoView.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart' as loc;

import 'package:path/path.dart' as Path;
import 'package:async/async.dart';
import 'package:http/http.dart' as http;
import 'package:video_trimmer/video_trimmer.dart';

import 'TrianglePath.dart';
import 'Utils.dart';
import 'global.dart';
import 'helper/sizeConfig.dart';

class OffSetObject {
  String x = "";
  String y = "";
  String tagName = "Who's this";
  String tagUserId = "";
  String profileImage = "";
  String email = "";
  int currentPageValue = 0;
}

class TagWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PostWithMessageWidgetState();
  }
}

class PostWithMessageWidgetState extends State<TagWidget> {
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
  List<OffSetObject> offSetList = [];
  List<File> selectedFiles = [];
  bool _isPlaying = false;
  bool _progressVisibility = false;
  bool isFirstTime = false;
  bool isAddTag = false;
  bool isVideoTag = false;
  bool isVideo = false;

  List<Widget> getPageView() {
    List<Widget> list = [];
    for (int i = 0; i < selectedFiles!.length; i++) {
      var extenstion = Path.extension(selectedFiles![i].path.toString());
      if (extenstion == ".jpg" ||
          extenstion == ".png" ||
          extenstion == ".jpeg") {
        list.add(Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: Stack(
                children: [
                  GestureDetector(
                    child: Container(
                      margin: EdgeInsets.only(top: 10),
                      constraints: BoxConstraints(
                        minHeight: 320,
                        maxHeight: 350,
                        maxWidth: double.infinity,
                        minWidth: double.infinity,
                      ),
                      child: Image.file(
                        selectedFiles![i],
                        fit: BoxFit.cover,
                      ),
                    ),
                    onTapDown: (details) {
                      print("tapdown");
                      isVideoTag = false;
                      if (!isAddTag) {
                        isAddTag = true;
                        setState(() {});
                        onTapDown(context, details);
                      } else {
                        print("isNotAdded");
                        isAddTag = false;
                        offSetList.removeAt(offSetList.length - 1);
                        setState(() {});
                      }
                    },
                  ),
                  Container(
                    child: Stack(
                      children: getPointedWidget(),
                    ),
                    height: double.infinity,
                  )
                ],
              )),
            ],
          ),
        ));
      } else {
        list.add(InkWell(
          child: Container(
            // height: 300,
            child: Stack(
              children: [
                VideoViewWidget(
                  url: selectedFiles![i],
                ),
              ],
            ),
          ),
          onTap: () {
            if (isAddTag) {
              isVideoTag = false;
              isAddTag = false;
            } else {
              isVideoTag = true;
              isAddTag = true;
            }
            setState(() {});
          },
        ));
      }
    }
    return list;
  }

  void onTapDown(BuildContext context, TapDownDetails details) {
    OffSetObject offSet = OffSetObject();
    offSet.tagName = "Who's this";
    offSet.x = details.localPosition.dx.toString();
    offSet.y = details.localPosition.dy.toString();
    offSet.currentPageValue = currentPageValue.toInt();
    offSetList.add(offSet);
    setState(() {});
  }

  List<Widget> getPointedWidget() {
    List<Widget> list = [];
    for (int i = 0; i < offSetList.length; i++) {
      list.add(offSetList[i].currentPageValue == currentPageValue.toInt()
          ? Positioned(
              top: double.parse(offSetList[i].y),
              left: double.parse(offSetList[i].x),
              child: /*Container(
                height: 50,
                child: Column(
                  children: [
                    Container(
                      child: Image(
                        image: AssetImage("assets/images/up_arrow.png"),
                        height: 15,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                          left: 15, right: 15, top: 5, bottom: 5),
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                          ),
                          color: Colors.black,
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                      child: Flexible(child: Container(width: 80,child: Text(
                        offSetList[i].tagName.startsWith("https:")||offSetList[i].tagName.startsWith("http:")?"Link":offSetList[i].tagName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,style: TextStyle(color: offSetList[i].tagName.startsWith("https")||offSetList[i].tagName.startsWith("http")?Colors.blue:Colors.white, fontSize: 12),
                      ),),),
                    )
                  ],
                ),
              )*/Container(
                  child:Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment:CrossAxisAlignment.start,
                      children:[
                        Container(
                            child:CustomPaint(
                              painter: TrianglePainter(
                                strokeColor: Colors.black,
                                strokeWidth: 10,
                                paintingStyle: PaintingStyle.fill,
                              ),
                              child: Container(
                                height: 10,
                                width: 20,
                              ),
                            )
                        ),
                        Container(
                          padding: EdgeInsets.only(
                              left: 15, right: 15, top: 5, bottom: 5),
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black,
                              ),
                              color: Colors.black,
                              borderRadius: BorderRadius.all(Radius.circular(2))),
                          child: Flexible(child: Container(width: 80,child: Text(
                            Uri.parse(offSetList[i].tagName).isAbsolute?"Link":offSetList[i].tagName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,style: TextStyle(color: Uri.parse(offSetList[i].tagName!).isAbsolute?Colors.blue:Colors.white, fontSize: 12),
                          ),),),
                        )
                      ]
                  )

              ),
            )
          : Container());
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
    //  getLocationData();
    /* pageViewController.addListener(() {
      setState(() {
        currentPageValue = pageViewController.page!.toInt();
        print("currentPageValue");
        print(currentPageValue.toInt());

      });
    });*/
    LoadingUtils.instance.setContext(context);
    streamSubscription = eventBus.on<ApiResponse>().listen((event) {
      if (event.status == Status.COMPLETED) {
        if (event.data is SearchList) {
          isLoading = false;

          var postList = event.data as SearchList;
          if (!postList.iserror!) {
            searchList.addAll(postList.storyList);
            if (mounted) {
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

  void _scrollListener() {
    print(scrollController!.position.extentAfter);
    if (scrollController!.position.maxScrollExtent ==
        scrollController!.offset) {
      if (searchList.length >= (10 * pageNumber!) && !isLoading!) {
        pageNumber = (pageNumber! + 1);
        isLoading = true;
        print("loadMore");
        getSearchList(controller.text.toString());
      }
    }
  }

  void getArguments() {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    selectedFiles = arguments["selectedFiles"];
    scrollController = ScrollController()..addListener(_scrollListener);

    setState(() {});
  }

  TextEditingController controller = new TextEditingController();
  List<SearchObject> searchList = [];
  int? pageNumber = 1;
  ScrollController? scrollController;
  bool? isLoading = false;
  var currentPageValue = 0;

  onSearchTextChanged(String text) async {
    searchList = [];
    // _searchUserResult.clear();
    if (text.isEmpty) {
      searchList = [];
      getSearchList("");
      setState(() {});
      return;
    } else {
      searchList = [];
      getSearchList(text);
    }

    setState(() {});
  }

  getSearchList(String text) {
    var request = {'search_username': text};
    print("request");

    baseApiService.postResponse(
        "follower/search?perpage=10&page=" + pageNumber.toString(),
        request,
        Status.SEARCH);
  }

  Widget _searchTextfield(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 10, right: 10, left: 10),
        child: Container(
          decoration: new BoxDecoration(
              color: Colors.green,
              borderRadius: new BorderRadius.all(
                Radius.circular(15.0),
              )),
          height: 40,
          child: InkWell(
            child: Container(
              color: Colors.white,
              child: TextField(
                controller: controller,
                onChanged: onSearchTextChanged,
                style: TextStyle(color: Colors.grey),
                decoration: new InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: new BorderSide(color: Colors.grey[200]!),
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(20.0),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: new BorderSide(color: Colors.grey[200]!),
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(
                        20.0,
                      ),
                    ),
                  ),
                  filled: true,
                  hintStyle:
                      new TextStyle(color: Colors.grey[600], fontSize: 14),
                  hintText: "Search",
                  contentPadding: EdgeInsets.only(top: 10.0),
                  fillColor: Colors.grey[100],
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey[600],
                    size: 25.0,
                  ),
                ),
              ),
            ),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    if (!isFirstTime) {
      isFirstTime = true;
      getArguments();
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: isAddTag
          ? AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.white,
              elevation: 0,
              title: _searchTextfield(context),
              centerTitle: false,
              leadingWidth: 30,
              leading: InkWell(
                child: Container(margin: EdgeInsets.only(left: 5),padding: EdgeInsets.all(5),
                  child: Icon(Icons.close,color: Colors.black,),
                ),
                onTap: () {
                  searchList.clear();
                  //  _searchResult.clear();
                  controller.clear();
                  isAddTag = false;
                  offSetList.removeAt(offSetList.length - 1);
                  setState(() {

                  });
                },
              ),
              titleSpacing: 0,
              actions: [
                Container(
                  width: 80,
                  child: IconButton(
                      padding: const EdgeInsets.all(0),
                      onPressed: () {
                        setState(() {
                          if(Utils.isEmpty(controller.text)){
                            searchList.clear();
                            //  _searchResult.clear();
                            controller.clear();
                            isAddTag = false;
                            offSetList.removeAt(offSetList.length - 1);
                          }else{
                            offSetList[offSetList.length - 1].tagName =
                                controller.text.toString();
                            offSetList[offSetList.length - 1].tagUserId ="";
                            offSetList[offSetList.length - 1].profileImage ="";
                            offSetList[offSetList.length - 1].email = "";
                            searchList.clear();
                            //  _searchResult.clear();
                            controller.clear();
                            isAddTag = false;
                          }

                        });
                      },
                      icon: Text(
                        "Add Tag",
                        maxLines: 1,
                        style: TextStyle(
                            color: appColorBlack,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      )),
                )
              ],
            )
          : AppBar(
              title: Text(
                "Tag People",
                style: TextStyle(
                    color: Colors.black, fontFamily: "Poppins-medium"),
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
                    Navigator.of(context).pop({"tagList": offSetList});
                  },
                )
              ],
            ),
      body: searchList.length > 0
          ? _getMoviesListView()
          : Column(
              children: [
                Container(
                  constraints: BoxConstraints(
                    minHeight: 320,
                    maxHeight: 350,
                    maxWidth: double.infinity,
                    minWidth: double.infinity,
                  ),
                  child: PageView(
                    controller: PageController(initialPage: currentPageValue),
                    children: getPageView(),
                    allowImplicitScrolling: true,
                    onPageChanged: (pos) {
                      currentPageValue = pos;

                      setState(() {});
                    },
                  ),
                  height: 300,
                ),
                offSetList.length > 0
                    ? Container(
                        child: Text(
                          "TAGGED USER",
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                        margin: EdgeInsets.only(top: 10),
                      )
                    : Container(),
                offSetList.length > 0
                    ? Expanded(
                        child: ListView.builder(
                        itemCount: offSetList.length,
                        shrinkWrap: true,
                        itemBuilder: (context, i) {
                          return offSetList[i].tagName != "" &&
                                  offSetList[i].currentPageValue ==
                                      currentPageValue.toInt()
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10, top: 5),
                                      child: Row(
                                        children: <Widget>[
                                          offSetList[i].profileImage!.length > 0
                                              ? CircleAvatar(
                                                  radius: 24,
                                                  child: CircleAvatar(
                                                    backgroundImage:
                                                        NetworkImage(
                                                            offSetList[i]
                                                                .profileImage),
                                                    radius: 22,
                                                  ),
                                                )
                                              : Container(
                                                  child: CircleAvatar(
                                                    child: CircleAvatar(
                                                      backgroundImage: AssetImage(
                                                          'assets/images/name.jpg'),
                                                      radius: 22,
                                                    ),
                                                  ),
                                                ),
                                          SizedBox(
                                            width: SizeConfig
                                                    .blockSizeHorizontal! *
                                                4,
                                          ),
                                          Expanded(
                                              child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                child: Text(
                                                  offSetList[i].tagName,
                                                  style: TextStyle(
                                                      fontSize: SizeConfig
                                                              .safeBlockHorizontal! *
                                                          4,
                                                      fontFamily:
                                                          "Poppins-Medium",
                                                      color: Colors.black),
                                                ),
                                              ),
                                             /* Container(
                                                child: Text(
                                                  offSetList[i].email,
                                                  style: TextStyle(
                                                      fontSize: SizeConfig
                                                              .safeBlockHorizontal! *
                                                          3,
                                                      fontFamily:
                                                          "Poppins-Medium",
                                                      color: Colors.grey),
                                                ),
                                              )*/
                                            ],
                                          )),
                                          InkWell(
                                            child: Container(
                                              child: Icon(Icons.close),
                                              margin:
                                                  EdgeInsets.only(right: 10),
                                              padding: EdgeInsets.all(5),
                                            ),
                                            onTap: () {
                                              offSetList.removeAt(i);
                                              setState(() {});
                                            },
                                          )
                                        ],
                                      ),
                                    ),
                                    Divider(),
                                    Container(
                                      height: 2,
                                    ),
                                  ],
                                )
                              : Container();
                        },
                      ))
                    : Container(
                        child: Text(
                          "Tap photo to tag people",
                          style: TextStyle(fontSize: 12),
                        ),
                        margin: EdgeInsets.only(top: 30),
                      )
              ],
            ),
    );
  }

  Widget _getMoviesListView() {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: searchList.length,
        controller: scrollController,
        itemBuilder: (context, position) {
          return postDetails(searchList[position], position);
        });
  }

  Widget postDetails(SearchObject? document, pos) {
    return InkWell(
      child: Container(
        child: Column(
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
                            backgroundImage:
                                NetworkImage(document.profileimage!),
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
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Text(
                          document.firstname!,
                          style: TextStyle(
                              fontSize: SizeConfig.safeBlockHorizontal! * 4,
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
                     /* Container(
                        child: Text(
                          document.email!,
                          style: TextStyle(
                              fontSize: SizeConfig.safeBlockHorizontal! * 3,
                              fontFamily: "Poppins-Medium",
                              color: Colors.grey),
                        ),
                      )*/
                    ],
                  )),
                ],
              ),
            ),
            Divider(),
            Container(
              height: 2,
            ),
          ],
        ),
        margin: EdgeInsets.only(top: 5),
      ),
      onTap: () {
        isAddTag = false;
        if (isVideoTag) {
          OffSetObject object = OffSetObject();
          object.tagName = searchList[pos].username!;
          object.tagUserId = searchList[pos].userid!;
          object.profileImage = searchList[pos].profileimage!;
          object.email = searchList[pos].email!;
          offSetList.add(object);
        } else {
          offSetList[offSetList.length - 1].tagName =
              searchList[pos].username!;
          offSetList[offSetList.length - 1].tagUserId = searchList[pos].userid!;
          offSetList[offSetList.length - 1].profileImage =
              searchList[pos].profileimage!;
          offSetList[offSetList.length - 1].email = searchList[pos].email!;
        }

        searchList = [];
        //pageViewController.page!=currentPageValue.toDouble();
        //pageViewController = PageController(initialPage: currentPageValue.toInt());

        setState(() {});
      },
    );
  }

}
