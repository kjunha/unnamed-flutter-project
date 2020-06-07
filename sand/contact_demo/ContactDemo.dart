import 'package:flutter/material.dart';
import 'ContactListPage.dart';
import 'ContactDetailPage.dart';

void main() {
  runApp(ContactDemo());
}



class ContactDemo extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contact List Demo',
      debugShowCheckedModeBanner: false,
      home: ContactListPage(),
    );
  }
  final MaterialPageRoute _noWay = MaterialPageRoute(
    builder: (_) => Scaffold(
    body: Center(
      child: Text('No Route'),
    )
    )
  );
}



