import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import './add_record.dart';

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
        '/sand': (context) => Sandbox(), //Dev Dependancy
      },
    );
  }
}

class Overview extends StatefulWidget {
  @override
  _OverviewState createState() => _OverviewState();

}

class _OverviewState extends State<Overview> {
  var dummy = [1,2,3,4,5];

  //List Tile UI
  Widget _buildRecordList(BuildContext context, int i) {
    var labelColor = Colors.blue;
    var trailingTextColor = Colors.green;
    return ListTile(
      title:Text('지출내역 상세기록', ),
      subtitle: Text('지불수단'),
      leading: Container(
        child: Center(child: Text('최대글자', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1),)),
        width: 48,
        height: 22,
        decoration: BoxDecoration(border: Border.all(color:labelColor, width:1), borderRadius: BorderRadius.circular(12), color: labelColor),
      ),
      trailing: Text('10,000', style: TextStyle(color: trailingTextColor, fontWeight: FontWeight.bold, fontSize: 18),) ,
      onTap: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Overview'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {Navigator.pushNamed(context, '/add');},
          ),
          IconButton(
            icon:Icon(Icons.question_answer),
            onPressed: () {},
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PointWalletListView(),
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
          Divider(thickness: 2),
          Flexible(child: ListView.builder(
            itemCount: dummy.length,
            itemBuilder: _buildRecordList,
          ),)
        ],
      ),
    );
  }
}

//(REMAIN)Togglable Features in overview page
class PointWalletListView extends StatefulWidget {
  @override
  _PointWalletListViewState createState() => _PointWalletListViewState();
}

class _PointWalletListViewState extends State<PointWalletListView> {
  var _dummy = ['p1', 'p2', 'p3'];

  Widget _buildPointWallet(BuildContext context, int i) {
    return Container(
      width: double.infinity,
      color: Colors.blue,
      child: Column(
        children: <Widget>[
          ListTile(title: Text('네이버 페이 포인트'), subtitle: Text('메모할 내용'),),
          SizedBox(height: 5,),
          Center(child: Text('1,234,567 P'),),
          SizedBox(height: 55,),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _dummy.length,  
      itemBuilder: _buildPointWallet
    );
  }
}

//(WILLBEGONE)To Be Created
class AboutApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
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
      ),
    );
  }
}



