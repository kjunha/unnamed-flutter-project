class ExpenditureData {
  DateTime date;
  String title;
  double amount;
  String tag;

  ExpenditureData({date, this.title, amount, this.tag}) {
    this.date = DateTime.parse(date);
    this.amount = double.parse(amount);
  }

  static List<ExpenditureData> getExpenditureList() {
    return <ExpenditureData>[
      ExpenditureData(date: "2020-05-30", title: "shopping", amount: "150000.00", tag: "A"),
      ExpenditureData(date: "2020-06-01", title: "travel", amount: "3000.0532", tag: "B"),
      ExpenditureData(date: "2020-06-03", title: "point", amount: "+2500", tag: "A"),
      ExpenditureData(date: "2020-06-04", title: "event A", amount: "10000000", tag: "C"),
      ExpenditureData(date: "2020-06-05", title: "event B", amount: "-500"),
    ];
  }

}