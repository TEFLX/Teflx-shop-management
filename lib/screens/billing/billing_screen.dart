import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import 'invoice_screen.dart';

class BillingScreen extends StatefulWidget {
  @override
  _BillingScreenState createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  DBHelper db = DBHelper();

  List products = [];
  List filtered = [];
  List cart = [];
  List customers = [];

  String customerType = "retail";
  String? selectedCustomer;

  final searchController = TextEditingController();
  final discountController = TextEditingController();

  // 🔥 MANUAL ENTRY CONTROLLERS
  TextEditingController manualName = TextEditingController();
  TextEditingController manualPrice = TextEditingController();
  TextEditingController manualQty = TextEditingController();

  double kgStep = 0.25;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    products = await db.getProducts();
    customers = await db.getCustomers();
    filtered = products;
    setState(() {});
  }

  // 🔍 SEARCH
  search(String value) {
    filtered = products
        .where((p) =>
        p['name'].toLowerCase().contains(value.toLowerCase()))
        .toList();
    setState(() {});
  }

  // ➕ ADD PRODUCT
  addToCart(p) {
    double price = (customerType == "retail"
        ? p['retail_price']
        : p['wholesale_price'])
        .toDouble();

    var i = cart.indexWhere((e) => e['id'] == p['id']);

    if (i >= 0) {
      cart[i]['qty'] += p['unit'] == 'kg' ? kgStep : 1.0;
    } else {
      cart.add({
        'id': p['id'],
        'name': p['name'],
        'unit': p['unit'] ?? 'pcs',
        'qty': p['unit'] == 'kg' ? kgStep : 1.0,
        'price': price,
      });
    }

    setState(() {});
  }

  // 🔥 MANUAL PRODUCT ADD
  void addManualItem() {
    String name = manualName.text.trim();
    double price = double.tryParse(manualPrice.text) ?? 0;
    double qty = double.tryParse(manualQty.text) ?? 1;

    if (name.isEmpty || price <= 0) return;

    cart.add({
      'id': DateTime.now().toString(),
      'name': name,
      'unit': 'custom',
      'qty': qty.toDouble(),
      'price': price.toDouble(),
    });

    manualName.clear();
    manualPrice.clear();
    manualQty.clear();

    setState(() {});
  }

  // ➕
  increase(item) {
    double step = item['unit'] == 'kg' ? kgStep : 1.0;
    item['qty'] += step;
    setState(() {});
  }

  // ➖
  decrease(item) {
    double step = item['unit'] == 'kg' ? kgStep : 1.0;
    item['qty'] -= step;

    if (item['qty'] <= 0) cart.remove(item);

    setState(() {});
  }

  // ✏️ EDIT QTY
  updateQty(item, value) {
    double val = double.tryParse(value) ?? 0;
    item['qty'] = val;
    setState(() {});
  }

  // 🔥 FIXED TOTAL
  double total() => cart.fold(0.0, (s, e) {
    double qty = (e['qty'] as num).toDouble();
    double price = (e['price'] as num).toDouble();
    return s + (qty * price);
  });

  double finalTotal() {
    double d = double.tryParse(discountController.text) ?? 0;
    return total() - d;
  }

  // 🔥 CHECKOUT FIXED
  checkout() async {
    double totalAmount = finalTotal();
    double paidAmount = 0;

    await showDialog(
      context: context,
      builder: (_) {
        TextEditingController paidController =
        TextEditingController(text: totalAmount.toString());

        return AlertDialog(
          title: Text("Payment"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Total: ₹$totalAmount"),
              TextField(
                controller: paidController,
                keyboardType: TextInputType.number,
                decoration:
                InputDecoration(labelText: "Paid Amount"),
                onChanged: (v) {
                  paidAmount = double.tryParse(v) ?? 0;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text("Confirm"),
              onPressed: () {
                paidAmount =
                    double.tryParse(paidController.text) ?? 0;
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );

    double dueAmount = totalAmount - paidAmount;

    // 🔥 UPDATE STOCK FIXED
    for (var item in cart) {

      // 🔥 SKIP MANUAL PRODUCTS
      if (item['unit'] == 'custom') continue;

      await db.updateStock(
        item['id'],
        (item['qty'] as num).toDouble(),
      );
    }

    // SAVE ORDER
    await db.insertOrderWithItems({
      'customer': selectedCustomer ?? "Walk-in",
      'type': customerType,
      'total': totalAmount,
      'paid': paidAmount,
      'due': dueAmount,
      'date': DateTime.now().toString(),
    }, cart);

    // CUSTOMER UPDATE
    if (selectedCustomer != null) {
      await db.updateCustomerAccountWithPayment(
          selectedCustomer!, totalAmount, dueAmount);
    }

    // PAYMENT SAVE
    if (paidAmount > 0 && selectedCustomer != null) {
      await db.addPayment(selectedCustomer!, paidAmount);
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InvoiceScreen(
          cart: cart,
          total: totalAmount,
          finalTotal: totalAmount,
          customer: selectedCustomer ?? "Walk-in",
        ),
      ),
    );
  }

  // 🔥 CUSTOMER AUTOCOMPLETE
  Widget customerField() {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        final names =
        customers.map((c) => c['name'].toString()).toList();

        if (textEditingValue.text.isEmpty) return names;

        return names.where((name) => name
            .toLowerCase()
            .contains(textEditingValue.text.toLowerCase()));
      },
      onSelected: (value) {
        selectedCustomer = value;
      },
      fieldViewBuilder:
          (context, controller, focusNode, onEditingComplete) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: "Select / Type Customer",
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            selectedCustomer = value;
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Billing POS")),
      body: Row(
        children: [
          // LEFT
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(8),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Search product",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: search,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      var p = filtered[i];

                      double price = (customerType == "retail"
                          ? p['retail_price']
                          : p['wholesale_price'])
                          .toDouble();

                      return Card(
                        child: ListTile(
                          title: Text(p['name']),
                          subtitle:
                          Text("₹$price (${p['unit'] ?? 'pcs'})"),
                          trailing: ElevatedButton(
                            onPressed: () => addToCart(p),
                            child: Text("ADD"),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // RIGHT
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Expanded(child: customerField()),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () =>
                            setState(() => customerType = "retail"),
                        child: Text("Retail"),
                      ),
                      SizedBox(width: 5),
                      ElevatedButton(
                        onPressed: () => setState(
                                () => customerType = "wholesale"),
                        child: Text("Wholesale"),
                      ),
                    ],
                  ),
                ),

                // 🔥 MANUAL ENTRY UI
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: manualName,
                          decoration:
                          InputDecoration(hintText: "Product"),
                        ),
                      ),
                      SizedBox(width: 5),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          controller: manualPrice,
                          keyboardType: TextInputType.number,
                          decoration:
                          InputDecoration(hintText: "Price"),
                        ),
                      ),
                      SizedBox(width: 5),
                      SizedBox(
                        width: 60,
                        child: TextField(
                          controller: manualQty,
                          keyboardType: TextInputType.number,
                          decoration:
                          InputDecoration(hintText: "Qty"),
                        ),
                      ),
                      SizedBox(width: 5),
                      ElevatedButton(
                        onPressed: addManualItem,
                        child: Text("ADD"),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    itemCount: cart.length,
                    itemBuilder: (_, i) {
                      var item = cart[i];

                      return ListTile(
                        title: Text(
                            "${item['name']} (${item['unit']})"),
                        subtitle: Text("₹${item['price']}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                onPressed: () => decrease(item),
                                icon: Icon(Icons.remove)),
                            SizedBox(
                              width: 60,
                              child: TextField(
                                keyboardType:
                                TextInputType.number,
                                controller:
                                TextEditingController(
                                    text: item['qty']
                                        .toString()),
                                onSubmitted: (v) =>
                                    updateQty(item, v),
                              ),
                            ),
                            IconButton(
                                onPressed: () => increase(item),
                                icon: Icon(Icons.add)),
                            IconButton(
                              onPressed: () {
                                cart.remove(item);
                                setState(() {});
                              },
                              icon: Icon(Icons.delete,
                                  color: Colors.red),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Text("Subtotal: ₹${total()}"),
                      TextField(
                        controller: discountController,
                        keyboardType: TextInputType.number,
                        decoration:
                        InputDecoration(labelText: "Discount"),
                      ),
                      Text(
                        "Final: ₹${finalTotal()}",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton(
                        onPressed: checkout,
                        child: Text("CHECKOUT"),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}