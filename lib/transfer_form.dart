import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:hive/hive.dart';
import './bottom_nav_common.dart';
import './model/method.dart';
import './model/record.dart';

class TransferForm extends StatefulWidget {
  @override
  _TransferFormState createState() => _TransferFormState();
}

class _TransferFormState extends State<TransferForm> {
  final _formKey = GlobalKey<FormBuilderState>();
  List<String> _methodNameList = [];
  Box _methodsBox;
  Box _recordsBox;
  String _fromMethod;
  String _toMethod;
  double _amount;
  double _txFee;
  bool _isPercent;


  //Submit onPress Handler
  void makeTransfer() {
    if(_formKey.currentState.saveAndValidate()) {
      //Create two record for each method (exp for from, inc for to)
      Record fromRecord;
      Record toRecord;
      //Update Method's inc, exp balance
      Method formMethod;
      Method toMethod;
      //Add them to list
      //save records and methods
      _recordsBox.add(fromRecord);

    }
  }

  @override
  void initState() {
    super.initState();
    _methodsBox = Hive.box('methods');
    _recordsBox = Hive.box('records');
    List<dynamic> keys = _methodsBox.keys.toList();
    for(dynamic key in keys) {
      _methodNameList.add(_methodsBox.get(key).name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('다른 거래수단으로 송금'),
        backgroundColor: Colors.blue,
      ),
      bottomNavigationBar: loadBottomNavigator(context),
      body: SingleChildScrollView(scrollDirection: Axis.vertical, child: Container(
        margin: EdgeInsets.symmetric(vertical: 18, horizontal:30),
        child: Column(
          children: <Widget>[
            FormBuilder(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  FormBuilderDropdown(
                    attribute: "from_method",
                    decoration: InputDecoration(
                      labelText: '송금할 월렛',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide())
                    ),
                    hint: Text('거래수단을 선택해주세요'),
                    validators: [(value) { return value == null? "보낼 거래수단은 필수항목입니다.":null;},],
                    items: _methodNameList
                      .map((value) => DropdownMenuItem(
                        value: value,
                        child: Text("$value")
                    )).toList(),
                    onChanged: (value) {setState(() {
                      _fromMethod = value;
                    });},
                  ),
                  SizedBox(height: 18,),
                  FormBuilderDropdown(
                    attribute: "to_method",
                    decoration: InputDecoration(
                      labelText: '수금할 월렛 ',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide())
                    ),
                    // initialValue: 'Male',
                    hint: Text('거래수단을 선택해주세요'),
                    validators: [(value) { return value == null? "받는 거래수단은 필수항목입니다.":null;},],
                    items: _methodNameList
                      .map((value) => DropdownMenuItem(
                        value: value,
                        child: Text("$value")
                    )).toList(),
                    onChanged: (value) {setState(() {
                      _toMethod = value;
                    });},
                  ),
                  SizedBox(height: 18,),
                  FormBuilderTextField(
                    attribute: "send_amount",
                    validators: [
                      (value) {return value.length == 0? "금액은 필수항목 입니다.":null;},
                      (value) {return double.tryParse(value) == null ? "숫자값을 입력해 주세요":null;}
                    ],
                    maxLines: 1,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '송금액',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide())
                    ),
                    onChanged: (value) {setState(() {
                      if(value.length > 0) {
                        _amount = double.parse(value);
                      }
                    });},
                  ),
                  SizedBox(height: 18,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                    Expanded(child: FormBuilderTextField(
                      attribute: "tx_fee",
                      validators: [
                        (value) {return double.tryParse(value) == null ? "숫자값을 입력해 주세요":null;}
                      ],
                      maxLines: 1,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: '거래 수수료',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide())
                      ),
                      onChanged: (value) {setState(() {
                        if(value.length > 0) {
                          _txFee = double.parse(value);
                        }
                      });},
                    ),),
                    SizedBox(width: 20,),
                    Expanded(child: FormBuilderSwitch(
                      label: Row(children: <Widget>[Text('퍼센트 계산'),Flexible(child: IconButton(icon: Icon(Icons.question_answer), onPressed: () {
                        //TODO Show Tooltip
                      },))],),
                      attribute: "include_total_asset",
                      initialValue: _isPercent,
                      decoration: InputDecoration(border: InputBorder.none),
                      onChanged: (value) {
                        _isPercent = value;
                      },
                    ),),
                    ButtonTheme(
                      minWidth: double.infinity,
                      height: 50,
                      child: RaisedButton(
                        child: Text('송금하기', style: TextStyle(color: Colors.white, fontSize: 16),),
                        color: Colors.blueAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        //TODO: DEBUG
                        onPressed: () {
                          _formKey.currentState.saveAndValidate();
                          print('DEBUG: Clicked');
                        },
                      ),
                    ),
                  ],),
                ],
              )
            )
          ],
        ),
      ),)
    );
  }
}