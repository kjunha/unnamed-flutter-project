import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_chips_input/flutter_chips_input.dart';

class NewMethod extends StatefulWidget {
  @override
  _NewMethodState createState() => _NewMethodState();
}

class _NewMethodState extends State<NewMethod> {
  final _formKey = GlobalKey<FormBuilderState>();

  //Dummydata field -DEV
  var _dummyColor = [Colors.red, Colors.green, Colors.blue];

  List<FormBuilderFieldOption> _randerColorOption() {
    List<FormBuilderFieldOption> colorOptionRadio = [];
    for(Color color in _dummyColor) {
      colorOptionRadio.add(
        FormBuilderFieldOption(
          child: Container(
            decoration: BoxDecoration(
              color: color, 
              border: Border.all(color: color), borderRadius: BorderRadius.circular(15) 
              ), 
            width: 30, height: 30
          ),
          value: color.toString(),
        ),
      );
    }
    return colorOptionRadio;
  }

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
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: '거래수단 이름',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide())
                      ),
                      onChanged: (value) {setState(() {

                      });},
                    ),
                    SizedBox(height: 18,),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: '거래수단 설명',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide())
                      ),
                      onChanged: (value) {setState(() {

                      });},
                    ),
                    SizedBox(height: 10,),
                    Divider(thickness: 2,),
                    FormBuilderChoiceChip(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      decoration: InputDecoration(
                        labelText: '거래수단 종류',
                        border: InputBorder.none
                      ),
                      attribute: "method_type",
                      options: [
                        FormBuilderFieldOption(
                          child: Text("신용카드"),
                          value: "credit"
                        ),
                        FormBuilderFieldOption(
                          child: Text("체크카드"),
                          value: "debit"
                        ),
                        FormBuilderFieldOption(
                          child: Text("현금예산"),
                          value: "cash"
                        ),
                        FormBuilderFieldOption(
                          child: Text("포인트"),
                          value: "point"
                        ),
                      ],
                    ),
                    SizedBox(height: 18,),
                    FormBuilderChoiceChip(
                      alignment: WrapAlignment.center,
                      spacing: 15,
                      decoration: InputDecoration(
                        labelText: '표시할 색',
                        border: InputBorder.none
                      ),
                      attribute: "method_type",
                      options: _randerColorOption(),
                      onChanged: (value) {if(value != null) {print('color selection: ' + value);} else {print('value is null');}},
                    ),
                    FormBuilderSwitch(
                      label: Text('이 거래수단을 총자산에 추가합니다'),
                      attribute: "include_total_asset",
                      initialValue: true,
                      decoration: InputDecoration(border: InputBorder.none),
                    ),
                    FormBuilderSwitch(
                      label: Text('이 거래수단을 메인 페이지에 표시합니다'),
                      attribute: "add_to_main",
                      initialValue: true,
                      decoration: InputDecoration(border: InputBorder.none),
                    ),
                    ButtonTheme(
                      minWidth: double.infinity,
                      height: 50,
                      child: RaisedButton(
                        child: Text('거래수단 추가', style: TextStyle(color: Colors.white, fontSize: 16),),
                        color: Colors.blueAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        //TODO Alert when amount is 0
                        //TODO Alert when txDescription == null
                        //TODO Alert when method == null
                        onPressed: () {},
                      ),
                    )
                  ],
                ),
              )
            ],
        )
      )),
    );
  }
}