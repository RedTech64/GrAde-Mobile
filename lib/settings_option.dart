import 'package:flutter/material.dart';
import './utils/settings_inkwell.dart';

class SimpleSettingsOption extends StatelessWidget {
  final String mainLine;
  final String secondLine;
  final VoidCallback onPressed;

  SimpleSettingsOption({
    @required this.mainLine,
    this.secondLine,
    @required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return new Row(
      children: <Widget>[
        new Expanded(
          child: new InkWell(
            child: new Padding(
              padding: const EdgeInsets.all(15.0),
              child: new Text(
                mainLine,
                style: new TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ),
            splashFactory: new CustomSplashFactory(),
            onTap: onPressed,
          ),
        ),
      ],
    );
  }
}

class SwitchSettingsOption extends StatefulWidget {
  final String mainLine;
  final String secondLine;
  final bool switchValue;
  final VoidCallback onPressed;

  SwitchSettingsOption({
    @required this.mainLine,
    this.secondLine,
    this.switchValue,
    @required this.onPressed,
  });

  State createState() => new SwitchSettingsOptionState(
    mainLine: mainLine,
    secondLine: secondLine,
    switchValue: switchValue,
    onPressed: onPressed
  );
}

class SwitchSettingsOptionState extends State<SwitchSettingsOption> {
  String mainLine;
  String secondLine;
  bool switchValue;
  VoidCallback onPressed;

  SwitchSettingsOptionState({
    @required this.mainLine,
    this.secondLine,
    @required this.switchValue,
    @required this.onPressed,
  });

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Row(
      children: <Widget>[
        new Expanded(
          child: new InkWell(
            child: new Padding(
              padding: const EdgeInsets.all(15.0),
              child: new Row(
                children: <Widget>[
                  new Expanded(
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Text(
                          mainLine,
                          style: new TextStyle(
                            fontSize: 16.0,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        new Text(
                          secondLine,
                          style: new TextStyle(
                            color: Colors.grey
                          ),
                        ),
                      ],
                    ),
                  ),
                  new Switch(
                      value: switchValue,
                      onChanged: (value) {}
                  ),
                ],
              ),
            ),
            splashFactory: new CustomSplashFactory(),
            onTap: () {
              onPressed();
              setState(() {
                switchValue = !switchValue;
              });
            },
          ),
        ),
      ],
    );
  }
}