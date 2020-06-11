import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_segmented_control/material_segmented_control.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class NewMethod extends StatefulWidget {
  @override
  _NewMethodState createState() => _NewMethodState();
}

class _NewMethodState extends State<NewMethod> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('새로운 거래수단 추가하기'), backgroundColor: Colors.blue,),
      body: SingleChildScrollView(scrollDirection: Axis.vertical, child: Container(
          margin: EdgeInsets.symmetric(vertical: 18, horizontal: 30),
          child: Column(
            children: [
              FormBuilder(
                key: _formKey,
                child: Column(
                  children: [
                    
                  ],
                ),
              )
            ],
        )
      )),
    );
  }
}