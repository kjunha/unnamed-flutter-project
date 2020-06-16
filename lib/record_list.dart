import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import './source_common.dart';
import './drawer_common.dart';

class RecordList extends StatefulWidget {
  @override
  _RecordListState createState() => _RecordListState();
}

class _RecordListState extends State<RecordList> {
  final _formKey = GlobalKey<FormBuilderState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('수입 및 지출내역 편집'),  backgroundColor: Colors.blue,),
      drawer: loadDrawer(context),
      body: Column(children: <Widget>[
        Card(child: Container(margin:EdgeInsets.symmetric(vertical:16, horizontal:16),child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('수입 및 지출내역 조회', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
            SizedBox(height: 10,),
            FormBuilder(key: _formKey, child: Row(children: <Widget>[
              Text('시작일: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
              Flexible(child: FormBuilderDateTimePicker(
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
              ),),
              SizedBox(width: 8,),
              Text('기간: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
              Flexible(child: TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: '일수',
                    hintText: '15일',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide())
                  ),
                  //TODO Validate only positive value
                  //TODO Validate only parsable
                  onChanged: (value) {},
                ),),
                SizedBox(width: 8,),
              RaisedButton(
                child: Text('조회'),
                onPressed: () {},
              )
            ],),)
          ],
        ),),),
        Flexible(child:TxRecordGroupListView()),
      ],)
    );
  }
}

class TxRecordGroupListView extends StatelessWidget {
  final _dummy = [
    {"date": "2020/06/05", "value":"10000"},
    {"date": "2020/06/05", "value":"10000"},
    {"date": "2020/06/05", "value":"-123.4567"},
    {"date": "2020/06/07", "value":"-10000"},
    {"date": "2020/06/07", "value":"5432.12345"},
    {"date": "2020/06/05", "value":"-10000"},
    {"date": "2020/06/05", "value":"10000"},
    {"date": "2020/06/03", "value":"-10000"},
    {"date": "2020/05/30", "value":"100000000"}
  ];
  Widget _buildGroupSeparator(dynamic groupByValue) {
    return Text('$groupByValue');
  }

  //List Tile UI
  Widget _buildRecordList(BuildContext context, dynamic element) {
    var labelColor = Colors.blue;
    var positiveTextColor = Colors.green;
    var negativeTextColor = Colors.red;
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: Card(
        child: ListTile(
          title:Text('지출내역 상세기록 ',),
          subtitle: Text('지불수단'),
          leading: Container(
            child: Center(child: Text('최대글자', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1),)),
            width: 48,
            height: 22,
            decoration: BoxDecoration(border: Border.all(color:labelColor, width:1), borderRadius: BorderRadius.circular(12), color: labelColor),
          ),
          trailing: Text(
            buildCurrencyString(double.parse(element['value']), false), 
            style: TextStyle(
              color: double.parse(element['value'])>0?positiveTextColor:negativeTextColor, 
              fontWeight: FontWeight.bold, fontSize: 18
            ),),
          onTap: () {},
        ),
      ),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: '수정',
          color: Colors.black45,
          icon: Icons.mode_edit,
          onTap: () => print('More'),
        ),
        IconSlideAction(
          caption: '삭제',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () => print('Delete'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GroupedListView(
      elements: _dummy,
      groupBy: (element) => element['date'],
      groupSeparatorBuilder: _buildGroupSeparator,
      itemBuilder: _buildRecordList,
      shrinkWrap: false,
      //physics: const NeverScrollableScrollPhysics(),
      physics: null,
    );
  }
}