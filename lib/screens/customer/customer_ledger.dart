import 'package:flutter/material.dart';
import '../../database/db_helper.dart';

class CustomerLedger extends StatefulWidget {
  final String name;

  CustomerLedger({required this.name});

  @override
  _CustomerLedgerState createState() => _CustomerLedgerState();
}

class _CustomerLedgerState extends State<CustomerLedger> {
  DBHelper db = DBHelper();

  List orders = [];
  List payments = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  load() async {
    orders = await db.getCustomerOrders(widget.name);
    payments = await db.getPayments(widget.name);
    setState(() {});
  }

  addPaymentDialog() async {
    TextEditingController controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Add Payment"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: "Amount"),
        ),
        actions: [
          ElevatedButton(
            child: Text("Save"),
            onPressed: () async {
              double amt = double.tryParse(controller.text) ?? 0;
              await db.addPayment(widget.name, amt);
              Navigator.pop(context);
              load();
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        actions: [
          IconButton(
            icon: Icon(Icons.payment),
            onPressed: addPaymentDialog,
          )
        ],
      ),
      body: Column(
        children: [
          Text("Orders", style: TextStyle(fontSize: 18)),

          Expanded(
            child: ListView(
              children: orders.map((o) {
                return ListTile(
                  title: Text("₹${o['total']}"),
                  subtitle: Text(o['date']),
                );
              }).toList(),
            ),
          ),

          Divider(),

          Text("Payments", style: TextStyle(fontSize: 18)),

          Expanded(
            child: ListView(
              children: payments.map((p) {
                return ListTile(
                  title: Text("Paid ₹${p['amount']}"),
                  subtitle: Text(p['date']),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}