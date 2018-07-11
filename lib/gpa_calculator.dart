import 'package:flutter/material.dart';
import 'main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'loading.dart';
import 'thin_divider.dart';
import 'class.dart';
import 'class_dialog.dart';
import 'dart:async';

GPACalculatorState gpaCalculatorState;

class GPACalculator extends StatefulWidget {
  final String _userID;

  GPACalculator(Key key,this._userID) : super(key: key);

  @override
  State createState() {
    gpaCalculatorState = new GPACalculatorState(_userID);
    return gpaCalculatorState;
  }
}
 
class GPACalculatorState extends State<GPACalculator> {
  int _decimalPlaces = 3;
  var _classes = [];
  bool _empty;
  String _userID;
  int _quickUpdate = 0;

  GPACalculatorState(this._userID);

  @override
  void initState() {
    super.initState();
    Firestore.instance.collection('users').document(_userID).get().then((doc) {
      _setupData();
    });
  }

  Future<bool> _setupData() async {
    DocumentReference docRef = Firestore.instance.collection('users').document(_userID);
    DocumentSnapshot data = await docRef.get();
    if(!data.exists || data['classes'] == null) {
      await docRef.setData({
        'classes': []
      });
      return true;
    } else {
      return true;
    }
  }

  void addClass(name,grade,qp) {
    var newClasses = fixArray(_classes);
    newClasses.add({
      'name': name,
      'grade': grade,
      'qp': qp,
    });
    Firestore.instance.collection('users').document(_userID).updateData({'classes': newClasses});
    setState(() {
      _classes = newClasses;
      _quickUpdate = 2;
    });
  }

  void editClass(index,name,grade,qp) {
    var newClasses = fixArray(_classes);
    newClasses[index] = {
      'name': name,
      'grade': grade,
      'qp': qp,
    };
    Firestore.instance.collection('users').document(_userID).updateData({'classes': newClasses});
    setState(() {
      _classes = newClasses;
      _quickUpdate = 2;
    });
  }

  void deleteClass(index) {
    var newClasses = fixArray(_classes);
    newClasses.removeAt(index);
    Firestore.instance.collection('users').document(_userID).updateData({'classes': newClasses});
    setState(() {
      _classes = newClasses;
      _quickUpdate = 2;
    });
  }

  List<Widget> _buildClasses(classes) {
    var list = <Widget>[];
    for(var i = 0; i < classes.length; i++) {
      var name = classes[i]['name'];
      var grade = classes[i]['grade'];
      var qp = classes[i]['qp'];
      if(grade == null) {
        grade = 0;
      }
      if(qp == null) {
        qp = 0;
      }
      list.add(new Class(i,name,grade,qp));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return new StreamBuilder(
      stream: Firestore.instance.collection('users').document(_userID).snapshots(),
      builder: (context,snapshot) {
        if(!snapshot.hasData) return new Loading();
        _classes = snapshot.data['classes'];
        _empty = _classes.isEmpty;
        return new SingleChildScrollView(
          child: new Padding(
            padding: const EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 100.0),
            child: new Center(
              child: new Column(
                children: <Widget>[
                  new Card(
                    child: new Column(
                      children: <Widget>[
                        new Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: new Text(
                            'GPA',
                            style: new TextStyle(
                              fontSize: 24.0,
                            ),
                          ),
                        ),
                        new ThinDivider(),
                        new Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: new GestureDetector(
                            child: new Text(
                              '${_getGPA().toStringAsFixed(_decimalPlaces)}%',
                              style: new TextStyle(
                                fontSize: 34.0,
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                if(_decimalPlaces <= 3) {
                                  _decimalPlaces = _decimalPlaces+1;
                                } else {
                                  _decimalPlaces = 0;
                                }
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  new Card(
                    child: new Column(
                      children: <Widget>[
                        new Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: new Text(
                            'Classes',
                            style: new TextStyle(
                              fontSize: 24.0,
                            ),
                          ),
                        ),
                        new ThinDivider(),
                        new Column(
                          children:
                          _empty ?
                          [
                            new Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('No Classes Added'),
                            )
                          ] : _buildClasses(_classes)
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
 
  double _getGPA() {
    double sum = 0.0;
    for(var i = 0; i < _classes.length; i++) {
      var c = _classes[i];
      if(c['grade']+c['qp'] > 100+c['qp']) {
        sum += 100+c['qp'];
      } else {
        sum += c['grade']+c['qp'];
      }
    }
    if(_classes.length == 0) {
      return 0.0;
    } else {
      return sum/_classes.length;
    }
  }
}

class GPACalculatorFAB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new FloatingActionButton.extended(
      label: new Text('Add Class'),
      icon: new Icon(Icons.add_box),
      onPressed: () {
        openCreateClassDialog(context);
      },
    );
  }
}

Future openCreateClassDialog(context) async {
  ClassDialogData c = await Navigator.of(context).push(new MaterialPageRoute<ClassDialogData>(
      builder: (BuildContext context) {
        return new ClassDialog("",100,0,false);
      },
      fullscreenDialog: true
  ));
  if(c != null) {
    gpaCalculatorState.addClass(c.name, c.grade,c.qp);
  }
}