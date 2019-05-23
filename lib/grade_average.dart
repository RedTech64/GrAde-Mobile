import 'package:flutter/material.dart';
import 'category_dialoge.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'category_card.dart';
import 'average_dialog.dart';
import 'main.dart';
import 'loading.dart';
import 'dart:async';
import 'thin_divider.dart';
import 'utils/analytics.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:provider/provider.dart';
import 'utils/data_provider.dart';

bool averageLoaded = false;

class GradeAverage extends StatefulWidget {
  final String _userID;

  GradeAverage(Key key,this._userID) : super(key: key);

  @override
  State createState() => new GradeAverageState(_userID);
}

class GradeAverageState extends State<GradeAverage> {
  String _userID;
  int _gradeValue = 100;
  int _weightValue = 100;
  String _selectedAverage;
  int _selectedCategory = 0;
  var _categories = [];
  bool dataExists = false;
  int quickUpdate = 0;
  DocumentReference userData;
  TextEditingController gradeController;
  TextEditingController weightController;
  bool keyboard = false;

  GradeAverageState(this._userID);

  @override
  void initState() {
    KeyboardVisibilityNotification().addNewListener(
        onChange: (visible) {
          keyboard = visible;
          if(!visible) {
            FocusScope.of(context).requestFocus(new FocusNode());
          }
        }
    );
    gradeController = new TextEditingController(text: _gradeValue.toString());
    weightController = new TextEditingController(text: _weightValue.toString());
    var data = false;
    _setupData().then((result) {
      data = result;
      Firestore.instance.collection('users').document(_userID).get().then((doc) {
        setState(() {
          _selectedAverage = doc['selectedAverage'];
          dataExists = data;
          userData = Firestore.instance.collection('users').document(_userID);
        });
      });
    });
    super.initState();
  }

  Future<bool> _setupData() async {
    DocumentReference docRef = Firestore.instance.collection('users').document(_userID);
    DocumentSnapshot data = await docRef.get();
    if(!data.exists || data['selectedAverage'] == null) {
      DocumentReference averageRef = await docRef.collection('averages').add({});
      String averageID = averageRef.documentID;
      await averageRef.updateData({
        'id': averageID,
        'name': "Average",
        'categories': [{
          'name': "Category 1",
          'weight': 100,
          'grades': [],
        }],
        'selectedCategory': 0,
      });
      setState(() {
        _selectedAverage = averageRef.documentID;
      });
      await docRef.updateData({'selectedAverage': averageRef.documentID});
      return true;
    } else {
      return true;
    }
  }

  List<Widget> _buildCategoryCards(categories) {
    var list = <Widget>[];
    for(var i = 0; i < categories.length; i++) {
      list.add(new CategoryCard(
          new Category(categories[i]['name'],categories[i]['weight'], i), categories[i]['grades']));
    }
    return list;
  }

  List<Widget> _buildCategoryChips(categories) {
    var list = <Widget>[];
    for(var i = 0; i < categories.length; i++) {
      var selected = false;
      if(_selectedCategory == i) {
        selected = true;
      }
      list.add(new Padding(
        padding: const EdgeInsets.fromLTRB(2.0, 0.0, 2.0, 0.0),
        child: new ChoiceChip(
          selected: selected,
          label: new Text(categories[i]['name']),
          onSelected: (selected) {
            if(selected) {
              setState(() {
                _selectedCategory = i;
              });
            }
          },
        ),
      ));
    }
    return list;
  }

  void _uploadCategories() {
    userData.collection('averages').document(_selectedAverage).updateData({
      'categories': _categories,
    });
  }

