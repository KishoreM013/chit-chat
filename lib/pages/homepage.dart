import 'package:chit_chat/firebase/auth.dart';
import 'package:chit_chat/pages/chat_screen.dart';
import 'package:chit_chat/pages/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../utils/homeutils.dart'; // Import the utilities
import 'dart:typed_data';

Uint8List imageListToUint8List(dynamic imageData) {
  if (imageData is List<dynamic>) {
    return Uint8List.fromList(imageData.cast<int>());
  } else if (imageData is List<int>) {
    return Uint8List.fromList(imageData);
  }
  return Uint8List(0);
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthMethods authMethods = AuthMethods();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> contacts = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadContacts();
  }

  Future<void> loadContacts() async {
    final currentUser = auth.currentUser;
    if (currentUser == null) return;

    final snapshot =
        await firestore
            .collection('users')
            .doc(currentUser.uid)
            .collection('contacts')
            .get();
    contacts = snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> searchUser() async {
    final query = searchController.text.trim();
    if (query.isEmpty) return;

    final snapshot =
        await firestore
            .collection('users')
            .where('username', isEqualTo: query)
            .get();

    if (snapshot.docs.isNotEmpty) {
      final userData = snapshot.docs.first.data();
      addUserToContacts(userData);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('User not found')));
    }
  }

  Future<void> addUserToContacts(Map<String, dynamic> userData) async {
    final currentUser = auth.currentUser;
    if (currentUser == null) return;

    await firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('contacts')
        .doc(userData['uid'])
        .set(userData);

    setState(() {
      contacts.add(userData);
    });
  }

  Future<void> logout() async {
    await authMethods.signout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Login()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = auth.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
        actions: [IconButton(icon: Icon(Icons.logout), onPressed: logout)],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Search user by username...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(icon: Icon(Icons.search), onPressed: searchUser),
              ],
            ),
          ),
          Expanded(
            child:
                contacts.isEmpty
                    ? Center(child: Text('No contacts found'))
                    : ListView.builder(
                      itemCount: contacts.length,
                      itemBuilder: (context, index) {
                        final contact = contacts[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage:
                                (contact['profilePic'] != null &&
                                        imageListToUint8List(
                                          contact['profilePic'],
                                        ).isNotEmpty)
                                    ? MemoryImage(
                                      imageListToUint8List(
                                        contact['profilePic'],
                                      ),
                                    )
                                    : null,
                            child:
                                (contact['profilePic'] == null ||
                                        imageListToUint8List(
                                          contact['profilePic'],
                                        ).isEmpty)
                                    ? Icon(Icons.person)
                                    : null,
                          ),
                          title: Text(contact['username']),
                          subtitle: Text(contact['email']),
                          onTap: () {
                            if (currentUser != null) {
                              // Compute chatId using the utility function.
                              String chatId = HomeUtils.getChatId(
                                currentUser.uid,
                                contact['uid'],
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ChatScreen(
                                        chatId: chatId,
                                        userData: contact,
                                      ),
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
