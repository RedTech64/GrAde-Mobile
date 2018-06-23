import 'package:flutter/material.dart';
import 'category_dialoge.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'category_card.dart';
import 'utils/auth.dart';
import 'loading.dart';
import 'dart:async';

int selectedAverage = 0;
var average = [];
GradeAverageState gradeAverageState;

class GradeAverage extends StatefulWidget {
  @override
  State createState() {
    gradeAverageState = new GradeAverageState();
    return gradeAverageState;
  }
}

class GradeAverageState extends State<GradeAverage> {
  var _gradeValue = 100.0;
  var _weightValue = 100.0;
  var _selectedCategory = 0;
  var categories = [];
  bool dataExists = false;
  int quickUpdate = 0;
  
  @override
  void initState() {
    signInWithGoogle().then((result) {
      _setupData().then((result) {
        setState(() {
          dataExists = result;
        });
      });
    });
    super.initState();
  }

  void addGrade() {
    setState(() {
      var grades = fixArray(categories[_selectedCategory]['grades']);
      grades.add({'grade': _gradeValue.floor().toInt(), 'weight': _weightValue.floor().toInt()});
      quickUpdate = 2;
      categories[_selectedCategory]['grades'] = grades;
    });
  } 

  void deleteGrade(int categoryIndex,int gradeIndex) {
    setState(() {
      var grades = fixArray(categories[categoryIndex]['grades']);
      grades.removeAt(gradeIndex);
      quickUpdate = 2;
      categories[categoryIndex]['grades'] = grades;
    });
  }

  void addCategory(Category category) {
    setState(() {
      categories.add({
        'name': category.name,
        'weight': category.weight,
        'grades': []
    });
    quickUpdate = 2;
  });
}

void editCategory(Category category) {
  setState(() {
     categories[category.index] = {
       'name': category.name,
       'weight': category.weight,
       'grades': []
     };
     quickUpdate = 2;
  });
}

void deleteCategory(Category category) {
  setState(() {
    categories.removeAt(category.index);
    quickUpdate = 2;
  });
}

  void _runTransaction() {
    print("RUN TRANS");
    final DocumentReference docRef = Firestore.instance.collection('users').document(userID);
    var batch = Firestore.instance.batch();
    average[selectedAverage]['categories'] = categories;
    batch.updateData(docRef, {
        'average': average,
    });
    batch.commit();
    Firestore.instance.runTransaction((transaction) async {
      DocumentSnapshot freshSnap = await transaction.get(docRef);
      freshSnap['average'][selectedAverage]['categories'] = categories;
      await transaction.update(docRef, {
        'average': freshSnap['average'],
      }); 
    });
  }

  Future<bool> _setupData() async {
    DocumentReference docRef = Firestore.instance.collection('users').document(userID);
    DocumentSnapshot data = await docRef.get();
    if(!data.exists || data['average'] == null) {
      await docRef.setData({
        'average': [
          {
            'categories': [
            {
              'grades': [],
              'max': 100,
              'name': "Category 1",
              'weight': 100
            }],
            'name': "Average 1",
            'selectedCategory': 0
          }],
        'averageSelected': 0
      });
      return true;
    } else {
      return true;
    }
  }

  List<Widget> _buildCategoryGradeList(categories) {
    var list = <Widget>[];
    for(var i = 0; i < categories.length; i++) {
      list.add(new CategoryGrade(categories[i]['name'], _getCategoryGrade(categories[i]['grades'])));
    }
    return list;
  }

