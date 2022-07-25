import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:famewall/PrefUtils.dart';
import 'package:famewall/api/ApiResponse.dart';
import 'package:famewall/api/BaseApiService.dart';
import 'package:famewall/api/LoadingUtils.dart';
import 'package:famewall/api/NetworkApiService.dart';
import 'package:famewall/helper/sizeConfig.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:http/http.dart' as http;
import 'package:async/async.dart';

import 'package:location/location.dart' as loc;
import '../global.dart';

class EditProfile extends StatefulWidget {
  UserResponse? userResponse;

  EditProfile({this.userResponse});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  bool isLoading = false;
  TextEditingController controller = TextEditingController();

  TextEditingController nameController = TextEditingController();
  TextEditingController firstNameCntrl = TextEditingController();
  TextEditingController webController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  StreamSubscription? streamSubscription = null;
  BaseApiService baseApiService = NetworkApiService();

  UserResponse? userResponse = null;
  loc.Location location = new loc.Location();
  String locationData = "";
  bool? _serviceEnabled = false;
  loc.PermissionStatus? _permissionGranted;
  loc.LocationData? _locationData;
  bool isImageUpload = false;
  String gender = "Male";
  final ImagePicker _picker = ImagePicker();
  File? file = null;

  Future<void> captureImage(imageSource) async {
    final XFile? image = await _picker.pickImage(source: imageSource);
    if (image != null && image!.path!.isNotEmpty) {
      file = File(image!.path!);
      upload(file!);
    }
  }

  upload(File imageFile) async {
    var stream =
        new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    var length = await imageFile.length();

    var uri = Uri.parse("http://3.110.176.237:3000/updateprofileimage");
    Map<String, String> requestHeaders = {
      'Accept': 'application/json',
      'auth-key': PreferenceUtils.getString("token", "")
    };

    var request = new http.MultipartRequest("POST", uri);
    request.headers.addAll(requestHeaders);

    var multipartFile = new http.MultipartFile('profile_image', stream, length,
        filename: Path.basename(imageFile.path));
    //contentType: new MediaType('image', 'png'));
    LoadingUtils.instance.showLoadingIndicator("Please wait...");
    request.files.add(multipartFile);
    var response = await request.send();
    print(response.statusCode);
    response.stream.transform(utf8.decoder).listen((value) {
      LoadingUtils.instance.hideOpenDialog();
      streamSubscription!.cancel();
      print("multipartFile");
      print(value);
      Navigator.of(context).pop();
    });
  }

  Future<void> getLocationData() async {
    print("getLocationData");
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled!) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled!) {
        return;
      }
    }
    print("_locationData");
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == loc.PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted == loc.PermissionStatus.granted) {
        _locationData = await location.getLocation();
        print("_locationData");
        if (_locationData != null) {
          List<Placemark> placemarks = await placemarkFromCoordinates(
              _locationData!.latitude!, _locationData!.longitude!);
          if (placemarks.length > 0) {
            locationData = placemarks[0].locality! +
                "," +
                placemarks[0].administrativeArea!;
            print("locationData");
            print(locationData);
            // locationController.text=locationData;
          }
        }
      }
    } else {
      _locationData = await location.getLocation();
      print("_locationData");
      if (_locationData != null) {
        List<Placemark> placemarks = await placemarkFromCoordinates(
            _locationData!.latitude!, _locationData!.longitude!);
        if (placemarks.length > 0) {
          locationData =
              placemarks[0].locality! + "," + placemarks[0].administrativeArea!;
          print("locationData");
          print(locationData);
          // locationController.text=locationData;
        }
      }
    }
  }
