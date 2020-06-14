import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'source_common.dart';
import './record_form.dart';
import './method_form.dart';
import './drawer_common.dart';
import './record_list.dart';
import './method_list.dart';

//Sandbox Dependency

main() => runApp(ExtraCreditApp());
//Sandbox
//main() => runApp(Sandbox());

class ExtraCreditApp extends StatefulWidget {
  @override
  _ExtraCreditAppState createState() => _ExtraCreditAppState();
}

class _ExtraCreditAppState extends State<ExtraCreditApp> {

  Future<dynamic> _initialDBSetup() async {
    final _appDocDir = await path_provider.getApplicationDocumentsDirectory();
    Hive.init(_appDocDir.path);
    final methodsBox = await Hive.openBox('methods');
    final recordsBox = await Hive.openBox('records');
    return [methodsBox, recordsBox];
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Extra Credit',
      home: FutureBuilder(
        future: _initialDBSetup(),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.done) {
            if(snapshot.hasError) {
              return Text(snapshot.error.toString());
            } else {
              return Overview();
            }
          } else {
            return Text('Waiting');
          }
        },
      ),
      routes: {
        '/add': (context) => RecordForm(),
        //'/about': (context) => AboutApp(),
        '/new': (context) => MethodForm(),
        '/sand': (context) => Sandbox(),
        '/edit': (context) => RecordList(),
        '/manage': (context) => MethodList()
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
  var _dummy = [
    {"date": "2020/06/05", "value":"10000"},
    {"date": "2020/06/05", "value":"10000"},
    {"date": "2020/06/05", "value":"10000"},
    {"date": "2020/06/07", "value":"10000"},
    {"date": "2020/06/07", "value":"10000"},
    {"date": "2020/06/05", "value":"10000"},
    {"date": "2020/06/05", "value":"10000"},
    {"date": "2020/06/03", "value":"10000"},
    {"date": "2020/05/30", "value":"10000"}
  ];
  Widget _buildGroupSeparator(dynamic groupByValue) {
    return Text('$groupByValue');
  }

  //List Tile UI
  Widget _buildRecordList(BuildContext context, dynamic element) {
    var labelColor = Colors.blue;
    var positiveTextColor = Colors.green;
    var negativeTextColor = Colors.red;
    return Card(
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
          buildCurrencyString(10000, false), 
          style: TextStyle(
            color: double.parse(element['value'])>0?positiveTextColor:negativeTextColor, 
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
            TxMethodWalletListView(),
            //수입 및 지출내역 block
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
            Flexible(child: GroupedListView(
              elements: _dummy,
              groupBy: (element) => element['date'],
              groupSeparatorBuilder: _buildGroupSeparator,
              itemBuilder: _buildRecordList,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
            ),)
          ],
        ),
      )
    );
  }
}

class TxMethodWalletListView extends StatelessWidget {
  final _dummy = [Colors.green, Colors.red, Colors.blue, Colors.black];

  List<Widget> _buildPointWallet(BuildContext context) {
    List<Widget> _walletStack = [];
    _walletStack.add(RaisedButton(
      child: Text('새로운 거래수단 추가하기', style: TextStyle(color: Colors.white),),
      color: Colors.blue,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      onPressed: () {Navigator.pushNamed(context, '/new');},
    ));
    for(Color color in _dummy) {
      _walletStack.add(
        Card(
          color: color,
          margin: EdgeInsets.symmetric(vertical: 3,horizontal:25),
          child: Column(
            children: <Widget>[
              ListTile(
                title: Text('네이버 페이 포인트', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),), 
                subtitle: Text('메모할 내용', style: TextStyle(color: Colors.grey[200]),), 
                trailing: IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () {},
                ),
              ),
              SizedBox(height: 5,),
              Center(child: Text(buildCurrencyString(10000, true), style: TextStyle(fontSize: 23, color: Colors.white, fontWeight: FontWeight.bold),),),
              SizedBox(height: 55,),
            ],
          ),
        )
      );
    }
    return _walletStack;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: Text('거래수단 목록', style: TextStyle(fontWeight: FontWeight.bold), ),
        initiallyExpanded: true,
        children: _buildPointWallet(context),
      ),
    );
  }
}

//(DEVONLY)Sandbox
class Sandbox extends StatefulWidget {
  @override
  _SandboxState createState() => _SandboxState();
}

class _SandboxState extends State<Sandbox> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Sandbox'), backgroundColor: Colors.orange,),
        drawer: loadDrawer(context),
        body:Column(
          children: [
            Text('hi')
          ],
        )
      ),
    );
  }
}