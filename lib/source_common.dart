import './model/record.dart';
import './model/method.dart';
import 'package:intl/intl.dart';

final _nf = NumberFormat("#,###.##");
final df = DateFormat('yyyy-MM-dd');
final _unit = ' 원';
final _point = ' P';

String buildCurrencyString(double value, bool isPoint) {
  return _nf.format(value) + " " + (isPoint?_point:_unit);
}

double getMethodTotal(Method method) {
  return method.incSubtotal - method.expSubTotal;
}

class RecordKeySet {
  Record record;
  int key;
  RecordKeySet(this.record, this.key);
}