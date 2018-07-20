import 'package:flutter/material.dart';
import 'category_dialoge.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'category_card.dart';
import 'average_dialog.dart';
import 'main.dart';
import 'loading.dart';
import 'dart:async';
import 'thin_divider.dart';

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
  String _selectedAverage;
  int _selectedCategory;
  var _categories = [];
  bool dataExists = false;
  int quickUpdate = 0;
  DocumentReference userData;

  GradeAverageState(this._userID);
  
  @override
  void initState() {
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

  void addAverage(name) async {
    DocumentReference averageDoc = await userData.collection('averages').add({'selectedCategory': 0});
    var id = averageDoc.documentID;
    averageDoc.updateData({
      'id': id,
      'name': name,
      'categories': [{
        'name': "Category 1",
        'weight': 100,
        'grades': [],
      }]
    });
    userData.updateData({'selectedAverage': id});
  }

  void updateAverage(name) {
    userData.collection('averages').document(_selectedAverage).updateData({'name': name});
  }

  void deleteAverage(String averageID) async {
    await userData.collection('averages').document(averageID).delete();
    QuerySnapshot docs = await userData.collection('averages').limit(1).getDocuments();
    DocumentSnapshot firstDoc = docs.documents[0];
    setState(() {
      _selectedAverage = firstDoc.documentID;
    });
  }

  void addGrade() {
    setState(() {
      var grades = fixArray(_categories[_selectedCategory]['grades']);
      grades.add({
        'grade': _gradeValue.floor().toInt(),
        'weight': _weightValue.floor().toInt()
      });
      quickUpdate = 2;
      _categories[_selectedCategory]['grades'] = grades;
    });
  }

  void deleteGrade(int categoryIndex,int gradeIndex) {
      setState(() {
        var grades = fixArray(_categories[categoryIndex]['grades']);
        grades.removeAt(gradeIndex);
        quickUpdate = 2;
        _categories[categoryIndex]['grades'] = grades;
      });
    }

  void addCategory(Category category) {
    List categories = fixArray(_categories);
    categories.add({
      'name': category.name,
      'weight': category.weight,
      'grades': []
    });
    setState(() {
      _categories = categories;
      quickUpdate = 2;
    });
  }

  void editCategory(Category category) {
    setState(() {
      _categories[category.index] = {
        'name': category.name,
        'weight': category.weight,
        'grades': []
      };
      quickUpdate = 2;
    });
  }

  void deleteCategory(Category category) {
    List categories = fixArray(_categories);
    categories.removeAt(category.index);
    setState(() {
      _categories = categories;
      quickUpdate = 2;
    });
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
      await docRef.setData({'selectedAverage': averageRef.documentID});
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
    if(_userID == null) return new Loading();
    return new StreamBuilder(
      stream: Firestore.instance.collection('users').document(_userID).collection('averages').document(_selectedAverage).snapshots(),
      builder: (context, snapshot) {
        if(!snapshot.hasData || snapshot.data.data == null) return new Loading();
        averageLoaded = true;
        if(quickUpdate == 0) {
          _categories = snapshot.data['categories'];
        }
        if(quickUpdate != 0) quickUpdate--;
        if(quickUpdate == 1) _uploadCategories();
        _selectedCategory = snapshot.data['selectedCategory'];
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
                            children: _categories.map((category) => new CategoryGrade(category['name'], _getCategoryGrade(category['grades']))).toList(),
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
                          padding: const EdgeInsets.all(8.0),
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
                              ),
                            ],
                          ),
                        ),
                        new Padding(
                          padding: const EdgeInsets.all(8.0),
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
                        new ThinDivider(),
                        new Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: new Wrap(
                            children: _buildCategoryChips(_categories),
                          ),
                        ),
                        new ThinDivider(),
                        new Padding(
                          padding: const EdgeInsets.all(8.0),
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

  Future<List> getAverages() async {
    var docs = await userData.collection('averages').getDocuments();
    return docs.documents;
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

  double getOverallGrade(categories) {
    double sum = 0.0;
    for(var i = 0; i < categories.length; i++) {
      sum += _getCategoryGrade(categories[i]['grades'])*(categories[i]['weight']/100);
    }
    return sum;
  }

  String getSelectedAverage() {
    return _selectedAverage;
  }

  Future openAverageEditDialog(context) async {
    var result;
    var averages = await userData.collection('averages').document(_selectedAverage).get();
    if(averageLoaded) {
      result = await showDialog(
          context: context,
          builder: (BuildContext context) => new AverageEditDialog(averages['name'],false)
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

  Future openAverageDialog(context) async {
    var result;
    var addResult;
    QuerySnapshot averageDocs = await userData.collection('averages').getDocuments();
    List averages = [];
    for(var i = 0; i < averageDocs.documents.length; i++) {
      averages.add(averageDocs.documents[i].data);
    }
    if(averageLoaded) {
      result = await showDialog(
          context: context,
          builder: (BuildContext context) => new AverageDialog(true)
      );
      if(result == -1) {
        addResult = await showDialog(
          context: context,
          builder: (BuildContext context) => new AverageEditDialog("New Average",true),
        );
        if(addResult != null) {
          addAverage(addResult['name']);
        }
      } else if(result != null) {
        setState(() {
          _selectedAverage = result['id'];
        });
      }
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

class GradeAverageFAB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new FloatingActionButton.extended(
      label: new Text('Add Category'),
      icon: new Icon(Icons.add_box),
      onPressed: () {
        if(average) openCreateCategoryDialog(context);
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