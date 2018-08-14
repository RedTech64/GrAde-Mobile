import 'package:flutter/material.dart';

class Category {
  String name;
  int weight;
  int index;

  Category(this.name,this.weight,this.index);
}

class CategoryDialogData {
  String name;
  int weight;
  int index;
  bool delete;

  CategoryDialogData(this.name,this.weight,this.index,this.delete);
}

class CategoryDialog extends StatefulWidget {
  final Category _category;
  final bool _edit;

  CategoryDialog(this._category,this._edit);
  
  State createState() {
    return new CategoryDialogState(this._category,this._edit);
  }
}

class CategoryDialogState extends State<CategoryDialog> {
  Category category;
  String _name;
  double _weight;
  int _index;
  bool edit;
  var _controller;

  CategoryDialogState(Category category,this.edit) {
    this._name = category.name;
    this._weight = category.weight.toDouble();
    this._index = category.index;
  }

  @override
  void initState() {
    super.initState();
    _controller = new TextEditingController(text: _name);
  }
  
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: edit ? new Text('Edit Category') : new Text('New Category'),
        actions: <Widget>[
          edit ? new IconButton(
            icon: new Icon(Icons.delete),
            onPressed: () {
              Navigator.of(context).pop(
                new CategoryDialogData(_name, _weight.floor(),_index,true)
              );
            },
          ) : new Container(),
          new IconButton(
            icon: new Icon(Icons.save),
            onPressed: () {
              Navigator.of(context).pop(
                new CategoryDialogData(_name, _weight.floor(),_index,false)
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
                    hintText: 'Category Name',
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
                      child: new Text(
                        'Weight',
                        style: new TextStyle(
                          fontSize: 15.0,
                        ),
                      ),
                    ),
                    new Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: new Text(
                        _weight.floor().toString()+"%",
                        style: new TextStyle(
                          fontSize: 15.0,
                        ),
                      ),
                    ),
                  ]
                ),
              ),
              new Slider(
                min: 0.0,
                max: 100.0,
                value: _weight,
                onChanged: (value) {
                  setState(() {
                    _weight = value;      
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
} 