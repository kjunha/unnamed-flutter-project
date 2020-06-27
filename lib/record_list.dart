import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import './model/record.dart';
import './source_common.dart';
import './bottom_nav_common.dart';
import './model/method.dart';

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
  //List Tile UI
  Widget _buildRecordList(BuildContext context, Record element, Box box) {
    //Record Promise
    Record record = element as Record;
    //UI Colors
    var positiveTextColor = Colors.green;
    var negativeTextColor = Colors.red;
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: Card(
        child: ListTile(
          title:Text(record.description),
          subtitle: Text(record.method.name),
          leading: tagUIProvider(record.tag, Color(record.method.colorHex), record.amount >= 0),
          trailing: Text(
            buildCurrencyString(element.amount, false), 
            style: TextStyle(
              color: element.amount>0?positiveTextColor:negativeTextColor, 
              fontWeight: FontWeight.bold, fontSize: 18
            ),),
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
                    onPressed: () {
                      //Find Element Key
                      int key = findRecordKey(element);
                      Record record = Hive.box('records').get(key);
                      Method method = Hive.box('methods').get(toKey(record.method.name));
                      if(record.amount >= 0) {
                        method.incSubtotal -= record.amount;
                      } else {
                        method.expSubTotal += record.amount;
                      }
                      method.recordKeys.remove(key);
                      Hive.box('methods').put(toKey(method.name), method);
                      Hive.box('records').delete(key);
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
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('수입 및 지출내역 편집'),  backgroundColor: Colors.blue,),
      bottomNavigationBar: loadBottomNavigator(context),
      body: Column(children: <Widget>[
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text('수입 및 지출내역 조회', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
              SizedBox(height: 10,),
              FormBuilder(key: _formKey, child: Row(children: <Widget>[
                Text('시작일: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                Flexible(child: FormBuilderDateTimePicker(
                  attribute: "date",
                  inputType: InputType.date,
                  format: DateFormat('M/d'),
                  resetIcon: null,
                  decoration: InputDecoration(
                    labelText: '날짜',
                    labelStyle: TextStyle(fontSize: 14),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  ),
                  onChanged: (value) {
                  },
                ),),
                SizedBox(width: 8,),
                Text('기간: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                Flexible(child: TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: '일수',
                      labelStyle: TextStyle(fontSize: 14),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    ),
                    onChanged: (value) {},
                  ),),
                  SizedBox(width: 8,),
                RaisedButton(
                  child: Text('조회'),
                  onPressed: () {},
                )
              ],),)
            ],
          ),
        ),
        ValueListenableBuilder(
          valueListenable: Hive.box('records').listenable(),
          builder: (context, box, _) {
            if(box.values.isEmpty) {
              return Center(child: Text('여기에 수입 및 지출기록이 보여집니다.'),);
            }
            return Flexible(child: GroupedListView(
              elements: _readBoxData(box),
              groupBy: (element) {
                final record = element as Record;
                return df.format(record.date);
              },
              groupSeparatorBuilder: buildGroupSeparator,
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