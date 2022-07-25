import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:famewall/FilterPostScreen.dart';
import 'package:famewall/api/ApiResponse.dart';
import 'package:famewall/crop/crop_your_image.dart';
import 'package:famewall/story/VideoView.dart';
import 'package:famewall/videoView.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photofilters/filters/filters.dart';
import 'package:photofilters/filters/preset_filters.dart';
import 'package:path/path.dart' as Path;
import 'package:image/image.dart' as imageLib;

import 'FilterImageWidget.dart';
import 'PostWithTextWidget.dart';
import 'crop/CroppedX.dart';

class PostScreen extends StatefulWidget {
  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final GlobalKey _cropperKey = GlobalKey();
  Uint8List? _imageToCrop;
  Uint8List? _croppedImage;
  OverlayType _overlayType = OverlayType.rectangle;
  int _rotationTurns = 0;
  final ImagePicker _picker = ImagePicker();

  File? _file;
  List<FileModel> files = [];
  List<AssetPathEntity> assetPathList = [];
  FileModel? selectedModel;
  bool isEnableMultiSelection = false;

  String? image;
  AssetEntity? entity = null;
  final _cropController = CropController();

  /// Customize your own filter options.
  final FilterOptionGroup _filterOptionGroup = FilterOptionGroup(
    imageOption: const FilterOption(
      sizeConstraint: SizeConstraint(ignoreSize: true),
    ),
  );
  final int _sizePerPage = 50;

  AssetPathEntity? _path;
  List<MultiSelection>? _multiEntities = [];
  List<File>? selectedFiles = [];
  List<File>? croppedFiles = [];
  int _totalEntitiesCount = 0;
  int lastSelectedPos = -1;
  int _page = 0;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreToLoad = true;

