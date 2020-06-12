import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_segmented_control/material_segmented_control.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_chips_input/flutter_chips_input.dart';


class AddRecord extends StatefulWidget {
  @override
  _AddRecordState createState() => _AddRecordState();
}

class _AddRecordState extends State<AddRecord> {
  final _formKey = GlobalKey<FormBuilderState>();
  final df = DateFormat('yyyy-MM-dd');
  final Map<int, Widget> _children = {
    -1:Text('지출 내역'),
    1:Text('수입 내역')
  };

  //State variable
  var _segctrSelection = -1;
  var _dateInput = DateTime.now();
  var _txDescription;
  var _amount;

  //Dummydata field - DEV
  var _dummyMethods = ['np', 'pc', 'gm'];
  var _dummyCategory = ['c1', 'c2', 'c3'];

  Widget selectRecordType() {
    Widget txMethod = (
      FormBuilderDropdown(
        attribute: "transaction_method",
        decoration: InputDecoration(
          labelText: '거래수단',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide())
        ),
        // initialValue: 'Male',
        hint: Text('거래수단을 선택해주세요'),
        validators: [FormBuilderValidators.required()],
        items: _dummyMethods
          .map((value) => DropdownMenuItem(
            value: value,
            child: Text("$value")
        )).toList(),
      )
    );
    if(_segctrSelection == -1) {
      return Container(
        child: Column(
          children: [
            txMethod,
            SizedBox(height: 18,),
            FormBuilderDropdown(
              attribute: "transaction_tag",
              decoration: InputDecoration(
                labelText: '테그',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide())
              ),
              // initialValue: 'Male',
              hint: Text('포함하실 테그를 추가해 주세요'),
              validators: [FormBuilderValidators.required()],
              items: _dummyCategory
                .map((value) => DropdownMenuItem(
                  value: value,
                  child: Text("$value")
              )).toList(),
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
                      decoration: InputDecoration(
                        labelText: '날짜',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide())
                      ),
                      // onChanged: (value) {setState(() {
                      //   _dateInput = value;
                      //   print('date: ' + df.format(_dateInput));
                      // });},
                    ),
                    SizedBox(height: 18,),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: '거래내역',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide())
                      ),
                      onChanged: (value) {setState(() {
                        _txDescription = value;
                      });},
                    ),
                    SizedBox(height: 18,),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: '금액',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide())
                      ),
                      //TODO Validate only positive value
                      //TODO Validate only parsable
                      onChanged: (value) {setState(() {
                        _amount = double.parse(value);
                      });},
                    ),
                    SizedBox(height: 18,),
                    selectRecordType(),
                    SizedBox(height: 25,),
                    ButtonTheme(
                      minWidth: double.infinity,
                      height: 50,
                      child: RaisedButton(
                        child: Text('기록 추가', style: TextStyle(color: Colors.white, fontSize: 16),),
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
          ),
      ),) 
    );
  }
}