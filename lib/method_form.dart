import 'package:finance_point/form_mode_enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:hive/hive.dart';
import './model/method.dart';

class MethodForm extends StatefulWidget {
  FormMode mode;
  Method method;
  MethodForm() {
    mode = FormMode.ADD;
  }
  MethodForm.edit(this.method) {
    mode = FormMode.EDIT;
  }

  @override
  _MethodFormState createState() => _MethodFormState();
}

class _MethodFormState extends State<MethodForm> {
  final _formKey = GlobalKey<FormBuilderState>();
  List<String> methodsNameList = [];

  //State variables
  String _methodName;
  String _methodDescription;
  String _methodType;
  int _methodColor;
  bool _isTotalAsset = true;
  bool _isOnMain = true;

  //Dummydata field -DEV
  var _colorSet = [0xff0000, 0x00ff00, 0x0000ff];

  //Button Action Handler
  void _addNewMethod() {
    if(_formKey.currentState.saveAndValidate()) {
      methodsNameList.add(_methodName);
      Hive.box('methods').put(_methodName ,Method(_methodName, _methodDescription, _methodType, _methodColor, _isTotalAsset, _isOnMain,0,0,DateTime.now()));
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('입력 완료'),
            content: Text('새로운 거래수단이 추가되었습니다.'),
            actions: <Widget>[
              FlatButton(
                child: Text('확인'),
                onPressed: () {
                  _formKey.currentState.reset();
                  Navigator.of(context).pop();
                },
              )
            ]
          );
        }
      );
    } else {
      //DEBUG
      print("validation 실패");
    }
  }

  //Chip Option builder
  List<FormBuilderFieldOption> _randerColorOption() {
    List<FormBuilderFieldOption> colorOptionRadio = [];
    for(int hexCode in _colorSet) {
      colorOptionRadio.add(
        FormBuilderFieldOption(
          child: Container(
            decoration: BoxDecoration(
              color: Color(hexCode), 
              border: Border.all(color: Color(hexCode)), borderRadius: BorderRadius.circular(15) 
              ), 
            width: 30, height: 30
          ),
          value: hexCode,
        ),
      );
    }
    return colorOptionRadio;
  }

  @override
  void initState() {
    super.initState();
    Box box = Hive.box('methods');
    List<dynamic> keys = box.keys.toList();
    for(dynamic key in keys) {
      Method mtd = box.get(key);
      methodsNameList.add(mtd.name);
    }
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
                    FormBuilderTextField(
                      attribute: 'method_name',
                      validators: [
                        (value) { 
                          return value.length == 0?'거래수단 이름을 입력해 주세요.':null;
                        },
                        (value) {
                          return methodsNameList.indexOf(value) != -1?'이미 등록된 이름입니다':null;
                        }
                      ],
                      maxLines: 1,
                      decoration: InputDecoration(
                        labelText: '거래수단 이름',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide())
                      ),
                      onChanged: (value) {setState(() {
                        _methodName = value;
                      });},
                    ),
                    SizedBox(height: 18,),
                    //Description is optional
                    FormBuilderTextField(
                      attribute: 'method_description',
                      maxLines: 1,
                      decoration: InputDecoration(
                        labelText: '거래수단 설명',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide())
                      ),
                      onChanged: (value) {setState(() {
                        _methodDescription = value;
                      });},
                    ),
                    SizedBox(height: 10,),
                    Divider(thickness: 2,),
                    FormBuilderChoiceChip(
                      alignment: WrapAlignment.center,
                      validators: [
                        (value) { return value == null?'거래수단 종류를 선택해 주세요.':null;}
                      ],
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
                      onChanged: (value) {
                        _methodType = value;
                      },
                    ),
                    SizedBox(height: 18,),
                    FormBuilderChoiceChip(
                      alignment: WrapAlignment.center,
                      spacing: 15,
                      decoration: InputDecoration(
                        labelText: '표시할 색',
                        border: InputBorder.none
                      ),
                      attribute: "method_color",
                      validators: [
                        (value) { return value == null?'선택하지 않으실 경우 기본색은 회색으로 지정됩니다.':null;}
                      ],
                      options: _randerColorOption(),
                      onChanged: (value) {
                        if(value != null) {
                          _methodColor = value;
                          print('color selection: ' + value.toString());
                        } else {
                          _methodColor = 0x333333;
                          print('value is null');
                        }
                      },
                    ),
                    FormBuilderSwitch(
                      label: Text('이 거래수단을 총자산에 추가합니다'),
                      attribute: "include_total_asset",
                      initialValue: _isTotalAsset,
                      decoration: InputDecoration(border: InputBorder.none),
                      onChanged: (value) {
                        _isTotalAsset = value;
                      },
                    ),
                    FormBuilderSwitch(
                      label: Text('이 거래수단을 메인 페이지에 표시합니다'),
                      attribute: "add_to_main",
                      initialValue: _isOnMain,
                      decoration: InputDecoration(border: InputBorder.none),
                      onChanged: (value) {
                        _isOnMain = value;
                      },
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
                        onPressed: _addNewMethod
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