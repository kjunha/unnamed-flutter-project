class Record {
  DateTime date;
  double balance;
  String note;
  String method;

  Record(String _date, String _balance, this.note, this.method) {
    this.date = DateTime.parse(_date);
    this.balance = double.parse(_balance);
  }
}