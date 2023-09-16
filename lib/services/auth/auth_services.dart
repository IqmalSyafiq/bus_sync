import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';

import '../../views/auth/controllers/auth_controllers.dart';

class AuthServices {
  Future<void> signInwithGoogle(BuildContext context) async {
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

    if (gUser == null) {
      // Handle the case when the user cancels the sign-in process.
      return;
    }

    final GoogleSignInAuthentication gAuth = await gUser.authentication;

    final credential = GoogleAuthProvider.credential(accessToken: gAuth.accessToken, idToken: gAuth.idToken);

    try {
      // Sign in with Firebase Authentication
      final UserCredential authResult = await FirebaseAuth.instance.signInWithCredential(credential);
      final User? firebaseUser = authResult.user;

      // Check if the user exists in Firestore
      final userDoc = FirebaseFirestore.instance.collection('users').doc(firebaseUser?.uid);

      final userDocSnapshot = await userDoc.get();

      if (userDocSnapshot.exists) {
        // User exists in Firestore
        Logger().i('User exists: true');
      } else {
        // User doesn't exist in Firestore, create a new user document
        Logger().w('User exists: false');
        await setUser();
      }

      Logger().i('successfully sign in');
      // Navigate to the home screen or perform other actions
      // context.pop(RoutePaths.home);
    } catch (e) {
      // Handle errors here
      Logger().e("Error signing in with Google: $e");
    }
  }
}
