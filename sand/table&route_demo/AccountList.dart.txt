import 'ExpenditureData.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'AddRecord.dart';

void main() => runApp(AccountList());

class AccountList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Account Book",
      home: AccountListView(),
      initialRoute: '/',
      routes: {
        '/add': (context) => AddRecord()
      },
    );
  }
}

class AccountListView extends StatefulWidget {
  @override
  _AccountListViewState createState() => _AccountListViewState();
}

class _AccountListViewState extends State<AccountListView> {
  List<ExpenditureData> expenditureDataList;
  @override
  void initState() {
    super.initState();
    this.expenditureDataList = ExpenditureData.getExpenditureList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Account Book"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              print("add pressed");
              Navigator.pushNamed(context, '/add');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 15,
          columns: [
            DataColumn(
              label: Text("날짜"),
              numeric: false,
            ),
            DataColumn(
              label: Text("항목"),
              numeric: false
            ),
            DataColumn(
              label: Text("금액"),
              numeric: true
            ),
            DataColumn(
              label: Text("테그"),
              numeric: false
            ),
            DataColumn(
              label: Text("수정"),
              numeric: false
            ),
            DataColumn(
              label: Text("삭제"),
              numeric: false
            )
          ],
          rows: expenditureDataList.map(
            (item) => DataRow(
              cells: [
                DataCell(
                  Text(DateFormat('yyyy/MM/dd').format(item.date))
                ),
                DataCell(
                  Text(item.title)
                ),
                DataCell(
                  Text(NumberFormat("#.00").format(item.amount))
                ),
                DataCell(
                  Text(item.tag??"-")
                ),
                DataCell(
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {print("edit pressed");},
                  )
                ),
                DataCell(
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {print("delete pressed");}
                  )
                )
              ]
            )
          ).toList(),
        ),
      ),
    );
  }
}