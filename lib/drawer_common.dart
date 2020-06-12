import 'package:flutter/material.dart';

Drawer loadDrawer(BuildContext context) {
  return Drawer(
    child: ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
          child: Text('Extra Credit'),
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
        ),
        ListTile(
          title: Text('Sandbox'),
          onTap: () {
            Navigator.pushNamed(context, '/sand');
          },
        ),
      ],
    ),
  );
}