  List<Widget> _buildCategoryCards(categories) {
    var list = <Widget>[];
    for(var i = 0; i < categories.length; i++) {
      list.add(new CategoryCard(
        new Category(categories[i]['name'],categories[i]['weight'], i),
        categories[i]['grades']));
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

  @override
  Widget build(BuildContext context) {
    if(userID == null || dataExists == false) return new Loading();
    return new StreamBuilder(
      stream: Firestore.instance.collection('users').document(userID).snapshots(),
      builder: (context, snapshot) {
        if(!snapshot.hasData) return new Loading();
        average = snapshot.data['average'];
        if(quickUpdate == 0) categories = fixArray(snapshot.data['average'][selectedAverage]['categories']);
        if(quickUpdate != 0) quickUpdate--;
        if(quickUpdate == 1) _runTransaction();
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
                          padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                          child: new Text(
                            'Overall Grades',
                            style: new TextStyle(
                              fontSize: 24.0,
                            ),
                          ),
                        ),
                        new Divider(),
                        new Padding(
                          padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                          child: new Text(
                            '${_getOverallGrade(categories).toStringAsFixed(2)}%',
                            style: new TextStyle(
                              fontSize: 34.0
                            ),
                          ),
                        ),
                        new Divider(),
                        new Padding(
                          padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
                          child: new Column(
                            children: _buildCategoryGradeList(categories),
                          ),
                        ),
                      ],
                    ),
                  ),
                  new Card(
                    child: new Column(
                      children: <Widget>[
                        new Padding(
                          padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                          child: new Text(
                            'Add Grades',
                            style: new TextStyle(
                              fontSize: 24.0
                            ),
                          ),
                        ),
                        new Divider(),
                        new Padding(
                          padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                          child: new Text(
                            _getGradeDisplay(),
                            style: new TextStyle(
                              fontSize: 20.0
                            ),
                          ),
                        ),
                        new Padding(
                          padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                          child: new Row(
                            children: <Widget>[
                              new Text(
                                'Grade:'
                              ),
                              new Expanded(
                                  child: new Slider(
                                  max: 100.0,
                                  min: 0.0,
                                  value: _gradeValue,
                                  onChanged: (value) {
                                    setState(() {
                                      _gradeValue = value;                                
                                    });
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                        new Padding(
                          padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                          child: new Row(
                            children: <Widget>[
                              new Text(
                                'Weight:'
                              ),
                              new Expanded(
                                  child: new Slider(
                                  max: 100.0,
                                  min: 0.0,
                                  value: _weightValue,
                                  onChanged: (value) {
                                    setState(() {
                                      _weightValue = value;                                
                                    });
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                        new Divider(),
                        new Wrap(
                          children: _buildCategoryChips(categories),
                        ),
                        new Divider(),
                        new Padding(
                          padding: const EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 16.0),
                          child: new RaisedButton(
                            child: new Text('ADD'),
                            onPressed: () {
                              addGrade();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  new Column(
                    children: _buildCategoryCards(categories),
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
      return '${_gradeValue.floor().toString()}/${_weightValue.floor().toString()} (${((_gradeValue.floor()/_weightValue.floor())*100).floor()}%)';
    } else {
      return '${_gradeValue.floor().toString()}/${_weightValue.floor().toString()} (EC)';
    }
  }

  double _getCategoryGrade(grades) {
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

  double _getOverallGrade(categories) {
    double sum = 0.0;
    for(var i = 0; i < categories.length; i++) {
      sum += _getCategoryGrade(categories[i]['grades'])*(categories[i]['weight']/100);
    }
    return sum;
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

class GradeAverageFAB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new FloatingActionButton.extended(
      label: new Text('Add Category'),
      icon: new Icon(Icons.add_box),
      onPressed: () {
        openCreateCategoryDialog(context);
      },
    );
  }
}

Future openCreateCategoryDialog(context) async {
  CategoryDialogData category = await Navigator.of(context).push(new MaterialPageRoute<CategoryDialogData>(
    builder: (BuildContext context) {
      return new CategoryDialog(new Category("", 100, -1),false);
    },
    fullscreenDialog: true
  ));
  if(category != null) {
    gradeAverageState.addCategory(new Category(category.name, category.weight, -1));
  }
}

List<dynamic> fixArray(array) {
  var list = [];
  for(var i = 0; i < array.length; i++) {
   list.add(array[i]);
  }
  return list;
}