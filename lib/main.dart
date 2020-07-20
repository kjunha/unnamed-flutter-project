import 'dart:ffi';

import 'package:finance_point/model/record.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
//common source
import './guage_view_painter.dart';
import './source_common.dart';
//import model
import './model/record.dart';
import './model/method.dart';
//router
import './record_form.dart';
import './method_form.dart';
import './bottom_nav_common.dart';
import './record_list.dart';
import './method_list.dart';
import './transfer_form.dart';

//Sandbox Dependency

main() {
  runApp(ExtraCreditApp());
}
//Sandbox
//main() => runApp(Sandbox());

class ExtraCreditApp extends StatefulWidget {
  @override
  _ExtraCreditAppState createState() => _ExtraCreditAppState();
}

class _ExtraCreditAppState extends State<ExtraCreditApp> {
  final _initFuture = Init.initialize();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Extra Credit',
      home: FutureBuilder(
        future: _initFuture,
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.done) {
            if(snapshot.hasError) {
              print('snapshot error');
              return Text('SNAPSHOT_ERROR!');
            } else {
              return Overview();
            }
          } else {
            //Splash Screen
            return Scaffold(
              backgroundColor: Colors.blueAccent,
              body: Center(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('엑스트라 크레딧', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),),
                  Text('나의 모든 자산을 한눈에', style: TextStyle(color: Colors.white, fontSize: 16),),
                  SizedBox(height: 150,),
                  CircularProgressIndicator(backgroundColor: Colors.white,),
                  SizedBox(height: 50,),
                  Text('정보를 가져오는중 입니다.', style: TextStyle(color:Colors.white),)
                ],
              ),)
            );
          }
        },
      ),
      routes: {
        '/add': (context) => RecordForm(),
        //'/about': (context) => AboutApp(),
        '/new': (context) => MethodForm(),
        '/records': (context) => RecordList(),
        '/methods': (context) => MethodList(),
        '/transfer': (context) => TransferForm(),
      },
      onGenerateRoute: (setting) {
        if(setting.name == '/records/edit') {
          final RecordKeySet valueSet = setting.arguments;
          return MaterialPageRoute(
            builder: (_) => RecordForm.edit(valueSet.record, valueSet.key)
          );
        }
        if(setting.name == '/methods/edit') {
          final Method valueSet = setting.arguments;
          return MaterialPageRoute(
            builder: (_) => MethodForm.edit(valueSet)
          );
        }
        return MaterialPageRoute(builder: (_) => Scaffold(
          body: Center(child: Text('no routes detected'),),
        ),);
      },
    );
  }

  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }

}

class Init {
  static Future initialize() async {
    await _registerService();
    await _loadSettings();
    //DEBUG: await Future.delayed(Duration(seconds: 10));
  }

  static _registerService() async {
      //print('DEBUG: Starting registering services.');
      await Hive.initFlutter();
      Hive.registerAdapter(RecordAdapter());
      Hive.registerAdapter(MethodAdapter());
      //print('DEBUG: finished registering services');
  }

  static _loadSettings() async {
    //print('DEBUG: starting loading settings.');
    await Hive.openBox('records');
    await Hive.openBox('methods');
    await Hive.openBox('tags');
    //print('DEBUG: finished loading settings.');
  }
}



class Overview extends StatefulWidget {
  @override
  _OverviewState createState() => _OverviewState();

}

