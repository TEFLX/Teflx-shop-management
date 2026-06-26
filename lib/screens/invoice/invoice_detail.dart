import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';
import '../../database/db_helper.dart';

class InvoiceDetail extends StatefulWidget {
  final int orderId;

  InvoiceDetail({required this.orderId});

  @override
  _InvoiceDetailState createState() => _InvoiceDetailState();
}

class _InvoiceDetailState extends State<InvoiceDetail> {
  DBHelper db = DBHelper();

  List items = [];
  Map<String, dynamic>? order;

  @override
  void initState() {
    super.initState();
    load();
  }

  // 🔄 LOAD DATA
  load() async {
    final database = await db.db;

    List o = await database.query(
      'orders',
      where: 'id = ?',
      whereArgs: [widget.orderId],
    );

    if (o.isNotEmpty) order = o.first;

    items = await database.query(
      'order_items',
      where: 'order_id = ?',
      whereArgs: [widget.orderId],
    );

    setState(() {});
  }

  // 📄 GENERATE PDF
  Future<void> generatePdf() async {
    final pdf = pw.Document();

    // 🔥 LOAD LOGO
    final logo = pw.MemoryImage(
      (await rootBundle.load('assets/logo.png')).buffer.asUint8List(),
    );

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [

              // 🔥 HEADER
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Image(logo, height: 60),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text("Girish Chand karyana store",
                          style: pw.TextStyle(fontSize: 18)),
                      pw.Text("Ambari,UP"),
                      // pw.Text("Phone: 9026861300"),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 10),
              pw.Divider(),

              // 🧾 CUSTOMER DETAILS
              pw.Text("Invoice ID: ${order?['id']}"),
              pw.Text("Customer: ${order?['customer']}"),
              pw.Text("Date: ${order?['date']}"),

              pw.SizedBox(height: 10),

              // 📦 ITEMS TABLE
              pw.Table.fromTextArray(
                headers: ["Item", "Qty", "Price", "Total"],
                data: items.map((i) {
                  return [
                    i['name'],
                    i['qty'].toString(),
                    i['price'].toString(),
                    i['total'].toString(),
                  ];
                }).toList(),
              ),

              pw.SizedBox(height: 10),

              // 💰 TOTALS
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("Total: ${order?['total']}"),
                    pw.Text("Paid: ${order?['paid']}"),
                    pw.Text("Due: ${order?['due']}"),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              pw.Center(child: pw.Text("Thank You Visit Again!")),
            ],
          );
        },
      ),
    );

    // 🔥 OPEN PRINT / SAVE / SHARE
    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Invoice Detail"),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: generatePdf,
          )
        ],
      ),
      body: items.isEmpty
          ? Center(child: Text("No Data"))
          : Column(
        children: [

          // 🧾 HEADER UI
          Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Customer: ${order?['customer']}"),
                Text("Total: ₹${order?['total']}"),
                Text("Paid: ₹${order?['paid']}"),
                Text("Due: ₹${order?['due']}"),
              ],
            ),
          ),

          Divider(),

          // 📦 ITEMS
          Expanded(
            child: ListView(
              children: items.map((i) {
                return ListTile(
                  title: Text(i['name']),
                  subtitle:
                  Text("${i['qty']} x ₹${i['price']}"),
                  trailing: Text("₹${i['total']}"),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}