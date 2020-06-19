import 'package:hive/hive.dart';
import '../source_common.dart';
import './method.dart';

part 'record.g.dart';

@HiveType(typeId: 0)
class Record {
  @HiveField(0)
  DateTime date;
  @HiveField(1)
  double amount;
  @HiveField(2)
  String description;
  @HiveField(3)
  Method method;
  @HiveField(4)
  String tag;

  Record(this.date, this.description, this.amount, this.method, this.tag);

  @override
  String toString() {
    return '날짜: ' + df.format(date) + ', 내역: ' + description + ', 금액: ' + buildCurrencyString(amount, false) + ', 수단: ' + method.name + ', 테그: ' + tag; 
  }
}