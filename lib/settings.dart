import 'package:flutter/material.dart';
import './utils/auth.dart';
import 'settings_option.dart';
import 'main.dart';
import 'thin_divider.dart';

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
              new SimpleSettingsOption(
                mainLine: 'Sign Out',
                onPressed: () {
                  Navigator.of(context).pop({'signout': true});
                },
              ),
              new ThinDivider(),
              new SimpleSettingsOption(
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
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: new Text('Version: '+version.toString()),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: new Text('Published by RedTech Software'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: new Text('Developed by Cole Weinman'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: new Text('Email bugs, feedback and suggestions to grade@redtech.software'),
                                ),
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
              new ThinDivider(),
              new SwitchSettingsOption(
                  mainLine: "Simple Add Buttons",
                  secondLine: "Removes text from lower FAB",
                  switchValue: simpleFAB,
                  onPressed: () {
                    simpleFAB = !simpleFAB;
                    updateSettings();
                  }
              ),
              new ThinDivider(),
            ],
          ),
        ),
      ),
    );
  }
}