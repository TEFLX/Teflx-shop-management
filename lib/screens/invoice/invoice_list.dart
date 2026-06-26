import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import 'invoice_detail.dart';

class InvoiceList extends StatefulWidget {
  @override
  _InvoiceListState createState() => _InvoiceListState();
}

class _InvoiceListState extends State<InvoiceList> {
  DBHelper db = DBHelper();
  List orders = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  load() async {
    final database = await db.db;
    orders = await database.query('orders', orderBy: 'id DESC');
    setState(() {});
  }

  String format(dynamic v) {
    double val = (v ?? 0).toDouble();
    return val % 1 == 0 ? val.toInt().toString() : val.toString();
  }

  // 🔥 DELETE FUNCTION
  deleteInvoice(int id) async {
    bool confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Delete Invoice"),
        content: Text("Are you sure?"),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            child: Text("Delete"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await db.deleteOrder(id);
      load();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invoice Deleted")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [

            // 🔥 HEADER
            Container(
              padding: EdgeInsets.all(12),
              color: Colors.white,
              child: Row(
                children: [
                  Image.asset('assets/logo.png', height: 60),
                  SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "GC KARYANA STORE",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("Invoice List"),
                    ],
                  ),
                ],
              ),
            ),

            Divider(),

            // 📊 TABLE
            Expanded(
              child: orders.isEmpty
                  ? Center(child: Text("No Invoices"))
                  : SingleChildScrollView(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 20,
                    headingRowColor:
                    MaterialStateProperty.all(Colors.grey[200]),
                    columns: [
                      DataColumn(label: Text("ID")),
                      DataColumn(label: Text("Customer")),
                      DataColumn(label: Text("Total")),
                      DataColumn(label: Text("Paid")),
                      DataColumn(label: Text("Due")),
                      DataColumn(label: Text("Date")),
                      DataColumn(label: Text("Action")), // 🔥 NEW
                    ],
                    rows: orders.map((o) {
                      return DataRow(
                        cells: [
                          DataCell(Text(o['id'].toString())),
                          DataCell(Text(o['customer'])),

                          DataCell(Text("₹${format(o['total'])}")),

                          DataCell(
                            Text(
                              "₹${format(o['paid'])}",
                              style: TextStyle(color: Colors.green),
                            ),
                          ),

                          DataCell(
                            Text(
                              "₹${format(o['due'])}",
                              style: TextStyle(
                                color: (o['due'] ?? 0) > 0
                                    ? Colors.red
                                    : Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          DataCell(Text(o['date'].toString())),

                          // 🔥 DELETE BUTTON
                          DataCell(
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  deleteInvoice(o['id']),
                            ),
                          ),
                        ],
                        onSelectChanged: (_) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  InvoiceDetail(orderId: o['id']),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}