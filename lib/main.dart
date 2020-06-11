import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import './add_record.dart';

//Sandbox Dependency
import 'package:material_segmented_control/material_segmented_control.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

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
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {},
        ),
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
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
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

  Widget _buildPointWallet(BuildContext context, int i) {
    return Container(
      width: double.infinity,
      color: _dummy[i],
      margin: EdgeInsets.symmetric(vertical: 3,horizontal:25),
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text('네이버 페이 포인트', style: TextStyle(color: Colors.white),), 
            subtitle: Text('메모할 내용', style: TextStyle(color: Colors.grey),), 
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(child: ListView.builder(
      itemCount: _dummy.length,  
      itemBuilder: _buildPointWallet,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
    ),);
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
    final _formKey = GlobalKey<FormBuilderState>();
    var _currentSelection = -1;
    var _date = DateTime.now();
    Map<int, Widget> _children = {
      -1:Text('지출 기록'),
      1: Text('수입 기록')
    };
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Sandbox'), backgroundColor: Colors.orange,),
        body:Column(
          children: [
            //Segmented Control
            Container(
              margin: EdgeInsets.symmetric( vertical: 20, horizontal: 20),
              width: double.infinity,
              child: MaterialSegmentedControl(
                children: _children,
                selectionIndex: _currentSelection,
                selectedColor: Colors.blueAccent,
                unselectedColor: Colors.white,
                borderRadius: 5.0,
                onSegmentChosen: (index) {
                  setState(() {
                    _currentSelection = index;
                    print('chisen selection: ' + _currentSelection.toString());
                  });
                },
              ),
            ),
            FormBuilder(
              key: _formKey,
              child: Column(
                children: [
                  FormBuilderDateTimePicker(
                    attribute: "date",
                    inputType: InputType.date,
                    format: DateFormat("yyyy-MM-dd"),
                    decoration:
                        InputDecoration(labelText: "Appointment Time"),
                  ),
                  FormBuilderTextField(
                    attribute: "age",
                    decoration: InputDecoration(labelText: "Age"),
                    validators: [
                      FormBuilderValidators.numeric(),
                      FormBuilderValidators.max(70),
                    ],
                  ),
                  FormBuilderDropdown(
                    attribute: "gender",
                    decoration: InputDecoration(labelText: "Gender"),
                    // initialValue: 'Male',
                    hint: Text('Select Gender'),
                    validators: [FormBuilderValidators.required()],
                    items: ['Male', 'Female', 'Other']
                      .map((gender) => DropdownMenuItem(
                        value: gender,
                        child: Text("$gender")
                    )).toList(),
                  ),
                ],
              ),
            )
          ],
        )
      ),
    );
  }
}



