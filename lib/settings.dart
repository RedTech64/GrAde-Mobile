import 'package:flutter/material.dart';
import './utils/auth.dart';

class Settings extends StatefulWidget {
  @override
  State createState() => new SettingsState();
}

class SettingsState extends State<Settings> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Settings'),
        backgroundColor: Colors.red,
      ),
      body: new Padding(
        padding: const EdgeInsets.all(8.0),
        child: new Center(
          child: new Column(
            children: <Widget>[
              new RaisedButton(
                child: new Text('Log In'),
                onPressed: () {
                  signInWithGoogle();
                }
              ),
            ],
          ),
        ),
      ),
    );
  }
}