bool isFirstTimeLoading=false;
  @override
  void initState() {
    super.initState();
    getLocationData();
    LoadingUtils.instance.setContext(context);

    userResponse = widget.userResponse;
    nameController.text = userResponse!.username!;
    firstNameCntrl.text = userResponse!.firstname!;
    webController.text = userResponse!.website!;
    bioController.text = userResponse!.bio!;
    emailController.text = userResponse!.email!;
    phoneController.text = userResponse!.mobileno!;
    genderController.text = userResponse!.gender!;
    locationController.text = userResponse!.location!;

    streamSubscription = eventBus.on<ApiResponse>().listen((event) {
      if(isFirstTimeLoading){
        LoadingUtils.instance.hideOpenDialog();
      }

      if (event.status == Status.COMPLETED) {
        var loginResponse = event.data as CommonResponse;
        if (!loginResponse.iserror!) {
         // Navigator.of(context).pop();
          LoadingUtils.instance.showToast(loginResponse.message);
          PreferenceUtils.setString("userName", nameController.text.toString());
        } else {
          LoadingUtils.instance.showToast(loginResponse.message);
        }
      }
    });
  }

  showGenderDialog() {
    Dialog errorDialog = Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      //this right here
      child: Container(
        height: 130.0,
        width: 300.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            InkWell(
              child: Padding(
                padding: EdgeInsets.all(15.0),
                child: Text(
                  'Male',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              onTap: () {
                gender = "Male";
                genderController.text = gender;
                setState(() {});
                Navigator.of(context!, rootNavigator: true).pop('dialog');
              },
            ),
            Divider(),
            InkWell(
              child: Padding(
                padding: EdgeInsets.all(15.0),
                child: Text(
                  'Female',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              onTap: () {
                gender = "Female";
                genderController.text = gender;
                setState(() {});
                Navigator.of(context!, rootNavigator: true).pop('dialog');
              },
            ),
            Padding(padding: EdgeInsets.only(top: 15.0)),
          ],
        ),
      ),
    );
    showDialog(
        context: context, builder: (BuildContext context) => errorDialog);
  }

  showImageChooser() {
    Dialog errorDialog = Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      //this right here
      child: Container(
        height: 130.0,
        width: 300.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            InkWell(
              child: Padding(
                padding: EdgeInsets.all(15.0),
                child: Row(
                  children: [
                    Text(
                      'Camera',
                      style: TextStyle(color: Colors.black),
                    )
                  ],
                ),
              ),
              onTap: () {
                Navigator.of(context!, rootNavigator: true).pop('dialog');
                captureImage(ImageSource.camera);
              },
            ),
            Divider(),
            InkWell(
              child: Padding(
                padding: EdgeInsets.all(15.0),
                child: Row(
                  children: [
                    Text(
                      'Gallery',
                      style: TextStyle(color: Colors.black),
                    )
                  ],
                ),
              ),
              onTap: () {
                Navigator.of(context!, rootNavigator: true).pop('dialog');
                captureImage(ImageSource.gallery);
              },
            ),
            Padding(padding: EdgeInsets.only(top: 15.0)),
          ],
        ),
      ),
    );
    showDialog(
        context: context, builder: (BuildContext context) => errorDialog);
  }

  @override
  void dispose() {
    super.dispose();
    streamSubscription!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
        backgroundColor: Colors.white,resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            "Edit Profile",
            style: TextStyle(
                fontSize: 16,
                fontFamily: "Poppins-medium",
                color: appColorBlack,
                fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: InkWell(
            child: Container(
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: "Poppins-medium",
                  fontSize: 12,
                ),
              ),
              margin: EdgeInsets.only(top: 20, left: 10),
            ),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          actions: [
            InkWell(
              onTap: () async {
                updateUser();
              },
              child: Container(
                child: Text(
                  'Update',
                  style: TextStyle(
                      color: Color(0xFFC4861A),
                      fontFamily: "Poppins-medium",
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
                margin: EdgeInsets.only(top: 20, right: 10),
              ),
            ),
          ],
        ),
        body: Stack(
          children: <Widget>[_userInfo2()],
        ));
  }

  Widget _userInfo2() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 0),
      child: Stack(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 40),
                Column(
                  children: [
                    userResponse!=null&&userResponse!.profileimage!.isNotEmpty?Container(
                      height: 100,
                      width: 100,
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          border:
                          Border.all(width: 2, color: Color(0xFFC4861A))),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(
                            userResponse!.profileimage!),
                        radius: 34,
                      ),
                    ):Container(
                      height: 100,
                      width: 100,
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          border:
                          Border.all(width: 2, color: Color(0xFFC4861A))),
                      child: CircleAvatar(
                        backgroundImage: AssetImage("assets/images/name.jpg"),
                        radius: 34,
                      ),
                    ),
                    Container(height: 5),
                    InkWell(
                      onTap: () {
                        showImageChooser();
                      },
                      child: Text(
                        "Change profile photo",
                        style: TextStyle(
                            fontFamily: "Poppins-medium",
                            color: Color(0xFFC4861A),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                Container(height: 20),
                divider(),
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 100,
                        child: Text(
                          "Name",
                          style: TextStyle(
                            fontFamily: "Poppins-Medium",
                            color: appColorBlack,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 0),
                          child: TextField(
                            controller: firstNameCntrl,
                            decoration: InputDecoration(
                              hintText: "Name",
                              hintStyle: TextStyle(
                                  fontFamily: "Poppins-medium",
                                  color: Colors.grey[500],
                                  fontSize: 14),
                              alignLabelWithHint: true,
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.black45, width: 0.5),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.black45, width: 0.5),
                              ),
                            ),
                            // scrollPadding: EdgeInsets.all(20.0),
                            // keyboardType: TextInputType.multiline,
                            // maxLines: 99999,
                            style:
                            TextStyle(color: appColorBlack, fontSize: 15),
                            autofocus: false,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                divider(),
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 100,
                        child: Text(
                          "User Name",
                          style: TextStyle(
                            fontFamily: "Poppins-Medium",
                            color: appColorBlack,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 0),
                          child: TextField(
                            controller: nameController,inputFormatters: [
                            FilteringTextInputFormatter.deny(
                                RegExp(r'\s'))
                          ],
                            decoration: InputDecoration(
                              hintText: "Enter Name",
                              hintStyle: TextStyle(
                                  fontFamily: "Poppins-medium",
                                  color: Colors.grey[500],
                                  fontSize: 14),
                              alignLabelWithHint: true,
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.black45, width: 0.5),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.black45, width: 0.5),
                              ),
                            ),
                            // scrollPadding: EdgeInsets.all(20.0),
                            // keyboardType: TextInputType.multiline,
                            // maxLines: 99999,
                            style:
                            TextStyle(color: appColorBlack, fontSize: 15),
                            autofocus: false,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: 100,
                        child: Text(
                          "Website",
                          style: TextStyle(
                            fontFamily: "Poppins-Medium",
                            color: appColorBlack,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 0),
                          child: TextField(
                            controller: webController,
                            decoration: InputDecoration(
                              hintText: "Enter Website",
                              hintStyle: TextStyle(
                                  fontFamily: "Poppins-medium",
                                  color: Colors.grey[500],
                                  fontSize: 14),
                              alignLabelWithHint: true,
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.black45, width: 0.5),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.black45, width: 0.5),
                              ),
                            ),
                            // scrollPadding: EdgeInsets.all(20.0),
                            // keyboardType: TextInputType.multiline,
                            // maxLines: 99999,
                            style:
                                TextStyle(color: appColorBlack, fontSize: 15),
                            autofocus: false,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 100,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            "Bio",
                            style: TextStyle(
                              fontFamily: "Poppins-Medium",
                              color: appColorBlack,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 0),
                          child: TextField(
                            controller: bioController,maxLength: 100,
                            decoration: InputDecoration(
                              hintText: "Enter Bio",
                              hintStyle: TextStyle(
                                  fontFamily: "Poppins-medium",
                                  color: Colors.grey[500],
                                  fontSize: 14),
                              alignLabelWithHint: true,
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.black45, width: 0.5),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.black45, width: 0.5),
                              ),
                            ),
                            scrollPadding: EdgeInsets.all(20.0),
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            style:
                                TextStyle(color: appColorBlack, fontSize: 15),
                            autofocus: false,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                divider(),
                Padding(
                  padding: const EdgeInsets.only(left: 15, top: 15),
                  child: InkWell(
                    onTap: () {},
                    child: Row(
                      children: [
                        Text(
                          'Private Information',
                          style: TextStyle(
                              fontFamily: "Poppins-medium",
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                Container(height: 10),
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 100,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            "Email",
                            style: TextStyle(
                              fontFamily: "Poppins-Medium",
                              color: appColorBlack,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 0),
                          child: TextField(
                            enabled: false,
                            controller: emailController,
                            decoration: InputDecoration(
                              hintText: "Enter Email",
                              hintStyle: TextStyle(
                                  fontFamily: "Poppins-medium",
                                  color: Colors.grey[500],
                                  fontSize: 14),
                              alignLabelWithHint: true,
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.black45, width: 0.5),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.black45, width: 0.5),
                              ),
                            ),
                            scrollPadding: EdgeInsets.all(20.0),
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            style:
                                TextStyle(color: appColorBlack, fontSize: 15),
                            autofocus: false,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 100,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            "Phone",
                            style: TextStyle(
                              fontFamily: "Poppins-Medium",
                              color: appColorBlack,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 0),
                          child: TextField(
                            controller: phoneController,
                            decoration: InputDecoration(
                              hintText: "Enter Phone number",
                              hintStyle: TextStyle(
                                  fontFamily: "Poppins-medium",
                                  color: Colors.grey[500],
                                  fontSize: 14),
                              alignLabelWithHint: true,
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.black45, width: 0.5),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.black45, width: 0.5),
                              ),
                            ),
                            scrollPadding: EdgeInsets.all(20.0),
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            style:
                                TextStyle(color: appColorBlack, fontSize: 15),
                            autofocus: false,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 100,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            "Gender",
                            style: TextStyle(
                              fontFamily: "Poppins-Medium",
                              color: appColorBlack,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 0),
                            child: TextField(
                              controller: genderController,
                              enabled: false,
                              decoration: InputDecoration(
                                hintText: "Gender",
                                hintStyle: TextStyle(
                                    fontFamily: "Poppins-medium",
                                    color: Colors.grey[500],
                                    fontSize: 14),
                                alignLabelWithHint: true,
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black45, width: 0.5),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black45, width: 0.5),
                                ),
                              ),
                              scrollPadding: EdgeInsets.all(20.0),
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              style:
                                  TextStyle(color: appColorBlack, fontSize: 15),
                              autofocus: false,
                            ),
                          ),
                          onTap: () {
                            showGenderDialog();
                          },
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 100,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            "Location",
                            style: TextStyle(
                              fontFamily: "Poppins-Medium",
                              color: appColorBlack,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 0),
                          child: TextField(
                            controller: locationController,
                            decoration: InputDecoration(
                              hintText: "Location",
                              prefixIcon: InkWell(
                                child: Icon(Icons.add_location),
                                onTap: () {
                                  locationController.text = locationData;
                                },
                              ),
                              hintStyle: TextStyle(
                                  fontFamily: "Poppins-medium",
                                  color: Colors.grey[500],
                                  fontSize: 14),
                              alignLabelWithHint: true,
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.black45, width: 0.5),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.black45, width: 0.5),
                              ),
                            ),
                            scrollPadding: EdgeInsets.all(20.0),
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            style:
                                TextStyle(color: appColorBlack, fontSize: 15),
                            autofocus: false,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget divider() {
    return Container(
      height: 0.5,
      color: Colors.grey[400],
    );
  }
  void updateUser() {
    var request = {
      'username': nameController.text,
      "firstname": firstNameCntrl.text,
      "lastname": userResponse!.firstname!,
      "bio": bioController.text,
      "gender": genderController.text,
      "location": locationController.text,
      "mobileno": phoneController.text,
      "website": webController.text
    };
    isFirstTimeLoading=true;
    LoadingUtils.instance.showLoadingIndicator("Please wait...");
    baseApiService.postResponse(
        "updateprofile", request, Status.UPDATE_PROFILE);
  }
}
