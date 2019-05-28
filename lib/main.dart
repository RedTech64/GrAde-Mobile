import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import './grade_average.dart';
import './gpa_calculator.dart';
import './settings.dart';
import './utils/auth.dart';
import 'loading.dart';
import 'welcome.dart';
import 'utils/analytics.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'utils/data_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';

double version = 1.41;
bool average = true;

void main() {
  runApp(new GrAdeApp());
}

class GrAdeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'GrAde',
      home: new ChangeNotifierProvider(
        builder: (_) => GPAState(),
        child: new ChangeNotifierProvider(
          builder: (_) => AverageState(),
          child: new MainView(),
        ),
      ),
      debugShowCheckedModeBanner: false,
      routes: <String, WidgetBuilder> {
        '/settings': (BuildContext context) => new Settings(),
        '/welcome': (BuildContext context) => new Welcome(),
      },
    );
  }
}

class MainView extends StatefulWidget {
  @override
  State createState() => new MainViewState();
}


class MainViewState extends State<MainView> {
  GradeAverage gradeAverage;
  GPACalculator gpaCalculator;
  Widget _page = new Loading();
  Widget _fab = GradeAverageFAB(new Key("true"), true);
  Widget _actions = GradeAverageActions(new Key(userID),userID);
  int _currentIndex = 0;
  int keyCount = 0;
  DocumentReference userData;
  bool keyboard = false;

  @override
  void initState() {
    KeyboardVisibilityNotification().addNewListener(
        onChange: (visible) {
          setState(() {
            keyboard = visible;
          });
        }
    );
    super.initState();
    signInWithGoogle(true).then((data) {
      print(data.uid);
      if (data.signedin) {
        _setUpPages(data);
        _changePage(0);
      } else {
        _initialize();
      }
    });
  }

  Future _initialize() async {
    WelcomePageData data = await Navigator.of(context).push(
        new MaterialPageRoute<WelcomePageData>(
            builder: (BuildContext context) {
              return new Welcome();
            },
            fullscreenDialog: true
        ));
    if (data.uid == null) {
      await _initialize();
    }
    _setUpPages(data);
    userID = data.uid;
    simpleFAB = data.simpleFAB;
    _changePage(0);
  }

  void _setUpPages(data) {
    gradeAverage = new GradeAverage(new Key(data.uid), data.uid);
    gpaCalculator = new GPACalculator(new Key(data.uid), data.uid);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: new AppBar(
        title: new Text('GrAde'),
        backgroundColor: Colors.red,
        actions: <Widget>[
          _actions,
          new IconButton(
            icon: new Icon(Icons.settings),
            onPressed: () {
              openSettings();
            }),
        ],
      ),
      body: new FormKeyboardActions(child: _page),
      bottomNavigationBar: new BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          new BottomNavigationBarItem(
              icon: new Icon(Icons.timeline), title: new Text('Average')),
          new BottomNavigationBarItem(
              icon: new Icon(Icons.school), title: new Text('GPA')),
        ],
        fixedColor: Colors.red,
        currentIndex: _currentIndex,
        onTap: _changePage,
      ),
      floatingActionButton: new Visibility(visible: !keyboard,child: _fab),
    );
  }

  void openSettings() async {
    sendSettingsOpenEvent();
    Map result = await Navigator.of(context).push(new MaterialPageRoute<Map>(
        builder: (BuildContext context) {
          return new Settings();
        },
        fullscreenDialog: true
    ));
    if (result != null && result['signout']) {
      await signOut();
      await _initialize();
    }
    _changePage(_currentIndex);
  }

  void _changePage(int index) {
    setState(() {
      if (simpleFAB == null) {
        _changePage(index);
      }
      if (index == 0) {
        _page = gradeAverage;
        _actions = new GradeAverageActions(new Key(userID),userID);
        _fab = new GradeAverageFAB(new Key(simpleFAB.toString()), simpleFAB);
        _currentIndex = 0;
        average = true;
      } else {
        _page = gpaCalculator;
        _actions = new GPACalculatorActions(new Key(userID),userID);
        _fab = new GPACalculatorFAB(new Key(simpleFAB.toString()+userID), simpleFAB, userID);
        _currentIndex = 1;
        average = false;
      }
    });
  }
}

List<dynamic> fixArray(array) {
  var list = [];
  for(var i = 0; i < array.length; i++) {
    list.add(array[i]);
  }
  return list;
}