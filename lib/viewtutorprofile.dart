import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tutelage_tutor/signin/signinorup.dart';
import 'package:tutelage_tutor/edittutorprofile.dart';

class TutorProfile extends StatefulWidget {

  final String tutorName;
  final FirebaseUser user;
  const TutorProfile({Key key, this.user, this.tutorName}) : super (key : key) ;

  @override
  State<StatefulWidget> createState() {
    return TutorProfileState(this.user, this.tutorName);
  }

}

class TutorProfileState extends State<TutorProfile> {

  FirebaseUser user;
  String tutorName;

  TutorProfileState(this.user, this.tutorName);

  TextEditingController bioController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$tutorName's Profile",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,)),
        centerTitle: true,
        backgroundColor: Colors.orange,
        actions: <Widget>[
          PopupMenuButton(
            icon: Icon(
              Icons.menu,
              color: Colors.black,),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text("Edit Personal Profile"),
                value: EditTutorProfile(user: user),
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
      ),

      body:
      Padding(
        padding: EdgeInsets.all(20.0),
        child: StreamBuilder(
            stream: Firestore.instance
                .collection("tutorUserProfiles")
                .document("tutor_" + tutorName).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              return ListView(

                children: <Widget>[

                  //1st Stat: Total Number of Points
                  Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.deepOrangeAccent,
                      ),
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          'Total Number of Points: \n${snapshot.data["totalPoints"].toString()}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 25,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
//                  color: Colors.blue[300],
                    ),
                  ),

                  //2nd Stat: Total Number of Qns Answered + points per qn
                  Padding(
                    padding: EdgeInsets.only(
                      top: 1.0,
                      bottom: 5.0,),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.deepOrangeAccent,
                          ),
                          alignment: Alignment.center,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text('Total Questions \nAnswered: \n${snapshot.data["noOfQuestionsAnswered"]}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ), ),
                          ),
//                      color: Colors.blue[300],
                        ),


                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.deepOrangeAccent,
                          ),
                          alignment: Alignment.center,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text('Average points \nper qn:\n${pointPerQuestion(snapshot.data["totalPoints"],
                                snapshot.data["noOfQuestionsAnswered"])} ',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ), ),
                          ),
//                      color: Colors.blue[300],
                        ),
                      ],
                    ),
                  ),
                  // List of Qualifications

                  Padding(
                    padding: EdgeInsets.only(
                      top: 20.0,
                      bottom: 5.0,),
                    child: Container(

                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.deepOrangeAccent,
                      ),

                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(snapshot.data['bio'],

                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ), ),
                      ),
//                  color: Colors.blue[300],
                    ),
                  ),


                ],
              );
            }),
      ),
    );
  }


  String pointPerQuestion(int totalPoints, noOfQns) {
    num pPQ;
    pPQ = totalPoints / noOfQns ;
    return pPQ.toStringAsFixed(1);
  }


}


//'noOfQuestionsAnswered': 0 ,
//              'totalPoints': 0,
//                'qualifications' : "Insert Qualifications"