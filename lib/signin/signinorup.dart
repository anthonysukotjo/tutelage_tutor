import 'package:flutter/material.dart';
import 'package:tutelage_tutor/signin/login.dart';
import 'package:tutelage_tutor/signin/register.dart';

class signInOrUp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        backgroundColor: Colors.orange,
        body: Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[

                Container(
                  child: Text(
                    "#code4corona",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),

                ),
                Image(
                  image:
                  AssetImage('assets/logo/tutelage_logo_full.png'),

                ),


                //   Text(
                //   "Tutelage",
                //   style: TextStyle(
                //     fontSize: 75,
                //     fontWeight: FontWeight.bold,
                //     color: Colors.lightGreenAccent.shade100,
                //   ),
                // ),



                SizedBox(
                  height: 5,
                ),


                Text(
                  "For Tutors\nBy Team TBIYTB",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  height: 40,
                ),

                PageButton(
                  title: "Log in",
                  callback: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                ),
                PageButton(
                  title: "Sign Up",
                  callback: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterPage()),
                    );
                  },
                ),
              ],
            )));
  }
}

class PageButton extends StatelessWidget {
  final String title;
  final VoidCallback callback;

  const PageButton({Key key, this.title, this.callback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Material(
        color: Colors.orangeAccent.shade100,
        borderRadius: BorderRadius.circular(50.0),
        child: MaterialButton(
          minWidth: 300,
          onPressed: callback,
          height: 45,
          child: Text(title,
            style: TextStyle(
              color: Colors.black,
              //fontWeight: FontWeight.bold,
              fontSize: 30,
            ),),
        ),
      ),
    );
  }
}
