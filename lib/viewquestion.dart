import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:tutelage_tutor/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tutelage_tutor/addanswer.dart';
import 'package:tutelage_tutor/viewanswer.dart';


class ViewQuestion extends StatefulWidget {

  final String toAnsQnOrQn;
  final String selectedDocID;
  final FirebaseUser user;
  final String studentUsername;



  const ViewQuestion(this.selectedDocID, this.user, this.studentUsername, this.toAnsQnOrQn);

  @override
  State<StatefulWidget> createState() {
    return ViewQuestionState(this.selectedDocID, this.user, this.studentUsername, this.toAnsQnOrQn);
  }
}

class ViewQuestionState extends State<ViewQuestion> {

  String selectedDocID;
  String studentUsername;
  String toAnsQnOrQn;
  FirebaseUser user;
  String _imageURL;

  Future getImageURL () async {
    String path = 'questions/' + selectedDocID;
    var cloudstorageRef = FirebaseStorage.instance
        .ref()
        .child(path);
    await cloudstorageRef.getDownloadURL().then((value) => {
      setState(() {
        _imageURL = value;
        debugPrint("PING " +value);
      }
      )
    }).catchError((e)=> debugPrint("No URL")
    );
  }

  ViewQuestionState(this.selectedDocID, this.user, this.studentUsername, this.toAnsQnOrQn);


  //qn number on database
  @override
  Widget build(BuildContext context) {

    String usernameCategory = "user_" + user.email;
    var firestoreRef= Firestore.instance
        .collection("askedquestions")
        .document("user_" + studentUsername)
        .collection(toAnsQnOrQn)
        .document(selectedDocID)
        .snapshots();

    return WillPopScope(
        onWillPop: () {
          returnToHomeScreen(user);
        },

        child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                "Question",
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
                    returnToHomeScreen(user);
                  }),
            ),
            body: Padding(
              padding: EdgeInsets.all(20.0),
              child: StreamBuilder(
                stream: firestoreRef,
                builder: (context, snapshot){
                  if (!snapshot.hasData){
                    return Center(
                      child: CircularProgressIndicator(),
                    );}
                  if(_imageURL == null)getImageURL().catchError((e)=>debugPrint("Caught at THIS"));
                  return ListView(
                    children: <Widget> [
                      Padding(

                          padding: EdgeInsets.only(bottom: 10.0),
                          child: Text(
                            snapshot.data['title'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),)),


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
                                    "Level: ${snapshot.data['level']} Subject: ${snapshot.data['subject']}",
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold
                                    ),
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
                            child:
                            Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Text(
                                  snapshot.data['description'],
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                )
                            )
                        ),
                      ),
//Load uploaded image
                      Padding(
                          padding: EdgeInsets.all(10.0),
                          child:
                          _imageURL !=null?
                          Image.network(_imageURL)
                              : Text('')

                      ),


                      Padding(
                        padding: EdgeInsets.all(5.0),
                        child: GestureDetector(
                          //makeAnswer(String ansid, user, username, questionID)
                          onTap: () => makeAnswer(snapshot.data["answerID"] , user, studentUsername, selectedDocID),
                          child: Container(
                              height: 50,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.redAccent.shade100,
                              ),

                              child:
                              Padding(
                                  padding: EdgeInsets.all(5.0),
                                  child: Text( answeredYet(snapshot.data["answerID"], ),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                              )
                          ),

                        ),
                      ),


                    ],
                  );
                },
              ),






            )
        ));


  }

  void makeAnswer(String ansid, user, studentUsername, questionID) {
    if(ansid == null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return AddAnswer(user, studentUsername, questionID);
      }));} else Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ViewAnswer(answerID: ansid, user: user, studentUsername: studentUsername, toAnsQnOrQn: toAnsQnOrQn,);
    }));
  }

  String answeredYet(String ansId) {
    if(ansId == null) {
      return "Click to add Answer";
    } else return "View Answer";
  }




  void returnToHomeScreen(FirebaseUser user) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return MainPage(user: user);
    }));
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(
        context: context,
        builder: (_) => alertDialog
    );}


}

