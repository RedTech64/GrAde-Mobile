import 'package:flutter/material.dart';
import 'utils/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'loading.dart';
import 'thin_divider.dart';
import 'class.dart';
 
class GPACalculator extends StatefulWidget {
  @override
  State createState() => new GPACalculatorState();
}
 
class GPACalculatorState extends State<GPACalculator> {
  int _decimalPlaces = 3;
  var _classes = [];
  bool _empty;

  @override
  void initState() {
    super.initState();
  }
 
  @override
  Widget build(BuildContext context) {
    return new StreamBuilder(
      stream: Firestore.instance.collection('users').document(userID).snapshots(),
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
                          _empty ? _classes.map((c) => new Class(c['name'],c['grade'],c['qp'])).toList() :
                          [
                            new Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('No Classes Added'),
                            )
                          ],
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
    return 100.0;
  }
}

class GPACalculatorFAB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new FloatingActionButton.extended(
      label: new Text('Add Class'),
      icon: new Icon(Icons.add_box),
      onPressed: () {
        //TODO: add dialog
      },
    );
  }
}