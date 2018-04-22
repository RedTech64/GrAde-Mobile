import 'package:flutter/material.dart';

class GPACalculator extends StatefulWidget {
  @override
  State createState() => new GPACalculatorState();
}

class GPACalculatorState extends State<GPACalculator> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new Text("GPA Calculator"),
    );
  }
}