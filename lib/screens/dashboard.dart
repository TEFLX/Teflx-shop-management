import 'package:flutter/material.dart';
import '/screens/product/product_menu.dart';
import '/screens/customer/customer_list.dart';
import '/screens/billing/billing_screen.dart';
import '/screens/invoice/invoice_list.dart';
import '../../database/db_helper.dart';
import '../../database/backup.dart';
class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  DBHelper db = DBHelper();

  int totalProducts = 0;
  int totalCustomers = 0;
  double todaySales = 0;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    final database = await db.db;

    var products = await database.query('products');
    var customers = await database.query('customers');

    var orders = await database.rawQuery('''
      SELECT SUM(total) as total FROM orders
      WHERE date LIKE '%${DateTime.now().toString().substring(0, 10)}%'
    ''');

    setState(() {
      totalProducts = products.length;
      totalCustomers = customers.length;
      todaySales = orders.first['total'] == null
          ? 0
          : (orders.first['total'] as num).toDouble();
    });
  }

  Widget menuButton(String title, Widget page) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(double.infinity, 60),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => page),
          );
        },
        child: Text(title, style: TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget card(String title, String value) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.all(8),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 5)
          ],
        ),
        child: Column(
          children: [
            Text(title),
            SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget actionButton(String title, Widget page) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => page),
          );
        },
        child: Text(title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [

            // 🔹 LEFT MENU
            Container(
              width: 220,
              color: Colors.blueGrey[900],
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  SizedBox(height: 20),

                  Text(
                    "MENU",
                    style: TextStyle(
                        color: Colors.white, fontSize: 18),
                  ),

                  SizedBox(height: 20),

                  menuButton("Product", ProductMenu()),
                  menuButton("Customer", CustomerList()),
                  menuButton("Billing", BillingScreen()),
                  menuButton("Invoice", InvoiceList()),

                  Spacer(),
                  ElevatedButton(
                    onPressed: () async {
                      await backupDatabase();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Backup Saved")),
                      );
                    },
                    child: Text("Backup"),
                  ),

                  ElevatedButton(
                    onPressed: () async {
                      await restoreDatabase();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Database Restored")),
                      );
                    },
                    child: Text("Restore"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Logout"),
                  ),
                ],
              ),
            ),

            // 🔹 RIGHT SIDE
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // 🔥 HEADER WITH BIG LOGO
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [

                            // LOGO
                            Container(
                              padding: EdgeInsets.all(6),
                              child: Image.asset(
                                'assets/logo.png',
                                height: 75,
                                fit: BoxFit.contain,
                              ),
                            ),

                            SizedBox(width: 12),

                            // SHOP NAME
                            Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "GC KARYANA STORE",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "Dashboard",
                                  style:
                                  TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),

                        Text(
                          "Welcome",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),

                    SizedBox(height: 20),

                    // 📊 SUMMARY CARDS
                    Row(
                      children: [
                        card("Today's Sales", "₹$todaySales"),
                        card("Products", "$totalProducts"),
                        card("Customers", "$totalCustomers"),
                      ],
                    ),

                    SizedBox(height: 30),

                    // ⚡ QUICK ACTIONS
                    Text(
                      "Quick Actions",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),

                    SizedBox(height: 10),

                    Row(
                      children: [
                        actionButton("New Bill", BillingScreen()),
                        actionButton("Add Product", ProductMenu()),
                        actionButton("Add Customer", CustomerList()),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}