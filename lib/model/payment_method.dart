import 'package:flutter/material.dart';

class PaymentMethod {
  String name;
  String description;
  String type;
  Color colorScheme;
  bool isIncluded;
  bool isMain;
  
  PaymentMethod(this.name, this.description, this.colorScheme, this.isIncluded, this.isMain);
}