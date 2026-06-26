import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import 'dashboard.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback toggleTheme;

  LoginScreen({required this.toggleTheme});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  DBHelper db = DBHelper();

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  // 🔥 UPDATED LOGIN (DB BASED)
  void login() async {
    String user = usernameController.text.trim();
    String pass = passwordController.text.trim();

    bool ok = await db.login(user, pass);

    if (ok) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => Dashboard()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid login")),
      );
    }
  }

  // 🔥 CHANGE PASSWORD DIALOG
  void changePassword() {
    TextEditingController oldPass = TextEditingController();
    TextEditingController newPass = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Change Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            // OLD PASSWORD
            TextField(
              controller: oldPass,
              obscureText: true,
              decoration: InputDecoration(labelText: "Old Password"),
            ),

            SizedBox(height: 10),

            // NEW PASSWORD
            TextField(
              controller: newPass,
              obscureText: true,
              decoration: InputDecoration(labelText: "New Password"),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),

          ElevatedButton(
            child: Text("Update"),
            onPressed: () async {
              String user = usernameController.text.trim();

              if (user.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Enter username first")),
                );
                return;
              }

              // 🔥 VERIFY OLD PASSWORD
              bool valid = await db.verifyUser(user, oldPass.text);

              if (!valid) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Wrong old password")),
                );
                return;
              }

              // 🔥 UPDATE PASSWORD
              await db.changePassword(user, newPass.text);

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Password Updated")),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      // 🔥 APPBAR WITH THEME TOGGLE
      appBar: AppBar(
        title: Text("Login"),
        actions: [
          IconButton(
            icon: Icon(Icons.dark_mode),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),

      body: Center(
        child: Container(
          width: 400,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 10)
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              // 🔥 LOGO
              Image.asset(
                'assets/logo.png',
                height: 100,
              ),

              SizedBox(height: 20),

              // USERNAME
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: "Username",
                ),
              ),

              SizedBox(height: 15),

              // PASSWORD
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                ),
              ),

              SizedBox(height: 20),

              // LOGIN BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: login,
                  child: Text("Login"),
                ),
              ),

              SizedBox(height: 10),

              // 🔥 CHANGE PASSWORD BUTTON
              TextButton(
                onPressed: changePassword,
                child: Text("Change Password"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}