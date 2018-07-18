import 'package:flutter/material.dart';
import 'thin_divider.dart';
import 'dart:async';
import 'class_dialog.dart';
import 'gpa_calculator.dart';

class Class extends StatelessWidget {
  final String _id;
  final String _name;
  final int _grade;
  final int _qp;

  Class(this._id,this._name,this._grade,this._qp);

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
                  "${_grade.toString()}%",
                  textAlign: TextAlign.center,
                  style: new TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ),
              new Expanded(
                flex: 1,
                child: new Text(
                  "+${_qp.toString()}",
                  textAlign: TextAlign.center,
                  style: new TextStyle(
                    fontSize: 20.0,
                  ),
                ),
              ),
              new IconButton(
                icon: new Icon(Icons.edit),
                onPressed: () {
                  _openEditClassDialog(context);
                }
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future _openEditClassDialog(context) async {
    ClassDialogData c = await Navigator.of(context).push(new MaterialPageRoute<ClassDialogData>(
        builder: (BuildContext context) {
          return new ClassDialog(_name,_grade,_qp,true,false);
        },
        fullscreenDialog: true
    ));
    if(c != null) {
      if(c.delete) {
        gpaCalculatorState.deleteClass(_id);
      } else {
        gpaCalculatorState.editClass(_id,c.name,c.grade,c.qp);
      }
    }
  }
}