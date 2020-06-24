import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';

import './model/record.dart';
import './model/method.dart';
import 'package:intl/intl.dart';

final nf = NumberFormat("#,###.##");
final df = DateFormat('yyyy-MM-dd');
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
  }
  return Container(
    child: Center(child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textCol??Colors.white, letterSpacing: 1),)),
    width: 48,
    height: 22,
    decoration: BoxDecoration(border: Border.all(color:col, width:1), borderRadius: BorderRadius.circular(12), color: isfill?col:null),
  );
}

class RecordKeySet {
  Record record;
  int key;
  RecordKeySet(this.record, this.key);
}