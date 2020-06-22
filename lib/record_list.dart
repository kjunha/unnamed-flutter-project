import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import './model/record.dart';
import './source_common.dart';
import './drawer_common.dart';

class RecordList extends StatefulWidget {
  @override
  _RecordListState createState() => _RecordListState();
}

class _RecordListState extends State<RecordList> {
  final _formKey = GlobalKey<FormBuilderState>();

  List<Record> _readBoxData(Box box) {
    List<Record> recordList = [];
    for(int i = 0; i < box.length; i++) {
      recordList.add(box.getAt(i));
    }
    return recordList;
  }

  Widget _buildGroupSeparator(dynamic groupByValue) {
    return Text(df.format(groupByValue));
  }

  //List Tile UI
  Widget _buildRecordList(BuildContext context, Record element, Box box) {
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
            buildCurrencyString(element.amount, false), 
            style: TextStyle(
              color: element.amount>0?positiveTextColor:negativeTextColor, 
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
          onTap: () {
            //Find Element Key
            var keys = box.keys.toList();
            var key;
            for(int i = 0; i < keys.length; i++) {
              if(box.getAt(i).hashCode == element.hashCode) {
                key = i;
                print('key found: $key');
                break;
              }
            }
            if(key == null) {
              print('key not found');
            }
            Record record = Hive.box('records').getAt(key);
            Navigator.pushNamed(context, '/records/edit', arguments: RecordKeySet(record, key));
          },
        ),
        IconSlideAction(
          caption: '삭제',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () {
            showDialog(
              context: context,
              barrierDismissible: false,
              child: AlertDialog(
                content: Text('정말로 삭제하시겠습니까?'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('아니오'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  FlatButton(
                    child: Text('네'),
                    onPressed: () async {
                      //Find Element Key
                      var keys = box.keys.toList();
                      var key;
                      for(int i = 0; i < keys.length; i++) {
                        if(box.getAt(i).hashCode == element.hashCode) {
                          key = i;
                          print('key found: $key');
                          break;
                        }
                      }
                      if(key == null) {
                        print('key not found');
                      }
                      await Hive.box('records').deleteAt(key);
                      Navigator.of(context).pop();
                    },
                  )
                ],
              )
            );
          },
        ),
      ],
    );
  }

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
        ValueListenableBuilder(
          valueListenable: Hive.box('records').listenable(),
          builder: (context, box, _) {
            if(box.values.isEmpty) {
              return Center(child: Text('Nothing to show'),);
            }
            return Flexible(child: GroupedListView(
              elements: _readBoxData(box),
              groupBy: (element) {
                final record = element as Record;
                return record.date;
              },
              groupSeparatorBuilder: _buildGroupSeparator,
              itemBuilder: (context,element) {
                // var keys = box.keys.toList();
                // for(int key in keys) {
                //   if(box.getAt(key).hashCode == element.hashCode) {
                //     return _buildRecordList(context, element, key);
                //   }
                // }
                // return null;
                return _buildRecordList(context, element, box);
              },
              shrinkWrap: false,
              //physics: const NeverScrollableScrollPhysics(),
              physics: null,
            ),);
          },
        ),
      ],)
    );
  }
}