import 'package:bus_sync/views/home/controllers/home_controllers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class BusStation extends Object {
  BusStation({
    required this.name,
    required this.location,
  });

  String name;
  String location;
}

class LocationService {
  final String key = 'AIzaSyA58PkS-ZLrsCbdbeICCuc80-jfWKmiNo8';

  Future<String> getPlaceId(String input) async {
    final String url = 'https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=$input&inputtype=textquery&key=$key';

    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var placeId = json['candidates'][0]['place_id'] as String;

    return placeId;
  }

  Future<Map<String, dynamic>> getPlace(String input) async {
    final placeId = await getPlaceId(input);

    final String url = 'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$key';

    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);
    var results = json['result'] as Map<String, dynamic>;

    return results;
  }

  Future<Map<String, dynamic>> getDirections(String origin, String destination) async {
    final String url = 'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=$key';

    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);

    var results = {
      'bounds_ne': json['routes'][0]['bounds']['northeast'],
      'bounds_sw': json['routes'][0]['bounds']['southwest'],
      'start_location': json['routes'][0]['legs'][0]['start_location'],
      'end_location': json['routes'][0]['legs'][0]['end_location'],
      'polyline': json['routes'][0]['overview_polyline']['points'],
      'polyline_decoded': PolylinePoints().decodePolyline(json['routes'][0]['overview_polyline']['points']),
    };

    return results;
  }
}

Future<List<BusStation>> fetchLocationsFromFirestore() async {
  CollectionReference locations = FirebaseFirestore.instance.collection('bus_stations');

  QuerySnapshot querySnapshot = await locations.get();

  List<BusStation> locationList = [];
  for (var doc in querySnapshot.docs) {
    var data = doc.data() as Map<String, dynamic>;
    var busStation = BusStation(
      name: data['name'],
      location: data['location'],
    );
    locationList.add(busStation);
  }

  return locationList;
}

Future<List<Bus>> fetchBussesFromFirestore() async {
  CollectionReference busses = FirebaseFirestore.instance.collection('busses');

  QuerySnapshot querySnapshot = await busses.get();

  List<Bus> bussesList = [];
  for (var doc in querySnapshot.docs) {
    var data = doc.data() as Map<String, dynamic>;
    var bus = Bus(
      idNumber: data['id_number'],
      plateNumber: data['plate_number'],
      driver: data['driver'],
      currentLocation: data['current_location'],
      eta: data['ETA'],
    );
    bussesList.add(bus);
  }

  return bussesList;
}