  @override
  Widget build(BuildContext context) {
    final averageState = Provider.of<AverageState>(context);
    quickUpdate = averageState.getQU();
    if(averageState.getSelectedAverage() == null && _selectedAverage != null)
      averageState.setSelectedAverage(_selectedAverage);
    else
      _selectedAverage = averageState.getSelectedAverage();
    if(_userID == null || averageState.getSelectedAverage() == null) return new Loading();
    return new StreamBuilder(
        stream: Firestore.instance.collection('users').document(_userID).collection('averages').document(averageState.getSelectedAverage()).snapshots(),
        builder: (context, snapshot) {
          if(!snapshot.hasData || snapshot.data.data == null) return new Loading();
          averageLoaded = true;
          if(quickUpdate == 0) {
            _categories = snapshot.data['categories'];
            averageState.setCategories(_categories, false);
          }
          if(quickUpdate != 0) quickUpdate--;
          if(quickUpdate == 1) _uploadCategories();
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
                            child: new Text(snapshot.data['name'],
                              style: new TextStyle(
                                fontSize: 24.0,
                              ),
                            ),
                          ),
                          new ThinDivider(),
                          new Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: new Text(
                              '${getOverallGrade(_categories).toStringAsFixed(2)}%',
                              style: new TextStyle(
                                  fontSize: 34.0
                              ),
                            ),
                          ),
                          new ThinDivider(),
                          new Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: new Column(
                              children: _categories.map((category) => new CategoryGrade(category['name'], getCategoryGrade(category['grades']))).toList(),
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
                              'Add Grades',
                              style: new TextStyle(
                                  fontSize: 24.0
                              ),
                            ),
                          ),
                          new ThinDivider(),
                          new Padding(
                            padding: const EdgeInsets.fromLTRB(0, 8, 0, 4),
                            child: new Text(
                              _getGradeDisplay(),
                              style: new TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              new Container(
                                height: 60,
                                width: 80,
                                child: new Padding(
                                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                                  child: new TextField(
                                    controller: gradeController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [new WhitelistingTextInputFormatter(new RegExp("[0-9]"))],
                                    decoration: new InputDecoration(
                                      border: OutlineInputBorder(borderRadius: new BorderRadius.circular(10.0)),
                                    ),
                                    onChanged: (text) {
                                      if(text == "") text = "0";
                                      setState(() {
                                        _gradeValue = int.parse(text);
                                      });
                                    },
                                    onTap: () {
                                      setState(() {
                                        gradeController.selection = new TextSelection(baseOffset: 0, extentOffset: gradeController.text.length);
                                      });
                                    },
                                  ),
                                ),
                              ),
                              new Text(
                                "/",
                                style: new TextStyle(
                                  fontSize: 32,
                                ),
                              ),
                              new Container(
                                height: 60,
                                width: 80,
                                child: new Padding(
                                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                                  child: new TextField(
                                    controller: weightController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [new WhitelistingTextInputFormatter(new RegExp("[0-9]"))],
                                    decoration: new InputDecoration(
                                      border: OutlineInputBorder(borderRadius: new BorderRadius.circular(10.0)),
                                    ),
                                    onChanged: (text) {
                                      if(text == "") text = "0";
                                      setState(() {
                                        _weightValue = int.parse(text);
                                      });
                                    },
                                    onTap: () {
                                      setState(() {
                                        weightController.selection = new TextSelection(baseOffset: 0, extentOffset: weightController.text.length);
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          new ThinDivider(),
                          new Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: new Wrap(
                              children: _buildCategoryChips(_categories),
                            ),
                          ),
                          new ThinDivider(),
                          new Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: new RaisedButton(
                              child: new Text(
                                'ADD',
                                style: new TextStyle(
                                    color: Colors.white
                                ),
                              ),
                              color: Colors.blue,
                              shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0)),
                              onPressed: () {
                                averageState.addGrade(_selectedCategory,_gradeValue.floor().toInt(),_weightValue.floor().toInt());
                                setState(() {
                                  print(keyboard);
                                  if(keyboard)
                                    gradeController.selection = new TextSelection(baseOffset: 0, extentOffset: gradeController.text.length);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    new Column(
                      children: _buildCategoryCards(_categories),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
    );
  }

  String _getGradeDisplay() {
    if(_weightValue.floor() != 0) {
      return '(${((_gradeValue.floor()/_weightValue.floor())*100).floor()}%)';
    } else {
      return '${_gradeValue.floor().toString()}/${_weightValue.floor().toString()} (EC)';
    }
  }

  String getSelectedAverage() {
    return _selectedAverage;
  }
}

Future openAverageEditDialog(AverageState averageState,userID,context) async {
  var result;
  DocumentSnapshot main = await Firestore.instance.collection('users').document(userID).get();
  String selectedAverage = main.data['selectedAverage'];
  DocumentSnapshot average = await Firestore.instance.collection('users').document(userID).collection('averages').document(selectedAverage).get();
  if(averageLoaded) {
    result = await showDialog(
        context: context,
        builder: (BuildContext context) => new AverageEditDialog(average.data['name'],false)
    );
    if(result != null) {
      if(result['delete']) {
        averageState.deleteAverage(Firestore.instance.collection('users').document(userID),averageState.getSelectedAverage());
      } else {
        averageState.updateAverage(Firestore.instance.collection('users').document(userID),result['name']);
      }
    }
  }
}

Future openAverageDialog(AverageState averageState,userID,context) async {
  var result;
  var addResult;
  if(averageLoaded) {
    result = await showDialog(
        context: context,
        builder: (BuildContext context) => new AverageDialog(userID,true)
    );
    if(result == -1) {
      addResult = await showDialog(
        context: context,
        builder: (BuildContext context) => new AverageEditDialog("New Average",true),
      );
      if(addResult != null) {
        averageState.addAverage(Firestore.instance.collection('users').document(userID),addResult['name']);
      }
    } else if(result != null) {
      averageState.updateSelectedAverage(Firestore.instance.collection('users').document(userID),result['id'],true);
      averageState.setSelectedAverage(result['id']);
    }
  }
}

class CategoryGrade extends StatelessWidget {
  final _name;
  final _grade;

  CategoryGrade(this._name,this._grade);

  @override
  Widget build(BuildContext context) {
    return new Text(
      '$_name: ${_grade.toStringAsFixed(2)}%',
      style: new TextStyle(
          fontSize: 20.0
      ),
    );
  }
}

class GradeAverageActions extends StatelessWidget {
  final String userID;

  GradeAverageActions(Key key,this.userID) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final averageState = Provider.of<AverageState>(context);
    return new Container(
      child: new Row(
        children: <Widget>[
          new IconButton(
            icon: new Icon(Icons.edit),
            onPressed: () {
              openAverageEditDialog(averageState,userID,context);
            },
          ),
          new IconButton(
            icon: new Icon(Icons.subject),
            onPressed: () {
              openAverageDialog(averageState,userID,context);
            },
          ),
        ],
      ),
    );
  }
}

class GradeAverageFAB extends StatelessWidget {
  final Key key;
  final simple;

  GradeAverageFAB(this.key,this.simple);

  @override
  Widget build(BuildContext context) {
    final averageState = Provider.of<AverageState>(context);
    if(!simple) {
      return new FloatingActionButton.extended(
        heroTag: "btn1",
        label: new Text('Add Category'),
        icon: new Icon(Icons.add_box),
        onPressed: () {
          if(average) openCreateCategoryDialog(averageState,context);
        },
      );
    } else {
      return new FloatingActionButton(
        heroTag: "btn2",
        child: new Icon(Icons.add),
        onPressed: () {
          if(average) openCreateCategoryDialog(averageState,context);
        },
      );
    }
  }
}

Future openCreateCategoryDialog(averageState,context) async {
  CategoryDialogData category = await Navigator.of(context).push(new MaterialPageRoute<CategoryDialogData>(
      builder: (BuildContext context) {
        return new CategoryDialog(new Category("", 100, -1),false);
      },
      fullscreenDialog: true
  ));
  if(category != null) {
    averageState.addCategory(new Category(category.name, category.weight, -1));
  }
}

Future<List> getAverages(userData) async {
  var docs = await userData.collection('averages').getDocuments();
  return docs.documents;
}

double getCategoryGrade(grades) {
  var top = 0;
  var bottom = 0;
  for (var j = 0; j < grades.length; j++) {
    top += grades[j]['grade'];
    bottom += grades[j]['weight'];
  }
  var sum = (top / bottom) * 100;
  if(sum.isNaN) {
    return 0.0;
  } else {
    return sum;
  }
}

double getOverallGrade(categories) {
  double sum = 0.0;
  for(var i = 0; i < categories.length; i++) {
    sum += getCategoryGrade(categories[i]['grades'])*(categories[i]['weight']/100);
  }
  return sum;
}