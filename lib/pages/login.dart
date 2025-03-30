import 'package:chit_chat/pages/homepage.dart';
import 'package:chit_chat/pages/signup.dart';
import 'package:flutter/material.dart';
import '../firebase/auth.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final AuthMethods authMethods = AuthMethods();
  bool isLoading = false;

  void login() async {
    if (email.text.isEmpty || password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }
    setState(() {
      isLoading = true;
    });
    await authMethods.login(email.text, password.text);
    setState(() {
      isLoading = false;
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: email,
              decoration: InputDecoration(hintText: "Enter email"),
            ),
            TextField(
              controller: password,
              decoration: InputDecoration(hintText: "Enter password"),
              obscureText: true,
            ),
            GestureDetector(
              child: Text('New user?'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Signup()),
                );
              },
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : TextButton(onPressed: login, child: Text('Log in')),
          ],
        ),
      ),
    );
  }
}
