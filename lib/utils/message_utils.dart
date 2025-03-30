import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;
final FirebaseAuth auth = FirebaseAuth.instance;

Future<void> addUserToContacts(Map<String, dynamic> userData) async {
  final currentUser = auth.currentUser;
  if (currentUser == null) return;

  await firestore
      .collection('users')
      .doc(currentUser.uid)
      .collection('contacts')
      .doc(userData['uid'])
      .set(userData);
}
