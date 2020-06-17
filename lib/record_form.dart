import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:material_segmented_control/material_segmented_control.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_chips_input/flutter_chips_input.dart';
import './source_common.dart';
import './model/record.dart';


class RecordForm extends StatefulWidget {
  @override
  _RecordFormState createState() => _RecordFormState();
}

class _RecordFormState extends State<RecordForm> {
  final _formKey = GlobalKey<FormBuilderState>();
  final Map<int, Widget> _children = {
    -1:Text('지출 내역'),
    1:Text('수입 내역')
  };

  //State variable
  var _segctrSelection = -1;
  var _dateInput = DateTime.now();
  var _txDescription;
  var _amount;
  var _txMethod;
  var _txTag;

  //Dummydata field - DEV
  var _dummyMethods = ['np', 'pc', 'gm'];
  var _dummyCategory = ['c1', 'c2', 'c3'];

  void _addRecord(Record record) {
    final recordsBox = Hive.box('records');
    recordsBox.add(record);
  }

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
        items: _dummyMethods
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
              Container(
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
              ),
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
                    ButtonTheme(
                      minWidth: double.infinity,
                      height: 50,
                      child: RaisedButton(
                        child: Text('기록 추가', style: TextStyle(color: Colors.white, fontSize: 16),),
                        color: Colors.blueAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        onPressed: () {
                          if(_formKey.currentState.saveAndValidate()) {
                            Record record = _segctrSelection == 1?
                            new Record(_dateInput, _txDescription, _amount, _txMethod, ''):
                            new Record(_dateInput, _txDescription, _amount*_segctrSelection, _txMethod, _txTag);
                            //print('recordInfo: ' + record.toString());
                            _addRecord(record);
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
                                        Navigator.pop(context);
                                      },
                                    )
                                  ],
                                );
                              }
                            );
                          }
                        },
                      ),
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