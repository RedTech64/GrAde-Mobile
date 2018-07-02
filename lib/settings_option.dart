import 'package:flutter/material.dart';
import './utils/settings_inkwell.dart';

class SettingsOption extends StatelessWidget {
  final String mainLine;
  final String secondLine;
  final VoidCallback onPressed;

  SettingsOption({
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