import '../source_common.dart';
class Record {
  DateTime date;
  double amount;
  String description;
  String method;
  String tag;

  //TODO add optional param
  Record(this.date, this.description, this.amount, this.method, this.tag);

  @override
  String toString() {
    return '날짜: ' + df.format(date) + ', 내역: ' + description + ', 금액: ' + buildCurrencyString(amount, false) + ', 수단: ' + method + ', 테그: ' + tag; 
  }
}