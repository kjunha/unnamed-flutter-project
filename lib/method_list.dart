import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:material_segmented_control/material_segmented_control.dart';
import './drawer_common.dart';
import './source_common.dart';
import './model/method.dart';

class MethodList extends StatefulWidget {
  @override
  _MethodListState createState() => _MethodListState();
}

class _MethodListState extends State<MethodList> {
  //final fields
  final Map<int, Widget> _children = {
    0:Text('전체'),
    1:Text('신용카드'),
    2:Text('체크카드'),
    3:Text('현금예산'),
    4:Text('포인트'),
  };

  //state fields
  List<Method> methodList;
  var _segctrSelection;

  @override
  void initState() {
    super.initState();
    methodList = [];
    _segctrSelection = 0;
    Box box = Hive.box('methods');
    List<dynamic> keys = box.keys.toList();
    for (dynamic key in keys) {
      methodList.add(box.get(key));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('거래수단 관리'),  backgroundColor: Colors.blue,),
      backgroundColor: Colors.grey[300],
      drawer: loadDrawer(context),
      body: Column(
        children: <Widget>[
          Card(child:Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(height: 5,),
              Row(children: <Widget>[SizedBox(width: 10,),Text('거래수단 종류별 정렬', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),],),
              Container(
                padding: EdgeInsets.symmetric(vertical:10, horizontal:0),
                width: double.infinity,
                child: MaterialSegmentedControl(
                  children: _children,
                  selectionIndex: _segctrSelection,
                  selectedColor: Colors.blueAccent,
                  unselectedColor: Colors.white,
                  borderRadius: 5.0,
                  onSegmentChosen: (index) {
                    setState(() {
                      _segctrSelection = index;
                    });
                  },
                ),
              ),
            ],
          ),),
          Flexible(child: ListView.builder(
            itemCount: methodList.length,
            itemBuilder: _buildPointWallet,
          ),)
        ],
      ),
    );
  }


  Widget _buildPointWallet(BuildContext context, int i) {
    return Card(child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: <Widget>[
      Container(width:280, child: Card(
        color: Color(methodList[i].colorHex),
        margin: EdgeInsets.symmetric(vertical: 10,horizontal:10),
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text(methodList[i].name, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),), 
              subtitle: Text(methodList[i].description, style: TextStyle(color: Colors.grey[200]),), 
            ),
            SizedBox(height: 10,),
            Center(child: Text(
              buildCurrencyString(getMethodTotal(methodList[i]), methodList[i].type == 'point'), 
              style: TextStyle(fontSize: 23, color: Colors.white, fontWeight: FontWeight.bold),
            ),),
            SizedBox(height: 60,),
          ],
        ),
      )),
      Flexible(child:Container(
        margin: EdgeInsets.symmetric(vertical: 10, horizontal:0), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Text('거래수단 종류:',style: TextStyle(fontWeight: FontWeight.bold),), 
            Center(child:Text(methodList[i].type)),
            Text('생성일자:',style: TextStyle(fontWeight: FontWeight.bold),), 
            Center(child:Text(df.format(methodList[i].dateCreated))),
            ButtonTheme(
              child: RaisedButton(
                child: Text('수정'),
                color: Colors.blue,
                onPressed: () {},
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            ),
            ButtonTheme(
              child: RaisedButton(
                child: Text('삭제'),
                color: Colors.red,
                onPressed: () {},
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            ),
          ],
        ),
      )),
      SizedBox(width: 10,),
    ],),);
  }
}