import 'package:flutter/material.dart';
import 'thin_divider.dart';
import 'dart:async';
import 'class_dialog.dart';
import 'gpa_calculator.dart';
import 'utils/data_provider.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LinkData {
  String id;
  String name;
  bool linked;

  LinkData(this.id,this.name) {
    this.linked = (id != "");
  }
}

class Class extends StatelessWidget {
  final String _id;
  final String _name;
  final int _grade;
  final int _qp;
  final Color color;
  final LinkData _linkData;
  String _userID;

  Class(this._userID,this._id,this._name,this._grade,this._qp,this.color,this._linkData);

  @override
  Widget build(BuildContext context) {
    final gpaState = Provider.of<GPAState>(context);
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
                  _getName(),
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
                    color: color,
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
                    _openEditClassDialog(Firestore.instance.collection('users').document(_userID),gpaState,context);
                  }
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getName() {
    if(_name == "") {
      return "Unnamed";
    } else {
      return _name;
    }
  }

  Future _openEditClassDialog(userData,GPAState gpaState,context) async {
    ClassDialogData c = await Navigator.of(context).push(new MaterialPageRoute<ClassDialogData>(
        builder: (BuildContext context) {
          return new ClassDialog(_userID,_name,_grade,_qp,true,_linkData);
        },
        fullscreenDialog: true
    ));
    if(c != null) {
      if(c.delete) {
        gpaState.deleteClass(userData,_id);
      } else {
        gpaState.editClass(userData,_id,c.name,c.grade,c.qp,c.linkData);
      }
    }
  }
}