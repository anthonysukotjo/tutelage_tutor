import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:io';
import 'package:intl/intl.dart';


class EditTutorProfile extends StatefulWidget {

  final FirebaseUser user;
  const EditTutorProfile({Key key, this.user}) : super (key : key) ;

  @override
  State<StatefulWidget> createState() {
    return EditTutorProfileState(this.user);
  }

}

class EditTutorProfileState extends State<EditTutorProfile> {

  FirebaseUser user;
  EditTutorProfileState(this.user);
  TextEditingController bioController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text("Edit Profile", style: TextStyle(color: Colors.black),),
        backgroundColor: Colors.orange,
      ),

      body: Column(
        //mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,

        children: <Widget>[
          SizedBox(
            height: 20,
          ),

          Container(
            alignment: Alignment.center,
            child: Text("Insert New Bio",
                style: TextStyle(
                  fontSize: 40,
                )),
          ),

          SizedBox(
            height: 30,
          ),




          TextField(
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
            maxLines: null,
            controller: bioController,
            onChanged: (value) {
              debugPrint('Something changed in Bio Text Field');
            },
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0)
                )
            ),
          ),

          SizedBox(
            height: 15,
          ),

          Row(
            children: <Widget>[

              RaisedButton(
                onPressed: () {
                  setState(() {
                    debugPrint(" Send button clicked");
                    debugPrint(bioController.text);
                    send();
                  });
                },
                child: Text('Save'),
              )
            ],
          ),

        ],
      ),
    );
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

  void send() async {


    if (bioController.text.isNotEmpty){
      Firestore.instance.collection("tutorUserProfiles")
          .document("tutor_" + user.email)
          .updateData(
          {"bio": bioController.text,
          }
      ).then((response) {
        print("success");
        Navigator.pop(context);
      }).catchError((error) {
        print(error);
        _showAlertDialog(
            'Error Status Local', 'Problem Saving Bio ');
      } );
    } else { // Failure
      _showAlertDialog(
          'Error Status', 'Problem Sending answer, Make sure a bio has been written');
    }


  }




}