import 'package:flutter/material.dart';
import './drawer_common.dart';

class MethodList extends StatefulWidget {
  @override
  _MethodListState createState() => _MethodListState();
}

class _MethodListState extends State<MethodList> {

  //Dummy Field
  var _dummy = [Colors.green, Colors.red, Colors.blue, Colors.black];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('거래수단 관리'),  backgroundColor: Colors.blue,),
      backgroundColor: Colors.grey,
      drawer: loadDrawer(context),
      body: Column(
        children: <Widget>[
          Flexible(child: ListView.builder(
            itemCount: _dummy.length,
            itemBuilder: _buildPointWallet,
          ),)
        ],
      ),
    );
  }


  Widget _buildPointWallet(BuildContext context, int i) {
    return Card(child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      Container(width:280, child: Card(
        color: _dummy[i],
        margin: EdgeInsets.symmetric(vertical: 10,horizontal:10),
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text('네이버 페이 포인트', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),), 
              subtitle: Text('메모할 내용', style: TextStyle(color: Colors.grey[200]),), 
            ),
            SizedBox(height: 5,),
            Center(child: Text('1,234,567 P', style: TextStyle(fontSize: 23, color: Colors.white, fontWeight: FontWeight.bold),),),
            SizedBox(height: 55,),
          ],
        ),
      )),
      SizedBox(width: 8,),
      Flexible(child:Container(
        margin: EdgeInsets.symmetric(vertical: 20,horizontal:0), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('생성일자'), 
            Text('txt2')
          ],),))
    ],),);
  }
}