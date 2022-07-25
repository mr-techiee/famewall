import 'dart:async';

import 'package:famewall/api/ApiResponse.dart';
import 'package:famewall/api/BaseApiService.dart';
import 'package:famewall/api/LoadingUtils.dart';
import 'package:famewall/api/NetworkApiService.dart';
import 'package:famewall/helper/sizeConfig.dart';
import 'package:famewall/profile/HomeRoutes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../global.dart';

class SearchFeed extends StatefulWidget {

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<SearchFeed>
    with SingleTickerProviderStateMixin {
  TextEditingController controller = new TextEditingController();
  /*bool isLoading = false;
  int limit = 10;*/
  //ScrollController listScrollController = ScrollController();
  FocusNode focus = new FocusNode();
  RegExp exp = new RegExp(r"\B#\w\w+");
  List? allList;
  StreamSubscription? streamSubscription = null;
  List<SearchObject>searchList=[];
  BaseApiService baseApiService = NetworkApiService();
  ScrollController? scrollController;
  bool? isLoading = false;
  int? pageNumber = 1;
  late final UserResponse? userResponse;
  bool isFirstTime=false;
  void getArgs(){
    if(!isFirstTime){
      isFirstTime=true;
      final arguments = ModalRoute.of(context)!.settings.arguments as Map;
      userResponse=arguments["uObject"];
      focus.addListener(_onFocusChange);
      scrollController = ScrollController()..addListener(_scrollListener);

      streamSubscription = eventBus.on<ApiResponse>().listen((event) {
        //LoadingUtils.instance.hideOpenDialog();
        if (event.status == Status.COMPLETED) {
          if (event.data is SearchList) {
            isLoading = false;

            var postList = event.data as SearchList;
            if (!postList.iserror!) {

              searchList.addAll(postList.storyList);
              if(mounted){
                setState(() {});
              }
            } else {
              LoadingUtils.instance.showToast(postList.message);
            }
          }

        }
      });
      getSearchList("");
    }

  }
  @override
  void initState() {
  }

  void _onFocusChange() {
    print("Focus: " + focus.hasFocus.toString());
  }

  void _onTap() {
    setState(() {
      focus.hasFocus;
      print("Ontap: " + focus.hasFocus.toString());
    });
    FocusScope.of(context).requestFocus(focus);
  }

  @override
  void dispose() {
    focus.dispose();
    scrollController!.removeListener(_scrollListener);
    streamSubscription!.cancel();
    super.dispose();
  }

  void _scrollListener() {
    print(scrollController!.position.extentAfter);
    if (scrollController!.position.maxScrollExtent == scrollController!.offset) {
      if (searchList.length >= (10 * pageNumber!) && !isLoading!) {
        pageNumber = (pageNumber! + 1);
        isLoading = true;
        print("loadMore");
       getSearchList(controller.text.toString());
      }
    }
  }

  void startLoader() {
    if (mounted)
      setState(() {
        isLoading = true;
        fetchData();
      });
  }

  fetchData() async {
    var _duration = new Duration(seconds: 2);
    return new Timer(_duration, onResponse);
  }

  void onResponse() {
   /* if (mounted)
      setState(() {
        isLoading = false;
        limit = limit + 2;
      });*/
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    getArgs();
    return Scaffold(
      backgroundColor: Colors.white,resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: _searchTextfield(context),
        centerTitle: false,leadingWidth: 30,
        titleSpacing: 0,leading: Container(child: IconButton(
          onPressed: () {
            Navigator.maybePop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: appColorBlack,
          )),margin: EdgeInsets.only(left: 5,top: 5),),
        actions: [
          focus.hasFocus == true
              ? Container(
                  width: 80,
                  child: IconButton(
                      padding: const EdgeInsets.all(0),
                      onPressed: () {
                        setState(() {
                          searchList.clear();
                        //  _searchResult.clear();
                          controller.clear();
                          focus.unfocus();
                        });
                      },
                      icon: Text(
                        "Cancel",
                        maxLines: 1,
                        style: TextStyle(
                            color: appColorBlack,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      )),
                )
              : Container(),

          Container(width: 10),
        ],
      ),
      body: searchList.length>0?_getMoviesListView():Center(child: Container(child: Text("No result found"),),)
    );
  }

  Widget _userInfo() {
    return Container(padding: EdgeInsets.all(10),child: GridView.builder(
        itemCount:30,  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount:3),
        itemBuilder: (context, position) {
          return Container(child: Column(children: [
           Container(height: 110,child: Image.network("https://www.gravatar.com/avatar/205e460b479e2e5b48aec07710c08d50",fit: BoxFit.contain,),)
          ],),margin: EdgeInsets.only(left: 0),);
        }),);
  }

