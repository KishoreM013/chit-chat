import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:chit_chat/firebase/auth.dart';
import 'package:chit_chat/pages/login.dart';
import 'package:chit_chat/utils/image_pick.dart';
import 'homepage.dart';

class Signup extends StatefulWidget {
  Signup({super.key});

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  Uint8List? image;
  final TextEditingController email = TextEditingController();
  final TextEditingController name = TextEditingController();
  final TextEditingController password1 = TextEditingController();
  final TextEditingController password2 = TextEditingController();
  final AuthMethods authMethods = AuthMethods();

  bool isLoading = false;

  Future<void> signup() async {
    if (password1.text != password2.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Passwords do not match')));
      return;
    }

    setState(() => isLoading = true);

    try {
      await authMethods.signup(email.text, password1.text, name.text, image);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Account Created Successfully!')));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() => isLoading = false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  Future<void> _pickImage() async {
    Uint8List? img = await ImageUtils.getImageFromGallery();
    if (img != null) {
      setState(() => image = img);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Signup')),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: image != null ? MemoryImage(image!) : null,
                    child: image == null ? Icon(Icons.person, size: 50) : null,
                  ),
                  Positioned(
                    right: 0,
                    child: IconButton(
                      onPressed: _pickImage,
                      icon: Icon(Icons.camera_alt),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              TextField(
                controller: email,
                decoration: InputDecoration(hintText: "Enter email"),
              ),
              TextField(
                controller: name,
                decoration: InputDecoration(hintText: "Enter username"),
              ),
              TextField(
                controller: password1,
                decoration: InputDecoration(hintText: "Enter password"),
                obscureText: true,
              ),
              TextField(
                controller: password2,
                decoration: InputDecoration(hintText: "Confirm password"),
                obscureText: true,
              ),
              SizedBox(height: 20),
              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(onPressed: signup, child: Text('Signup')),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Login()),
                  );
                },
                child: Text('Already have an account? Login here.'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
