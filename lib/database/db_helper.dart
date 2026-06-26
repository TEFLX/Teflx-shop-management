import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  // 🔹 GET DATABASE
  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  // 🔹 INIT DATABASE
  initDb() async {
    String path = join(await getDatabasesPath(), 'shop.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // 🔹 CREATE TABLES
  _onCreate(Database db, int version) async {

    // 🔐 USERS
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password TEXT
      )
    ''');

    // default admin
    await db.insert('users', {
      'username': 'admin',
      'password': '9598',
    });

    // PRODUCTS
    await db.execute('''
      CREATE TABLE products(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        category TEXT,
        retail_price REAL,
        wholesale_price REAL,
        purchase_price REAL,
        stock REAL,
        unit TEXT
      )
    ''');

    // CUSTOMERS
    await db.execute('''
      CREATE TABLE customers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        phone TEXT,
        address TEXT,
        total REAL DEFAULT 0,
        due REAL DEFAULT 0
      )
    ''');

    // ORDERS
    await db.execute('''
      CREATE TABLE orders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer TEXT,
        type TEXT,
        total REAL,
        paid REAL,
        due REAL,
        date TEXT
      )
    ''');

    // ORDER ITEMS
    await db.execute('''
      CREATE TABLE order_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER,
        product_id INTEGER,
        name TEXT,
        qty REAL,
        price REAL,
        total REAL
      )
    ''');

    // PAYMENTS
    await db.execute('''
      CREATE TABLE payments(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer TEXT,
        amount REAL,
        date TEXT
      )
    ''');
  }

  // ================= USERS =================

  Future<bool> login(String user, String pass) async {
    final database = await db;

    var result = await database.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [user, pass],
    );

    return result.isNotEmpty;
  }

  Future<int> addUser(String user, String pass) async {
    final database = await db;

    return await database.insert('users', {
      'username': user,
      'password': pass,
    });
  }

  Future<void> changePassword(String user, String newPass) async {
    final database = await db;

    await database.update(
      'users',
      {'password': newPass},
      where: 'username = ?',
      whereArgs: [user],
    );
  }

  // ================= PRODUCT =================

  Future<int> insertProduct(Map<String, dynamic> data) async {
    final database = await db;
    return await database.insert('products', data);
  }

  Future<List<Map<String, dynamic>>> getProducts() async {
    final database = await db;
    return await database.query('products');
  }

  Future<int> updateProduct(int id, Map<String, dynamic> data) async {
    final database = await db;
    return await database.update(
      'products',
      data,
      where: 'id=?',
      whereArgs: [id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final database = await db;

    return await database.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 🔥 UPDATE STOCK
  Future<void> updateStock(int id, double qty) async {
    final database = await db;

    await database.rawUpdate(
      '''
      UPDATE products 
      SET stock = stock - ? 
      WHERE id = ?
      ''',
      [qty, id],
    );
  }

  // ================= CUSTOMER =================

  Future<int> insertCustomer(Map<String, dynamic> data) async {
    final database = await db;
    return await database.insert('customers', data);
  }

  Future<List<Map<String, dynamic>>> getCustomers() async {
    final database = await db;
    return await database.query('customers');
  }

  Future<void> updateCustomerAccountWithPayment(
      String name, double totalAmount, double dueAmount) async {
    final database = await db;

    await database.rawUpdate(
      '''
      UPDATE customers
      SET total = total + ?,
          due = due + ?
      WHERE name = ?
      ''',
      [totalAmount, dueAmount, name],
    );
  }

  Future<bool> verifyUser(String user, String pass) async {
    final database = await db;

    var result = await database.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [user, pass],
    );

    return result.isNotEmpty;
  }
  Future<void> deleteOrder(int id) async {
    final database = await db;

    // 🔥 DELETE ITEMS FIRST
    await database.delete(
      'order_items',
      where: 'order_id = ?',
      whereArgs: [id],
    );

    // 🔥 DELETE ORDER
    await database.delete(
      'orders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateCustomerAccount(
      String name, double amount) async {
    final database = await db;

    await database.rawUpdate(
      '''
      UPDATE customers
      SET total = total + ?,
          due = due + ?
      WHERE name = ?
      ''',
      [amount, amount, name],
    );
  }

  // ================= ORDER =================

  Future<int> insertOrderWithItems(
      Map<String, dynamic> order,
      List cart) async {
    final database = await db;

    int orderId = await database.insert('orders', order);

    for (var item in cart) {
      await database.insert('order_items', {
        'order_id': orderId,

        // 🔥 HANDLE MANUAL PRODUCT
        'product_id': item['unit'] == 'custom' ? 0 : item['id'],

        'name': item['name'],

        'qty': (item['qty'] as num).toDouble(),
        'price': (item['price'] as num).toDouble(),

        'total': (item['qty'] as num).toDouble() *
            (item['price'] as num).toDouble(),
      });
    }

    return orderId;
  }

  Future<List<Map<String, dynamic>>> getCustomerOrders(
      String name) async {
    final database = await db;

    return await database.query(
      'orders',
      where: 'customer = ?',
      whereArgs: [name],
      orderBy: 'id DESC',
    );
  }

  // ================= PAYMENT =================

  Future<void> addPayment(String customer, double amount) async {
    final database = await db;

    await database.insert('payments', {
      'customer': customer,
      'amount': amount,
      'date': DateTime.now().toString(),
    });

    await database.rawUpdate(
      '''
      UPDATE customers
      SET due = due - ?
      WHERE name = ?
      ''',
      [amount, customer],
    );
  }

  Future<List<Map<String, dynamic>>> getPayments(
      String name) async {
    final database = await db;

    return await database.query(
      'payments',
      where: 'customer = ?',
      whereArgs: [name],
      orderBy: 'id DESC',
    );
  }
}