class _OverviewState extends State<Overview> with TickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Animation<double>animation;
  AnimationController aniController;

  List<Record> _readRecordData(Box box) {
    List<Record> recordList = [];
    for(int i = 0; i < box.length; i++) {
      recordList.add(box.getAt(i));
    }
    return recordList;
  }

  List<Method> _readMethodData(Box box) {
    List<Method> methodList = [];
    List<dynamic> keys = box.keys.toList();
    for(dynamic key in keys) {
      methodList.add(box.get(key));
    }
    return methodList;
  }

  //Method Card builder
  List<Widget> _buildPointWallet(BuildContext context) {
    List<Method> methods = _readMethodData(Hive.box('methods'));
    List<Widget> _walletStack = [];
    _walletStack.add(RaisedButton(
      child: Text('새로운 거래수단 추가하기', style: TextStyle(color: Colors.white),),
      color: Colors.blue,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      onPressed: () {Navigator.pushNamed(context, '/new');},
    ));
    for(Method method in methods) {
      if(method.isMain) {
        _walletStack.add(
          Card(
            color: Color(method.colorHex),
            margin: EdgeInsets.symmetric(vertical: 3,horizontal:25),
            child: Column(
              children: <Widget>[
                ListTile(
                  title: Text(method.name??'', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),), 
                  subtitle: Text(method.description??'', style: TextStyle(color: Colors.grey[200]),), 
                  // trailing: IconButton(
                  //   icon: Icon(Icons.settings),
                  //   onPressed: () {},
                  // ),
                ),
                SizedBox(height: 5,),
                Center(child: Text(buildCurrencyString(getMethodTotal(method), method.type == 'point'), style: TextStyle(fontSize: 23, color: Colors.white, fontWeight: FontWeight.bold),),),
                SizedBox(height: 55,),
              ],
            ),
          )
        );
      }
    }
    if(_walletStack.length == 1) {
      _walletStack.add(Center(child: Text('보유한 거래수단이 없습니다.'),));
    }
    _walletStack.add(SizedBox(height: 30,));
    return _walletStack;
  }
  //List Tile UI
  Widget _buildRecordList(BuildContext context, dynamic element) {
    //Record Promise
    Record record = element as Record;    
    //UI Colors
    var positiveTextColor = Colors.green;
    var negativeTextColor = Colors.red;
    return Card(
      child: ListTile(
        title:Text(record.description,),
        subtitle: Text(record.method.name),
        leading: tagUIProvider(record.tag, Color(record.method.colorHex), record.amount>=0),
        trailing: Text(
          buildCurrencyString(record.amount, false), 
          style: TextStyle(
            color: record.amount>0?positiveTextColor:negativeTextColor, 
            fontWeight: FontWeight.bold, fontSize: 18
          ),),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Extra Credit', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
        elevation: 0.0,
        centerTitle: true,
        backgroundColor: Colors.white,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit, color: Colors.black,),
            onPressed: () {},
          )
        ],
      ),
      bottomNavigationBar: loadBottomNavigator(context),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            //데이터 시각화 카드
            Container(
              color: Colors.white,
              child: ExpansionTile(
                title: Text('가계부 요약', style: TextStyle(fontWeight: FontWeight.bold),),
                initiallyExpanded: true,
                children: <Widget>[
                  ValueListenableBuilder(
                    valueListenable: Hive.box('records').listenable(),
                    builder: (context, box, _) {
                      List<dynamic> recordKeys = box.keys.toList();
                      double _incSubtotal = 0;
                      double _expSubtotal = 0;
                      double _previous = 0;
                      for(dynamic key in recordKeys) {
                        Record rcd = box.get(key) as Record;
                        if(rcd.method.isIncluded) {
                          if(rcd.amount != _previous) {
                            if(rcd.amount >= 0) {
                              _incSubtotal += rcd.amount;
                            } else {
                              _expSubtotal += rcd.amount*-1;
                            }
                          } else {
                            if(rcd.amount >= 0) {
                              _expSubtotal -= _previous;
                            } else {
                              _incSubtotal -= _previous*-1;
                            }
                          }
                        }
                        _previous = rcd.amount*-1;
                      }
                      double _total = _incSubtotal - _expSubtotal;
                      double _percentage = _incSubtotal == 0?0:_expSubtotal/_incSubtotal*100;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.all(10),
                            child: CustomPaint(
                              size: Size(364,200),
                              painter: GuageViewPainter(_percentage),
                            ),
                          ),
                          Divider(thickness: 2, color: Colors.grey, indent: 10, endIndent: 10,),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 15,horizontal: 30),
                            child: Table(
                              children: [
                                TableRow(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Text('수입', style:TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                                        Text(buildCurrencyString(_incSubtotal, false), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Text('지출', style:TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                                        Text(buildCurrencyString(_expSubtotal, false), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Text('누계', style:TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                                        Text(buildCurrencyString(_total, false), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))
                                      ],
                                    ),
                                  ]
                                )
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                  ),
                ],
              ),
            ),
            SizedBox(height: 5,),
            //거래수단 목록 카드
            Container(
              color: Colors.white,
              child: ValueListenableBuilder(
                valueListenable: Hive.box('methods').listenable(),
                builder: (context, box, _) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if(Hive.box('methods').isEmpty) {
                      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('먼저 거래수단을 추가해 주세요.'),));
                    }
                  });
                  return ExpansionTile(
                    title: Text('거래수단 목록', style: TextStyle(fontWeight: FontWeight.bold), ),
                    initiallyExpanded: true,
                    children: _buildPointWallet(context),
                  );
                },
              ), 
            ),
            SizedBox(height: 5,),
            //수입 및 지출내역 카드
            Container(
              color: Colors.white,
              child: ExpansionTile(
                title: Text("수입 및 지출내역"),
                initiallyExpanded: true,
                children: <Widget>[
                  ValueListenableBuilder(
                    valueListenable: Hive.box('records').listenable(),
                    builder: (context, box, _) {
                      if(box.values.isEmpty) return Center(child: Text('수입 및 지출기록이 없습니다.'));
                      return GroupedListView(
                        elements: _readRecordData(box),
                        groupBy: (element) {
                          final record = element as Record;
                          return df.format(record.date);
                        },
                        groupSeparatorBuilder: buildGroupSeparator,
                        itemBuilder: _buildRecordList,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                      );
                    },
                  ),
                ],
              ),
            ),         
          ],
        ),
      )
    );
  }
}