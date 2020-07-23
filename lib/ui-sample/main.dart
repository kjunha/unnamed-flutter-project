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
        body: Container(
          constraints:BoxConstraints.expand(),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors:[Colors.red, Colors.green, Colors.yellow, Colors.white, Colors.white]
            )
          ),
          child: Card(
            child: Center(child: Text("Design Preview"),),
            margin: EdgeInsets.all(30),
          ),
        )

      ),

    );
  }
}