import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:famewall/PrefUtils.dart';
import 'package:famewall/api/ApiResponse.dart';
import 'package:famewall/api/BaseApiService.dart';
import 'package:famewall/api/LoadingIndicator.dart';
import 'package:famewall/api/LoadingUtils.dart';
import 'package:famewall/api/NetworkApiService.dart';
import 'package:famewall/chat/chat_history_screen/widgets/chat_item.dart';
import 'package:famewall/chat/chat_history_screen/widgets/user_details.dart';
import 'package:famewall/helper/sizeConfig.dart';
import 'package:flutter/material.dart';

class ChatHistoryScreen extends StatefulWidget {
  ChatHistoryScreen({Key? key}) : super(key: key);

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  String userId = "";
  List<SearchObject> searchList = [];
  int pageNumber = 1;
  bool isLoading = false;
  StreamSubscription? streamSubscription;
  Timer? _debounce;
  bool isSearching = false;
  BaseApiService baseApiService = NetworkApiService();
  TextEditingController inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    LoadingUtils.instance.setContext(context);
    userId = PreferenceUtils.getString("userId", "");
  }

  getSearchList(String text) {
    var request = {'search_username': text};
    baseApiService.postResponse(
      "follower/search?perpage=10&page=" + pageNumber.toString(),
      request,
      Status.SEARCH,
    );
  }

  onSearchTextChanged(String text) async {
    searchList = [];
    pageNumber = 1;
    if (text.isEmpty) {
      isSearching = false;
      setState(() {});
      _debounce?.cancel();
      return;
    }
    isSearching = true;
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {});
      getSearchList(text);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: const Text(
          "Message",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontFamily: "Poppins-medium",
            fontSize: 14,
          ),
        ),
        leading: Container(),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Divider(),
            Container(
              padding: const EdgeInsets.all(16.0),
              height: 72,
              child: InkWell(
                onTap: () {},
                child: Container(
                  color: Colors.white,
                  child: TextField(
                    controller: inputController,
                    onChanged: onSearchTextChanged,
                    // focusNode: focus,
                    style: const TextStyle(color: Colors.grey),
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[200]!),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(20.0),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[200]!),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(
                            20.0,
                          ),
                        ),
                      ),
                      filled: true,
                      hintStyle: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      hintText: "Search",
                      contentPadding: const EdgeInsets.only(top: 10.0),
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
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("chatList")
                  .doc(userId)
                  .collection(userId)
                  .orderBy("timestamp", descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (isSearching) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height - 160,
                    width: MediaQuery.of(context).size.width,
                    child: SearchProfile(),
                  );
                }
                if (snapshot.hasData) {
                  List chatList = (snapshot.data as QuerySnapshot).docs;
                  return SizedBox(
                    height: MediaQuery.of(context).size.height - 160,
                    width: MediaQuery.of(context).size.width,
                    child: (snapshot.data as QuerySnapshot).docs.isNotEmpty
                        ? ListView.builder(
                            itemCount: chatList.length,
                            itemBuilder: (context, int index) {
                              return ChatItem(document: chatList[index].data());
                            },
                          )
                        : SizedBox(
                            height: MediaQuery.of(context).size.height * 0.75,
                            child: const Center(
                              child: Text("You don't have any messages."),
                            ),
                          ),
                  );
                }
                return Container(
                  height: MediaQuery.of(context).size.height * 0.8,
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                  child: LoadingIndicator(text: "Loading Messages"),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SearchProfile extends StatefulWidget {
  SearchProfile({Key? key}) : super(key: key);

  @override
  State<SearchProfile> createState() => _SearchProfileState();
}

class _SearchProfileState extends State<SearchProfile> {
  TextEditingController inputController = TextEditingController();
  late ScrollController scrollController;
  BaseApiService baseApiService = NetworkApiService();
  List<SearchObject> searchList = [];
  int pageNumber = 1;
  bool? isLoading = false;
  StreamSubscription? streamSubscription;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController()..addListener(_scrollListener);
    streamSubscription = eventBus.on<ApiResponse>().listen((event) {
      //LoadingUtils.instance.hideOpenDialog();
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
      }
    });
    // getSearchList("");
  }

  getSearchList(String text) {
    var request = {'search_username': text};
    baseApiService.postResponse(
      "follower/search?perpage=10&page=" + pageNumber.toString(),
      request,
      Status.SEARCH,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _debounce?.cancel();
    scrollController.removeListener(_scrollListener);
    streamSubscription!.cancel();
  }

  onSearchTextChanged(String text) async {
    searchList = [];
    pageNumber = 1;
    if (text.isEmpty) {
      setState(() {});
      _debounce?.cancel();
      return;
    }
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {});
      getSearchList(text);
    });
  }

  void _scrollListener() {
    if (scrollController.position.maxScrollExtent == scrollController.offset) {
      if (searchList.length >= (10 * pageNumber) && !isLoading!) {
        pageNumber = (pageNumber + 1);
        isLoading = true;
        getSearchList(inputController.text.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return ListView(
      controller: scrollController,
      children: [
        searchList.isNotEmpty
            ? Column(
                children: searchList
                    .map(
                      (e) => UserDetails(document: e),
                    )
                    .toList(),
              )
            : SizedBox(
                height: MediaQuery.of(context).size.height * 0.75,
                child: const Center(
                  child: Text("No results found."),
                ),
              ),
        if (searchList.isNotEmpty) const SizedBox(height: 50),
      ],
    );
  }
}
