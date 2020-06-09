import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'model/contact.dart';

class NewContractForm extends StatefulWidget {
  _NewContractFormState createState() => _NewContractFormState();
}

class _NewContractFormState extends State<NewContractForm> {
  final _formKey = GlobalKey<FormState>();
  
  String _name;
  String _age;

  void addContract(Contact contact) {
    final contactBox = Hive.box('contacts');
    if(contactBox != null) {
      print('box opened');
    }
    contactBox.add(contact);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Row(
            children: [
              Flexible(child:TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                onSaved: (value) => _name = value,
              )),
              SizedBox(width: 10,),
              Flexible(child: TextFormField(
                decoration: InputDecoration(labelText: 'Age'),
                onSaved: (value) => _age = value,
              ),)
            ],
          ),
          RaisedButton(
            child: Text('Add New'),
            onPressed: () {
              _formKey.currentState.save();
              final newContact = Contact(_name, int.parse(_age));
              addContract(newContact);
            },
          )
        ],
      ),
    );
  }
}