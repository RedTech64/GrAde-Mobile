import 'loading.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class AverageDialog extends StatelessWidget {
  final String userID;
  final bool add;

  AverageDialog(this.userID,this.add);

  Future<List<Widget>> _buildAverageElements(context) async {
    QuerySnapshot averageDocs = await Firestore.instance.collection('users').document(userID).collection('averages').getDocuments();
    List averages = [];
    for(DocumentSnapshot averageDoc in averageDocs.documents) {
      averages.add(averageDoc.data);
    }
    var list = <Widget>[];
    for(var i = 0; i < averages.length; i++) {
      list.add(new SimpleDialogOption(
        child: new Row(
          children: <Widget>[
            new Text(
                averages[i]['name'],
                style: new TextStyle(
                    fontSize: 18.0
                )
            )
          ],
        ),
        onPressed: () {
          Navigator.pop(context, {'id': averages[i]['id'], 'name': averages[i]['name']});
        },
      ));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _buildAverageElements(context),
      builder: (BuildContext context, future) => new SimpleDialog(
          title: new Text('Select Average'),
          children: <Widget>[
            new Divider(),
            new Column(
              children: <Widget>[
                new Column(
                  children: _getMenu(future),
                ),
              ],
            ),
            add ? new Divider() : new Container(),
            add ? new SimpleDialogOption(
              child: new Row(
                children: <Widget>[
                  new Icon(Icons.add),
                  new Text(
                      ' Add Average',
                      style: new TextStyle(
                          fontSize: 18.0
                      )
                  ),
                ],
              ),
              onPressed: () {
                Navigator.pop(context, -1);
              },
            ) : new Container(),
          ]
      ),
    );
  }

  _getMenu(future) {
    if(future.data == null) {
      return [new Loading()];
    } else {
      return future.data;
    }
  }
}

class AverageEditDialog extends StatefulWidget {
  final String _name;
  final bool _new;

  AverageEditDialog(this._name,this._new);

  @override
  State createState() => AverageEditDialogState(_name,_new);
}

class AverageEditDialogState extends State<AverageEditDialog> {
  String _name;
  String _text;
  bool _new;
  TextEditingController _controller;

  AverageEditDialogState(this._name,this._new);

  @override
  void initState() {
    super.initState();
    _controller = new TextEditingController(text: _text);
  }

  @override
  Widget build(BuildContext context) {
    return new AlertDialog(
      title: new Text("Edit Average"),
      content: new TextField(
        controller: _controller,
        onChanged: (result) {
          setState(() {
            _text = result;
          });
        },
      ),
      actions: <Widget>[
        _new ? new Container() :
        new FlatButton(
          child: new Text('DELETE'),
          onPressed: () {
            Navigator.pop(context, {'name': _text, 'delete': true});
          },
        ),
        new FlatButton(
          child: new Text('CANCEL'),
          onPressed: () {
            Navigator.pop(context, {'name': _text, 'delete': false});
          },
        ),
        new FlatButton(
          child: _new ? new Text('ADD') : new Text('UPDATE'),
          onPressed: () {
            Navigator.pop(context, {'name': _text,'delete': false});
          },
        ),
      ],
    );
  }
}