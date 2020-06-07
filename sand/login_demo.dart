import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Form',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          padding: EdgeInsets.fromLTRB(20, 120, 20, 120),
          child: Column(
            children: <Widget>[
              Hero(
                tag: 'hero',
                child: CircleAvatar(
                  backgroundColor: Colors.black,
                  radius: 58,
                ),
              ),
              SizedBox( height: 45 ),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                initialValue: 'your_email@email.com',
                decoration: InputDecoration(
                  border: OutlineInputBorder()
                ),
              ),
              SizedBox( height: 45 ),
              TextFormField(
                initialValue: 'password',
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder()
                ),  
              ),
              SizedBox( height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    child: Text('Log in'),
                    onPressed: () {print('log in pressed');},
                    color: Colors.blue,
                  ),
                  SizedBox( width: 10 ),
                  RaisedButton(
                    child: Text('Sign up'),
                    onPressed: () {print('sign in pressed');},
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

