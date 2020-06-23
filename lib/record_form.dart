import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:material_segmented_control/material_segmented_control.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import './form_mode_enum.dart';
import './source_common.dart';
import './model/record.dart';
import './model/method.dart';


class RecordForm extends StatefulWidget {
  FormMode mode;
  Record record;
  int boxKey;
  RecordForm() {
    mode = FormMode.ADD;
  }
  RecordForm.edit(this.record, this.boxKey) {
    mode = FormMode.EDIT;
  }
  @override
  _RecordFormState createState() => _RecordFormState();
}

class _RecordFormState extends State<RecordForm> {
  final _formKey = GlobalKey<FormBuilderState>();
  final Map<int, Widget> _children = {
    -1:Text('지출 내역'),
    1:Text('수입 내역')
  };
  List<String> _methodNameList = [];
  
  //State variable
  var _segctrSelection;
  var _dateInput;
  var _txDescription;
  var _amount;
  var _txMethod;
  var _txTag;
  var _boxKey;


  @override
  void initState() {
    super.initState();
    Box box = Hive.box('methods');
    List<dynamic> keys = box.keys.toList();
    for(dynamic key in keys) {
      _methodNameList.add(key);
    }
    if(widget.mode == FormMode.ADD) {
      _segctrSelection = -1;
      _dateInput = DateTime.now();
    } else {
      _segctrSelection = widget.record.amount >= 0? 1:-1;
      _dateInput = widget.record.date;
      _txDescription = widget.record.description;
      _amount = widget.record.amount;
      _txMethod = widget.record.method.name;
      _txTag = widget.record.tag;
      _boxKey = widget.boxKey;
    }
  }

  //Dummydata field - DEV
  var _dummyCategory = ['c1', 'c2', 'c3'];

