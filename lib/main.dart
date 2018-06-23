import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import './grade_average.dart';
import './gpa_calculator.dart';
import './settings.dart';
import './utils/auth.dart';

GradeAverage gradeAverage = new GradeAverage();
GPACalculator gpaCalculator = new GPACalculator();

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
      },
    );
  }
}

class MainView extends StatefulWidget {
  @override
  State createState() => new MainViewState();
}


class MainViewState extends State<MainView> {
  Widget _page = new GradeAverage();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('GrAde'),
        backgroundColor: Colors.red,
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).pushNamed('/settings');
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
      floatingActionButton: new GradeAverageFAB(),
    );
  }

  void _changePage(int index) {
    setState(() {
      if(index == 0) {
        _page = gradeAverage;
        _currentIndex = 0;

      } else {
        _page = gpaCalculator;
        _currentIndex = 1;
      }
    });
  }
}