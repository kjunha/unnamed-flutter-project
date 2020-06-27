import 'package:finance_point/form_mode_enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:hive/hive.dart';
import './model/method.dart';
import './model/record.dart';
import './source_common.dart';

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
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _methodNameController = TextEditingController();
  final _methodDescController = TextEditingController();
  List<String> methodsNameList = [];

  //State variables
  String _methodName;
  String _methodDescription;
  String _methodType;
  int _methodColor;
  bool _isTotalAsset = true;
  bool _isOnMain = true;

  //Dummydata field -DEV
  var _colorSet = [0xfff32728, 0xfff8c700, 0xff1ec200, 0xff0e2166, 0xff524e43];

  @override
  void initState() {
    super.initState();
    Box box = Hive.box('methods');
    List<dynamic> keys = box.keys.toList();
    for(dynamic key in keys) {
      Method mtd = box.get(key);
      methodsNameList.add(mtd.name);
    }
    if(widget.mode == FormMode.ADD) {
      _isTotalAsset = true;
      _isOnMain = true;
    } else {
      _methodName = widget.method.name;
      _methodDescription = widget.method.description;
      _methodType = widget.method.type;
      _methodColor = widget.method.colorHex;
      _isTotalAsset = widget.method.isIncluded;
      _isOnMain = widget.method.isMain;
    }
  }
  
  //Button Action Handler
  void _addNewMethod() {
    if(_formKey.currentState.saveAndValidate()) {
      methodsNameList.add(_methodName);
      Hive.box('methods').put(toKey(_methodName) ,Method(_methodName, _methodDescription, _methodType, _methodColor, _isTotalAsset, _isOnMain,0,0,DateTime.now()));
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('새로운 거래수단이 추가되었습니다.'),));
    }
  }

  //Button Action Handler
  void _editMethod() {
    if(_formKey.currentState.saveAndValidate()) {
      if(_methodName == widget.method.name) { //if key is same >> update
        Method updated = widget.method;
        updated.description = _methodDescription;
        updated.type = _methodType;
        updated.colorHex = _methodColor;
        updated.isIncluded = _isTotalAsset;
        updated.isMain = _isOnMain;
        Hive.box('methods').put(toKey(_methodName), updated);
      } else { //if key is different >> create new and replace
        Method replace = Method(_methodName, _methodDescription, _methodType, _methodColor, _isTotalAsset, _isOnMain, widget.method.incSubtotal, widget.method.expSubTotal, widget.method.dateCreated);
        List<dynamic> recordKeys = widget.method.recordKeys.toList();
        Box recordsBox = Hive.box('records');
        for(int i = 0; i < recordKeys.length; i++) {
          Record belonging = recordsBox.get(recordKeys[i]);
          belonging.method = replace;
          recordsBox.put(recordKeys[i], belonging);
          replace.recordKeys.add(recordKeys[i]);
        }
        Hive.box('methods').put(toKey(_methodName), replace);
        Hive.box('methods').delete(toKey(widget.method.name));
      }
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('수정된 거래수단의 정보를 저장했습니다.'),));
      Navigator.of(context).pop();
    }
  }

  //clear all inputs
  void _clearTextInput() {
    _methodDescController.clear();
    _methodNameController.clear();
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
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text('새로운 거래수단 추가하기'), 
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            if(widget.mode == FormMode.ADD) {
              Navigator.of(context).pop();
            } else {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('경고'),
                    content: Text('변경사항을 저장하지 않고 나가시겠습니까?'),
                    actions: <Widget>[
                      FlatButton(
                        child: Text('아니오'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      FlatButton(
                        child: Text('네'),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                      )
                    ],
                  );
                }
              );
            }
          },
        ),
      ),
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
                      initialValue: widget.mode == FormMode.ADD?null:_methodName,
                      controller: widget.mode == FormMode.ADD?_methodNameController:null,
                      validators: [
                        (value) { 
                          return value.length == 0?'거래수단 이름을 입력해 주세요.':null;
                        },
                        (value) {
                          if(widget.mode == FormMode.ADD) {
                            return methodsNameList.indexOf(value) != -1?'이미 등록된 이름입니다':null;
                          } else {
                            return (methodsNameList.indexOf(value) != -1 && value != widget.method.name)?'이미 등록된 이름입니다':null;
                          }
                          
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
                      initialValue: widget.mode == FormMode.ADD?null:_methodDescription,
                      controller: widget.mode == FormMode.ADD?_methodDescController:null,
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
                      initialValue: _methodType,
                      options: [
                        FormBuilderFieldOption(
                          child: Text(convertMethodType("credit")),
                          value: "credit"
                        ),
                        FormBuilderFieldOption(
                          child: Text(convertMethodType("debit")),
                          value: "debit"
                        ),
                        FormBuilderFieldOption(
                          child: Text(convertMethodType("cash")),
                          value: "cash"
                        ),
                        FormBuilderFieldOption(
                          child: Text(convertMethodType("point")),
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
                      //initialValue: widget.method.colorHex??0x333333,
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
                        child: Text(widget.mode == FormMode.ADD?'신규 거래수단 추가':'거래수단 정보 변경', style: TextStyle(color: Colors.white, fontSize: 16),),
                        color: Colors.blueAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        //TODO Alert when amount is 0
                        //TODO Alert when txDescription == null
                        //TODO Alert when method == null
                        onPressed: () {
                          if(widget.mode == FormMode.ADD) {
                            _addNewMethod();
                          } else {
                            _editMethod();
                          }
                        }
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