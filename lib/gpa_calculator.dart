import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'loading.dart';
import 'thin_divider.dart';
import 'class.dart';
import 'class_dialog.dart';
import 'dart:async';
import 'grade_average.dart';
import 'utils/data_provider.dart';
import 'package:provider/provider.dart';

class GPACalculator extends StatefulWidget {
  final String _userID;

  GPACalculator(Key key,this._userID) : super(key: key);

  @override
  State createState() => new GPACalculatorState(_userID);
}

class GPACalculatorState extends State<GPACalculator> {
  int _decimalPlaces = 3;
  bool _empty;
  String _userID;
  DocumentReference userData;

  GPACalculatorState(this._userID) {
    userData = Firestore.instance.collection('users').document(_userID);
  }

  @override
  void initState() {
    super.initState();
    _setupData().then((result) {
      setState(() {
        userData = Firestore.instance.collection('users').document(_userID);
      });
    });
  }

  Future<bool> _setupData() async {
    DocumentReference docRef = Firestore.instance.collection('users').document(_userID);
    DocumentSnapshot data = await docRef.get();
    if(!data.exists || data['classes'] == null) {
      await docRef.updateData({
        'classes': true,
      });
      return true;
    } else {
      return true;
    }
  }

  List<Widget> _buildClasses(classes) {
    var list = <Widget>[];
    num gpa = _getGPA(classes);
    for(var i = 0; i < classes.length; i++) {
      var id = classes[i].data['id'];
      var name = classes[i].data['name'];
      var grade = classes[i].data['grade'];
      var qp = classes[i].data['qp'];
      var linkID = classes[i].data['linkID'];
      var color;
      if(grade == null) grade = 0;
      if(qp == null) qp = 0;
      if(linkID != "") _updateLinkedData(classes[i]['id'],classes[i]['linkID']);
      if(grade+qp < gpa) color = Colors.red;
      else color = Colors.green;
      list.add(new Class(_userID,id,name,grade,qp,color,new LinkData(classes[i]['linkID'],classes[i]['linkName'])));
    }
    return list;
  }

  _updateLinkedData(classID,averageID) async {
    DocumentSnapshot averageData = await userData.collection('averages').document(averageID).get();
    var categories = averageData.data['categories'];
    var grade = getOverallGrade(categories);
    DocumentSnapshot c = await userData.collection('classes').document(classID).get();
    if(c.data['linkID'] != "")
      await userData.collection('classes').document(classID).updateData({
        'grade': grade.toInt(),
      });
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
      var grade = c['grade'];
      var qp = c['qp'];
      if(grade == null) {
        grade = 0;
      }
      if(qp == null) {
        qp = 0;
      }
      if (grade + qp > 100 + qp) {
        sum += 100 + qp;
      } else {
        sum += grade + qp;
      }
    }
    if(classes.length == 0) {
      return 0.0;
    } else {
      return sum/classes.length;
    }
  }
}

class GPACalculatorActions extends StatelessWidget {
  final String userID;

  GPACalculatorActions(Key key,this.userID) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new Row(
        children: <Widget>[

        ],
      ),
    );
  }
}

class GPACalculatorFAB extends StatelessWidget {
  final Key key;
  final bool simple;
  final String userID;

  GPACalculatorFAB(this.key,this.simple,this.userID);

  @override
  Widget build(BuildContext context) {
    final gpaState = Provider.of<GPAState>(context);
    if(!simple) {
      return new FloatingActionButton.extended(
        heroTag: "btn1",
        label: new Text('Add Class'),
        icon: new Icon(Icons.add_box),
        onPressed: () {
          openCreateClassDialog(gpaState,userID,context);
        },
      );
    } else {
      return new FloatingActionButton(
        heroTag: "btn2",
        child: new Icon(Icons.add_box),
        onPressed: () {
          openCreateClassDialog(gpaState,userID,context);
        },
      );
    }
  }
}

Future openCreateClassDialog(GPAState gpaState,userID,context) async {
  ClassDialogData c = await Navigator.of(context).push(new MaterialPageRoute<ClassDialogData>(
      builder: (BuildContext context) {
        return new ClassDialog(userID,"",100,0,false,new LinkData("",""));
      },
      fullscreenDialog: true
  ));
  if(c != null) {
    gpaState.addClass(Firestore.instance.collection('users').document(userID),c.name, c.grade,c.qp,c.linkData);
  }
}