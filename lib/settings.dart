import 'package:flutter/material.dart';
import './utils/auth.dart';
import 'settings_option.dart';
import 'main.dart';

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
        padding: const EdgeInsets.all(0.0),
        child: new Center(
          child: new Column(
            children: <Widget>[
              new SettingsOption(
                mainLine: 'Switch Accounts',
                onPressed: () {
                  switchAccounts();
                },
              ),
              new Divider(
                height: 0.0,
              ),
              new SettingsOption(
                mainLine: 'About',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return new AlertDialog(
                        title: new Text('About'),
                          content: new SingleChildScrollView(
                            child: new Column(
                              children: <Widget>[
                                new Text('Version: '+version.toString()),
                                new Text('Published by RedTech Software'),
                                new Text('Developed by Cole Weinman'),
                                new Text('Email bugs, feedback and suggestions to grade@redtech.software'),
                              ],
                            ),
                        ),
                        actions: <Widget>[
                          new FlatButton(
                            child: new Text('OK'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          )
                        ],
                      );
                    }
                  );
                },
              ),
              new Divider(
                height: 0.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}