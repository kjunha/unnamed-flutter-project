import 'package:hive/hive.dart';

part 'method.g.dart';
@HiveType(typeId: 1)
class Method {
  @HiveField(1)
  String name;
  @HiveField(2)
  String description;
  @HiveField(3)
  String type;
  @HiveField(4)
  int colorHex;
  @HiveField(5)
  bool isIncluded;
  @HiveField(6)
  bool isMain;
  @HiveField(7)
  double incSubtotal; //Subtotal for income
  @HiveField(8)
  double expSubTotal; //Subtotal for expenditure
  @HiveField(9)
  DateTime dateCreated;
  
  Method(this.name, this.description, this.type, this.colorHex, this.isIncluded, this.isMain, this.incSubtotal, this.expSubTotal, this.dateCreated);
}