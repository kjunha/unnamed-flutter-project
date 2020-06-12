import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import './add_record.dart';
import './new_method.dart';
import './drawer_common.dart';

//Sandbox Dependency

main() => runApp(ExtraCreditApp());
//Sandbox
//main() => runApp(Sandbox());

class ExtraCreditApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Extra Credit',
      home: Overview(),
      routes: {
        '/add': (context) => AddRecord(),
        '/about': (context) => AboutApp(),
        '/new': (context) => NewMethod(),
        '/sand': (context) => Sandbox()
      },
    );
  }
}

class Overview extends StatefulWidget {
  @override
  _OverviewState createState() => _OverviewState();

}

class _OverviewState extends State<Overview> {
  var _dummy = [
    {"date": "2020/06/05", "value":"v1"},
    {"date": "2020/06/05", "value":"v2"},
    {"date": "2020/06/05", "value":"v3"},
    {"date": "2020/06/07", "value":"v4"},
    {"date": "2020/06/07", "value":"v5"},
    {"date": "2020/06/05", "value":"v6"},
    {"date": "2020/06/05", "value":"v7"},
    {"date": "2020/06/03", "value":"v8"},
    {"date": "2020/05/30", "value":"v9"}
  ];
  Widget _buildGroupSeparator(dynamic groupByValue) {
    return Text('$groupByValue');
  }

  //List Tile UI
  Widget _buildRecordList(BuildContext context, dynamic element) {
    var labelColor = Colors.blue;
    var trailingTextColor = Colors.green;
    return Card(
      child: ListTile(
        title:Text('지출내역 상세기록 ' + element['value'], ),
        subtitle: Text('지불수단'),
        leading: Container(
          child: Center(child: Text('최대글자', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1),)),
          width: 48,
          height: 22,
          decoration: BoxDecoration(border: Border.all(color:labelColor, width:1), borderRadius: BorderRadius.circular(12), color: labelColor),
        ),
        trailing: Text('10,000', style: TextStyle(color: trailingTextColor, fontWeight: FontWeight.bold, fontSize: 18),) ,
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
            PointWalletListView(),
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
                              Text('10,000', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text('지출', style:TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                              Text('10,000', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text('누계', style:TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                              Text('10,000', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))
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

//(REMAIN)Togglable Features in overview page
class PointWalletListView extends StatefulWidget {
  @override
  _PointWalletListViewState createState() => _PointWalletListViewState();
}

class _PointWalletListViewState extends State<PointWalletListView> {
  var _dummy = [Colors.green, Colors.red, Colors.blue, Colors.black];

  List<Widget> _buildPointWallet() {
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
              Center(child: Text('1,234,567 P', style: TextStyle(fontSize: 23, color: Colors.white, fontWeight: FontWeight.bold),),),
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
        children: _buildPointWallet(),
      ),
    );
  }
}

//(TOBEGONE)To Be Created
class AboutApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}

class RecordEditView extends StatefulWidget {
  @override
  _RecordEditViewState createState() => _RecordEditViewState();
}

class _RecordEditViewState extends State<RecordEditView> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'record_edit_view',
      home: Scaffold(
        appBar: AppBar(),
        body: Text(''),
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



