import 'package:finance_point/model/record.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
//common source
import 'source_common.dart';
//import model
import './model/record.dart';
import './model/method.dart';
//router
import './record_form.dart';
import './method_form.dart';
import './bottom_nav_common.dart';
import './record_list.dart';
import './method_list.dart';

//Sandbox Dependency

main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(RecordAdapter());
  Hive.registerAdapter(MethodAdapter());
  await Hive.openBox('records');
  await Hive.openBox('methods');
  await Hive.openBox('tags');
  runApp(ExtraCreditApp());
}
//Sandbox
//main() => runApp(Sandbox());

class ExtraCreditApp extends StatefulWidget {
  @override
  _ExtraCreditAppState createState() => _ExtraCreditAppState();
}

class _ExtraCreditAppState extends State<ExtraCreditApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Extra Credit',
      home: Overview(),
      routes: {
        '/add': (context) => RecordForm(),
        //'/about': (context) => AboutApp(),
        '/new': (context) => MethodForm(),
        '/sand': (context) => Sandbox(),
        '/records': (context) => RecordList(),
        '/methods': (context) => MethodList()
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

class Overview extends StatefulWidget {
  @override
  _OverviewState createState() => _OverviewState();

}

class _OverviewState extends State<Overview> {
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

  //TODO: such state like: onReloaded
  //update Total Asset view

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

  //Group List Group bar
  Widget _buildGroupSeparator(dynamic groupByValue) {
    return Text(groupByValue);
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
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text('Overview'),
        centerTitle: true,
      ),
      bottomNavigationBar: loadBottomNavigator(context),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            //거래수단 목록 카드
            Card(
              child: ValueListenableBuilder(
                valueListenable: Hive.box('methods').listenable(),
                builder: (context, box, _) {
                  return ExpansionTile(
                    title: Text('거래수단 목록', style: TextStyle(fontWeight: FontWeight.bold), ),
                    initiallyExpanded: true,
                    children: _buildPointWallet(context),
                  );
                },
              ), 
            ),
            //수입 및 지출내역 카드
            Card(
              child: Column(children: [
                ListTile(  
                  //title: Center(child: Text('수입 및 지출 내역', style: TextStyle(fontWeight: FontWeight.bold),)),
                  title: Text('수입 및 지출 내역', style: TextStyle(fontWeight: FontWeight.bold),),
                  dense: false,
                  trailing: IconButton(icon: Icon(Icons.add), onPressed: () {Navigator.pushNamed(context, '/add');},),
                ),
                Divider(thickness: 2,),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 15,horizontal: 30),
                  child: ValueListenableBuilder(
                    valueListenable: Hive.box('methods').listenable(),
                    builder: (context, box, _) {
                      List<dynamic> methodKeys = box.keys.toList();
                      double _incSubtotal = 0;
                      double _expSubtotal = 0;
                      for(dynamic key in methodKeys) {
                        Method mtd = box.get(key) as Method;
                        _incSubtotal += mtd.incSubtotal;
                        _expSubtotal += mtd.expSubTotal;
                      }
                      double _total = _incSubtotal - _expSubtotal;
                      return Table(
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
                      );
                    },
                  ),
                ),
              ]),
            ),
            ValueListenableBuilder(
              valueListenable: Hive.box('records').listenable(),
              builder: (context, box, _) {
                if(box.values.isEmpty) return Center(child: Text('수입 및 지출기록이 없습니다.'));
                return Flexible(child: GroupedListView(
                  elements: _readRecordData(box),
                  groupBy: (element) {
                    final record = element as Record;
                    return df.format(record.date);
                  },
                  groupSeparatorBuilder: _buildGroupSeparator,
                  itemBuilder: _buildRecordList,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                ),);
              },

            )
          ],
        ),
      )
    );
  }
}

//(DEVONLY)Sandbox
class Sandbox extends StatefulWidget {
  @override
  _SandboxState createState() => _SandboxState();
}

class _SandboxState extends State<Sandbox> {
  final _dummy = [1,2,3,4,5];
  Widget _buildListItem(BuildContext context, int index) {
    return ListTile(
      title: Text('item ' + _dummy[index].toString()),
      subtitle: Text('my item'),
      trailing: SizedBox(width: 96, child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {},
          )
        ],
      ),),
    );
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Sandbox'), backgroundColor: Colors.orange, actions: [IconButton(icon: Icon(Icons.add), onPressed: () {},)],),
        bottomNavigationBar: BottomNavigationBar (
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              title: SizedBox(height: 0,)
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              title: SizedBox(height: 0,)
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              title: SizedBox(height: 0,)
            ),
          ],
        ),
        body:Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(child: ListView.builder(
              itemCount: _dummy.length,
              itemBuilder: _buildListItem
            ),)
          ],
        )
      ),
    );
  }
}