import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import './grade_average.dart';
import './gpa_calculator.dart';

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
        '/grade_average': (BuildContext context) => new GradeAverage(),
        '/gpa_calculator': (BuildContext context) => new GPACalculator(),
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
    );
  }

  void _changePage(int index) {
    setState(() {
      if(index == 0) {
        _page = new GradeAverage();
        _currentIndex = 0;

      } else {
        _page = new GPACalculator();
        _currentIndex = 1;
      }
    });
  }
}