import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddRecord extends StatefulWidget {
  @override
  _AddRecordState createState() => _AddRecordState();
}

class _AddRecordState extends State<AddRecord> {
  var dateInput = DateTime.now();
  final df = DateFormat('yyyy-MM-dd');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
              appBar: AppBar(title: Text('Add New Record'),backgroundColor: Colors.blue,),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.symmetric( vertical: 0, horizontal: 30),
              child: Form(
                child: Column(
                  // crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Row(
                    //   crossAxisAlignment: CrossAxisAlignment.start, 
                    //   children: [SizedBox(width: 18,) ,Text('Input Label', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),),]),
                    // SizedBox(height: 5,),
                    // Divider(thickness: 2,),
                    Row(children: [
                      Flexible(child: TextFormField(
                        readOnly: true,
                        initialValue: df.format(dateInput),
                        decoration: InputDecoration(
                          labelText: '날짜',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide())
                        ),
                      )),
                      SizedBox(width: 15,),
                      RaisedButton(child: Text('button'), onPressed: () {showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));},)
                    ],),
                    SizedBox(height: 15,),
                    TextFormField(
                      readOnly: true,
                      initialValue: df.format(dateInput),
                      decoration: InputDecoration(
                        labelText: '날짜',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide())
                      ),
                    ),
                    SizedBox(height: 15,),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: '금액',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide())
                      ),
                    ),
                    SizedBox(height: 15,),
                    
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: '결제수단',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide())
                      ),
                    ),
                    SizedBox(height: 15,),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: '상세내역',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide())
                      ),
                    ),
                    SizedBox(height: 30,),
                    
                    ButtonTheme(
                      minWidth: double.infinity,
                      height: 50,
                      child: RaisedButton(
                        child: Text('기록 추가'),
                        color: Colors.green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        onPressed: () {},
                      ),
                    )
                  ],
                ),
              )
            ),
          ],
        ),
    );
  }
}