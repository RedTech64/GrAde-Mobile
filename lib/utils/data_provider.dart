import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:GrAde/main.dart';
import 'package:GrAde/category_dialoge.dart';
import 'analytics.dart';

class AverageState with ChangeNotifier {
  AverageState();

  int _quickUpdate = 0;
  String _selectedAverage;
  List _categories;
  String _uid;

  void setUID(uid) {
    if(uid != _uid) {
      _uid = uid;
      _quickUpdate = 0;
      _selectedAverage = null;
      _categories = null;
    }
  }

  void setQU(qu) {
    _quickUpdate = qu;
  }

  void setSelectedAverage(averageID) {
    _selectedAverage = averageID;
  }

  void updateSelectedAverage(userData,averageID,notify) {
    _selectedAverage = averageID;
    userData.updateData({
      'selectedAverage': averageID,
    });
    if(notify) notifyListeners();
  }

  void setCategories(categories,notify) {
    _categories = categories;
    if(notify) notifyListeners();
  }

  int getQU() => _quickUpdate;
  String getSelectedAverage() => _selectedAverage;
  List getCategories() => _categories;

  void addAverage(userData,name) async {
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
    _selectedAverage = id;
    notifyListeners();
    sendAverageAddEvent(name);
  }

  void updateAverage(userData,name) {
    userData.collection('averages').document(_selectedAverage).updateData({'name': name});
    sendAverageEditEvent(name);
    notifyListeners();
  }

  void deleteAverage(userData,String averageID) async {
    DocumentSnapshot data = await userData.collection('averages').document(averageID).get();
    String name = data.data['name'];
    sendAverageDeleteEvent(name);
    await userData.collection('averages').document(averageID).delete();
    QuerySnapshot docs = await userData.collection('averages').limit(1).getDocuments();
    DocumentSnapshot firstDoc = docs.documents[0];
    userData.updateData({'selectedAverage': firstDoc.documentID});
    _selectedAverage = firstDoc.documentID;
    notifyListeners();
  }

  void addGrade(int categoryIndex,int grade,int weight) {
    var grades = fixArray(_categories[categoryIndex]['grades']);
    grades.add({
      'grade': grade,
      'weight': weight
    });
    _quickUpdate = 2;
    _categories[categoryIndex]['grades'] = grades;
    sendGradeAddEvent(grade, weight);
    notifyListeners();
  }

  void deleteGrade(int categoryIndex,int gradeIndex) {
    var grade = _categories[categoryIndex]['grades'][gradeIndex]['grade'];
    var weight = _categories[categoryIndex]['grades'][gradeIndex]['weight'];
    var grades = fixArray(_categories[categoryIndex]['grades']);
    grades.removeAt(gradeIndex);
    _quickUpdate = 2;
    _categories[categoryIndex]['grades'] = grades;
    sendGradeDeleteEvent(grade, weight);
    notifyListeners();
  }

  void addCategory(Category category) {
    List categories = fixArray(_categories);
    categories.add({
      'name': category.name,
      'weight': category.weight,
      'grades': []
    });
    _categories = categories;
    _quickUpdate = 2;
    sendCategoryAddEvent(category.name, category.weight);
    notifyListeners();
  }

  void editCategory(Category category) {
    _categories[category.index] = {
      'name': category.name,
      'weight': category.weight,
      'grades': _categories[category.index]['grades']
    };
    _quickUpdate = 2;
    sendCategoryEditEvent(category.name, category.weight);
    notifyListeners();
  }

  void deleteCategory(Category category) {
    List categories = fixArray(_categories);
    categories.removeAt(category.index);
    _categories = categories;
    _quickUpdate = 2;
    sendCategoryDeleteEvent(category.name, category.weight);
    notifyListeners();
  }

  void uploadCategories(userData) {
    print(_selectedAverage);
    userData.collection('averages').document(_selectedAverage).updateData({
      'categories': _categories,
    });
  }
}

class GPAState with ChangeNotifier {
  GPAState();

  void addClass(userData,name,grade,qp,linkData) async {
    DocumentReference classDoc = await userData.collection('classes').add({
      'name': name,
      'grade': grade,
      'qp': qp,
      'linkID': linkData.id,
      'linkName': linkData.name,
    });
    var id = classDoc.documentID;
    await classDoc.updateData({
      'id': id,
    });
    sendClassAddEvent(name, grade, qp,linkData.linked);
  }

  void editClass(userData,id,name,grade,qp,linkData) async {
    await userData.collection('classes').document(id).updateData({
      'name': name,
      'grade': grade,
      'qp': qp,
      'linkID': linkData.id,
      'linkName': linkData.name,
    });
    sendClassEditEvent(name, grade, qp,linkData.linked);
  }

  void deleteClass(userData,id) async {
    DocumentSnapshot c = await userData.collection('classes').document(id).get();
    bool linked = false;
    if(c.data['linkID'] != "") linked = true;
    sendClassDeleteEvent(c.data['name'], c.data['grade'], c.data['qp'],linked);
    await userData.collection('classes').document(id).delete();
  }
}