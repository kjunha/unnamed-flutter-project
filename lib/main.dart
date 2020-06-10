import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';

//main() => runApp(ExtraCreditApp());
//Sandbox
main() => runApp(Sandbox());

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
            onPressed: () {},
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
  var dateInput = DateTime.now();
  final df = DateFormat('yyyy-MM-dd');
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Add New Record'),backgroundColor: Colors.orange,),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.symmetric( vertical: 0, horizontal: 30),
              child: Form(
                child: Column(
                  // crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Row(
                    //   crossAxisAlignment: CrossAxisAlignment.start, 
                    //   children: [SizedBox(width: 18,) ,Text('Input Label', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),),]),
                    // SizedBox(height: 5,),
                    // Divider(thickness: 2,),
                    Row(children: [
                      Flexible(child: TextFormField(
                        readOnly: true,
                        initialValue: df.format(dateInput),
                        decoration: InputDecoration(
                          labelText: '날짜',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide())
                        ),
                      )),
                      SizedBox(width: 15,),
                      RaisedButton(child: Text('button'), onPressed: () {showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));},)
                    ],),
                    SizedBox(height: 15,),
                    TextFormField(
                      readOnly: true,
                      initialValue: df.format(dateInput),
                      decoration: InputDecoration(
                        labelText: '날짜',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide())
                      ),
                    ),
                    SizedBox(height: 15,),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: '금액',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide())
                      ),
                    ),
                    SizedBox(height: 15,),
                    
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: '결제수단',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide())
                      ),
                    ),
                    SizedBox(height: 15,),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: '상세내역',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide())
                      ),
                    ),
                    SizedBox(height: 30,),
                    
                    ButtonTheme(
                      minWidth: double.infinity,
                      height: 50,
                      child: RaisedButton(
                        child: Text('기록 추가'),
                        color: Colors.green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        onPressed: () {},
                      ),
                    )
                  ],
                ),
              )
            ),

          ],
        ),
      ),
    );
  }
}



