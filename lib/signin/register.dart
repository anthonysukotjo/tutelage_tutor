import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tutelage_tutor/home.dart';
import 'package:tutelage_tutor/signin/login.dart';
import 'package:tutelage_tutor/signin/signinorup.dart';

class RegisterPage extends StatefulWidget {
  @override
  RegisterPageState createState() => new RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  String email, password;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        elevation: 0,
      ),
      resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.orange,
      body: Container(
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "Sign Up",
              style: TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(
              height: 50,
            ),
            TextField(
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) => email = value.trim(),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: "Enter your email",
                border: const OutlineInputBorder(),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              autocorrect: false,
              obscureText: true,
              onChanged: (value) => password = value,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: "Enter your password",
                border: const OutlineInputBorder(),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            PageButton(
              title: "Register",
              callback: register,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> register() async {
    if (email == null) {
      _showAlertDialog("Error", "Please enter your email");
    } else if (!isEmail(email)) {
      _showAlertDialog("Error", "Please enter a valid email");
    } else if (password == null) {
      _showAlertDialog("Error", "Please enter a password");
    } else if (password.length < 6 || password == null) {
      _showAlertDialog(
          "Error", "Your password needs to be longer than 6 characters");
    } else
      try {
        FirebaseUser user = (await _auth.createUserWithEmailAndPassword(
            email: email, password: password))
            .user;

        Firestore.instance.collection("tutorUserProfiles")
            .document("tutor_" + email)
            .setData(
            {'tutorName' : email ,
              'noOfQuestionsAnswered': 0 ,
              'totalPoints': 0,
              'bio' : "Edit Profile to Add Qualifications"}

        ).then((response) {
          print("success setting up counter");
        }).catchError((error) {
          print(error);
          _showAlertDialog(
              'Error', 'Problem Initializing User');
        } );






        Navigator.pop(context);
        _showAlertDialog("Status", "Registered Successfully");
      } catch (e) {
        _showAlertDialog("ERROR", e.message);
      }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }

  bool isEmail(String email) {
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = new RegExp(p);

    return regExp.hasMatch(email);
  }
}
