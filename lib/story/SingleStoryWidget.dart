import 'package:famewall/api/ApiResponse.dart';
import 'package:famewall/profile/HomeRoutes.dart';
import 'package:famewall/story/StoryController.dart';
import 'package:famewall/story/StoryView.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path/path.dart' as Path;

class StoryViewWidget extends StatelessWidget {
  final StoryController controller = StoryController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Delicious Ghanaian Meals"),
      ),
      body: Container(
        margin: EdgeInsets.all(
          8,
        ),
        child: ListView(
          children: <Widget>[
            Container(
              height: 300,
              child: StoryView(
                controller: controller,
                storyItems: [
                  StoryItem.text(
                    title:
                        "Hello world!\nHave a look at some great Ghanaian delicacies. I'm sorry if your mouth waters. \n\nTap!",
                    backgroundColor: Colors.orange,
                    roundedTop: true,
                  ),
                  // StoryItem.inlineImage(
                  //   NetworkImage(
                  //       "https://image.ibb.co/gCZFbx/Banku-and-tilapia.jpg"),
                  //   caption: Text(
                  //     "Banku & Tilapia. The food to keep you charged whole day.\n#1 Local food.",
                  //     style: TextStyle(
                  //       color: Colors.white,
                  //       backgroundColor: Colors.black54,
                  //       fontSize: 17,
                  //     ),
                  //   ),
                  // ),
                  StoryItem.inlineImage(
                    url:
                        "https://image.ibb.co/cU4WGx/Omotuo-Groundnut-Soup-braperucci-com-1.jpg",
                    controller: controller,
                    caption: Text(
                      "Omotuo & Nkatekwan; You will love this meal if taken as supper.",
                      style: TextStyle(
                        color: Colors.white,
                        backgroundColor: Colors.black54,
                        fontSize: 17,
                      ),
                    ),
                  ),
                  StoryItem.inlineImage(
                    url:
                        "https://media.giphy.com/media/5GoVLqeAOo6PK/giphy.gif",
                    controller: controller,
                    caption: Text(
                      "Hektas, sektas and skatad",
                      style: TextStyle(
                        color: Colors.white,
                        backgroundColor: Colors.black54,
                        fontSize: 17,
                      ),
                    ),
                  )
                ],
                onStoryShow: (s) {
                  print("Showing a story");
                },
                onComplete: () {
                  print("Completed a cycle");
                },
                progressPosition: ProgressPosition.bottom,
                repeat: false,
                inline: true,
              ),
            ),
            Material(
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => MoreStories()));
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius:
                          BorderRadius.vertical(bottom: Radius.circular(8))),
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      Text(
                        "View more stories",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MoreStories extends StatefulWidget {


  @override
  _MoreStoriesState createState() => _MoreStoriesState();
}

class _MoreStoriesState extends State<MoreStories> {
  final storyController = StoryController();
  List<StoryItem> storyList = [];
  bool isMyStory = false;
 int allPos=1;
 String userName="";
 String profileImage="";
  List<StoryObject>? myStoryList = [];
  List<AllStoryMainObject>? allStoriesList = [];
  bool? isFirstTime=false;
  void getArgument(){
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    userName=arguments["userName"]!=null?arguments["userName"]:"";
    myStoryList=arguments["myStoryList"];
    allPos=arguments["allPos"];
    profileImage=arguments["profileImage"]!=null?arguments["profileImage"]:"";
    allStoriesList=arguments["allStoriesList"];

    if (myStoryList != null&&myStoryList!.length>0) {
      isMyStory = true;
      userName=userName!;
      profileImage=profileImage!;
      for (int i = 0; i < myStoryList!.length; i++) {
        final extension = Path.extension(myStoryList![i].filepath!);
        if(extension.contains(".mp4")){
          DateTime tempDate = new DateFormat("yyyy-MM-ddTHH:mm:ss.SSSZ").parse(myStoryList![i].createdon!,true);
          String day="Yesterday";
          if(calculateDifference(tempDate)==0){
            print("Today");
            day="Today";
          }
          String uploadedTime=DateFormat("hh:mm").format(tempDate.toLocal());
          print(uploadedTime);
          uploadedTime=day+" "+uploadedTime;
          storyList.add(StoryItem.pageVideo(myStoryList![i].filepath!, controller: storyController,uploadedTime:uploadedTime));

        }else{
          DateTime tempDate = new DateFormat("yyyy-MM-ddTHH:mm:ss.SSSZ").parse(myStoryList![i].createdon!,true);
          String day="Yesterday";
          if(calculateDifference(tempDate)==0){
            print("Today");
            day="Today";
          }
          String uploadedTime=DateFormat("hh:mm").format(tempDate.toLocal());
          print(uploadedTime);
          uploadedTime=day+" "+uploadedTime;
          storyList.add(StoryItem.pageImage(
              url: myStoryList![i].filepath!,
              caption: "",
              controller: storyController,uploadedTime:uploadedTime
          ));
        }

      }
    }else{
      userName=allStoriesList![allPos].userName!;
      profileImage=allStoriesList![allPos].profileimage!;
      print(allStoriesList!.length);
      print(allStoriesList![allPos].storyList.length);
      for (int i = 0; i < allStoriesList![allPos].storyList.length; i++) {
        final extension = Path.extension(allStoriesList![allPos].storyList[i].filepath!);
        print(allStoriesList![allPos].storyList[i].filepath!);
        print("allStoriesList![allPos].storyList[i].filepath!)");
        if(extension.contains(".mp4")){
          DateTime tempDate = new DateFormat("yyyy-MM-ddTHH:mm:ss.SSSZ").parse(allStoriesList![allPos].storyList[i].createdon!,true);
          String day="Yesterday";
          if(calculateDifference(tempDate)==0){
            print("Today");
            day="Today";
          }
          String uploadedTime=DateFormat("hh:mm").format(tempDate.toLocal());
          print(uploadedTime);
          uploadedTime=day+" "+uploadedTime;
          storyList.add(StoryItem.pageVideo(allStoriesList![allPos].storyList[i].filepath!, controller: storyController,uploadedTime: uploadedTime));
        }else{
          DateTime tempDate = new DateFormat("yyyy-MM-ddTHH:mm:ss.SSSZ").parse(allStoriesList![allPos].storyList[i].createdon!,true);
          String day="Yesterday";
          if(calculateDifference(tempDate)==0){
            print("Today");
            day="Today";
          }
          String uploadedTime=DateFormat("hh:mm").format(tempDate.toLocal());
          print(uploadedTime);
          uploadedTime=day+" "+uploadedTime;
          storyList.add(StoryItem.pageImage(
            url: allStoriesList![allPos].storyList[i].filepath!,
            caption: "",uploadedTime: uploadedTime,
            controller: storyController,
          ));
        }

      }
    }
  }
  @override
  void dispose() {
    storyController.dispose();
    super.dispose();
  }
  int calculateDifference(DateTime date) {
    DateTime now = DateTime.now();
    return DateTime(date.year, date.month, date.day).difference(DateTime(now.year, now.month, now.day)).inDays;
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    if(!isFirstTime!){
      isFirstTime=true;
       getArgument();
    }
    return Scaffold(
      body: storyList!=null?StoryView(
        storyItems:
            storyList,userName:userName==null?"": userName,profileImage: profileImage==null?"": profileImage /*[
          */ /*StoryItem.text(
            title: "I guess you'd love to see more of our food. That's great.",
            backgroundColor: Colors.blue,
          ),
          StoryItem.text(
            title: "Nice!\n\nTap to continue.",
            backgroundColor: Colors.red,
            textStyle: TextStyle(
              fontFamily: 'Dancing',
              fontSize: 40,
            ),
          ),
          StoryItem.pageImage(
            url:
            "https://image.ibb.co/cU4WGx/Omotuo-Groundnut-Soup-braperucci-com-1.jpg",
            caption: "Still sampling",
            controller: storyController,
          ),
          StoryItem.pageImage(
              url: "https://media.giphy.com/media/5GoVLqeAOo6PK/giphy.gif",
              caption: "Working with gifs",
              controller: storyController),
          StoryItem.pageImage(
            url: "https://media.giphy.com/media/XcA8krYsrEAYXKf4UQ/giphy.gif",
            caption: "Hello, from the other side",
            controller: storyController,
          ),
          StoryItem.pageImage(
            url: "https://media.giphy.com/media/XcA8krYsrEAYXKf4UQ/giphy.gif",
            caption: "Hello, from the other side2",
            controller: storyController,
          )*/ /*,
        ]*/
        ,
        onStoryShow: (s) {
          print("Showing a story");
        },
        onComplete: () {
          print("onComplete");
          if(isMyStory){
            Navigator.of(context).maybePop();
          }else{
            print(allPos);
            print(allStoriesList!.length-1);
            if(allPos==allStoriesList!.length-1){
              print("completed");
              Navigator.of(context).maybePop();
            }else{
              allPos++;
             /* storyList=[];
              for (int i = 0; i < allStoriesList![allPos].storyList.length; i++) {
                storyList.add(StoryItem.pageImage(
                  url:  allStoriesList![allPos].storyList[i].filepath!,
                  caption: "",
                  controller: storyController,
                ));
              }*/
              Navigator.of(context).pushReplacementNamed(HomeWidgetRoutes.screen8,arguments: {
                "allStoriesList":allStoriesList,"allPos":allPos
              });
            //  Navigator.pushReplacement(context, PageTransition(type: PageTransitionType.rotate, duration: Duration(seconds: 1), child: MoreStories(allStoriesList: allStoriesList,allPos: allPos,),alignment: Alignment.topCenter));

             /* Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MoreStories(allStoriesList: allStoriesList,allPos: allPos,)),
              );*/
             /* setState(() {

              });*/
            }
          }

          print("Completed a cycle");
        },
        progressPosition: ProgressPosition.top,
        repeat: false,
        controller: storyController,
      ):Container(),
    );
  }
}
