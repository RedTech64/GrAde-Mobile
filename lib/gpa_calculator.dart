import 'package:flutter/material.dart';
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
  bool _empty;
  String _userID;
  DocumentReference userData;

  GPACalculatorState(this._userID);

  @override
  void initState() {
    super.initState();
    Firestore.instance.collection('users').document(_userID).get().then((doc) {
      _setupData().then((result) {
        userData = Firestore.instance.collection('users').document(_userID);
      });
    });
  }

  Future<bool> _setupData() async {
    DocumentReference docRef = Firestore.instance.collection('users').document(_userID);
    DocumentSnapshot data = await docRef.get();
    if(!data.exists || data['classes'] == null) {
      await docRef.setData({
        'classes': true,
      });
      return true;
    } else {
      return true;
    }
  }

  void addClass(name,grade,qp) async {
    DocumentReference classDoc = await userData.collection('classes').add({
      'name': name,
      'grade': grade,
      'qp': qp,
    });
    var id = classDoc.documentID;
    await classDoc.updateData({
      'id': id,
    });
  }

  void editClass(id,name,grade,qp) async {
    await userData.collection('classes').document(id).updateData({
      'name': name,
      'grade': grade,
      'qp': qp,
    });
  }

  void deleteClass(id) async {
    await userData.collection('classes').document(id).delete();
  }

  void link(String classID,String averageID) async {
    var doc = Firestore.instance.collection('user').document(_userID).collection('classes').document(classID);
    doc.updateData({
      'link': averageID,
    });
  }

  List<Widget> _buildClasses(classes) {
    var list = <Widget>[];
    for(var i = 0; i < classes.length; i++) {
      var id = classes[i].data['id'];
      var name = classes[i].data['name'];
      var grade = classes[i].data['grade'];
      var qp = classes[i].data['qp'];
      if(grade == null) {
        grade = 0;
      }
      if(qp == null) {
        qp = 0;
      }
      list.add(new Class(id,name,grade,qp));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return new StreamBuilder(
      stream: Firestore.instance.collection('users').document(_userID).collection('classes').snapshots(),
      builder: (context,snapshot) {
        if(!snapshot.hasData) return new Loading();
        if(snapshot.data.documents.length == 0) {
          _empty = true;
        } else {
          _empty = false;
        }
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
                              '${_getGPA(snapshot.data.documents).toStringAsFixed(_decimalPlaces)}%',
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
                          ] : _buildClasses(snapshot.data.documents)
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

  Future<List> getAverages() async {
    DocumentSnapshot doc = await Firestore.instance.collection('users').document(_userID).get();
    return doc.data['average'];
  }
 
  double _getGPA(classes) {
    double sum = 0.0;
    for(var i = 0; i < classes.length; i++) {
      var c = classes[i].data;
      if (c['grade'] + c['qp'] > 100 + c['qp']) {
        sum += 100 + c['qp'];
      } else {
        sum += c['grade'] + c['qp'];
      }
    }
    if(classes.length == 0) {
      return 0.0;
    } else {
      return sum/classes.length;
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
  List averages = await gpaCalculatorState.getAverages();
  ClassDialogData c = await Navigator.of(context).push(new MaterialPageRoute<ClassDialogData>(
      builder: (BuildContext context) {
        return new ClassDialog("",100,0,false,false,averages);
      },
      fullscreenDialog: true
  ));
  if(c != null) {
    gpaCalculatorState.addClass(c.name, c.grade,c.qp);
  }
}