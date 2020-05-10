import 'package:flutter/material.dart';
import '../addanswer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../viewquestion.dart';
import 'package:firebase_auth/firebase_auth.dart';

//all question list page
class NewQuestionListPage extends StatefulWidget {


  final FirebaseUser user;

  const NewQuestionListPage(this.user);

  @override
  State<StatefulWidget> createState() {

    return NewQuestionListPageState(this.user);
  }
}

class NewQuestionListPageState extends State<NewQuestionListPage>{

  FirebaseUser user;
  NewQuestionListPageState(this.user);



  //var  firestoredbunamedcollection = Firestore.instance.collection("question").snapshots();
  //var  firestoredbunamedcollection = Firestore.instance ;
  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body:
      StreamBuilder(
        stream:  Firestore
            .instance
            .collection("unansweredquestionlist")
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.data.documents.length == 0) {
            return new Container(
                child: new Center(
                  child: Text("All questions have been answered!"),
                ));
          } else return ListView.builder(
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context,int index){
              return Card(
                color: Colors.white,
                elevation: 2.0,
                child: ListTile(
                  title: Text(snapshot.data.documents[index]['title']),
                  subtitle: Text("Level: ${snapshot.data.documents[index]['level']}, Subject: ${snapshot.data.documents[index]['subject']}, Posted on: ${snapshot.data.documents[index]['timestamp']}"),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      //moves to page for more details on selected question
                      return ViewQuestion(snapshot.data.documents[index].documentID, user, snapshot.data.documents[index]['askedBy'], snapshot.data.documents[index]['askedOrAnswered']);
                    }));
                  },
                  //Text(snapshot.data.documents[index]['title']);
                ),
              );
            }, //itemBuilder
          );
        },



      ),


    );

  }


}

