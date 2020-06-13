import 'package:flutter/material.dart';
import './drawer_common.dart';

class RecordList extends StatefulWidget {
  @override
  _RecordListState createState() => _RecordListState();
}

class _RecordListState extends State<RecordList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('수입 및 지출내역 편집'),  backgroundColor: Colors.blue,),
      drawer: loadDrawer(context),
      body: Text('Record List Connection'),
    );
  }
}