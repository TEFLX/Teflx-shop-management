import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import 'add_edit_product.dart';

class ProductList extends StatefulWidget {
  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  DBHelper db = DBHelper();

  List products = [];
  List filtered = [];

  String sortType = "name";
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    load();
  }

  // 🔄 LOAD DATA
  load() async {
    products = await db.getProducts();
    filtered = List.from(products);
    applySort();
    setState(() {});
  }

  // 🔍 SEARCH
  search(String value) {
    filtered = products
        .where((p) =>
        p['name'].toString().toLowerCase().contains(value.toLowerCase()))
        .toList();

    applySort();
    setState(() {});
  }

  // 📊 SORT
  applySort() {
    if (sortType == "name") {
      filtered.sort((a, b) =>
          a['name'].toString().compareTo(b['name'].toString()));
    } else if (sortType == "stock") {
      filtered.sort((a, b) =>
          (b['stock'] ?? 0)
              .toDouble()
              .compareTo((a['stock'] ?? 0).toDouble()));
    } else if (sortType == "top") {
      filtered.shuffle(); // temporary
    }
  }

  // 🎨 STOCK COLOR
  Color getStockColor(double stock) {
    if (stock <= 5) return Colors.red;
    if (stock <= 10) return Colors.orange;
    return Colors.green;
  }

  // 🔢 FORMAT STOCK
  String formatStock(dynamic stock) {
    double value = (stock ?? 0).toDouble();
    if (value % 1 == 0) {
      return value.toInt().toString();
    } else {
      return value.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Product List")),
      body: Column(
        children: [
          // 🔍 SEARCH
          Padding(
            padding: EdgeInsets.all(8),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search product...",
                border: OutlineInputBorder(),
              ),
              onChanged: search,
            ),
          ),

          // 📊 SORT
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Text("Sort: "),
                DropdownButton(
                  value: sortType,
                  items: [
                    DropdownMenuItem(value: "name", child: Text("Name")),
                    DropdownMenuItem(value: "stock", child: Text("Stock")),
                    DropdownMenuItem(
                        value: "top", child: Text("Top Selling")),
                  ],
                  onChanged: (v) {
                    sortType = v.toString();
                    applySort();
                    setState(() {});
                  },
                )
              ],
            ),
          ),

          // 📋 TABLE (FINAL FIXED)
          Expanded(
            child: filtered.isEmpty
                ? Center(child: Text("No Products Found"))
                : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 800,
                child: ListView.builder(
                  itemCount: filtered.length + 1,
                  itemBuilder: (context, index) {

                    // 🔥 HEADER
                    if (index == 0) {
                      return Container(
                        padding: EdgeInsets.all(10),
                        color: Colors.grey[300],
                        child: Row(
                          children: [
                            Expanded(child: Text("Name")),
                            Expanded(child: Text("Retail")),
                            Expanded(child: Text("Wholesale")),
                            Expanded(child: Text("Unit")),
                            Expanded(child: Text("Stock")),
                          ],
                        ),
                      );
                    }

                    var p = filtered[index - 1];
                    double stockValue =
                    (p['stock'] ?? 0).toDouble();

                    return InkWell(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AddEditProduct(product: p),
                          ),
                        );
                        load();
                      },
                      child: Container(
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
                                formatStock(stockValue),
                                style: TextStyle(
                                  color:
                                  getStockColor(stockValue),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}