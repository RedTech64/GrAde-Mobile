import 'package:flutter/material.dart';
import 'dart:async';
import 'average_dialog.dart';
import 'class.dart';

class ClassDialogData {
  String name;
  int grade;
  int qp;
  LinkData linkData;
  bool delete;

  ClassDialogData(this.name,this.grade,this.qp,this.linkData,this.delete);
}

class ClassDialog extends StatefulWidget {
  final String name;
  final int grade;
  final int qp;
  final bool edit;
  final LinkData linkData;

  ClassDialog(this.name,this.grade,this.qp,this.edit,this.linkData);

  State createState() => new ClassDialogState(name,grade.toDouble(),qp,edit,linkData);
}

class ClassDialogState extends State<ClassDialog> {
  String _name;
  double _grade;
  int _qp;
  bool _edit;
  LinkData _linkData;
  var _controller;

  ClassDialogState(this._name,this._grade,this._qp,this._edit,this._linkData);

  @override
  void initState() {
    super.initState();
    _controller = new TextEditingController(text: _name);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: _edit ? new Text('Edit Class') : new Text('New Class'),
        actions: <Widget>[
          _edit ? new IconButton(
            icon: new Icon(Icons.delete),
            onPressed: () {
              Navigator.of(context).pop(
                new ClassDialogData(_name,_grade.floor().toInt(),_qp.toInt(),_linkData,true),
              );
            },
          ) : new Container(),
          new IconButton(
            icon: new Icon(Icons.save),
            onPressed: () {
              Navigator.of(context).pop(
                new ClassDialogData(_name,_grade.floor().toInt(),_qp.toInt(),_linkData,false),
              );
            },
          ),
        ],
      ),
      body: new Padding(
        padding: const EdgeInsets.all(8.0),
        child: new Form(
          child: new Column(
            children: <Widget>[
              new ListTile(
                leading: new Icon(Icons.speaker_notes, color: Colors.grey[500]),
                title: new TextField(
                  controller: _controller,
                  decoration: new InputDecoration(
                    hintText: 'Class Name',
                  ),
                  onChanged: (value) {
                    _name = value;
                  },
                ),
              ),
              new Divider(),
              new Padding(
                padding: const EdgeInsets.all(8.0),
                child: new Row(
                    children: <Widget>[
                      new Expanded(
                        child: new Text('Grade'),
                      ),
                      _linkData.linked ? new Container() :
                      new Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: new Text(_grade.floor().toString()),
                      ),
                    ]
                ),
              ),
              _linkData.linked ? new Container() :
              new Slider(
                min: 0.0,
                max: 100.0,
                value: _grade,
                onChanged: (value) {
                  setState(() {
                    _grade = value;
                  });
                },
              ),
              _linkData.linked ? new Column(
                children: <Widget>[
                  new Text('Linked to ${_linkData.name}'),
                  new FlatButton(
                    child: new Text('UNLINK'),
                    onPressed: () {
                      setState(() {
                        _linkData.linked = false;
                        _linkData.id = "";
                        _linkData.name = "";
                      });
                    },
                  ),
                ],
              ) :
              new FlatButton(
                child: new Text('LINK TO AVERAGE'),
                onPressed: () => _openLinkDialog(context),
              ),
              new Divider(),
              new Padding(
                padding: const EdgeInsets.all(8.0),
                child: new Row(
                    children: <Widget>[
                      new Expanded(
                        child: new Text('Quality Points'),
                      ),
                      new Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: new Text(_qp.toString()),
                      ),
                    ]
                ),
              ),
              new Slider(
                min: 0.0,
                max: 15.0,
                divisions: 15,
                value: _qp.toDouble(),
                onChanged: (value) {
                  setState(() {
                    _qp = value.floor();
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future _openLinkDialog(context) async {
    var result;
    result = await showDialog(
        context: context,
        builder: (BuildContext context) => new AverageDialog(false)
    );
    if(result != null) {
      setState(() {
        _linkData.linked = true;
        _linkData.name = result['name'];
        _linkData.id = result['id'];
      });
    }
  }
}