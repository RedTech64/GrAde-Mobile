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

double version = 0.5;
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
        builder: (_) => AverageState(),
        child: new MainView(),
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

  @override
  void initState() {
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
    final averageState = Provider.of<AverageState>(context);
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('GrAde'),
        backgroundColor: Colors.red,
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.settings),
            onPressed: () {
              openSettings();
            }),
          _actions,
        ],
      ),
      body: _page,
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
      floatingActionButton: _fab,
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
        _fab = new GPACalculatorFAB(new Key(simpleFAB.toString()), simpleFAB);
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