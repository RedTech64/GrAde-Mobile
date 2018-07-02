import 'package:flutter/material.dart';
import 'category_dialoge.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'category_card.dart';
import 'average_dialog.dart';
import 'utils/auth.dart';
import 'loading.dart';
import 'dart:async';

var average = [];
bool averageLoaded = false;
GradeAverageState gradeAverageState;

class GradeAverage extends StatefulWidget {
  final String _userID;

  GradeAverage(Key key,this._userID) : super(key: key);
  
  @override
  State createState() {
    gradeAverageState = new GradeAverageState(_userID);
    return gradeAverageState;
  }
}

class GradeAverageState extends State<GradeAverage> {
  String _userID;
  var _gradeValue = 100.0;
  var _weightValue = 100.0;
  int _selectedAverage = 0;
  var _selectedCategory = 0;
  var categories = [];
  bool dataExists = false;
  int quickUpdate = 0;

  GradeAverageState(this._userID);
  
  @override
  void initState() {
    var data = false;
    _setupData().then((result) {
      data = result;
      Firestore.instance.collection('users').document(_userID).get().then((doc) {
        setState(() {
          _selectedAverage = doc['averageSelected'];
          dataExists = data;
        });
      });
    });
    super.initState();
  }

  void addAverage(name) {
    var newAverage = fixArray(average);
    newAverage.add({
      'name': name,
      'categories': [{
        'name': "Category 1", 
        'weight': 100, 
        'grades': []
      }],
      'selectedCategory': 0
    });
    average = newAverage;
    Firestore.instance.collection('users').document(_userID).updateData({'average': average});
    setState(() {
      quickUpdate = 2;
      _selectedAverage = newAverage.length-1;
    });
  }

  void updateAverage(name) {
    var newAverage = fixArray(average);
    newAverage[_selectedAverage]['name'] = name;
    Firestore.instance.collection('users').document(_userID).updateData({'average': newAverage});
  }

  void setAverage(int averageIndex) {
    setState(() {
      _selectedAverage = averageIndex;
    });
  }

  void deleteAverage(int averageIndex) {
    var newAverage = fixArray(average);
    newAverage.removeAt(averageIndex);
    Firestore.instance.collection('users').document(_userID).updateData({'average': newAverage});
    setState(() {
      _selectedAverage = 0;
    });
  }

  void addGrade() {
    setState(() {
      var grades = fixArray(categories[_selectedCategory]['grades']);
      grades.add({
        'grade': _gradeValue.floor().toInt(), 
        'weight': _weightValue.floor().toInt()
      });
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
    final DocumentReference docRef = Firestore.instance.collection('users').document(_userID);
    var batch = Firestore.instance.batch();
    average[_selectedAverage]['categories'] = categories;
    batch.updateData(docRef, {
        'average': average,
    });
    batch.commit();
  }

  Future<bool> _setupData() async {
    DocumentReference docRef = Firestore.instance.collection('users').document(_userID);
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

  @override
  Widget build(BuildContext context) {
    if(_userID == null) return new Loading();
    return new StreamBuilder(
      stream: Firestore.instance.collection('users').document(_userID).snapshots(),
      builder: (context, snapshot) {
        if(!snapshot.hasData) return new Loading();
        averageLoaded = true;
        if(quickUpdate == 0) {
          average = snapshot.data['average'];
          categories = fixArray(snapshot.data['average'][_selectedAverage]['categories']);
        }
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
                          child: new Text(average[_selectedAverage]['name'],
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
                            children: categories.map((category) => new CategoryGrade(category['name'], _getCategoryGrade(category['grades']))).toList(),
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

  int getSelectedAverage() {
    return _selectedAverage;
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

Future openAverageDialog(context) async {
  var result;
  var addResult;
  if(averageLoaded) {
    result = await showDialog(
      context: context,
      builder: (BuildContext context) => new AverageDialog(average)
    );
    if(result == -1) {
      addResult = await showDialog(
        context: context,
        builder: (BuildContext context) => new AverageEditDialog("New Average",true),
      );
      if(addResult != null) {
        gradeAverageState.addAverage(addResult['name']);
      }
    } else if(result != null) {
      gradeAverageState.setAverage(result);
    }
  }
}

Future openAverageEditDialog(context) async {
  var result;
  if(averageLoaded) {
    result = await showDialog(
      context: context,
      builder: (BuildContext context) => new AverageEditDialog(average[gradeAverageState.getSelectedAverage()]['name'],false)
    );
    if(result != null) {
      if(result['delete']) {
        gradeAverageState.deleteAverage(gradeAverageState.getSelectedAverage());
      } else {
        gradeAverageState.updateAverage(result['name']);
      }
    }
  }
}

List<dynamic> fixArray(array) {
  var list = [];
  for(var i = 0; i < array.length; i++) {
   list.add(array[i]);
  }
  return list;
}