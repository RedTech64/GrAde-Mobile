import 'package:flutter/material.dart';
import 'package:GrAde/utils/auth.dart';
import 'package:url_launcher/url_launcher.dart';

class WelcomePageData {
  String uid;
  bool simpleFAB;
  
  WelcomePageData(this.uid,this.simpleFAB);
}

class Welcome extends StatefulWidget {
  @override
  State createState() => new WelcomeState();
}

class WelcomeState extends State<Welcome> {
  bool _tapped = false;

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
            _tapped ? new CircularProgressIndicator() :
            new RaisedButton(
              child: new Text(
                'SIGN IN WITH GOOGLE',
                style: new TextStyle(
                  fontSize: 24.0,
                ),
              ),
              color: Colors.redAccent,
              onPressed: () {
                setState(() {
                  _tapped = true;
                });
                signInWithGoogle(false).then((data) {
                  if(data.signedin) {
                    print(data.simpleFAB);
                    Navigator.pop(context,new WelcomePageData(data.uid, data.simpleFAB));
                  } else {
                    setState(() {
                      _tapped = false;
                    });
                  }
                });
              }
            ),
            new SizedBox(
              height: 20.0,
            ),
            new FlatButton(
                child: new Text(
                  'PRIVACY POLICY'
                ),
                onPressed: _launchURL
            ),
          ],
        ),
      ),
    );
  }

  _launchURL() async {
    const url = 'https://sites.google.com/view/grade-privacy-policy/home';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

}