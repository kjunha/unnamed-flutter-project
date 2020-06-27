import 'package:finance_point/source_common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import './bottom_nav_common.dart';
import './model/method.dart';
import './model/record.dart';

class TransferForm extends StatefulWidget {
  @override
  _TransferFormState createState() => _TransferFormState();
}

class _TransferFormState extends State<TransferForm> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _amountController = TextEditingController();
  final _txFeeController = TextEditingController();
  List<String> _methodNameList = [];
  Box _methodsBox;
  Box _recordsBox;
  Method _fromMethod;
  Method _toMethod;
  double _amount;
  double _txFee;
  bool _isPercent;


  //Submit onPress Handler
  void _makeTransfer(BuildContext context) {
    if(_formKey.currentState.saveAndValidate()) {
      //Calculate Transfer amount
      if(_isPercent) {_txFee = _amount*(_txFee/100);}
      //Create two record for each method (exp for from, inc for to)
      Record fromRecord = Record(DateTime.now(), '${_fromMethod.name}에서 ${_toMethod.name}로 송금' , _amount*-1, _fromMethod, '내부송금');
      _fromMethod.expSubTotal += _amount;
      Record toRecord = Record(DateTime.now(), '${_fromMethod.name}에서 ${_toMethod.name}로 송금' , _amount, _toMethod, '내부송금');
      _toMethod.incSubtotal += _amount;
      //Add them to list (find new record)
      _recordsBox.add(fromRecord);
      _fromMethod.recordKeys.add(findRecordKey(fromRecord));
      _recordsBox.add(toRecord);
      _toMethod.recordKeys.add(findRecordKey(toRecord));
      //if txFee != 0, deduct from fromMethod
      if(_txFee > 0) {
        Record txFeeRcd = Record(DateTime.now(), '송금 수수료', _txFee*-1, _fromMethod, '수수료');
        _fromMethod.expSubTotal += _txFee;
        _recordsBox.add(txFeeRcd);
        _fromMethod.recordKeys.add(findRecordKey(txFeeRcd));
      }
      //save records and methods
      _methodsBox.put(toKey(_fromMethod.name),_fromMethod);
      _methodsBox.put(toKey(_toMethod.name),_toMethod);
      //reset all fields
      _clearTextInput();
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text('송금이 정상적으로 기록되었습니다.'),
        )
      );
    }
  }
  //reset Textfields
  void _clearTextInput() {
    _amountController.clear();
    _txFeeController.clear();
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
    _isPercent = false;
    _amount = 0;
    _txFee = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text('다른 거래수단으로 송금'),
        backgroundColor: Colors.blue,
      ),
      bottomNavigationBar: loadBottomNavigator(context),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical, 
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              ValueListenableBuilder(
                valueListenable: Hive.box('methods').listenable(),
                builder: (context, box, _) {
                  return Container(
                    decoration: BoxDecoration(color: Colors.grey[300]),
                    padding: EdgeInsets.symmetric(vertical: 30, horizontal: 18),
                    child: Column(
                      children: <Widget>[
                        //보낼 거래수단
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 0,horizontal:25),
                          child:FormBuilderDropdown(
                            attribute: "from_method",
                            decoration: InputDecoration(
                              isDense: true,
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(vertical: 3, horizontal: 13),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide(color: Colors.white)),
                            ),
                            hint: Text('보낼 거래수단'),
                            validators: [
                              (value) {
                                if(value == null) return "보낼 거래수단은 필수항목입니다.";
                                else {
                                  if(_toMethod != null) {
                                    return _toMethod.name==value?"같은 거래수단으로 송금할 수 없습니다.":null;
                                  }
                                  return null;
                                }
                              },
                            ],
                            items: _methodNameList
                              .map((value) => DropdownMenuItem(
                                value: value,
                                child: Text("$value")
                            )).toList(),
                            onChanged: (value) {setState(() {
                              _fromMethod = Hive.box('methods').get(toKey(value));
                            });},
                          ),
                        ),
                        Card(
                          color: _fromMethod==null?Colors.grey:Color(_fromMethod.colorHex),
                          margin: EdgeInsets.symmetric(vertical: 3,horizontal:25),
                          child: Column(
                            children: <Widget>[
                              ListTile(
                                title: Text(_fromMethod==null?'':_fromMethod.name, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),), 
                                subtitle: Text(_fromMethod==null?'':_fromMethod.description, style: TextStyle(color: Colors.grey[200]),), 
                              ),
                              SizedBox(height: 5,),
                              Center(
                                child: _fromMethod == null?
                                Text('보낼 거래수단이 선택되지 않았습니다.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),):
                                Text(
                                  _fromMethod==null?'':buildCurrencyString(_fromMethod.incSubtotal-_fromMethod.expSubTotal, _fromMethod.type == 'point'),
                                  style: TextStyle(fontSize: 23, color: Colors.white, fontWeight: FontWeight.bold)
                                ),
                              ),
                              SizedBox(height: 53,),
                            ],
                          ),
                        ),
                        //중앙 송금 로고
                        Container(
                          child: Icon(Icons.swap_horiz, size: 35,color: Colors.white,),
                          margin: EdgeInsets.all(10),
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: _fromMethod != null && _toMethod != null?Colors.red:Colors.grey,
                            shape: BoxShape.circle
                          ),
                        ),
                        //받을 거래수단
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 3,horizontal:25),
                          child:FormBuilderDropdown(
                            attribute: "to_method",
                            decoration: InputDecoration(
                              isDense: true,
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(vertical: 3, horizontal: 13),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide(color: Colors.white)),
                            ),
                            hint: Text('받을 거래수단'),
                            validators: [
                              (value) {
                                if(value == null) return "받을 거래수단은 필수항목입니다.";
                                else {
                                  if(_fromMethod != null) {
                                    return _fromMethod.name==value?"같은 거래수단으로 송금할 수 없습니다.":null;
                                  }
                                  return null;
                                }
                              },
                            ],
                            items: _methodNameList
                              .map((value) => DropdownMenuItem(
                                value: value,
                                child: Text("$value")
                            )).toList(),
                            onChanged: (value) {setState(() {
                              _toMethod = Hive.box('methods').get(toKey(value));
                            });},
                          ),
                        ),
                        Card(
                          color: _toMethod==null?Colors.grey:Color(_toMethod.colorHex),
                          margin: EdgeInsets.symmetric(vertical: 3,horizontal:25),
                          child: Column(
                            children: <Widget>[
                              ListTile(
                                title: Text(_toMethod==null?'':_toMethod.name, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),), 
                                subtitle: Text(_toMethod==null?'':_toMethod.description, style: TextStyle(color: Colors.grey[200]),), 
                              ),
                              SizedBox(height: 5,),
                              Center(
                                child: _toMethod == null?
                                Text('받을 거래수단이 선택되지 않았습니다.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),):
                                Text(
                                  _toMethod==null?'':buildCurrencyString(_toMethod.incSubtotal-_toMethod.expSubTotal, _toMethod.type == 'point'),
                                  style: TextStyle(fontSize: 23, color: Colors.white, fontWeight: FontWeight.bold)
                                ),
                              ),
                              SizedBox(height: 53,),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ), 
              //----<<Divider>>----
              Container(
                padding: EdgeInsets.fromLTRB(18, 15, 18, 30),
                color: Colors.white,
                child: Column(
                  children: <Widget>[
                    FormBuilderTextField(
                      attribute: "send_amount",
                      validators: [
                        (value) {return value.length == 0? "금액은 필수항목 입니다.":null;},
                        (value) {return double.tryParse(value) == null ? "숫자값을 입력해 주세요":null;},
                      ],
                      maxLines: 1,
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: '송금액',
                        contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 13),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide())
                      ),
                      onChanged: (value) {setState(() {
                        if(value.length > 0) {
                          _amount = double.parse(value);
                        }
                      });},
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                      Expanded(child: FormBuilderTextField(
                        attribute: "tx_fee",
                        validators: [
                          (value) {
                            if(value.length > 0) {
                              if(double.tryParse(value) == null) {
                                return "숫자값을 입력해 주세요";
                              } else {
                                if(_isPercent) {
                                  double val = double.parse(value);
                                  return val >= 0 && val <=100?null:'퍼센트 범위가 아닙니다.';
                                }
                                return null;
                              }
                            }
                            return null;
                          },
                        ],
                        maxLines: 1,
                        controller: _txFeeController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: '거래 수수료',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 13),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide())
                        ),
                        onChanged: (value) {setState(() {
                          if(value.length > 0) {
                            _txFee = double.parse(value);
                          }
                        });},
                      ),),
                      SizedBox(width: 10,),
                      Expanded(child: FormBuilderSwitch(
                        label: Row(children: <Widget>[Text('퍼센트 계산'),Flexible(child: 
                          Builder(builder: (context) => IconButton(icon: Icon(Icons.help_outline, color: Colors.grey,), onPressed: () {
                            Scaffold.of(context).showSnackBar(SnackBar(
                              content: Text('거래수수료 입력시 수수료가 송금액에서 차감되어 받을 거래수단으로 송금됩니다. 퍼센트 계산이 활성화되어 있으면, 수수료가 송금액의 일정 퍼센트로 계산되고, 송금액에서 차감된 후 받을 거래수단으로 송금됩니다.'),
                              duration: Duration(seconds: 5),
                            ));
                          },),),
                        ),],),
                        attribute: "include_total_asset",
                        initialValue: _isPercent,
                        decoration: InputDecoration(border: InputBorder.none),
                        onChanged: (value) {
                          _isPercent = value;
                        },
                      ),),
                    ],),
                    ButtonTheme(
                      minWidth: double.infinity,
                      height: 50,
                      child: RaisedButton(
                        child: Text('송금하기', style: TextStyle(color: Colors.white, fontSize: 16),),
                        color: Colors.blueAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        onPressed: () => _makeTransfer(context)
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        ),
      ),
    );
  }
}