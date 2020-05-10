import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tutelage_tutor/home.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddAnswer extends StatefulWidget {
  final FirebaseUser user;
  final String studentUsername;
  final String questionID;
  const AddAnswer(this.user, this.studentUsername, this.questionID);

  @override
  State<StatefulWidget> createState() {
    return AddAnswerState(this.user, this.studentUsername, this.questionID);
  }
}

class AddAnswerState extends State<AddAnswer> {
  FirebaseUser user;
  String studentUsername;
  String questionID;
  AddAnswerState(this.user, this.studentUsername, this.questionID);

  // Camera API
  File _image;

  Future getImage() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50);

    setState(() {
      _image = image;
    });
  }

  TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          moveToLastScreen();
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              "Add Answer",
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
                  // Write some code to control things, when user press back button in AppBar
                  moveToLastScreen();
                }),
          ),
          body: Padding(
            padding: EdgeInsets.all(10.0),
            child: ListView(
              children: <Widget>[
                // Second Element
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: TextField(
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: null,
                    controller: descriptionController,
                    onChanged: (value) {
                      debugPrint('Something changed in Description Text Field');
                    },
                    decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: RaisedButton(
                          onPressed: () {
                            getImage();
                            debugPrint("Image Pressed");
                          },
                          color: Colors.blue[300],
                          child: Text(
                            "Attach Image",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                    padding: EdgeInsets.all(10.0),
                    child: _image == null
                        ? Text(
                      "No Image Selected",
                      textAlign: TextAlign.center,
                    )
                        : Image.file(_image)),
                //Buttons below
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: RaisedButton(
                          color: Colors.lightGreenAccent.shade100,
                          textColor: Colors.black,
                          child: Text(
                            'Send',
                            textScaleFactor: 1.5,
                          ),
                          onPressed: () {
                            setState(() {
                              debugPrint("Send button clicked");
                              _send(studentUsername, questionID);
                            });
                          },
                        ),
                      ),
                      Container(
                        width: 10.0,
                      ),
                      Expanded(
                        child: RaisedButton(
                          color: Colors.redAccent[100],
                          textColor: Colors.black,
                          child: Text(
                            'Cancel',
                            textScaleFactor: 1.5,
                          ),
                          onPressed: () {
                            setState(() {
                              debugPrint("Cancel button clicked");
                              _cancel();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  // Save data to personal user database
  void _send(String studentUsername, String questionID) async {
    String answerID = questionID + '_ans';
    if (_image != null) uploadPicture(answerID);
    //save to student answerdatabase
    if (descriptionController.text.isNotEmpty) {
      Firestore.instance
          .collection("askedquestions")
          .document("user_" + studentUsername)
          .collection("answers")
          .document(answerID)
          .setData({
        "description": descriptionController.text,
        "timestamp": new DateFormat.yMMMd().add_jm().format(DateTime.now()),
        "writtenBy": user.email,
      }).then((response) {
        print("success");
      }).catchError((error) {
        print(error);
        _showAlertDialog('Error Status Local', 'Problem Saving Question ');
      });
      //save to global answer database
      Firestore.instance
          .collection("highlightedAnswers")
          .document(answerID)
          .setData({
        "description": descriptionController.text,
        "timestamp": new DateFormat.yMMMd().add_jm().format(DateTime.now()),
        "writtenBy": user.email,
      }).then((response) {
        print("success");
      }).catchError((error) {
        print(error);
        _showAlertDialog('Error Status Local', 'Problem Saving Question ');
      });
//update student question database to add answer ID show question has been answered
      Firestore.instance
          .collection("askedquestions")
          .document("user_" + studentUsername)
          .collection("questions")
          .document(questionID)
          .updateData({'answerID': answerID, 'answeredBy': user.email}).then(
              (response) {
            print("success");
          }).catchError((error) {
        print(error);
        _showAlertDialog('Error Status Global', 'Problem Saving Question');
      });

      //transfer from unanswered list to my answered questions

      DocumentReference fromUnanswered = Firestore.instance
          .collection("unansweredquestionlist")
          .document(questionID);

      DocumentReference toMyAnswers = Firestore.instance
          .collection("answeredquestions")
          .document("tutor_" + user.email)
          .collection("questions")
          .document(questionID);

      fromUnanswered.get().then((dataSnapshot) {
        if (dataSnapshot.exists) {
          toMyAnswers.setData(dataSnapshot.data).then((data) {
            fromUnanswered.delete();
            print("File transferred successfully");
          }).catchError((e) => print(e));
        }
      });

      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return MainPage(user: user);
      }));
    } else {
      // Failure
      _showAlertDialog('Error Status',
          'Problem Sending answer, Make sure a solution has been written');
    }
  }

  void uploadPicture(String answerID) {
    StorageReference storageReference =
    FirebaseStorage.instance.ref().child('answers/${answerID}');
    StorageUploadTask uploadTask = storageReference.putFile(_image);
    uploadTask.onComplete;
    storageReference.getDownloadURL().then((value) => {
      setState(() {
        // _uploadedFileURL = value;
        debugPrint(value);
      })
    });
  }

  void _cancel() async {
    moveToLastScreen();
    debugPrint("Deleted button pressed");
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}

//grabs all documents from database before counting number of documents
//To find more efficient way to count documents
//List<DocumentSnapshot> docCount = (await questionDB.getDocuments()).documents ;

//String numberOfQns = docCount.length.toString();
