import 'package:flutter/material.dart';
import '../../database/db_helper.dart';

class AddCustomer extends StatefulWidget {
  final Map? customer;

  AddCustomer({this.customer});

  @override
  _AddCustomerState createState() => _AddCustomerState();
}

class _AddCustomerState extends State<AddCustomer> {
  DBHelper db = DBHelper();

  final name = TextEditingController();
  final phone = TextEditingController();
  final address = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.customer != null) {
      name.text = widget.customer!['name'];
      phone.text = widget.customer!['phone'];
      address.text = widget.customer!['address'];
    }
  }

  save() async {
    var data = {
      'name': name.text,
      'phone': phone.text,
      'address': address.text,
      'total': 0,
      'due': 0,
    };

    if (widget.customer != null) {
      await db.updateProduct(widget.customer!['id'], data); // reuse logic
    } else {
      await db.insertCustomer(data);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Customer")),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            TextField(controller: name, decoration: InputDecoration(labelText: "Name")),
            TextField(controller: phone, decoration: InputDecoration(labelText: "Phone")),
            TextField(controller: address, decoration: InputDecoration(labelText: "Address")),
            SizedBox(height: 10),
            ElevatedButton(onPressed: save, child: Text("Save"))
          ],
        ),
      ),
    );
  }
}