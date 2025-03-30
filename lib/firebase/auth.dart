import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:typed_data';

class AuthMethods {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> login(String email, String password) async {
    await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signup(
    String email,
    String password,
    String username,
    Uint8List? image,
  ) async {
    UserCredential userCredential = await firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password);

    String uid = userCredential.user!.uid;

    await firestore.collection("users").doc(uid).set({
      "uid": uid,
      "username": username,
      "email": email,
      "profilePic": image ?? Uint8List(0),
      "status": "online",
      "lastSeen": FieldValue.serverTimestamp(),
      "contacts": [],
      "fcmToken": "",
    });
  }

  Future<void> signout() async {
    User? user = firebaseAuth.currentUser;
    if (user != null) {
      await firestore.collection("users").doc(user.uid).update({
        "status": "offline",
        "lastSeen": FieldValue.serverTimestamp(),
      });

      await firebaseAuth.signOut();
    }
  }
}
