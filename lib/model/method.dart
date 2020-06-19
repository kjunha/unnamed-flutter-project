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
  String colorHex;
  @HiveField(5)
  bool isIncluded;
  @HiveField(6)
  bool isMain;
  
  Method(this.name, this.description, this.type, this.colorHex, this.isIncluded, this.isMain);
}