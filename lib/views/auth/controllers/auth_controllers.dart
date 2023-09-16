import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

Future<void> setUser() async {
  final collectionRef = FirebaseFirestore.instance.collection('users');
  final user = FirebaseAuth.instance.currentUser;

  try {
    await collectionRef.doc(user!.uid).set({
      'displayName': user.displayName,
      'email': user.email,
      'role': '',
      'status': 'offline',
    });
  } catch (error) {
    Logger().e(error);
  }
}

Future<DocumentSnapshot<Map<String, dynamic>>?> checkUserExistence() async {
  final collectionRef = FirebaseFirestore.instance.collection('users');

  final userEmail = FirebaseAuth.instance.currentUser?.email;
  try {
    final documentSnapshot = await collectionRef.doc(userEmail).get();
    Logger().i(documentSnapshot.exists);
    return documentSnapshot;
  } catch (error) {
    return null;
  }
}
