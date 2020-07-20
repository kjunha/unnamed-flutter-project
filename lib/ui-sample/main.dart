import 'package:flutter/material.dart';

main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "UI Sample",
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white, title: Text("Extra Credit", style: TextStyle(color: Colors.black),),
          centerTitle: true,
          elevation: 0.0,
          actions: <Widget>[IconButton(icon: Icon(Icons.edit, color: Colors.black,),onPressed: () {print("appbar button");},)],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  height: 100,
                  color: Colors.white,
                  child: Center(child: Text("first container")),
                ),
                SizedBox(height: 10,),
                Container(
                  height: 100,
                  color: Colors.white,
                  child: Center(child: Text("second container")),
                ),
              ],
            ),
          )
        )

      ),

    );
  }
}