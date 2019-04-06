import 'dart:async';

import 'package:egitim/model/car.dart';
import 'package:flutter/material.dart';

// widget burdan başlıyor
class FullScreenDialogDemo extends StatefulWidget {
  @override
  FullScreenDialogDemoState createState() => FullScreenDialogDemoState();
}

// class burdan başlıyor
class FullScreenDialogDemoState extends State<FullScreenDialogDemo> {
  bool isFavorite = false;
  String description = '';
  String name = '';

  Future<bool> _onWillPop() async {
    var saveNeeded = name.isNotEmpty || description.isNotEmpty || isFavorite;
    if (!saveNeeded) return true;

    final ThemeData theme = Theme.of(context);
    final TextStyle dialogTextStyle = theme.textTheme.subhead.copyWith(color: theme.textTheme.caption.color);

    // eğer değişiklik varsa çıkmak istiyor musun diye soruyor
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text('Discard New Car?', style: dialogTextStyle),
              actions: <Widget>[
                FlatButton(
                    child: const Text('CANCEL'),
                    onPressed: () {
                      Navigator.of(context).pop(false); // Pops the confirmation dialog but not the page.
                    }),
                FlatButton(
                    child: const Text('DISCARD'),
                    onPressed: () {
                      Navigator.of(context).pop(true); // Returning true to _onWillPop will pop again.
                    })
              ],
            );
          },
        ) ??
        false;
  }

  // başlık burdaaa
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('Add a New Car'), actions: <Widget>[
        FlatButton(
            child: Text('SAVE', style: theme.textTheme.body1.copyWith(color: Colors.white)),
            onPressed: () {
              Navigator.pop(context, Car.added(this.name, this.description, this.isFavorite));
            })
      ]),
      body: Form(
          onWillPop: _onWillPop,
          child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: <Widget>[
                Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    alignment: Alignment.bottomLeft,
                    child: TextField(
                        decoration: const InputDecoration(labelText: 'Car Name', filled: true),
                        onChanged: (String value) {
                          setState(() {
                            name = value;
                          });
                        })),
                Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    alignment: Alignment.bottomLeft,
                    child: TextField(
                        decoration: const InputDecoration(labelText: 'Description', filled: true),
                        onChanged: (String value) {
                          setState(() {
                            description = value;
                          });
                        })),
                Container(
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: theme.dividerColor))),
                    child: Row(children: <Widget>[
                      Checkbox(
                          value: isFavorite,
                          onChanged: (bool value) {
                            setState(() {
                              isFavorite = value;
                            });
                          }),
                      const Text('Is Favorite'),
                    ]))
              ].map<Widget>((Widget child) {
                return Container(padding: const EdgeInsets.symmetric(vertical: 8.0), height: 96.0, child: child);
              }).toList())),
    );
  }
}
