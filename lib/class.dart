import 'package:flutter/material.dart';
import 'thin_divider.dart';

class Class extends StatelessWidget {
  final _name;
  final _grade;
  final _qp;

  Class(this._name,this._grade,this._qp);

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        new ThinDivider(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: new Row(
            children: <Widget>[
              new Expanded(
                flex: 2,
                child: new Text(
                  _name,
                  textAlign: TextAlign.start,
                  style: new TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ),
              new Expanded(
                flex: 1,
                child: new Text(
                  _grade,
                  textAlign: TextAlign.center,
                  style: new TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ),
              new Expanded(
                flex: 1,
                child: new Text(
                  _qp,
                  textAlign: TextAlign.center,
                  style: new TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ),
              new IconButton(
                icon: new Icon(Icons.edit),
                onPressed: () {}
              ),
            ],
          ),
        ),
      ],
    );
  }
}