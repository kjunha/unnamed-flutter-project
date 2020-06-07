import 'package:flutter/material.dart';
import 'ContactDetailPage.dart';

class ContactListPage extends StatefulWidget {
  @override
  _ContactListPageState createState() => _ContactListPageState();
  
}

class _ContactListPageState extends State<ContactListPage> {
  var _contacts = ["Tony Stark", "Steve Rogers", "Doctor Banner", "Doctor Strange"];
  var _phone = ["0000", "111", "22222222", "3"];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Contacts Demo"),),
      body: _contacts != null
        ?ListView.builder(
          itemCount: _contacts.length,
          itemBuilder: _buildRow
        ):Center(child: CircularProgressIndicator(),),
    );
  }

  Widget _buildRow(BuildContext context, int i) {
    var c = _contacts[i];
    var p = _phone[i];
    return ListTile(
      leading: CircleAvatar(
        child: Text("A"),
        backgroundColor: Colors.blue,
      ),
      title: Wrap(
        spacing: 100,
        //mainAxisAlignment: MainAxisAlignment.spaceEvenly, >> for Row
        children: <Widget>[
        Text(c),
        Text(p)
      ],),
    );
  }

}