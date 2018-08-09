import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import './grade_average.dart';
import './gpa_calculator.dart';
import './settings.dart';
import './utils/auth.dart';
import 'loading.dart';
import 'welcome.dart';
import 'utils/analytics.dart';

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
      home: new MainView(),
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
  Widget _fab = GradeAverageFAB(new Key("true"),true);
  int _currentIndex = 0;
  int keyCount = 0;

  @override
  void initState() {
    super.initState();
    signInWithGoogle(true).then((signedin) {
      if(signedin) {
        gradeAverage =  new GradeAverage(new Key(userID), userID);
        gpaCalculator = new GPACalculator(new Key(userID), userID);
        _changePage(0);
      } else {
        _initialize();
      }
    });
  }

  void _initialize() async {
    var uid = await Navigator.of(context).pushNamed('/welcome');
    if(uid == null) {
      _initialize();
    }
    gradeAverage =  new GradeAverage(new Key(uid), uid);
    gpaCalculator = new GPACalculator(new Key(uid), uid);
    _changePage(0);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('GrAde'),
        backgroundColor: Colors.red,
        actions: <Widget>[
          average ? new IconButton(
            icon: new Icon(Icons.edit),
            onPressed: () {
              gradeAverageState.openAverageEditDialog(context);
            },
          ) : new Container(),
          average ? new IconButton(
            icon: new Icon(Icons.subject),
            onPressed: () {
              gradeAverageState.openAverageDialog(context);
            },
          ) : new Container(),
          new IconButton(
            icon: new Icon(Icons.settings),
            onPressed: () {
              openSettings();
            }),
        ],
      ),
      body: _page,
      bottomNavigationBar: new BottomNavigationBar(
        items: <BottomNavigationBarItem> [
          new BottomNavigationBarItem(icon: new Icon(Icons.timeline), title: new Text('Average')),
          new BottomNavigationBarItem(icon: new Icon(Icons.school), title: new Text('GPA')),
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
    await Navigator.of(context).pushNamed('/settings');
    _updateUser();
  }

  void _changePage(int index) {
    setState(() {
      if(index == 0) {
        _page = gradeAverage;
        _fab = new GradeAverageFAB(new Key(simpleFAB.toString()),simpleFAB);
        _currentIndex = 0;
        average = true;
      } else {
        _page = gpaCalculator;
        _fab = new GPACalculatorFAB(new Key(simpleFAB.toString()),simpleFAB);
        _currentIndex = 1;
        average = false;
      }
    });
  }

  void _updateUser() {
    setState(() {
      if(_currentIndex == 0) {
        _page = new GradeAverage(new Key(userID+keyCount.toString()),userID);
        _fab = new GradeAverageFAB(new Key(simpleFAB.toString()),simpleFAB);
        average = true;
      } else {
        _page = new GPACalculator(new Key(userID+keyCount.toString()), userID);
        _fab = new GPACalculatorFAB(new Key(simpleFAB.toString()),simpleFAB);
        average = false;
      }
      keyCount = keyCount+1;
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