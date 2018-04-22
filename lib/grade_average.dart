import 'package:flutter/material.dart';

class GradeAverage extends StatefulWidget {
  @override
  State createState() => new GradeAverageState();
}

class GradeAverageState extends State<GradeAverage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new Text("Grade Average"),
    );
  }
}