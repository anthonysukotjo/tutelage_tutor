import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:tutelage_tutor/chat/chatui.dart';
import 'package:tutelage_tutor/viewquestion.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tutelage_tutor/home.dart';

class ViewAnswer extends StatefulWidget {
  final String toAnsQnOrQn;
  final String studentUsername;
  final String answerID;
  final FirebaseUser user;
  ViewAnswer(
      {Key key,
        this.answerID,
        this.user,
        this.studentUsername,
        this.toAnsQnOrQn})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ViewAnswerState(
        this.answerID, this.user, this.studentUsername, this.toAnsQnOrQn);
  }
}

class ViewAnswerState extends State<ViewAnswer> {
  String toAnsQnOrQn;
  String answerID;
  FirebaseUser user;
  String studentUsername;
  ViewAnswerState(
      this.answerID, this.user, this.studentUsername, this.toAnsQnOrQn);
  String _imageURL;

  Future getImageURL() async {
    String path = 'answers/' + answerID;
    var cloudstorageRef = FirebaseStorage.instance.ref().child(path);
    await cloudstorageRef
        .getDownloadURL()
        .then((value) => {
      setState(() {
        _imageURL = value;
        debugPrint("PING " + value);
      })
    })
        .catchError((e) => debugPrint("No URL"));
  }

  @override
  Widget build(BuildContext context) {
    var firestoreRef = Firestore.instance
        .collection("askedquestions")
        .document("user_" + studentUsername)
        .collection("answers")
        .document(answerID)
        .snapshots();

    return WillPopScope(
        onWillPop: () {
          Navigator.pop(context, true);
        },
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              "Answer",
              style:
              TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
            backgroundColor: Colors.orange,
            leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.pop(context, true);
                }),
          ),
          body: Padding(
            padding: EdgeInsets.all(20.0),
            child: StreamBuilder(
                stream: firestoreRef,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (_imageURL == null)
                    getImageURL()
                        .catchError((e) => debugPrint("Caught at THIS"));
                  return ListView(
                    children: <Widget>[
//timestamp
                      Padding(
                          padding: EdgeInsets.only(
                            top: 1.0,
                            bottom: 5.0,
                          ),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Container(
                                  child: Text(
                                    snapshot.data['timestamp'],
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    "Written By ${snapshot.data['writtenBy']}",
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ])),

                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Container(
                            alignment: Alignment.topLeft,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.orangeAccent.shade100,
                            ),
                            child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Text(
                                  snapshot.data['description'],
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                ))),
                      ),

                      Padding(
                          padding: EdgeInsets.all(10.0),
                          child: _imageURL != null
                              ? Image.network(_imageURL)
                              : Text('')
                      ),

                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: isClosed()? Container(
                                color: Colors.lightGreenAccent[200],
                                child: Text(
                                  completedYet(),
                                  textAlign: TextAlign.center,

                                ),
                              ):
                              Container(
                                  color: Colors.redAccent.shade100,
                                  child: Text(
                                    completedYet(),
                                    textAlign: TextAlign.center,
                                  )
                              ),
                            ),
                            Container(
                              width: 10.0,
                            ),
                            Expanded(
                              child: RaisedButton(
                                color: Colors.lightGreenAccent.shade100,
                                textColor: Colors.black,
                                child: Text(
                                  'Chat with Student',
                                ),
                                onPressed: () {
                                  setState(() {
                                    debugPrint("Chat button clicked");
                                    answerChat();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
          ),
        ));
  }

  bool isClosed(){
    if(toAnsQnOrQn=="questions") return false;
    else if (toAnsQnOrQn=="answeredQuestions")return true;
  }
  String completedYet() {
    if (toAnsQnOrQn == "questions") {
      return "Student has not closed question";
    } else if (toAnsQnOrQn == "answeredQuestions") {
      return "Question has been closed";
    }
    return "ERROR";
  }

//  final String studentUsername;
//  final String ansID;
//  final FirebaseUser user;

  void answerChat() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return chatPage(
        studentUsername: studentUsername,
        ansID: answerID,
        user: user,
      );
    }));
  }

  void deleteFromPending(String userId) async {
    //string is user ID
    String docID = answerID.substring(0, answerID.length - 4);

    //TODO: update to delete from pending database and add to

    DocumentReference fromPending = Firestore.instance
        .collection("askedquestions")
        .document(userId)
        .collection("questions")
        .document(docID);

    DocumentReference toHistory = Firestore.instance
        .collection("askedquestions")
        .document(userId)
        .collection("answeredQuestions")
        .document(docID);

    fromPending.get().then((dataSnapshot) {
      if (dataSnapshot.exists) {
        toHistory.setData(dataSnapshot.data).then((data) {
          fromPending.delete();
          print("File transferred successfully");
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return MainPage(user: user);
          }));
        }).catchError((e) => print(e));
      }
    });
  }

  void completedYetButton(String string) {
    if (studentUsername == "questions") {
      deleteFromPending(string);
    } else
      return null;
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}
