import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _dateTimeFilterController = TextEditingController();
  final _numDateFilterController = TextEditingController();
  DateTime _dateTimeFilter;
  DateTime _dateTimePickValue;
  int _numDateFilter;
  String _methodNameFilter;
  String _txTagFilter;
  Box methodsBox;
  Box recordsBox;
  List<String> _methodsNameList = [];
  Set<String> _txTagSet = {};

  @override
  void initState() {
    super.initState();
    methodsBox = Hive.box('methods');
    recordsBox = Hive.box('records');
    Box tagsBox = Hive.box('tags');
    List keys = methodsBox.keys.toList();
    for(dynamic key in keys) {
      _methodsNameList.add(methodsBox.get(key).name);
    }
    for(int i = 0; i < tagsBox.length; i++) {
      _txTagSet.add(tagsBox.getAt(i));
    }
    _txTagSet.add('수입');
    _txTagSet.add('지출');
    _txTagSet.add('내부송금');
    _txTagSet.add('수수료');
  }
  //revert original list
  List<Record> _revertOriginal() {
    List<Record> originalRecordsList = [];
    List keys = recordsBox.keys.toList();
    for(dynamic key in keys) {
      originalRecordsList.add(recordsBox.get(key));
    }
    return originalRecordsList;
  }
  //filter Logic
  List<Record> _filterByOptions(List<Record> beforeFilter) {
    Set<Record> trash = {};
    List<Record> afterSort = [];
    afterSort.addAll(beforeFilter);
    if(_methodNameFilter != null) {
      for(Record record in beforeFilter) {
        if(record.method.name != _methodNameFilter) {
          trash.add(record);
        }
      }
    }
    if(_txTagFilter != null) {
      for(Record record in beforeFilter) {
        if(record.tag != _txTagFilter) {
          trash.add(record);
        }
      }
    }
    if(_dateTimeFilter != null) {
      DateTime startDate = _dateTimeFilter;
      DateTime endDate = startDate.add(Duration(days: _numDateFilter));
      for(Record record in beforeFilter) {
        if(record.date.isBefore(startDate) || record.date.isAfter(endDate)) {
          trash.add(record);
        }
      }
    }
    if(trash.length > 0) {
      for(Record record in trash) {
        afterSort.remove(record);
      }
    }
    return afterSort;
  }

  //List Tile UI
  Widget _buildRecordList(BuildContext context, Record element, Box box) {
    //Record Promise
    Record record = element;
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
                break;
              }
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
      key: _scaffoldKey,
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text('수입 및 지출내역 편집'),  
        backgroundColor: Colors.blue,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/add');
            },
          ),
        ],
      ),
      bottomNavigationBar: loadBottomNavigator(context),
      body: Column(children: <Widget>[
        Container(color: Colors.white, child:ExpansionTile(
          title: Text('수입 및 지출내역 조회', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
          backgroundColor: Colors.white,
          initiallyExpanded: true,
          children: <Widget>[
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  FormBuilder(
                    key: _formKey, 
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        //검색날짜 + 일수
                        Row(
                          children: <Widget>[
                            Flexible(child: FormBuilderDateTimePicker(
                              attribute: "date",
                              inputType: InputType.date,
                              format: df,
                              resetIcon: null,
                              controller: _dateTimeFilterController,
                              decoration: InputDecoration(
                                labelText: '시작일 (날짜)',
                                labelStyle: TextStyle(fontSize: 14),
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide())
                              ),
                              onChanged: (value) {
                                _dateTimePickValue = value;
                                if(_numDateFilter != null && _numDateFilter != 0) {
                                  setState(() {
                                    _dateTimeFilter = value;
                                  });
                                }
                              },
                            ),),
                            SizedBox(width: 8,),
                            Flexible(child: FormBuilderTextField(
                                attribute: 'num_date',
                                keyboardType: TextInputType.number,
                                controller: _numDateFilterController,
                                decoration: InputDecoration(
                                  labelText: '기간 (일수)',
                                  labelStyle: TextStyle(fontSize: 14),
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide()),
                                ),
                                onChanged: (value) {
                                  if(int.tryParse(value) != null) {
                                  setState(() {
                                      _numDateFilter = int.parse(value);
                                      _dateTimeFilter = _dateTimePickValue??DateTime.now();
                                    });
                                  }
                                },
                              ),),
                          ],
                        ),
                        //검색용 거래수단
                        SizedBox(height: 6,),
                        FormBuilderDropdown(
                          attribute: "tx_method",
                          decoration: InputDecoration(
                            labelText: '거래수단',
                            labelStyle: TextStyle(fontSize: 14),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide()),
                          ),
                          hint: Text('검색할 거래수단을 선택해 주세요'),
                          items: _methodsNameList
                            .map((value) => DropdownMenuItem(
                              value: value,
                              child: Text("$value")
                          )).toList(),
                          onChanged: (value) {
                            setState(() {
                              _methodNameFilter = value;
                            });
                          },
                        ),
                        //검색용 태그
                        SizedBox(height: 6,),
                        FormBuilderDropdown(
                          attribute: "tx_tag",
                          decoration: InputDecoration(
                            labelText: '태그',
                            labelStyle: TextStyle(fontSize: 14),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide()),
                          ),
                          hint: Text('검색할 태그 이름을 선택해 주세요'),
                          items: _txTagSet
                            .map((value) => DropdownMenuItem(
                              value: value,
                              child: Text("$value")
                          )).toList(),
                          onChanged: (value) {
                            setState(() {
                              _txTagFilter = value;
                            });
                          },
                        ),
                      ],
                    ), 
                  ),
                  Center(child: SizedBox(
                    width: 120,
                    child: FlatButton(
                      child: Text('필터 초기화', style: TextStyle(color: Colors.blue),),
                      onPressed: () {
                        _dateTimeFilterController.clear();
                        _numDateFilterController.clear();
                        _formKey.currentState.reset();
                        setState(() {
                          _dateTimeFilter = null;
                          _numDateFilter = null;
                          _methodNameFilter = null;
                          _txTagFilter = null;
                        });
                      },
                    ),
                  ),)
                ],
              ),
            ),
          ],
        ),),

        ValueListenableBuilder(
          valueListenable: Hive.box('records').listenable(),
          builder: (context, box, _) {
            if(box.values.isEmpty) {
              return Center(child: Text('여기에 수입 및 지출기록이 보여집니다.'),);
            }
            List<Record> original = _revertOriginal();
            List<Record> filtered = [];
            if(_dateTimeFilter == null && _numDateFilter == null && _methodNameFilter == null && _txTagFilter == null) {
              filtered.addAll(original);
            } else {
              filtered.addAll(_filterByOptions(original));
            }
            return Flexible(child: GroupedListView(
              elements: filtered,
              groupBy: (element) {
                final record = element as Record;
                return df.format(record.date);
              },
              groupSeparatorBuilder: buildGroupSeparator,
              itemBuilder: (context,element) {
                return _buildRecordList(context, element, box);
              },
              shrinkWrap: false,
              physics: null,
            ),);
          },
        ),
      ],)
    );
  }
}