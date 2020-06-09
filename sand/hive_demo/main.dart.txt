import 'package:finance_point/model/contact.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'contact_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  Hive.registerAdapter(ContactAdapter());
  runApp(MyApp());
}

class MyApp extends StatefulWidget{
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hive Tutorial',
      home: FutureBuilder(
        future: Hive.openBox('contacts'),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if(snapshot.connectionState == ConnectionState.done) {
            if(snapshot.hasError) {
              return Text(snapshot.error.toString());
            } else {
              return ContactPage();
            }
          } else {
            return Scaffold();
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }
}