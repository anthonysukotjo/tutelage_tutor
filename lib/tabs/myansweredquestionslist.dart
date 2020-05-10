import 'package:flutter/material.dart';
import '../addanswer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../viewquestion.dart';
import 'package:firebase_auth/firebase_auth.dart';


class MyAnsweredQuestionsList extends StatefulWidget {

  final FirebaseUser user;

  MyAnsweredQuestionsList(this.user);

  @override
  createState() {
    return new MyAnsweredQuestionsListState(this.user);
  }
}

class MyAnsweredQuestionsListState extends State<MyAnsweredQuestionsList> {

  FirebaseUser user;
  MyAnsweredQuestionsListState(this.user);

  @override
  Widget build(BuildContext context) {

    String usernameCategory = "tutor_" + user.email;

    return Scaffold(

      body:
      StreamBuilder(
        stream:  Firestore
            .instance
            .collection("answeredquestions")
            .document(usernameCategory)
            .collection("questions")
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
                  child: Text("You have no questions. Answer a question!"),
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
                      //ViewQuestion(this.selectedDocID, this.user, this.studentUsername, this.toAnsQnOrQn);
                      return ViewQuestion(snapshot.data.documents[index].documentID, user, snapshot.data.documents[index]['askedBy'], snapshot.data.documents[index]['askedOrAnswered'] );
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