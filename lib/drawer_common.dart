import 'package:flutter/material.dart';

Drawer loadDrawer(BuildContext context) {
  return Drawer(
    child: ListView(
      // Important: Remove any padding from the ListView.
      padding: EdgeInsets.zero,
      children: <Widget>[
        Container(width: double.infinity, height: 100, color: Colors.blue, padding: EdgeInsets.fromLTRB(30, 50, 0, 0),
        child: Text('메인메뉴', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),),),
        ListTile(
          title: Text('홈', style: TextStyle(fontSize: 18),),
          leading: Icon(Icons.account_circle),
          onTap: () {
            Navigator.popUntil(context, (route) => route.isFirst);
            if(Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        Divider(thickness: 3,height: 3,),
        ListTile(
          title: Text('수입 및 지출내역 추가', style: TextStyle(fontSize: 18),),
          leading: Icon(Icons.account_circle),
          onTap: () {
            Navigator.pushNamed(context, '/add');
          },
        ),
        Divider(thickness: 3,height: 3,),
        ListTile(
          title: Text('거래수단 추가', style: TextStyle(fontSize: 18),),
          leading: Icon(Icons.account_circle),
          onTap: () {
            Navigator.pushNamed(context, '/new');
          },
        ),
        Divider(thickness: 3,height: 3,),
        ListTile(
          title: Text('수입 및 지출내역 편집', style: TextStyle(fontSize: 18),),
          leading: Icon(Icons.account_circle),
          onTap: () {
            Navigator.pushNamed(context, '/edit');
          },
        ),
        Divider(thickness: 3,height: 3,),
        ListTile(
          title: Text('거래수단 관리', style: TextStyle(fontSize: 18),),
          leading: Icon(Icons.account_circle),
          onTap: () {
            Navigator.pushNamed(context, '/manage');
          },
        ),
        Divider(thickness: 3,height: 3,),
        ListTile(
          title: Text('설정', style: TextStyle(fontSize: 18),),
          leading: Icon(Icons.account_circle),
          onTap: () {
            Navigator.pushNamed(context, '/sand');
          },
        ),
        Divider(thickness: 3,height: 3,),
        

      ],
    ),
  );
}