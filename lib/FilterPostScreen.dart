import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as Path;
import 'package:photo_manager/photo_manager.dart';
import 'package:photofilters/filters/filters.dart';
import 'package:photofilters/filters/preset_filters.dart';
import 'package:photofilters/widgets/photo_filter.dart';
import 'package:image/image.dart' as imageLib;

class FilterPostScreen extends StatefulWidget {
  File? file;

  FilterPostScreen({this.file});

  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<FilterPostScreen> {
  List<FileModel> files = [];
  List<AssetPathEntity> assetPathList = [];
  FileModel? selectedModel;
  String? image;
  List<Filter> filters = presetFiltersList;
  String? fileName;
  File? imageFile;

  @override
  void initState() {
    super.initState();
    imageFile = widget.file;
    getImage();
  }

  Future getImage() async {
    if (imageFile != null) {
      fileName = Path.basename(imageFile!.path);
      var image = imageLib.decodeImage(await imageFile!.readAsBytes());
      image = imageLib.copyResize(image!, width: 600);
      Map imagefile = await Navigator.push(
        context,
        new MaterialPageRoute(
          builder: (context) => new PhotoFilterSelector(
            title: Text("Filter"),
            image: image!,circleShape: false,
            filters: presetFiltersList,
            filename: fileName!,appBarColor: Colors.white,
            loader: Center(child: CircularProgressIndicator()),
            fit: BoxFit.contain,
          ),
        ),
      );

      if (imagefile != null && imagefile.containsKey('image_filtered')) {
        setState(() {
          imageFile = imagefile['image_filtered'];
        });
        print(imageFile!.path);
      }
    }
  }

  Widget _buildBody(BuildContext context) {
    return Container();
    /*Container(
      child: GridView.custom(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
        ),
        childrenDelegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            if (index == _entities!.length - 8 &&
                !_isLoadingMore &&
                _hasMoreToLoad) {
              _loadMoreAsset();
            }
            final AssetEntity entiy = _entities![index];
            return ImageItemWidget(
              key: ValueKey<int>(index),
              entity: entiy,
              option: const ThumbnailOption(size: ThumbnailSize.square(200)),onTap:(){
              entity=_entities![index];
              setState(() {

              });
            },
            );
          },
          childCount: _entities!.length,
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
    )*/
    ;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
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
                                  "",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                margin: EdgeInsets.only(left: 20),
                              )
                            ],
                          ),
                        )),
                    Container(
                      child: Text(
                        "NEXT",
                        style: TextStyle(
                            color: Colors.blue,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      margin: EdgeInsets.only(right: 20),
                    )
                  ],
                ),
                padding: EdgeInsets.only(top: 15, bottom: 15, left: 10),
              ),
              Container(
                child: Image.file(imageFile!),
                height: 300,
              ),
              /* Container(
                        color: Colors.white,
                        child: Row(
                          children: [
                            Expanded(
                                child: DropdownButton<AssetPathEntity>(
                              underline: SizedBox(),
                              hint: Text(
                                _path!.name,
                                style: TextStyle(color: Colors.black),
                              ),
                              items: assetPathList.map((AssetPathEntity value) {
                                return DropdownMenuItem<AssetPathEntity>(
                                  value: value,
                                  child: Text(value.name),
                                );
                              }).toList(),
                              onChanged: (_) {
                                _path = _;
                              },
                            )),
                            Container(
                              child: Icon(Icons.camera_alt_sharp),
                            )
                          ],
                        ),
                        padding: EdgeInsets.only(
                            top: 10, bottom: 10, left: 10, right: 10)),
                    _buildBody(context)*/
            ],
          )),
    );
  }
}

class ImageItemWidget extends StatelessWidget {
  const ImageItemWidget({
    Key? key,
    required this.entity,
    required this.option,
    this.onTap,
  }) : super(key: key);

  final AssetEntity entity;
  final ThumbnailOption option;
  final GestureTapCallback? onTap;

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