  List<Filter> filters = presetFiltersList;
  String? fileName;
  File? imageFile;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _requestAssets();
    });
  }

  Future<void> _requestAssets() async {
    setState(() {
      _isLoading = true;
    });
    // Request permissions.
    final PermissionState _ps = await PhotoManager.requestPermissionExtend();
    if (!mounted) {
      return;
    }
    // Further requests can be only procceed with authorized or limited.
    if (_ps != PermissionState.authorized && _ps != PermissionState.limited) {
      setState(() {
        _isLoading = false;
      });
      //showToast('Permission is not granted.');
      return;
    }
    // Obtain assets using the path entity.
    print("assetPathList");
    assetPathList = await PhotoManager.getAssetPathList();
    if (!mounted) {
      return;
    }
    // Return if not paths found.
    if (assetPathList.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      // showToast('No paths found.');
      return;
    }
    setState(() {
      _path = assetPathList.first;
    });
    loadImages();
  }

  Future<void> loadImages() async {
    _totalEntitiesCount = 0;

    _page = 0;
    _isLoading = false;
    _isLoadingMore = false;
    _hasMoreToLoad = true;
    entity = null;
    _multiEntities = [];
    _totalEntitiesCount = _path!.assetCount;
    final List<AssetEntity> entities = await _path!.getAssetListPaged(
      page: 0,
      size: _sizePerPage,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      print("_entities");
      print(entities);
      for (int i = 0; i < entities.length; i++) {
        MultiSelection multiSelection = new MultiSelection();
        multiSelection.assetEntity = entities[i];
        _multiEntities!.add(multiSelection);
      }
      entity = _multiEntities![0].assetEntity;
      entity!.file.then((value) => {
            _file = value,
            if (!isEnableMultiSelection)
              {
                //selectedFiles=[],
                //selectedFiles!.add(_file!)
              },
            setState(() {})
          });
      _isLoading = false;
      _hasMoreToLoad = _multiEntities!.length < _totalEntitiesCount;
    });
  }

  Future<void> _loadMoreAsset() async {
    final List<AssetEntity> entities = await _path!.getAssetListPaged(
      page: _page + 1,
      size: _sizePerPage,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      for (int i = 0; i < entities.length; i++) {
        MultiSelection multiSelection = new MultiSelection();
        multiSelection.assetEntity = entities[i];
        _multiEntities!.add(multiSelection);
      }
      //_multiEntities!.addAll(entities);
      _page++;
      _hasMoreToLoad = _multiEntities!.length < _totalEntitiesCount;
      _isLoadingMore = false;
    });
  }

  getImagesPath() async {
    var assetPathList =
        await PhotoManager.getAssetPathList(type: RequestType.image);
    assetPathList.addAll(assetPathList);
    final List<AssetEntity> entities = await _path!.getAssetListPaged(
      page: 0,
      size: _path!.assetCount,
    );
    print("assetPathList");
    print(assetPathList);
    /* var imagePath = await StoragePath.imagesPath;
    var images = jsonDecode(imagePath) as List;*/
    files = []; // images.map<FileModel>((e) => FileModel.fromJson(e)).toList();
    /*if (files != null && files!.length > 0)
      setState(() {
        selectedModel = files![0];
        image = files![0].files![0];
      });*/
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    if (_path == null) {
      return const Center(child: Text('Request paths first.'));
    }
    if (_multiEntities?.isNotEmpty != true) {
      return const Center(child: Text('No assets found on this device.'));
    }
    return Container(
      child: GridView.custom(
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
        ),
        childrenDelegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            if (index == _multiEntities!.length - 8 &&
                !_isLoadingMore &&
                _hasMoreToLoad) {
              _loadMoreAsset();
            }
            final AssetEntity entiy = _multiEntities![index].assetEntity!;
            return Container(child: Stack(
              children: [
                Container(
                  child: ImageItemWidget(
                    key: ValueKey<int>(index),
                    entity: entiy,
                    option:
                    const ThumbnailOption(size: ThumbnailSize.square(200)),
                    onTap: () async {
                      print("entity!.type!");
                      if (isEnableMultiSelection) {
                        _multiEntities![index].isSelect =
                        !_multiEntities![index].isSelect;
                      }

                      if (isEnableMultiSelection) {
                        if (_multiEntities![index].isSelect) {
                          print(index.toString());
                          print(lastSelectedPos.toString());
                          if (!selectedFiles!.contains(_file!)) {
                            print("addFiles");
                            //lastSelectedPos=index;
                            if (entity!.type != AssetType.video) {
                              selectedFiles!.add(_file!);
                              final imageBytes = await Cropper.crop(
                                cropperKey: _cropperKey,
                              );
                              final imageFile =
                              await getFileFromUnit8(imageBytes!);
                              print(imageFile.path);
                              croppedFiles!.add(imageFile);
                              setState(() {});
                            } else {
                              selectedFiles!.add(_file!);
                              croppedFiles!.add(_file!);
                            }
                          }
                        } else {
                          deleteFiles();
                        }
                      } else {
                        selectedFiles = [];
                        selectedFiles!.add(_file!);
                      }
                      entity = _multiEntities![index].assetEntity!;
                      _file = await entity!.file;
                      setState(() {});
                      print(entity!.type);
                    },
                    onLong: () {
                      if (!isEnableMultiSelection) {
                        selectedFiles = [];
                        _multiEntities![index].isSelect = true;
                        isEnableMultiSelection = true;
                        entity = _multiEntities![index].assetEntity!;
                        print("entity!.type!");
                        entity!.file.then((value) => {
                          _file = value,
                          // addFiles(index, value!),
                          /*if(!selectedFiles!.contains(_file!)){
                        //selectedFiles!.add(_file!)
                      }*/
                          setState(() {})
                        });
                        print(entity!.type);
                        setState(() {});
                      }
                    },
                  ),
                  width: double.infinity,
                ),
                entiy.type == AssetType.video
                    ? Align(
                  child: Container(
                    child: Text(
                      formatedTime(entiy.duration),
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    margin: EdgeInsets.all(5),
                  ),
                  alignment: Alignment.bottomRight,
                )
                    : Container(),
                isEnableMultiSelection
                    ? Align(
                  child: Container(
                    width: 30,
                    height: 20,
                    child: Checkbox(
                        value: _multiEntities![index].isSelect,
                        onChanged: (value) {
                          _multiEntities![index].isSelect =
                          !_multiEntities![index].isSelect;
                          entity = _multiEntities![index].assetEntity!;
                          print("entity!.type!");
                          entity!.file.then((value) => {
                            _file = value,
                            if (_multiEntities![index].isSelect)
                              {
                                if (!selectedFiles!.contains(_file!))
                                  {selectedFiles!.add(_file!)}
                              }
                            else
                              {selectedFiles!.remove(_file!)},
                            setState(() {})
                          });
                          print(entity!.type);
                          setState(() {});
                        }),
                    margin: EdgeInsets.only(top: 5, right: 0, bottom: 0),
                  ),
                  alignment: Alignment.topRight,
                )
                    : Container()
              ],
            ),margin: EdgeInsets.only(left: 1),);
          },
          childCount: _multiEntities!.length,
          findChildIndexCallback: (Key key) {
            // Re-use elements.
            if (key is ValueKey<int>) {
              return key.value;
            }
            return null;
          },
        ),
      ),
      height: 270,
    );
  }
  Future<void> captureImage(imageSource) async {
    final XFile? image = await _picker.pickImage(source: imageSource);
    var images=image;
    if (image != null && image.path.isNotEmpty) {
      selectedFiles=[];
      _file = File(images!.path);
      selectedFiles!.add(_file!);
      imageFile =_file;
      fileName = Path.basename(imageFile!.path);
      var image = imageLib.decodeImage(
          await imageFile!.readAsBytes());
      await Navigator.push(
        context,
        new MaterialPageRoute(
          builder: (context) =>
          new FilterPhotoFilterSelector(
            title: Text("Filter"),
            image: image!,
            circleShape: false,
            filters: presetFiltersList,
            filename: fileName!,
            appBarColor: Colors.white,
            loader: Center(
                child: CircularProgressIndicator()),
            fit: BoxFit.contain,
          ),
        ),
      ).then((value) => {
        print("value great"),
        if (value != null)
          {Navigator.of(context).pop(true)}
        //
      });
    }
  }
  Future<void> storeImageToFile() async {
    final imageBytes = await Cropper.crop(
      cropperKey: _cropperKey,
    );
    File imageFile = await getFileFromUnit8(imageBytes!);
    croppedFiles!.add(imageFile);
  }

  void addFiles(int index, File file) async {}

  void deleteFiles() {
    int pos = selectedFiles!.indexWhere((element) => element == _file);
    if (pos != -1) {
      selectedFiles!.removeAt(pos);
      croppedFiles!.removeAt(pos);
    }
  }

  String formatedTime(int secTime) {
    String getParsedTime(String time) {
      if (time.length <= 1) return "0$time";
      return time;
    }

    int min = secTime ~/ 60;
    int sec = secTime % 60;

    String parsedTime =
        getParsedTime(min.toString()) + " : " + getParsedTime(sec.toString());

    return parsedTime;
  }

  Widget buildContent(BuildContext context) {
    if (entity!.type == AssetType.audio) {
      return const Center(
        child: Icon(Icons.audiotrack, size: 30),
      );
    } else if (entity!.type == AssetType.video) {
      return _file != null
          ? Center(
              child: VideoViewWidget(
                url: _file,
                play: true,
              ),
            )
          : Container();
    }
    return _file != null
        ? _buildImageWidget(
            entity!, ThumbnailOption(size: ThumbnailSize.square(300)))
        : Container();
  }

  Widget _buildImageWidget(AssetEntity entity, ThumbnailOption option) {
    File file = _file!;
    Uint8List bytes = file.readAsBytesSync();
    return Cropper(
            cropperKey: _cropperKey,
            aspectRatio: 1.2,
            overlayType: _overlayType,
            rotationTurns: _rotationTurns,
            image: Image.memory(
                bytes!)) /*Crop(cornerDotBuilder: (size, edgeAlignment) =>
    const SizedBox.shrink(),
        interactive: true,initialAreaBuilder: (rect) {
      return Rect.fromLTRB(
        rect.left +2,
        rect.top+2,
        rect.right - 2,
        rect.bottom - 2,
      );
    },fixArea: true,
        radius: 0,maskColor:null,image: bytes,controller: _cropController,onCropped: (onCropped){
       print("cropped");
    })*/ /*AssetEntityImage(
      entity,
      isOriginal: false,
      thumbnailSize: option.size,
      thumbnailFormat: option.format,
      fit: BoxFit.fill,
    )*/
        ;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: assetPathList!.length > 0
              ? Column(
                  children: [
                    Container(
                      color: Colors.white,
                      child: Row(
                        children: [
                          Expanded(
                              child: Container(
                            child: Row(
                              children: [
                                InkWell(
                                  child: Container(
                                    child: Icon(Icons.close),
                                    padding: EdgeInsets.all(5),
                                  ),
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                Container(
                                  child: Text(
                                    "New Post",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontFamily: "Poppins-medium",
                                        fontWeight: FontWeight.bold),
                                  ),
                                  margin: EdgeInsets.only(left: 20),
                                )
                              ],
                            ),
                          )),
                          InkWell(
                            child: Container(
                              child: Text(
                                "NEXT",
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 18,
                                    fontFamily: "Poppins-medium",
                                    fontWeight: FontWeight.bold),
                              ),
                              margin: EdgeInsets.only(right: 20),
                            ),
                            onTap: () async {
                              imageFile = _file;
                              if (selectedFiles!.length == 0) {
                                if (entity!.type == AssetType.video) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            PostWithMessageWidget(
                                              imageFile: imageFile,
                                              selectedFiles: selectedFiles,
                                              isVideoUpload: true,
                                            )),
                                  ).then((value) => {
                                        print("value great"),
                                        if (value != null)
                                          {Navigator.of(context).pop(true)}
                                      });
                                } else {
                                  final imageBytes = await Cropper.crop(
                                    cropperKey: _cropperKey,
                                  );
                                  imageFile =
                                      await getFileFromUnit8(imageBytes!);
                                  fileName = Path.basename(imageFile!.path);
                                  var image = imageLib.decodeImage(
                                      await imageFile!.readAsBytes());
                                  await Navigator.push(
                                    context,
                                    new MaterialPageRoute(
                                      builder: (context) =>
                                          new FilterPhotoFilterSelector(
                                        title: Text("Filter"),
                                        image: image!,
                                        circleShape: false,
                                        filters: presetFiltersList,
                                        filename: fileName!,
                                        appBarColor: Colors.white,
                                        loader: Center(
                                            child: CircularProgressIndicator()),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ).then((value) => {
                                        print("value great"),
                                        if (value != null)
                                          {Navigator.of(context).pop(true)}
                                        //
                                      });
                                }
                              } else {
                                if (entity!.type != AssetType.video) {
                                  selectedFiles!.add(_file!);
                                  final imageBytes = await Cropper.crop(
                                    cropperKey: _cropperKey,
                                  );
                                  File imageFile =
                                      await getFileFromUnit8(imageBytes!);
                                  croppedFiles!.add(imageFile);
                                } else {
                                  selectedFiles!.add(_file!);
                                  croppedFiles!.add(_file!);
                                }

                                print("uploaded size");
                                print(croppedFiles!.length);
                                for (int i = 0; i < croppedFiles!.length; i++) {
                                  print(croppedFiles![i].path);
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          PostWithMessageWidget(
                                            selectedFiles: croppedFiles,
                                            imageFile: croppedFiles![
                                                croppedFiles!.length - 1],
                                            isVideoUpload: true,
                                          )),
                                ).then((value) => {
                                      print("value great"),
                                      croppedFiles!
                                          .removeAt(croppedFiles!.length - 1),
                                      selectedFiles!
                                          .removeAt(selectedFiles!.length - 1),
                                      if (value != null)
                                        {Navigator.of(context).pop(true)}
                                    });
                              }
                            },
                          )
                        ],
                      ),
                      padding: EdgeInsets.only(top: 15, bottom: 15, left: 10),
                    ),
                    entity != null
                        ? Container(
                            child: buildContent(context),
                            width: double.infinity,
                            height: 300,
                          )
                        : Container(),
                    Container(
                        color: Colors.white,
                        child: Row(
                          children: [
                            Expanded(child: dropDownButtonsColumn()),
                            InkWell(child: Container(
                              child: Icon(Icons.camera_alt_sharp),
                            ),onTap: (){
                              captureImage(ImageSource.camera);
                            },)
                          ],
                        ),
                        padding: EdgeInsets.only(
                            top: 10, bottom: 10, left: 10, right: 5)),
                    Expanded(child: _buildBody(context))
                  ],
                )
              : Container()),
    );
  }

  Future<File> getFileFromUnit8(Uint8List uint8list) async {
    Uint8List imageInUnit8List = uint8list; // store unit8List image here ;
    final tempDir = await getApplicationDocumentsDirectory();
    DateTime dateNow = new DateTime.now();
    File file = await File(
            '${tempDir.path}/image_${dateNow.millisecondsSinceEpoch}.png')
        .create();
    file.writeAsBytesSync(imageInUnit8List);
    return file;
  }

  Widget dropDownButtonsColumn() {
    return Padding(
      padding: const EdgeInsets.only(left: 0, right: 5),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(3)),
            color: Color(0xFFF2F2F2)),
        // padding: const EdgeInsets.symmetric(horizontal: 13), //you can include padding to control the menu items
        child: Theme(
            data: Theme.of(context).copyWith(
                canvasColor: Colors.white,
                // background color for the dropdown items
                buttonTheme: ButtonTheme.of(context).copyWith(
                  alignedDropdown:
                      true, //If false (the default), then the dropdown's menu will be wider than its button.
                )),
            child: DropdownButtonHideUnderline(
              // to hide the default underline of the dropdown button
              child: DropdownButton<AssetPathEntity>(
                iconEnabledColor: Color(0xFF595959),
                // icon color of the dropdown button
                items: assetPathList.map((AssetPathEntity value) {
                  return DropdownMenuItem<AssetPathEntity>(
                    value: value,
                    child: Text(
                      value.name,
                      style: TextStyle(
                          color: Colors.black, fontFamily: "Poppins-medium"),
                    ),
                  );
                }).toList(),

                hint: Text(
                  _path!.name,
                  style: TextStyle(
                      color: Colors.black, fontFamily: "Poppins-medium"),
                ),
                // setting hint
                onChanged: (_) {
                  _file = null;
                  _path = _;
                  loadImages();
                }, // displaying the selected value
              ),
            )),
      ),
    );
  }
}

class ImageItemWidget extends StatelessWidget {
  const ImageItemWidget(
      {Key? key,
      required this.entity,
      required this.option,
      this.onTap,
      this.onLong})
      : super(key: key);

  final AssetEntity entity;
  final ThumbnailOption option;
  final GestureTapCallback? onTap;
  final GestureTapCallback? onLong;

  Widget buildContent(BuildContext context) {
    if (entity.type == AssetType.audio) {
      return const Center(
        child: Icon(Icons.audiotrack, size: 30),
      );
    }
    return _buildImageWidget(entity, option);
  }

  Widget _buildImageWidget(AssetEntity entity, ThumbnailOption option) {
    return AssetEntityImage(
      entity,
      isOriginal: false,
      thumbnailSize: option.size,
      thumbnailFormat: option.format,
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onLongPress: onLong,
      child: buildContent(context),
    );
  }
}

class FileModel {
  List<String>? files;
  String? folder;

  FileModel({this.files, this.folder});

  FileModel.fromJson(Map<String, dynamic> json) {
    files = json['files'].cast<String>();
    folder = json['folderName'];
  }
}
