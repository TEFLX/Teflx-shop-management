import 'package:flutter/material.dart';
import '../../database/db_helper.dart';

class AddEditProduct extends StatefulWidget {
  final Map? product;

  AddEditProduct({this.product});

  @override
  _AddEditProductState createState() => _AddEditProductState();
}

class _AddEditProductState extends State<AddEditProduct> {
  DBHelper db = DBHelper();

  final name = TextEditingController();
  final retail = TextEditingController();
  final wholesale = TextEditingController();
  final purchase = TextEditingController();
  final stock = TextEditingController();

  String unit = "pcs";

  bool get isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();

    if (isEdit) {
      var p = widget.product!;
      name.text = p['name'].toString();
      retail.text = p['retail_price'].toString();
      wholesale.text = p['wholesale_price'].toString();
      purchase.text = p['purchase_price'].toString();
      stock.text = p['stock'].toString();
      unit = p['unit'] ?? "pcs";
    }
  }

  save() async {
    var data = {
      'name': name.text.trim(),
      'category': 'General',

      // ✅ SAFE DOUBLE PARSE
      'retail_price': double.tryParse(retail.text) ?? 0,
      'wholesale_price': double.tryParse(wholesale.text) ?? 0,
      'purchase_price': double.tryParse(purchase.text) ?? 0,

      // 🔥 FIXED (DOUBLE INSTEAD OF INT)
      'stock': double.tryParse(stock.text) ?? 0,

      'unit': unit,
    };

    if (isEdit) {
      await db.updateProduct(widget.product!['id'], data);
    } else {
      await db.insertProduct(data);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(isEdit ? "Update Product" : "Add Product")),
      body: ListView(
        padding: EdgeInsets.all(10),
        children: [
          TextField(
            controller: name,
            decoration: InputDecoration(labelText: "Name"),
          ),

          DropdownButton(
            value: unit,
            items: [
              DropdownMenuItem(value: "pcs", child: Text("PCS")),
              DropdownMenuItem(value: "kg", child: Text("KG")),
            ],
            onChanged: (v) => setState(() => unit = v.toString()),
          ),

          TextField(
            controller: retail,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: "Retail Price"),
          ),

          TextField(
            controller: wholesale,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: "Wholesale Price"),
          ),

          TextField(
            controller: purchase,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: "Purchase Price"),
          ),

          TextField(
            controller: stock,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: "Stock"),
          ),

          SizedBox(height: 10),

          ElevatedButton(
            onPressed: save,
            child: Text(isEdit ? "UPDATE" : "SAVE"),
          )
        ],
      ),
    );
  }
}