  //Button Action Handler
  //on pressed for new record
  void _addNewRecord() {
    if(_formKey.currentState.saveAndValidate()) {
      Method method = Hive.box('methods').get(_txMethod);
      if(_segctrSelection == 1) {
        Hive.box('records').add(Record(_dateInput, _txDescription, _amount, method, ''));
        method.incSubtotal += _amount;
      } else {
        Hive.box('records').add(Record(_dateInput, _txDescription, _amount*_segctrSelection, method, _txTag??''));
        method.expSubTotal += _amount;
      }
      Hive.box('methods').put(_txMethod,method);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('입력 완료'),
            content: Text('새로운 수입 및 지출내역이 추가되었습니다.'),
            actions: <Widget>[
              FlatButton(
                child: Text('확인'),
                onPressed: () {
                  _formKey.currentState.reset();
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        }
      );
    }
  }

  //on pressed for edited record
  void _editRecord() {
    if(_formKey.currentState.saveAndValidate()) {
      Method method = Hive.box('methods').get(_txMethod);
      Record origRecord = Hive.box('records').getAt(_boxKey);
      if(_segctrSelection == 1) {
        Hive.box('records').putAt(_boxKey, Record(_dateInput, _txDescription, _amount, method, ''));
        method.incSubtotal += (_amount - origRecord.amount);
      } else {
        Hive.box('records').putAt(_boxKey, Record(_dateInput, _txDescription, _amount*_segctrSelection, method, _txTag??''));
        method.expSubTotal += (_amount - origRecord.amount);
      }
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('입력 완료'),
            content: Text('수입 및 지출내역이 변경되었습니다.'),
            actions: <Widget>[
              FlatButton(
                child: Text('확인'),
                onPressed: () {
                  _formKey.currentState.reset();
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        }
      );
    }
  }

  //Dynamic Element by Segment Control
  Widget _selectRecordType() {
    Widget txMethod = (
      FormBuilderDropdown(
        attribute: "transaction_method",
        decoration: InputDecoration(
          labelText: '거래수단',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide())
        ),
        // initialValue: 'Male',
        hint: Text('거래수단을 선택해주세요'),
        validators: [(value) { return value == null? "거래수단은 필수항목입니다.":null;},],
        initialValue: _txMethod,
        items: _methodNameList
          .map((value) => DropdownMenuItem(
            value: value,
            child: Text("$value")
        )).toList(),
        onChanged: (value) {setState(() {
          _txMethod = value;
        });},
      )
    );
    if(_segctrSelection == -1) {
      return Container(
        child: Column(
          children: [
            txMethod,
            SizedBox(height: 18,),
            FormBuilderTypeAhead(
              attribute: "transaction_tag",
              validators: [
                (value) {
                  if(value == null) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('테그가 입력되지 않았습니다.'),
                          content: Column(children: [
                            Text('새로 추가하는 수입 및 지출내역에 테그가 입력되지 않았습니다.')
                          ],),
                          actions: [],
                        );
                      });
                  }
                  return '';
                }
              ],
              decoration: InputDecoration(
                labelText: '테그',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide())
              ),
              suggestionsCallback: (pattern) async {
                List<String> sorted = [];
                for(String item in _dummyCategory) {
                  if(item.contains(pattern)) {
                    sorted.add(item);
                  }
                }
                return sorted;
              },
              itemBuilder: (context, suggestion) {
                return ListTile(
                  title: Text(suggestion)
                );
              },

              noItemsFoundBuilder: (context) {
                return ListTile(
                  title: Text('add new item')
                );
              },
              onChanged: (value) {setState(() {
                _txTag = value;
              });},
            ),
          ],
        ),
      );
    } else {
      return Container(
        child: Column(
          children: [
            txMethod
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('수입 및 지출내역 추가'),backgroundColor: Colors.blue,),
        body: SingleChildScrollView(scrollDirection: Axis.vertical, child: Container(
          margin: EdgeInsets.symmetric(vertical: 18, horizontal: 30),
          child: Column(
            children: [
              widget.mode == FormMode.ADD?Container(
                width: double.infinity,
                child: MaterialSegmentedControl(
                  children: _children,
                  selectionIndex: _segctrSelection,
                  selectedColor: Colors.blueAccent,
                  unselectedColor: Colors.white,
                  borderRadius: 5.0,
                  onSegmentChosen: (index) {
                    setState(() {
                      _segctrSelection = index;
                    });
                  },
                ),
              ):SizedBox(height:0),
              SizedBox(height: 25,),
              FormBuilder(
                key: _formKey,
                child: Column(
                  children: [
                    FormBuilderDateTimePicker(
                      attribute: "date",
                      inputType: InputType.date,
                      format: df,
                      initialDate: _dateInput,
                      initialValue: _dateInput,
                      validators: [
                        (value) { return value == null? "날짜는 필수항목 입니다.":null;}
                      ],
                      decoration: InputDecoration(
                        labelText: '날짜',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide())
                      ),
                      onChanged: (value) {setState(() {
                        _dateInput = value;
                      });},
                    ),
                    SizedBox(height: 18,),
                    FormBuilderTextField(
                      attribute: "tx_description",
                      validators: [(value) { return value.length == 0? "거래내역은 필수항목 입니다.":null;}],
                      maxLines: 1,
                      initialValue: _txDescription,
                      decoration: InputDecoration(
                        labelText: '거래내역',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide())
                      ),
                      onChanged: (value) {setState(() {
                        _txDescription = value;
                      });},
                    ),
                    SizedBox(height: 18,),
                    FormBuilderTextField(
                      attribute: "amount",
                      validators: [
                        (value) { return value.length == 0? "금액은 필수항목 입니다.":null;},
                        (value) {
                          return double.parse(value) == null ? "숫자값을 입력해 주세요":null;
                        }
                      ],
                      maxLines: 1,
                      initialValue: _amount==null?'':_amount.toString(),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: '금액',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide())
                      ),
                      onChanged: (value) {setState(() {
                        _amount = double.parse(value);
                      });},
                    ),
                    SizedBox(height: 18,),
                    _selectRecordType(),
                    SizedBox(height: 25,),
                    widget.mode == FormMode.ADD?ButtonTheme(
                      minWidth: double.infinity,
                      height: 50,
                      child: RaisedButton(
                        child: Text('기록 추가', style: TextStyle(color: Colors.white, fontSize: 16),),
                        color: Colors.blueAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        onPressed: _addNewRecord
                      ),
                    ):Row(
                      children: <Widget>[
                        Expanded(
                          child: ButtonTheme(
                            height:50, 
                            child: RaisedButton(
                              child: Text('변경 취소'),
                              color: Colors.grey,
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                        ),
                        SizedBox(width: 30,),
                        Expanded(
                          child: ButtonTheme(
                              height: 50,
                              child: RaisedButton(
                              child: Text('기록 변경'),
                              onPressed: _editRecord,
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
      ),) 
    );
  }
}