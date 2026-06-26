import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import 'add_customer.dart';
import 'customer_ledger.dart';

class CustomerList extends StatefulWidget {
  @override
  _CustomerListState createState() => _CustomerListState();
}

class _CustomerListState extends State<CustomerList> {
  DBHelper db = DBHelper();

  List customers = [];
  List filtered = [];

  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    load();
  }

  // 🔄 LOAD
  load() async {
    customers = await db.getCustomers();
    filtered = List.from(customers);
    setState(() {});
  }

  // 🔍 SEARCH
  search(String value) {
    filtered = customers
        .where((c) => c['name']
        .toString()
        .toLowerCase()
        .contains(value.toLowerCase()))
        .toList();

    setState(() {});
  }

  // 🔢 FORMAT
  String formatNumber(dynamic val) {
    double value = (val ?? 0).toDouble();
    if (value % 1 == 0) {
      return value.toInt().toString();
    } else {
      return value.toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [

            // 🔥 HEADER WITH LOGO
            Container(
              padding: EdgeInsets.all(12),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  // LEFT SIDE (LOGO + NAME)
                  Row(
                    children: [
                      Image.asset(
                        'assets/logo.png',
                        height: 70,
                      ),
                      SizedBox(width: 10),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "My Shop",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text("Customer Management"),
                        ],
                      ),
                    ],
                  ),

                  // RIGHT SIDE (+ ADD)
                  ElevatedButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => AddCustomer()),
                      );
                      load();
                    },
                    child: Text("+ Add Customer"),
                  ),
                ],
              ),
            ),

            // 🔍 SEARCH
            Padding(
              padding: EdgeInsets.all(8),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Search customer...",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: search,
              ),
            ),

            // 📋 TABLE
            Expanded(
              child: filtered.isEmpty
                  ? Center(child: Text("No Customers Found"))
                  : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 20,
                  headingRowColor:
                  MaterialStateProperty.all(Colors.grey[200]),
                  columns: [
                    DataColumn(label: Text("Name")),
                    DataColumn(label: Text("Phone")),
                    DataColumn(label: Text("Address")),
                    DataColumn(label: Text("Total")),
                    DataColumn(label: Text("Due")),
                  ],
                  rows: filtered.map((c) {
                    return DataRow(
                      cells: [
                        DataCell(Text(c['name'].toString())),
                        DataCell(Text(c['phone'].toString())),
                        DataCell(Text(c['address'].toString())),
                        DataCell(Text("₹${formatNumber(c['total'])}")),
                        DataCell(
                          Text(
                            "₹${formatNumber(c['due'])}",
                            style: TextStyle(
                              color: (c['due'] ?? 0) > 0
                                  ? Colors.red
                                  : Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],

                      // 🔥 OPEN LEDGER
                      onSelectChanged: (_) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CustomerLedger(name: c['name']),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}