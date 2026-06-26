import 'package:flutter/material.dart';

class InvoiceScreen extends StatelessWidget {
  final List cart;
  final double total;
  final double finalTotal;
  final String customer;

  InvoiceScreen({
    required this.cart,
    required this.total,
    required this.finalTotal,
    required this.customer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Invoice")),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // 🔥 HEADER (LOGO + SHOP INFO)
              Row(
                children: [
                  Image.asset(
                    'assets/logo.png',
                    height: 70, // 🔥 bigger logo
                  ),
                  SizedBox(width: 10),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "GC KARYANA STORE",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("AMABRI"),
                      Text("Phone:              "),
                    ],
                  )
                ],
              ),

              SizedBox(height: 10),
              Divider(),

              // 👤 CUSTOMER
              Text(
                "Customer: $customer",
                style: TextStyle(fontSize: 16),
              ),

              SizedBox(height: 10),

              // 📦 ITEMS
              Expanded(
                child: ListView.builder(
                  itemCount: cart.length,
                  itemBuilder: (_, i) {
                    var item = cart[i];

                    double itemTotal =
                        item['qty'] * item['price'];

                    return ListTile(
                      title: Text(item['name']),
                      subtitle: Text(
                          "${item['qty']} x ₹${item['price']}"),
                      trailing: Text("₹$itemTotal"),
                    );
                  },
                ),
              ),

              Divider(),

              // 💰 TOTALS
              Text("Subtotal: ₹$total"),
              SizedBox(height: 5),

              Text(
                "Final: ₹$finalTotal",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 15),

              // 🔘 DONE BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("DONE"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}