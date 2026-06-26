import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import 'add_edit_product.dart';

class ProductMenu extends StatefulWidget {
  @override
  _ProductMenuState createState() => _ProductMenuState();
}

class _ProductMenuState extends State<ProductMenu> {
  DBHelper db = DBHelper();

  List products = [];
  List filtered = [];

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  // 🔄 LOAD PRODUCTS
  loadProducts() async {
    products = await db.getProducts();
    filtered = products;
    setState(() {});
  }

  // 🔍 SEARCH
  search(String value) {
    setState(() {
      filtered = products.where((p) {
        return p['name']
            .toString()
            .toLowerCase()
            .contains(value.toLowerCase());
      }).toList();
    });
  }

  // 🎨 STOCK COLOR
  Color stockColor(double stock) {
    if (stock <= 5) return Colors.red;
    if (stock <= 20) return Colors.orange;
    return Colors.green;
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Row(
                    children: [
                      Image.asset('assets/logo.png', height: 70),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("My Shop",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                          Text("Product Management"),
                        ],
                      ),
                    ],
                  ),

                  ElevatedButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddEditProduct(),
                        ),
                      );
                      loadProducts();
                    },
                    child: Text("+ Add Product"),
                  )
                ],
              ),
            ),

            // 🔍 SEARCH
            Padding(
              padding: EdgeInsets.all(10),
              child: TextField(
                controller: searchController,
                onChanged: search,
                decoration: InputDecoration(
                  hintText: "Search product...",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),

            // 📋 TABLE (🔥 FIXED SCROLL)
            Expanded(
              child: filtered.isEmpty
                  ? Center(child: Text("No Products Found"))
                  : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: 900, // 🔥 IMPORTANT
                  child: ListView.builder(
                    itemCount: filtered.length + 1,
                    itemBuilder: (context, index) {

                      // 🔥 HEADER ROW
                      if (index == 0) {
                        return Container(
                          padding: EdgeInsets.all(10),
                          color: Colors.grey[200],
                          child: Row(
                            children: [
                              Expanded(child: Text("Name")),
                              Expanded(child: Text("Retail")),
                              Expanded(child: Text("Wholesale")),
                              Expanded(child: Text("Unit")),
                              Expanded(child: Text("Stock")),
                              Expanded(child: Text("Action")),
                            ],
                          ),
                        );
                      }

                      var p = filtered[index - 1];

                      return Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                                color: Colors.grey.shade300),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                                child:
                                Text(p['name'].toString())),
                            Expanded(
                                child: Text(
                                    "₹${p['retail_price']}")),
                            Expanded(
                                child: Text(
                                    "₹${p['wholesale_price']}")),
                            Expanded(
                                child:
                                Text(p['unit'] ?? "pcs")),
                            Expanded(
                              child: Text(
                                p['stock'].toString(),
                                style: TextStyle(
                                  color: stockColor(
                                      (p['stock'] as num)
                                          .toDouble()),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            // 🔥 ACTION
                            Expanded(
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              AddEditProduct(
                                                  product: p),
                                        ),
                                      );
                                      loadProducts();
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () async {
                                      bool confirm =
                                      await showDialog(
                                        context: context,
                                        builder: (_) =>
                                            AlertDialog(
                                              title: Text(
                                                  "Delete Product"),
                                              content: Text(
                                                  "Are you sure?"),
                                              actions: [
                                                TextButton(
                                                  child:
                                                  Text("Cancel"),
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context,
                                                          false),
                                                ),
                                                ElevatedButton(
                                                  child:
                                                  Text("Delete"),
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context,
                                                          true),
                                                ),
                                              ],
                                            ),
                                      );

                                      if (confirm == true) {
                                        await db.deleteProduct(
                                            p['id']);
                                        loadProducts();
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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