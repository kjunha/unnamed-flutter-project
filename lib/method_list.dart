import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:material_segmented_control/material_segmented_control.dart';
import './bottom_nav_common.dart';
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
  var _segctrSelection;

  @override
  void initState() {
    super.initState();
    _segctrSelection = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('거래수단 관리'),  backgroundColor: Colors.blue,),
      backgroundColor: Colors.grey[300],
      bottomNavigationBar: loadBottomNavigator(context),
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
          
          ValueListenableBuilder(
            valueListenable: Hive.box('methods').listenable(),
            builder: (context, box,  _) {
              if(box.values.isEmpty) {
                return Center(child: Text('여기에 보유한 거래수단이 보여집니다.'),);
              }
              return Flexible(child: ListView.builder(
                itemCount: box.length,
                itemBuilder: (context, i) =>_buildPointWallet(context, i, box),
              ),);
            }
          )
        ],
      ),
    );
  }


  Widget _buildPointWallet(BuildContext context, int i, Box box) {
    Method currentMethod = box.getAt(i);
    return Card(child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: <Widget>[
      Container(width:280, child: Card(
        color: Color(currentMethod.colorHex),
        margin: EdgeInsets.symmetric(vertical: 10,horizontal:10),
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text(currentMethod.name, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),), 
              subtitle: Text(currentMethod.description, style: TextStyle(color: Colors.grey[200]),), 
            ),
            SizedBox(height: 10,),
            Center(child: Text(
              buildCurrencyString(getMethodTotal(currentMethod), currentMethod.type == 'point'), 
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
            Center(child:Text(convertMethodType(currentMethod.type)),),
            Text('생성일자:',style: TextStyle(fontWeight: FontWeight.bold),), 
            Center(child:Text(df.format(currentMethod.dateCreated))),
            ButtonTheme(
              child: RaisedButton(
                child: Text('수정'),
                color: Colors.blue,
                onPressed: () {
                  Navigator.pushNamed(context, '/methods/edit', arguments: currentMethod);
                },
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            ),
            ButtonTheme(
              child: RaisedButton(
                child: Text('삭제'),
                color: Colors.red,
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    child: AlertDialog(
                      content: Text('거래수단과 함께 등록된 수입 및 지출내역도 모두 삭제됩니다. 정말로 삭제하시겠습니까?'),
                      actions: <Widget>[
                        FlatButton(
                          child: Text('아니오'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        FlatButton(
                          child: Text('네'),
                          onPressed: () {
                            List<dynamic> recordKeys = currentMethod.recordKeys;
                            print('key check' + recordKeys.toString());
                            for(int i = 0; i < recordKeys.length; i++) {
                              Hive.box('records').delete(recordKeys[i]);
                            }
                            Hive.box('methods').delete(currentMethod.name);
                            Navigator.of(context).pop();
                          },
                        )
                      ],
                    )
                  );
                },
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