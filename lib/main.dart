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
import './drawer_common.dart';
import './record_list.dart';
import './method_list.dart';

//Sandbox Dependency

main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(RecordAdapter());
  Hive.registerAdapter(MethodAdapter());
  await Hive.openBox('records');
  await Hive.openBox('methods');
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
                  title: Text(method.name, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),), 
                  subtitle: Text(method.description, style: TextStyle(color: Colors.grey[200]),), 
                  trailing: IconButton(
                    icon: Icon(Icons.settings),
                    onPressed: () {},
                  ),
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
    return _walletStack;
  }

  //Group List Group bar
  Widget _buildGroupSeparator(dynamic groupByValue) {
    return Text(df.format(groupByValue));
  }

  //List Tile UI
  Widget _buildRecordList(BuildContext context, dynamic element) {
    //Record Promise
    Record record = element as Record;
    //UI Colors
    var labelColor = Colors.blue;
    var positiveTextColor = Colors.green;
    var negativeTextColor = Colors.red;
    return Card(
      child: ListTile(
        title:Text(record.description,),
        subtitle: Text(record.method.name),
        leading: Container(
          child: Center(child: Text(record.tag, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1),)),
          width: 48,
          height: 22,
          decoration: BoxDecoration(border: Border.all(color:labelColor, width:1), borderRadius: BorderRadius.circular(12), color: labelColor),
        ),
        trailing: Text(
          buildCurrencyString(record.amount, false), 
          style: TextStyle(
            color: record.amount>0?positiveTextColor:negativeTextColor, 
            fontWeight: FontWeight.bold, fontSize: 18
          ),),
        onTap: () {},
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
        actions: [
          IconButton(icon: Icon(Icons.build),onPressed: () {Navigator.pushNamed(context, '/sand');},)
        ],
      ),
      drawer: loadDrawer(context),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            //거래수단 목록 카드
            Card(
              child: ValueListenableBuilder(
                valueListenable: Hive.box('methods').listenable(),
                builder: (context, _, __) {
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
                  child: Table(
                    children: [
                      TableRow(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text('수입', style:TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                              Text(buildCurrencyString(10000, false), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text('지출', style:TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                              Text(buildCurrencyString(10000, false), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text('누계', style:TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                              Text(buildCurrencyString(10000, false), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))
                            ],
                          ),
                        ]
                      )
                    ],
                  ),
                ),
              ]),
            ),
            ValueListenableBuilder(
              valueListenable: Hive.box('records').listenable(),
              builder: (context, box, _) {
                if(box.values.isEmpty) return Center(child: Text('nothing to show'));
                return Flexible(child: GroupedListView(
                  elements: _readRecordData(box),
                  groupBy: (element) {
                    final record = element as Record;
                    return record.date;
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