import 'package:flutter/material.dart';
import 'package:GrAde/utils/auth.dart';

class Welcome extends StatefulWidget {
  @override
  State createState() => new WelcomeState();
}

class WelcomeState extends State<Welcome> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Center(
        child: Column(
          children: <Widget>[
            new SizedBox(
              height: 40.0,
            ),
            new Icon(Icons.school, size: 160.0,),
            new SizedBox(
              height: 20.0,
            ),
            new Text(
              'Welcome',
              style: new TextStyle(
                fontSize: 48.0,
              ),
            ),
            new Text(
              'to',
              style: new TextStyle(
                fontSize: 48.0,
              ),
            ),
            new Text(
              'GrAde',
              style: new TextStyle(
                fontSize: 48.0,
              ),
            ),
            new SizedBox(
              height: 20.0,
            ),
            new Text(
              'Sign in to get started!',
              textAlign: TextAlign.center,
              style: new TextStyle(
                fontSize: 24.0,
              ),
            ),
            new SizedBox(
              height: 20.0,
            ),
            new RaisedButton(
              child: new Text(
                'SIGN IN WITH GOOGLE',
                style: new TextStyle(
                  fontSize: 24.0,
                ),
              ),
              color: Colors.redAccent,
              onPressed: () {
                signInWithGoogle(false).then((signedin) {
                  if(signedin) {
                    print(userID);
                    Navigator.pop(context,userID);
                  }
                });
              }
            ),
          ],
        ),
      ),
    );
  }
}