import 'package:flutter/material.dart';

main() => runApp(ExtraCreditApp());

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

  Widget _buildRecordList(BuildContext context, int i) {
    return ListTile(
      title:Text(dummy[i].toString()),
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
            onPressed: () {},
          ),
          IconButton(
            icon:Icon(Icons.question_answer),
            onPressed: () {},
          )
        ],
      ),
      body: Column(
        children: [
          Flexible(child: DataTable(
            columns: [
              DataColumn(label: Text('총수입'), numeric: true),
              DataColumn(label: Text('총지출'), numeric: true),
              DataColumn(label: Text('차액'), numeric: true)
            ],
            rows: [
              DataRow(cells: [
                DataCell(Text('10,000')),
                DataCell(Text('10,000')),
                DataCell(Text('10,000'))
              ])
            ],
          ),),
          Flexible(child: ListView.builder(
            itemCount: dummy.length,
            itemBuilder: _buildRecordList,
          ),)
        ],
      ),
    );
  }
}

class AddRecord extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}

class AboutApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}

class Sandbox extends StatefulWidget {
  @override
  _SandboxState createState() => _SandboxState();
}

class _SandboxState extends State<Sandbox> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}

