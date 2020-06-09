import 'package:finance_point/new_contact.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'model/contact.dart';


class ContactPage extends StatefulWidget {
  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Hive Tutorial'),
        ),
        body: Column(
          children: <Widget>[
            Expanded(child: _buildListView()),
            NewContractForm()
          ],
        ));
  }

  Widget _buildListView() {
    return WatchBoxBuilder(
      box: Hive.box('contacts'),
      builder: (context, contactsBox) {
        return ListView.builder(
          itemCount: contactsBox.length,
          itemBuilder: (context, index) {
            final contact = contactsBox.getAt(index) as Contact;
            return ListTile(
              title: Text(contact.name),
              subtitle: Text(contact.age.toString()),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  contactsBox.deleteAt(index);
                },
              )
            );
          },
        );
      },
    );
  }
}