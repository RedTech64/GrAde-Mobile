import 'package:flutter/material.dart';
import 'grade_average.dart';
import 'category_dialoge.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'utils/auth.dart';
import 'dart:async';

class CategoryCard extends StatelessWidget {
  final Category _category;
  final _grades;

  CategoryCard(this._category, this._grades);

  List<Widget> _buildChips(_grades) {
    var list = <Widget>[];
    for(var i = 0; i < _grades.length; i++) {
      int _grade = _grades[i]['grade'];
      int _weight = _grades[i]['weight'];
      var _text = '';
      if(_weight != 100) {
        _text = '${_grade.toString()}/${_weight.toString()}';
      } else {
        _text = _grade.toString();
      }
      list.add(new Padding(
        padding: const EdgeInsets.fromLTRB(2.0, 4.0, 2.0, 0.0),
        child: new InputChip(
          label: new Text(_text),
          deleteIcon: new Icon(Icons.cancel),
          onPressed: () {
          },
          onDeleted: () {
            final DocumentReference docRef = Firestore.instance.collection('users').document(userID);
            Firestore.instance.runTransaction((transaction) async {
              DocumentSnapshot freshSnap = await transaction.get(docRef);
              var grades = freshSnap['average'][selectedAverage]['categories'][this._category.index]['grades'];
              var newGrades = fixArray(grades);
              newGrades.removeAt(i);
              freshSnap['average'][selectedAverage]['categories'][this._category.index]['grades'] = newGrades;
              await transaction.update(docRef, {
                'average': freshSnap['average'],
              });
            });
          },
        ),
      ));
    }
    if(list.isEmpty) {
      list.add(new Text('No Grades Added'));
    } 
    return list;
  }

  Future openEditCategoryDialog(context) async {
    CategoryDialogData category = await Navigator.of(context).push(new MaterialPageRoute<CategoryDialogData>(
      builder: (BuildContext context) {
        return new CategoryDialog(new Category(this._category.name, this._category.weight, this._category.index),true);
      },
      fullscreenDialog: true
    ));
    if(category != null) {
      if(category.delete) {
        deleteCategory(new Category(category.name, category.weight, category.index));
      } else {
        Firestore.instance.runTransaction((transaction) async {
          DocumentSnapshot freshSnap = await transaction.get(Firestore.instance.collection('users').document(userID));
          freshSnap['average'][selectedAverage]['categories'][category.index]['name'] = category.name;
          freshSnap['average'][selectedAverage]['categories'][category.index]['weight'] = category.weight;
          await transaction.update(freshSnap.reference, {
            'average': freshSnap['average'],
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Card(
      child: new Padding(
        padding: const EdgeInsets.all(8.0),
        child: new Column(
          children: <Widget>[
            new Row(
              children: <Widget>[
                new Expanded(
                  child: new Stack(
                    fit: StackFit.passthrough,
                    children: <Widget>[
                      new Positioned(
                        child: new Text(
                          this._category.name,
                          textAlign: TextAlign.center,
                          style: new TextStyle(
                            fontSize: 24.0,
                          ),
                        ),
                      ),
                      new Positioned(
                        right: 8.0,
                        top: 0.0,
                        bottom: 2.0,
                        child: new IconButton(
                          icon: new Icon(Icons.edit),
                          onPressed: () {
                            openEditCategoryDialog(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            new Divider(),
            new Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
              child: new Wrap(
                children: _buildChips(_grades),
              ),
            )
          ],
        ),
      ),
    );
  }
}