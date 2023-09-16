import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class Bus extends Object {
  Bus({
    required this.idNumber,
    required this.plateNumber,
    required this.driver,
    required this.currentLocation,
    required this.eta,
  });

  String idNumber;
  String plateNumber;
  String driver;
  String currentLocation;
  int eta;
}

final userRoleProvider = StreamProvider.autoDispose<String?>((ref) async* {
  final collectionRef = FirebaseFirestore.instance.collection('users');
  final userId = FirebaseAuth.instance.currentUser?.uid;

  try {
    final documentSnapshot = await collectionRef.doc(userId).get();

    if (documentSnapshot.exists) {
      final userData = documentSnapshot.data();
      final userRole = userData?['role'];
      Logger().w(userRole.toString());
      yield userRole as String?;
    } else {
      yield null;
    }
  } catch (error) {
    yield null;
  }
});

Future<String?> getUserRole() async {
  final collectionRef = FirebaseFirestore.instance.collection('users');

  final userId = FirebaseAuth.instance.currentUser?.uid;
  try {
    final documentSnapshot = await collectionRef.doc(userId).get();
    Logger().i(documentSnapshot.exists);

    if (documentSnapshot.exists) {
      final userData = documentSnapshot.data();
      final userRole = userData?['role'];
      return userRole as String?;
    } else {
      return null;
    }
  } catch (error) {
    return null;
  }
}

Future<void> updateUserRole(String newRole) async {
  final collectionRef = FirebaseFirestore.instance.collection('users');
  final userId = FirebaseAuth.instance.currentUser?.uid;

  try {
    final documentSnapshot = await collectionRef.doc(userId).get();

    if (documentSnapshot.exists) {
      await collectionRef.doc(userId).update({
        'role': newRole
      });
    }
  } catch (error) {
    Logger().e(error);
  }
}

Future<void> updateDriverStatus(String status) async {
  final collectionRef = FirebaseFirestore.instance.collection('users');
  final userId = FirebaseAuth.instance.currentUser?.uid;

  try {
    final documentSnapshot = await collectionRef.doc(userId).get();

    if (documentSnapshot.exists) {
      await collectionRef.doc(userId).update({
        'status': status
      });
    }
  } catch (error) {
    Logger().e(error);
  }
}

Future<String?> getDriverStatus() async {
  final collectionRef = FirebaseFirestore.instance.collection('users');

  final userId = FirebaseAuth.instance.currentUser?.uid;
  try {
    final documentSnapshot = await collectionRef.doc(userId).get();
    Logger().i(documentSnapshot.exists);

    if (documentSnapshot.exists) {
      final userData = documentSnapshot.data();
      final driverStatus = userData?['status'];
      return driverStatus as String?;
    } else {
      return null;
    }
  } catch (error) {
    return null;
  }
}

final driverStatusProvider = StreamProvider.autoDispose<String?>((ref) async* {
  final collectionRef = FirebaseFirestore.instance.collection('users');
  final userId = FirebaseAuth.instance.currentUser?.uid;

  try {
    final documentSnapshot = await collectionRef.doc(userId).get();

    if (documentSnapshot.exists) {
      final userData = documentSnapshot.data();
      final driverStatus = userData?['status'];
      Logger().w(driverStatus.toString());
      yield driverStatus as String?;
    } else {
      yield null;
    }
  } catch (error) {
    yield null;
  }
});

final busInfoProvider = FutureProvider<DocumentSnapshot<Map<String, dynamic>>?>((ref) async {
  final collectionRef = FirebaseFirestore.instance.collection('busses');
  final userId = FirebaseAuth.instance.currentUser?.uid;

  try {
    final querySnapshot = await collectionRef.where('user_id', isEqualTo: userId).get();

    if (querySnapshot.docs.isNotEmpty) {
      final documentSnapshot = querySnapshot.docs.first;
      return documentSnapshot;
    } else {
      return null;
    }
  } catch (error) {
    return null;
  }
});

Future<DocumentSnapshot<Map<String, dynamic>>?> getBusInfo() async {
  final collectionRef = FirebaseFirestore.instance.collection('busses');

  final userId = FirebaseAuth.instance.currentUser?.uid;
  try {
    final querySnapshot = await collectionRef.where('user_id', isEqualTo: userId).get();

    if (querySnapshot.docs.isNotEmpty) {
      Logger().i(querySnapshot.docs.first.toString());
      final documentSnapshot = querySnapshot.docs.first;
      Logger().i(documentSnapshot.data()); // Print the data of the document
      return documentSnapshot;
    } else {
      return null;
    }
  } catch (error) {
    return null;
  }
}

Future<String> getAddress(double latitude, double longitude) async {
  const apiKey = 'AIzaSyCX_AvFiQksO_3nZVnKaDdq5DKpPLiBrR0'; // Replace with your actual API key
  final url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey';

  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final results = data['results'] as List<dynamic>;
    if (results.isNotEmpty) {
      final address = results[0]['formatted_address'] as String;
      Logger().w(address);
      return address;
    }
  }
  return 'Address not found';
}

Future<void> updateBusLocation(String plateNumber, String newLocation) async {
  final collectionRef = FirebaseFirestore.instance.collection('busses');

  try {
    final querySnapshot = await collectionRef.where('plate_number', isEqualTo: plateNumber).get();

    if (querySnapshot.docs.isNotEmpty) {
      final documentSnapshot = querySnapshot.docs.first;
      await collectionRef.doc(documentSnapshot.id).update({
        'current_location': newLocation,
      });
    }
  } catch (error) {
    Logger().e(error);
  }
}
