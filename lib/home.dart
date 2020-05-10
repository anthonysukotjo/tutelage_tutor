import 'package:flutter/material.dart';
import 'package:tutelage_tutor/signin/login.dart';
import 'package:tutelage_tutor/signin/signinorup.dart';
import 'package:tutelage_tutor/viewtutorprofile.dart';
import 'edittutorprofile.dart';
import 'tabs/myansweredquestionslist.dart' as personalQnList;
import 'tabs/newquestionlist.dart' as allQnList;
import 'package:firebase_auth/firebase_auth.dart';
import 'tabs/leaderboard.dart'as leaderboard;

class MainPage extends StatefulWidget{

  final FirebaseUser user;

  const MainPage({
    Key key,
    this.user,
  }) : super(key: key);

  @override
  MainPageState createState() => new MainPageState(this.user);

}

class MainPageState extends State<MainPage> with SingleTickerProviderStateMixin {

  FirebaseUser user;

  MainPageState(this.user);

  TabController controller;


  @override
  void initState() {
    super.initState();
    controller = new TabController(vsync: this, length: 3);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Question List",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),

          ),
          automaticallyImplyLeading: false,
          centerTitle: true,
          backgroundColor: Colors.orange,
          actions: <Widget>[
            PopupMenuButton(
              icon: Icon(
                Icons.menu,
                color: Colors.black,),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Text("View Profile"),
                  value: TutorProfile(user: user, tutorName: user.email),
                ),
                PopupMenuItem(
                  child: Text("Log Out"),
                  value: signInOrUp(),
                ),
              ],

              onCanceled: () {
                print("You have canceled the menu.");
              },
              onSelected: (value) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => value),
                );
              },
            )






          ],
          bottom: new TabBar(
            controller: controller ,
            tabs: <Tab> [
              new Tab(text: "New Qns") ,
              new Tab(text: 'My Qns') ,
              new Tab(text: 'Leaderboard'),
            ],
            labelColor: Colors.black,
            indicatorColor: Colors.red,
          ),


        ),
        body: new TabBarView(
            controller: controller,
            children: <Widget>[
              new allQnList.NewQuestionListPage(user),
              new personalQnList.MyAnsweredQuestionsList(user),
              new leaderboard.LeaderBoard(user),
            ]),
      ),
    );
  }
}


