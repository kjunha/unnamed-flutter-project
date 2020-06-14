import 'package:hive/hive.dart';
import '../source_common.dart';

part 'record.g.dart';

@HiveType()
class Record {
  @HiveField(0)
  DateTime date;
  @HiveField(1)
  double amount;
  @HiveField(2)
  String description;
  @HiveField(3)
  String method;
  @HiveField(4)
  String tag;

  Record(this.date, this.description, this.amount, this.method, this.tag);

  @override
  String toString() {
    return '날짜: ' + df.format(date) + ', 내역: ' + description + ', 금액: ' + buildCurrencyString(amount, false) + ', 수단: ' + method + ', 테그: ' + tag; 
  }
}