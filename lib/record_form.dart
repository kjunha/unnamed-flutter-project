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
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _txAmountController = TextEditingController();
  final _txDescController = TextEditingController();
  final _txTagController = TextEditingController();
  final Map<int, Widget> _children = {
    -1:Text('지출 내역'),
    1:Text('수입 내역')
  };
  List<String> _methodsNameList = [];
  Set<String> _tagsSet = {};

  //State variable
  int _segctrSelection;
  DateTime _dateInput;
  String _txDescription;
  double _amount;
  String _txMethod;
  String _txTag;
  var _boxKey;


  @override
  void initState() {
    super.initState();
    Box methodsbox = Hive.box('methods');
    Box tagsBox = Hive.box('tags');
    //initialize tag box
    if(tagsBox.length == 0) {
      tagsBox.add('쇼핑');
      tagsBox.add('취미');
      tagsBox.add('생활');
      tagsBox.add('통신');
      tagsBox.add('교통');
      tagsBox.add('병원');
    }
    for(int i = 0; i < tagsBox.length; i++) {
      _tagsSet.add(tagsBox.getAt(i));
    }
    List<dynamic> keys = methodsbox.keys.toList();
    for(dynamic key in keys) {
      _methodsNameList.add(methodsbox.get(key).name);
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

  //Button Action Handler
  //on pressed for new record
  void _addNewRecord() {
    if(_formKey.currentState.saveAndValidate()) {
      Method method = Hive.box('methods').get(toKey(_txMethod));
      Box recordBox = Hive.box('records');
      Record newRecord;
      if(_segctrSelection == 1) {
        newRecord = Record(_dateInput, _txDescription, _amount, method, '');
        recordBox.add(newRecord);
        method.incSubtotal += _amount;
      } else {
        newRecord = Record(_dateInput, _txDescription, _amount*_segctrSelection, method, _txTag??'');
        recordBox.add(newRecord);
        method.expSubTotal += _amount;
      }
      int k = findRecordKey(newRecord);
      if(k != -1) {
         method.recordKeys.add(k);
      } else {
        _scaffoldKey.currentState.showSnackBar(
          SnackBar(content: Text('경고: 인덱스가 정상적으로 저장되지 않았습니다. 기록을 삭제하고 다시 시도해 주세요.'),),
        );
        return;
      }
      Hive.box('methods').put(toKey(_txMethod),method);
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(content: Text('새로운 수입 및 지출내역이 추가되었습니다.'),)
      );
      _formKey.currentState.reset();
      _clearTextInput();
    }
  }

  //on pressed for edited record
  void _editRecord() {
    if(_formKey.currentState.saveAndValidate()) {
      Record origRecord = Hive.box('records').getAt(_boxKey);
      Method newMethod = Hive.box('methods').get(toKey(_txMethod));
      Method origMethod = Hive.box('methods').get(toKey(origRecord.method.name));
      if(_segctrSelection == 1) {
        Hive.box('records').putAt(_boxKey, Record(_dateInput, _txDescription, _amount, newMethod, ''));
        newMethod.incSubtotal += (_amount - origRecord.amount);
      } else {
        Hive.box('records').putAt(_boxKey, Record(_dateInput, _txDescription, _amount*_segctrSelection, newMethod, _txTag??''));
        newMethod.expSubTotal += (_amount - origRecord.amount);
      }
      origMethod.recordKeys.remove(_boxKey);
      newMethod.recordKeys.add(_boxKey);
      Hive.box('methods').put(toKey(origMethod.name), origMethod);
      Hive.box('methods').put(toKey(_txMethod),newMethod);
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(content: Text('수입 및 지출내역이 변경되었습니다.'),)
      );
      Navigator.of(context).pop();
    }
  }

  //clear all inputs
  void _clearTextInput() {
    _txDescController.clear();
    _txAmountController.clear();
    _txTagController.clear();
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
        hint: Text('거래수단을 선택해주세요'),
        validators: [(value) { return value == null? "거래수단은 필수항목입니다.":null;},],
        initialValue: _txMethod,
        items: _methodsNameList
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
              initialValue: widget.mode == FormMode.ADD?null:_txTag,
              controller: widget.mode == FormMode.ADD?_txTagController:null,
              decoration: InputDecoration(
                labelText: '태그',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide())
              ),
              suggestionsCallback: (pattern) async {
                List<String> sorted = [];
                List<String> tagsList = _tagsSet.toList();
                for(String item in tagsList) {
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
                  title: Text('위 이름으로 새로운 태그를 지정합니다.')
                  
                );
              },
              onChanged: (value) {setState(() {
                _txTag = value??'';
              });},
              onSaved: (value) {
                setState(() {
                  _tagsSet.add(value);
                });
              },
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
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('수입 및 지출내역 추가'),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            if(widget.mode == FormMode.ADD) {
              Navigator.of(context).pop();
            } else {
              if(widget.record.description != _txDescription || widget.record.amount != _amount) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
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
            }
          },
        ),
      ),
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
                borderRadius: 25.0,
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
                    initialValue: widget.mode == FormMode.ADD?null:_txDescription,
                    controller: widget.mode == FormMode.ADD?_txDescController:null,
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
                      (value) {return value.length == 0? "금액은 필수항목 입니다.":null;},
                      (value) {return double.tryParse(value) == null ? "숫자값을 입력해 주세요":null;}
                    ],
                    maxLines: 1,
                    initialValue: widget.mode == FormMode.ADD?null:nf.format(_amount),
                    controller: widget.mode == FormMode.ADD?_txAmountController:null,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '금액',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide())
                    ),
                    onChanged: (value) {
                      if(value.length > 0) {
                        setState(() {
                          _amount = double.parse(value);
                        });
                      }
                    },
                  ),
                  SizedBox(height: 18,),
                  _selectRecordType(),
                  SizedBox(height: 25,),
                  ButtonTheme(
                    minWidth: double.infinity,
                    height: 50,
                    child: RaisedButton(
                      child: Text(widget.mode == FormMode.ADD?'기록 추가':'기록 변경', style: TextStyle(color: Colors.white, fontSize: 16),),
                      color: Colors.blueAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      onPressed: () {
                        if(widget.mode == FormMode.ADD) {
                          _addNewRecord();
                        } else {
                          _editRecord();
                        }
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),) 
    );
  }

  @override
  void deactivate() {
    super.deactivate();
    List<String> tagsList = _tagsSet.toList();
    List<String> allTags = [];
    Box tagsBox = Hive.box('tags');
    for(int i = 0; i < tagsBox.length; i++) {
      allTags.add(tagsBox.getAt(i));
    }
    for(String str in tagsList) {
      if(allTags.indexOf(str) == -1) {
        tagsBox.add(str);
      }
    }
  }
}