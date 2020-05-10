import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tutelage_tutor/viewtutorprofile.dart';

class LeaderBoard extends StatefulWidget {

  final FirebaseUser user ;
  const LeaderBoard(this.user);

  @override
  State<StatefulWidget> createState() {
    return new LeaderBoardState(this.user);
  }

}

class LeaderBoardState extends State<LeaderBoard> {

  FirebaseUser user;
  LeaderBoardState(this.user);

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body:  StreamBuilder(
          stream:  Firestore
              .instance
              .collection("tutorUserProfiles")
              .orderBy('totalPoints', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.data.documents.length == 0) {
              return new Container(
                  child: new Center(
                    child: Text("No users Found."),
                  ));
            } else return ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context,int index){
                return Card(
                    color: Colors.white,
                    elevation: 2.0,
                    child: ListTile(
                      title: Text(snapshot.data.documents[index]['tutorName']),
                      subtitle: Text("Total Points: ${snapshot.data.documents[index]['totalPoints']}"),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) {
                          return TutorProfile(user: user, tutorName: snapshot.data.documents[index]['tutorName']);
                        },
                          //Text(snapshot.data.documents[index]['title']);
                        ),
                        );
                      }, //itemBuilder
                    ));
              },
            );


          }
      ),


    );

  }

}
