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
  bool _tappedGoogle = false;
  bool _tappedAnonymous = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new SingleChildScrollView(
        child: new Center(
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
              new Visibility(
                visible: !_tappedAnonymous,
                child: _tappedGoogle ? new CircularProgressIndicator() :
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
                        _tappedGoogle = true;
                      });
                      signOut();
                      signInWithGoogle(false).then((data) {
                        print("DATA "+ data.toString());
                        if(data.signedin) {
                          Navigator.pop(context,new WelcomePageData(data.uid, data.simpleFAB));
                        } else {
                          setState(() {
                            _tappedGoogle = false;
                          });
                        }
                      });
                    }
                ),
              ),
              new SizedBox(
                height: 5.0,
              ),
              _tappedAnonymous ? new SizedBox(
                height: 5.0,
              ) : new Container(),
              new Visibility(
                visible: !_tappedGoogle,
                child: _tappedAnonymous ? new CircularProgressIndicator() : new FlatButton(
                    child: new Text(
                      'SIGN IN ANONYMOUSLY',
                      style: new TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _tappedAnonymous = true;
                      });
                      signOut();
                      signInAnonymously().then((data) {
                        if(data.signedin) {
                          Navigator.pop(context,new WelcomePageData(data.uid, data.simpleFAB));
                        } else {
                          setState(() {
                            _tappedAnonymous = false;
                          });
                        }
                      });
                    }
                ),
              ),
              new SizedBox(
                height: 6.0,
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