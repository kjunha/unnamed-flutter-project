import 'package:flutter/material.dart';

class AddRecord extends StatefulWidget {
  _AddRecordState createState() => _AddRecordState();
}

class _AddRecordState extends State<AddRecord> {
  var _signed;
  @override
  void initState() {
    _signed = 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("수입 및 지출내역 추가"),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(
          vertical: 0,
          horizontal: 30
        ),
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text("날짜: "),
              SizedBox(width: 20,),
              Flexible(child: TextFormField(
                keyboardType: TextInputType.datetime,
              ))
            ],
          ),
          SizedBox(height: 30,),
          Row(
            children: <Widget>[
              Text("금액: "),
              SizedBox(width: 20,),
              Flexible(child: TextFormField(
                keyboardType: TextInputType.number,
              ))
            ],
          ),
          SizedBox(height: 10,),
          Row(
            children: <Widget>[
              Flexible(child: RadioListTile<int>(
                title: Text("수입"),
                value: 1,
                groupValue: _signed,
                onChanged: (int value) {setState(() {_signed = value;});},
              )),
              Flexible(child: RadioListTile<int>(
                title: Text("지출"),
                value: -1,
                groupValue: _signed,
                onChanged: (int value) {setState(() {_signed = value;});},
              )),
            ],
          ),
          SizedBox(height: 10,),
          Row(
            children: <Widget>[
              Text("내용: "),
              SizedBox(width: 20,),
              Flexible(child: TextFormField())
            ],
          ),
          SizedBox(height: 30,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                child: Text("새로 고침"),
                onPressed: () {},
              ),
              SizedBox(width: 30,),
              RaisedButton(
                child: Text("내역 추가"),
                onPressed: () {},
                color: Colors.blue,
              )
            ],
          )
        ],
      )
      )
    );  
  }
}