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
  final _scaffoldKey = GlobalKey<ScaffoldState>();
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

  Widget _buildPointWallet(BuildContext context, int i, List<Method> filtered) {
    Method currentMethod = filtered[i];

    return Card(margin: EdgeInsets.fromLTRB(20, 5, 20, 10), child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: <Widget>[
      Container(width:255, child: Card(
        color: Color(currentMethod.colorHex),
        margin: EdgeInsets.symmetric(vertical: 10,horizontal:10),
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text(currentMethod.name??'', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),), 
              subtitle: Text(currentMethod.description??'', style: TextStyle(color: Colors.grey[200]),), 
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
                child: Text('수정', style: TextStyle(color: Colors.white),),
                color: Colors.grey,
                onPressed: () async {
                  final result = await Navigator.pushNamed(context, '/methods/edit', arguments: currentMethod);
                  if(result != null && result == true) {
                    _scaffoldKey.currentState
                      ..removeCurrentSnackBar()
                      ..showSnackBar(SnackBar(content: Text('수정된 거래수단의 정보를 저장했습니다.'),));
                  }
                },
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            ),
            ButtonTheme(
              child: RaisedButton(
                child: Text('삭제', style: TextStyle(color: Colors.white),),
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
                            for(int i = 0; i < recordKeys.length; i++) {
                              Hive.box('records').delete(recordKeys[i]);
                            }
                            Hive.box('methods').delete(toKey(currentMethod.name));
                            Navigator.of(context).pop();
                            _scaffoldKey.currentState
                              ..removeCurrentSnackBar()
                              ..showSnackBar(SnackBar(content: Text('삭제되었습니다.'),));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        title: Text('거래수단 관리', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),), 
        backgroundColor: Colors.white,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/new');
            },
          )
        ],
      ),
      bottomNavigationBar: loadBottomNavigator(context),
      body: Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(color: Colors.white, gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.centerLeft, colors: [Color(0xff5b99fc), Color(0xffb991fc)])),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(5),
              color: Colors.white,
              child:Column(
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
                      borderRadius: 25.0,
                      onSegmentChosen: (index) {
                        setState(() {
                          _segctrSelection = index;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            ValueListenableBuilder(
              valueListenable: Hive.box('methods').listenable(),
              builder: (context, box,  _) {
                if(box.values.isEmpty) {
                  return Center(child: Text('여기에 보유한 거래수단이 보여집니다.'),);
                }
                List<Method> filtered = [];
                List keys = box.keys.toList();
                for(dynamic key in keys) {
                  switch(_segctrSelection) {
                    case 1:
                      if(box.get(key).type == "credit") filtered.add(box.get(key));
                      break;
                    case 2:
                      if(box.get(key).type == "debit") filtered.add(box.get(key));
                      break;
                    case 3:
                      if(box.get(key).type == "cash") filtered.add(box.get(key));
                      break;
                    case 4:
                      if(box.get(key).type == "point") filtered.add(box.get(key));
                      break;
                    default:
                      filtered.add(box.get(key));
                      break;
                  }
                }
                return Flexible(child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, i) =>_buildPointWallet(context, i, filtered),
                ),);
              }
            )
          ],
        ),
      ),
    );
  }
}