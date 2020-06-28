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
  final _dateTimeSortController = TextEditingController();
  final _numDateSortController = TextEditingController();
  DateTime _dateTimeSort;
  int _numDateSort;
  String _methodNameSort;
  String _txTagSort;
  Box methodsBox;
  Box recordsBox;
  List<String> _methodsNameList = [];
  List<Record> _sortedRecordList = [];
  List<String> _txTagList = [];

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
    _sortedRecordList = _revertOriginal();
    for(int i = 0; i < tagsBox.length; i++) {
      _txTagList.add(tagsBox.getAt(i));
    }
    _txTagList.add('수입');
    _txTagList.add('지출');
    _txTagList.add('내부송금');
    _txTagList.add('수수료');
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
  //sort Logic
  List<Record> _sortByOptions(List<Record> beforeSort) {
    Set<Record> trash = {};
    List<Record> afterSort = [];
    afterSort.addAll(beforeSort);
    if(_methodNameSort != null) {
      for(Record record in _sortedRecordList) {
        if(record.method.name != _methodNameSort) {
          trash.add(record);
        }
      }
    }
    if(_txTagSort != null) {
      for(Record record in _sortedRecordList) {
        if(record.tag != _txTagSort) {
          trash.add(record);
        }
      }
    }
    if(_dateTimeSort != null) {
      DateTime startDate = _dateTimeSort;
      DateTime endDate = startDate.add(Duration(days: _numDateSort));
      for(Record record in _sortedRecordList) {
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

  //Input & Click Handler
  void _resetAllOptions() {
    //set current search result back to original
    List<Record> originalRecordsList = _revertOriginal();
    setState(() {
      _sortedRecordList = [];
      _sortedRecordList.addAll(originalRecordsList);
    });
    //reset all variables
    _methodNameSort = null;
    _txTagSort = null;
    _dateTimeSort = null;
    _numDateSort = null;
    _formKey.currentState.reset();
    clearTextInput();
    //show snackbar message
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text('검색값이 초기화 되었습니다.'),)
    );
  }
  void _submitSearch() {
    if(_formKey.currentState.saveAndValidate()) {
      List<Record>originalRecordsList = _revertOriginal();
      List<Record>afterSearch = _sortByOptions(originalRecordsList);
      setState(() {
        _sortedRecordList = [];
        _sortedRecordList.addAll(afterSearch);
      });

    }
  }
  //clear all Text based input
  void clearTextInput() {
    _dateTimeSortController.clear();
    _numDateSortController.clear();
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
          )
        ],
      ),
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
                          controller: _dateTimeSortController,
                          decoration: InputDecoration(
                            labelText: '시작일 (날짜)',
                            labelStyle: TextStyle(fontSize: 14),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide())
                          ),
                          onChanged: (value) {
                            _dateTimeSort = value;
                          },
                        ),),
                        SizedBox(width: 8,),
                        Flexible(child: FormBuilderTextField(
                            attribute: 'num_date',
                            keyboardType: TextInputType.number,
                            controller: _numDateSortController,
                            validators: [
                              (value) {
                                if(_dateTimeSort != null) {
                                  if(value == null || value.length == 0){
                                    return '검색할 기간을 설정해 주십시오.';
                                  } else {
                                    return double.tryParse(value) == null?'숫자값을 입력해 주십시오':null;
                                  }
                                }
                                return null;
                              },
                            ],
                            decoration: InputDecoration(
                              labelText: '기간 (일수)',
                              labelStyle: TextStyle(fontSize: 14),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide())
                            ),
                            onChanged: (value) {
                              _numDateSort = int.parse(value);
                            },
                          ),),
                      ],
                    ),
                    //검색용 거래수단
                    SizedBox(height: 6,),
                    Row(
                      children: <Widget>[
                        Expanded(child:FormBuilderDropdown(
                          attribute: "transaction_method",
                          decoration: InputDecoration(
                            labelText: '거래수단',
                            labelStyle: TextStyle(fontSize: 14),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide())
                          ),
                          hint: Text('검색할 거래수단을 선택해 주세요'),
                          items: _methodsNameList
                            .map((value) => DropdownMenuItem(
                              value: value,
                              child: Text("$value")
                          )).toList(),
                          onChanged: (value) {
                            _methodNameSort = value;
                          },
                        ),),
                        SizedBox(width: 8,),
                        RaisedButton(
                          child: Text('초기화', style: TextStyle(color: Colors.white),),
                          color: Colors.grey,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          onPressed: _resetAllOptions,
                        )
                      ],
                    ),
                    //검색용 태그
                    Row(
                      children: <Widget>[
                        Expanded(child:FormBuilderDropdown(
                          attribute: "transaction_method",
                          decoration: InputDecoration(
                            labelText: '태그',
                            labelStyle: TextStyle(fontSize: 14),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide())
                          ),
                          hint: Text('검색할 태그 이름을 선택해 주세요'),
                          items: _txTagList
                            .map((value) => DropdownMenuItem(
                              value: value,
                              child: Text("$value")
                          )).toList(),
                          onChanged: (value) {
                            _txTagSort = value;
                          },
                        ),),
                        SizedBox(width: 8,),
                        RaisedButton(
                          child: Text('조회', style: TextStyle(color: Colors.white),),
                          color: Colors.blueAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          onPressed: _submitSearch,
                        )
                      ],
                    ),
                  ],
                ), 

              ),
            ],
          ),
        ),
        ValueListenableBuilder(
          valueListenable: Hive.box('records').listenable(),
          builder: (context, box, _) {
            print('Value Listenable Builder called');
            if(box.values.isEmpty) {
              return Center(child: Text('여기에 수입 및 지출기록이 보여집니다.'),);
            }
            return Flexible(child: GroupedListView(
              elements: _sortedRecordList,
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