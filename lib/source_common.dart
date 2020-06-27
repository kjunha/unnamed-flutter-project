import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import './model/record.dart';
import './model/method.dart';
import 'package:intl/intl.dart';

final nf = NumberFormat("#,###.##");
final df = DateFormat('yyyy/MM/dd');
final _unit = ' 원';
final _point = ' P';

String buildCurrencyString(double value, bool isPoint) {
  return nf.format(value) + " " + (isPoint?_point:_unit);
}

double getMethodTotal(Method method) {
  return method.incSubtotal - method.expSubTotal;
}

//Convert method name to key for methods box
String toKey(String str) {
  List<int> bytes = utf8.encode(str);
  return bytes.toString();
}

//Build Tag UI for records
Widget tagUIProvider(String str, Color col, bool isIncome) {
  String text = str;
  Color textCol;
  bool isfill = true;
  if(str == null || str.length == 0) {
    isfill = false;
    if(isIncome) {
      text = '수입';
      textCol = Colors.green;
    } else {
      text = '지출';
      textCol = Colors.black;
    }
  } else if(text == '내부송금') {
    isfill = false;
    textCol = Colors.orange;
  }
  return Container(
    child: Center(child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textCol??Colors.white, letterSpacing: 1),)),
    width: 48,
    height: 22,
    decoration: BoxDecoration(border: Border.all(color:col, width:1), borderRadius: BorderRadius.circular(12), color: isfill?col:null),
  );
}
//i18n method type converter
String convertMethodType(String type) {
  Map multiLanguage = {
    "credit":"신용카드",
    "debit":"체크카드",
    "cash":"현금예산",
    "point":"포인트"
  };
  return multiLanguage[type];
}

//auto increment key finder(records)
//return -1 when key is not found
int findRecordKey(Record record) {
  Box box = Hive.box('records');
  List<dynamic> keysList = box.keys.toList();
  for(int i = 0; i < keysList.length; i++) {
    if(box.get(keysList[i]).hashCode == record.hashCode) {
      return keysList[i] as int;
    }
  }
  return -1;
}

//Group List Group bar
Widget buildGroupSeparator(dynamic groupByValue) {
  return Row(
    children: <Widget>[
      SizedBox(width: 20),
      Text(groupByValue, style: TextStyle(fontSize: 16),),
      SizedBox(width: 12),
      Expanded(child: Divider(color: Colors.black,),),
      SizedBox(width: 20),
    ],
  );
}

class RecordKeySet {
  Record record;
  int key;
  RecordKeySet(this.record, this.key);
}