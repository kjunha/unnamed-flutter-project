import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:hive/hive.dart';
import './model/method.dart';

class MethodForm extends StatefulWidget {
  @override
  _MethodFormState createState() => _MethodFormState();
}

class _MethodFormState extends State<MethodForm> {
  final _formKey = GlobalKey<FormBuilderState>();
  List<Method> methodsList = [];

  //State variables
  var _methodName;
  var _methodDescription;
  var _methodType;
  var _methodColor;
  var _isTotalAsset = true;
  var _isOnMain = true;

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

  // TODO Hive box needs to be open again.
  // @override
  // void initState() async {
  //   final methodsBox = await Hive.openBox('method');
  //   for(int i = 0;  i < methodsBox.length; i++) {
  //     methodsList.add(methodsBox.get(i));
  //   }
  //   super.initState();
  // }

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
                      attribute: "method_type",
                      validators: [
                        (value) { return value == null?'선택하지 않으실 경우 기본색은 회색으로 지정됩니다.':null;}
                      ],
                      options: _randerColorOption(),
                      onChanged: (value) {
                        _methodColor = '#333333';
                        if(value != null) {print('color selection: ' + value);} else {print('value is null');}
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
                        onPressed: () {
                          if(_formKey.currentState.saveAndValidate()) {
                            Hive.box('methods').add(Method(_methodName, _methodDescription, _methodType, _methodColor, _isTotalAsset, _isOnMain));
                            _formKey.currentState.reset();
                          } else {
                            print("validation 실패");
                          }
                        },
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