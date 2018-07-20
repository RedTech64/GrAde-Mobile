import 'package:flutter/material.dart';
import 'grade_average.dart';
import 'category_dialoge.dart';
import 'dart:async';
import 'thin_divider.dart';

class CategoryCard extends StatelessWidget {
  final Category _category;
  final _grades;

  CategoryCard(this._category,this._grades);

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
        padding: const EdgeInsets.all(2.0),
        child: new InputChip(
          label: new Text(_text),
          deleteIcon: new Icon(Icons.cancel),
          onPressed: () {
          },
          onDeleted: () {
            gradeAverageState.deleteGrade(_category.index, i);
          },
        ),
      ));
    }
    if(list.isEmpty) {
      list.add(new Text('No Grades Added'));
    } 
    return list;
  }

  Future _openEditCategoryDialog(context) async {
    CategoryDialogData category = await Navigator.of(context).push(new MaterialPageRoute<CategoryDialogData>(
      builder: (BuildContext context) {
        return new CategoryDialog(new Category(this._category.name, this._category.weight, this._category.index),true);
      },
      fullscreenDialog: true
    ));
    if(category != null) {
      if(category.delete) {
        gradeAverageState.deleteCategory(new Category(category.name, category.weight, category.index));
      } else {
        gradeAverageState.editCategory(new Category(category.name, category.weight, category.index));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Card(
      child: new Column(
        children: <Widget>[
          new Row(
            children: <Widget>[
              new Padding(
                padding: EdgeInsets.all(8.0),
                child: new SizedBox(
                  height: 32.0,
                  width: 32.0,
                  child: new SizedBox(
                    height: 24.0,
                    width: 24.0,
                  ),
                ),
              ),
              new Expanded(
                child: new Text(
                  _category.name,
                  textAlign: TextAlign.center,
                  style: new TextStyle(
                    fontSize: 24.0,
                  ),
                ),
              ),
              new IconButton(
                  icon: new Icon(Icons.edit),
                  onPressed: () {
                    _openEditCategoryDialog(context);
                  },
              )
            ],
          ),
          new ThinDivider(),
          new Padding(
            padding: const EdgeInsets.all(6.0),
            child: new Wrap(
              children: _buildChips(_grades),
            ),
          )
        ],
      ),
    );
  }
}