  Widget _getMoviesListView() {
    return ListView.builder(shrinkWrap: true,
        itemCount: searchList?.length,controller: scrollController,
        itemBuilder: (context, position) {
          return postDetails(searchList![position],position);
        });
  }

  Widget postDetails(SearchObject? document,pos) {
    return Container(child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        InkWell(
          onTap: () async {
            final v= await Navigator.of(context).pushNamed(HomeWidgetRoutes.screen2,arguments: {
              "uObject":userResponse,
              "searchObject":document
            });
            print("searchBack");
            print(userResponse!.username);
            isFirstTime=false;
            getArgs();
           /* Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Profile(userResponse: , ,)),
            );*/
            /*  if (globalID == document['idFrom']) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Profile(back: true)),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        PublicProfile(peerId: document['idFrom'])),
              );
            }*/
          },
          child: Padding(
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
                          fontSize:
                          SizeConfig.safeBlockHorizontal! * 3,
                          fontFamily: "Poppins-Medium",
                          color: Colors.grey),
                    ),

                  ),
                  /*Container(
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
                document.is_followed!.toLowerCase()=="no"?Container(
                  child: ElevatedButton(
                    onPressed: () {
                      searchList![pos].is_followed="yes";
                      followUser(document.userid!);
                      setState(() {

                      });
                    },
                    child: Text(
                      "Follow",
                      style: TextStyle(  fontFamily: "Poppins-medium",
                          color: Colors.white, fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                        primary: Color(0xFFC4861A)),
                  ),

                  margin: EdgeInsets.only(
                      left: 5, right: 5),
                ):InkWell(
                  onTap: () {
                    searchList![pos].is_followed="no";
                    unfollowUser(document.userid!);
                    setState(() {

                    });
                  },
                  child: Container(child: Text("Unfollow",textAlign: TextAlign.center,style: TextStyle(  fontFamily: "Poppins-medium",
                      color: Colors.black, fontSize: 12),),decoration: BoxDecoration(
                    border: Border.all(
                        width: 1.0,color:  Colors.grey
                    ),
                    borderRadius: BorderRadius.all(
                        Radius.circular(5.0) //                 <--- border radius here
                    ),
                  ),padding: EdgeInsets.all(8),margin: EdgeInsets.only(left: 2,right: 10),),
                ),
              ],
            ),
          ),
        ),
        Divider(),
        Container(
          height: 2,
        ),
      ],
    ),margin: EdgeInsets.only(top: 5),);
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
            onTap: _onTap,
            child: Container(
              color: Colors.white,
              child: TextField(
                controller: controller,
                onChanged: onSearchTextChanged,
                focusNode: focus,
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
                      const Radius.circular(20.0,),
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

  onSearchTextChanged(String text) async {
    searchList=[];
   // _searchUserResult.clear();
    if (text.isEmpty) {
      searchList=[];
      getSearchList("");
      setState(() {});
      return;
    }else{
      searchList=[];
      getSearchList(text);
    }

    setState(() {});
  }
  getSearchList(String text){
    var request = {
      'search_username': text
    };
    print("request");
   print(request);
    baseApiService.postResponse(
        "follower/search?perpage=10&page="+pageNumber.toString(), request, Status.SEARCH);
  }
  void followUser(String id){
    var request = {
      'following_userid': id
    };
    print("request");

    baseApiService.postResponse(
        "follow/add", request, Status.FOLLOW);
  }
  void unfollowUser(String id){

    baseApiService.deleteResponse(
        "unfollow/"+id, Status.FOLLOW);
  }
}

List _searchResult = [];

List _searchUserResult = [];
