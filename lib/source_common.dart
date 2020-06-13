import 'package:intl/intl.dart';

final _nf = NumberFormat("#,###.##");
final _unit = ' 원';
final _point = ' P';

String buildCurrencyString(double value, bool isPoint) {
  return _nf.format(value) + " " + (isPoint?_point:_unit);
}