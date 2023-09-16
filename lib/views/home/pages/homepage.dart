import 'dart:async';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:bus_sync/views/home/controllers/home_controllers.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';

import '../../../constant/app_colors.dart';
import '../../../constant/app_text_styles.dart';
import '../../../router/routes_info.dart';

import '../controllers/location_services.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => HomePageState();
}

class HomePageState extends ConsumerState<HomePage> {
  final Completer<GoogleMapController> _controller = Completer();
  final TextEditingController _busStationController = TextEditingController();

  final TextEditingController _selectedBusStationController = TextEditingController();
  final TextEditingController _selectedBusLocationController = TextEditingController();

  final TextEditingController _busController = TextEditingController();

  final jobRoleCtrl = TextEditingController();

  final Set<Marker> _markers = <Marker>{};
  final Set<Polygon> _polygons = <Polygon>{};
  final Set<Polyline> _polylines = <Polyline>{};
  List<LatLng> polygonLatLngs = <LatLng>[];

  Future<List<BusStation>>? busStations;
  Future<List<Bus>>? busses;

  int _polygonIdCounter = 1;
  int _polylineIdCounter = 1;

  String driverName = '';
  String plateNumber = '';
  String busIdNumber = '';
  String currentBusLocation = '';
  int eta = 0;

  bool showInfoContainer = false;

  static const CameraPosition _kGooglePlex = CameraPosition(target: LatLng(3.105690, 101.639120), zoom: 14.4746);

  @override
  void initState() {
    super.initState();
    busStations = fetchLocationsFromFirestore();
    busses = fetchBussesFromFirestore();

    _setMarker(const LatLng(3.105690, 101.639120));
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  void _setMarker(LatLng point) {
    setState(() {
      _markers.add(
        Marker(
          markerId: const MarkerId('marker'),
          position: point,
        ),
      );
    });
  }

  void _setPolygon() {
    final String polygonIdVal = 'polygon_$_polygonIdCounter';
    _polygonIdCounter++;

    _polygons.add(
      Polygon(
        polygonId: PolygonId(polygonIdVal),
        points: polygonLatLngs,
        strokeWidth: 2,
        fillColor: Colors.transparent,
      ),
    );
  }

  void _setPolyline(List<PointLatLng> points) {
    final String polylineIdVal = 'polyline_$_polylineIdCounter';
    _polylineIdCounter++;

    _polylines.add(
      Polyline(
        polylineId: PolylineId(polylineIdVal),
        width: 2,
        color: Colors.blue,
        points: points
            .map(
              (point) => LatLng(point.latitude, point.longitude),
            )
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildUserBody());
  }

  Widget _buildUserBody() => Column(
        children: [
          _buildMap(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSignOutButton(),
              Container(
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
                  child: ref.watch(userRoleProvider).when(
                        data: (userRole) {
                          // return _buildQueryContainer();
                          if (userRole != '' && userRole == 'user') {
                            return _buildQueryContainer();
                          } else if (userRole != '' && userRole == 'driver') {
                            //show driver content here
                            return _buildDriverContainer();
                          } else {
                            //show choose role here
                            return _buildChooseUserRoleContainer();
                          }
                        },
                        loading: CupertinoActivityIndicator.new,
                        error: (error, stackTrace) => Text(error.toString()),
                      )),
            ],
          ),
        ],
      );

  Widget _buildQueryContainer() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Current location/Bus station', style: AppTextStyles.regular12().copyWith(color: const Color.fromARGB(106, 0, 0, 0), fontSize: 10)),
          const SizedBox(height: 2),
          _buildBusStationsDropdown(),
          const SizedBox(height: 10),
          Text('Available bus', style: AppTextStyles.regular12().copyWith(color: const Color.fromARGB(106, 0, 0, 0), fontSize: 10)),
          const SizedBox(height: 2),
          _buildBussesDropdown(),
          const SizedBox(height: 15),
          _buildCheckEtaButton(),
          const SizedBox(height: 15),
          _buildInfoContainer()
        ],
      );

  Widget _buildSignOutButton() => InkWell(
        onTap: () => FirebaseAuth.instance.signOut().then((value) => context.go(RoutePaths.auth)),
        borderRadius: BorderRadius.circular(5),
        child: Container(
            width: 60,
            height: 30,
            margin: const EdgeInsets.only(top: 8, left: 8),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
            child: Center(
                child: Text(
              'Sign Out',
              style: AppTextStyles.bold().copyWith(color: Colors.redAccent, fontSize: 10),
            ))),
      );

  Widget _buildMap() => Expanded(
      child: GoogleMap(
          mapType: MapType.normal,
          markers: _markers,
          polygons: _polygons,
          polylines: _polylines,
          initialCameraPosition: _kGooglePlex,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          onTap: (point) {
            setState(() {
              polygonLatLngs.add(point);
              _setPolygon();
            });
          }));

  Widget _buildBusStationsDropdown() => FutureBuilder<List<BusStation>>(
        future: busStations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CupertinoActivityIndicator();
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Text('No data available.');
          }

          List<String> locationNames = snapshot.data!.map((busStation) => busStation.name).toList();

          return CustomDropdown(
            hintText: 'Your current location',
            hintStyle: AppTextStyles.medium12(),
            selectedStyle: AppTextStyles.medium12(),
            listItemStyle: AppTextStyles.regular12(),
            errorStyle: AppTextStyles.regular12(),
            items: locationNames,
            controller: _busStationController,
            onChanged: (selectedName) {
              // Find the BusStation object that matches the selected name
              BusStation? selectedStation = snapshot.data!.firstWhere(
                (station) => station.name == selectedName,
                // orElse: () => null,
              );
              // Set the location in a separate text field or wherever you want
              setState(() {
                _selectedBusStationController.text = selectedStation.location;
              });
            },
          );
        },
      );

  Widget _buildBussesDropdown() => FutureBuilder<List<Bus>>(
        future: busses,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CupertinoActivityIndicator();
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Text('No data available.');
          }

          List<String> busIds = snapshot.data!.map((bus) => bus.idNumber).toList();

          return CustomDropdown(
              hintText: 'Select available bus',
              hintStyle: AppTextStyles.medium12(),
              selectedStyle: AppTextStyles.medium12(),
              listItemStyle: AppTextStyles.regular12(),
              errorStyle: AppTextStyles.regular12(),
              items: busIds,
              controller: _busController,
              onChanged: (selectedBus) {
                // Find the BusStation object that matches the selected name
                Bus? selectedBusInfo = snapshot.data!.firstWhere(
                  (bus) => bus.idNumber == selectedBus,
                  // orElse: () => null,
                );

                setState(() {
                  _selectedBusLocationController.text = selectedBusInfo.currentLocation;
                  driverName = selectedBusInfo.driver;
                  plateNumber = selectedBusInfo.plateNumber;
                  currentBusLocation = selectedBusInfo.currentLocation;
                  busIdNumber = selectedBusInfo.idNumber;
                  eta = selectedBusInfo.eta;
                });
              });
        },
      );

  Widget _buildCheckEtaButton() => Center(
        child: InkWell(
          onTap: () async {
            var directions = await LocationService().getDirections(
              _selectedBusStationController.text,
              _selectedBusLocationController.text,
            );
            _goToPlace(
              directions['start_location']['lat'],
              directions['start_location']['lng'],
              directions['bounds_ne'],
              directions['bounds_sw'],
            );

            _setPolyline(directions['polyline_decoded']);

            if (_selectedBusStationController.text.isNotEmpty && _selectedBusLocationController.text.isNotEmpty) {
              setState(() {
                showInfoContainer = true;
              });
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 30,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 18),
            decoration: BoxDecoration(color: AppColors.primaryColor, borderRadius: BorderRadius.circular(12)),
            child: Text('Show ETA', style: AppTextStyles.bold12().copyWith(color: AppColors.white)),
          ),
        ),
      );

  Widget _buildInfoContainer() => Visibility(
        visible: showInfoContainer,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          // margin: const EdgeInsets.all(15),
          decoration: BoxDecoration(color: const Color.fromARGB(47, 187, 255, 222), borderRadius: BorderRadius.circular(8)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.bus_alert_rounded, size: 14, color: Colors.black),
                const SizedBox(width: 5),
                Text('Bus Information', style: AppTextStyles.bold().copyWith(color: const Color.fromARGB(232, 0, 0, 0), fontSize: 12))
              ]),
              const SizedBox(height: 10),
              RichText(
                  text: TextSpan(children: [
                TextSpan(text: 'Driver : ', style: AppTextStyles.bold().copyWith(color: Colors.black, fontSize: 10)),
                TextSpan(text: driverName, style: AppTextStyles.regular().copyWith(color: Colors.black, fontSize: 10)),
              ])),
              const SizedBox(height: 5),
              RichText(
                  text: TextSpan(children: [
                TextSpan(text: 'Bus Id Number : ', style: AppTextStyles.bold().copyWith(color: Colors.black, fontSize: 10)),
                TextSpan(text: busIdNumber, style: AppTextStyles.regular().copyWith(color: Colors.black, fontSize: 10)),
              ])),
              const SizedBox(height: 5),
              RichText(
                  text: TextSpan(children: [
                TextSpan(text: 'Plate Number : ', style: AppTextStyles.bold().copyWith(color: Colors.black, fontSize: 10)),
                TextSpan(text: plateNumber, style: AppTextStyles.regular().copyWith(color: Colors.black, fontSize: 10)),
              ])),
              const SizedBox(height: 5),
              RichText(
                  text: TextSpan(children: [
                TextSpan(text: 'Current Bus Location : ', style: AppTextStyles.bold().copyWith(color: Colors.black, fontSize: 10)),
                TextSpan(text: currentBusLocation, style: AppTextStyles.regular().copyWith(color: Colors.black, fontSize: 10)),
              ])),
              const SizedBox(height: 5),
              RichText(
                  text: TextSpan(children: [
                TextSpan(text: 'ETA : ', style: AppTextStyles.bold().copyWith(color: Colors.black, fontSize: 10)),
                TextSpan(text: '$eta minutes', style: AppTextStyles.regular().copyWith(color: Colors.black, fontSize: 10)),
              ])),
            ],
          ),
        ),
      );

  Widget _buildChooseUserTypeButton({required String buttonText, required Color buttonColor, required VoidCallback updateAction}) => InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: updateAction,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 35),
          decoration: BoxDecoration(color: buttonColor, borderRadius: BorderRadius.circular(12)),
          child: Text(buttonText, style: AppTextStyles.bold().copyWith(color: Colors.white, fontSize: 12)),
        ),
      );

  Widget _buildChooseUserRoleContainer() => Column(
        children: [
          Text('Are you a public transport user or a bus driver?', style: AppTextStyles.medium().copyWith(color: const Color.fromARGB(232, 0, 0, 0), fontSize: 12)),
          const SizedBox(height: 20),
          _buildChooseUserTypeButton(
            buttonText: 'I am a Public Transport User',
            buttonColor: AppColors.primaryColor,
            updateAction: () => updateUserRole('user').then((value) => ref.invalidate(userRoleProvider)),
          ),
          const SizedBox(height: 10),
          _buildChooseUserTypeButton(
            buttonText: 'I am a Bus Driver',
            buttonColor: Colors.blue,
            updateAction: () => updateUserRole('driver').then((value) => ref.invalidate(userRoleProvider)),
          ),
        ],
      );

  Widget _buildDriverContainer() => ref.watch(driverStatusProvider).when(
        data: (driverStatus) {
          bool isOnline = driverStatus == 'online';

          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              children: [
                Container(width: 12, height: 12, decoration: BoxDecoration(color: isOnline ? Colors.greenAccent : Colors.redAccent, borderRadius: BorderRadius.circular(50))),
                const SizedBox(width: 5),
                RichText(
                    text: TextSpan(children: [
                  TextSpan(text: 'Status : ', style: AppTextStyles.medium().copyWith(color: Colors.black, fontSize: 12)),
                  TextSpan(text: isOnline ? 'Online' : 'Offline', style: AppTextStyles.regular().copyWith(color: const Color.fromARGB(123, 0, 0, 0), fontSize: 12)),
                ])),
                const SizedBox(width: 15),
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    if (driverStatus == 'offline') {
                      updateDriverStatus('online').then((value) => ref.invalidate(driverStatusProvider));
                    } else {
                      updateDriverStatus('offline').then((value) => ref.invalidate(driverStatusProvider));
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                    decoration: BoxDecoration(color: isOnline ? Colors.redAccent : Colors.green, borderRadius: BorderRadius.circular(8)),
                    child: Text(isOnline ? 'Go Offline' : 'Go Online', style: AppTextStyles.regular12().copyWith(color: Colors.white, fontSize: 10)),
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
            ref.watch(busInfoProvider).when(
                  data: (busInfo) {
                    return Column(children: [
                      Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                          width: double.infinity,
                          decoration: BoxDecoration(color: const Color.fromARGB(110, 175, 202, 223), borderRadius: BorderRadius.circular(8)),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              const Icon(Icons.bus_alert_rounded, size: 14, color: Colors.black),
                              const SizedBox(width: 5),
                              Text('Driver Information', style: AppTextStyles.bold().copyWith(color: const Color.fromARGB(232, 0, 0, 0), fontSize: 12))
                            ]),
                            const SizedBox(height: 20),
                            RichText(
                                text: TextSpan(children: [
                              TextSpan(text: 'Name : ', style: AppTextStyles.medium().copyWith(color: Colors.black, fontSize: 12)),
                              TextSpan(text: busInfo!['driver'], style: AppTextStyles.regular().copyWith(color: const Color.fromARGB(123, 0, 0, 0), fontSize: 12)),
                            ])),
                            const SizedBox(height: 3),
                            RichText(
                                text: TextSpan(children: [
                              TextSpan(text: 'Bus Id Number : ', style: AppTextStyles.medium().copyWith(color: Colors.black, fontSize: 12)),
                              TextSpan(text: busInfo['id_number'], style: AppTextStyles.regular().copyWith(color: const Color.fromARGB(123, 0, 0, 0), fontSize: 12)),
                            ])),
                            const SizedBox(height: 3),
                            RichText(
                                text: TextSpan(children: [
                              TextSpan(text: 'Bus Plate Number : ', style: AppTextStyles.medium().copyWith(color: Colors.black, fontSize: 12)),
                              TextSpan(text: busInfo['plate_number'], style: AppTextStyles.regular().copyWith(color: const Color.fromARGB(123, 0, 0, 0), fontSize: 12)),
                            ])),
                          ])),
                      const SizedBox(height: 30),
                      InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => _determinePosition().then((position) {
                                getAddress(position.latitude, position.longitude).then((value) => updateBusLocation(busInfo['plate_number'], value));
                                _setMarker(LatLng(position.latitude, position.longitude));
                                _showMyCurrentPosition(position);
                              }).catchError((error) {
                                Logger().e(error);
                              }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                            decoration: BoxDecoration(color: AppColors.primaryColor, borderRadius: BorderRadius.circular(8)),
                            child: Text('Show My Current Location', style: AppTextStyles.bold().copyWith(color: Colors.white, fontSize: 12)),
                          ))
                    ]);
                  },
                  loading: CupertinoActivityIndicator.new,
                  error: (error, stackTrace) => Text('error is here : ${error.toString()}'),
                )
          ]);
        },
        loading: CupertinoActivityIndicator.new,
        error: (error, stackTrace) => Text(error.toString()),
      );

  Future<void> _showMyCurrentPosition(Position position) async {
    CameraPosition kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(position.latitude, position.longitude),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414,
    );

    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(kLake));
  }

  Future<void> _goToPlace(
    // Map<String, dynamic> place,
    double lat,
    double lng,
    Map<String, dynamic> boundsNe,
    Map<String, dynamic> boundsSw,
  ) async {
    // final double lat = place['geometry']['location']['lat'];
    // final double lng = place['geometry']['location']['lng'];

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: 12),
      ),
    );

    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(boundsSw['lat'], boundsSw['lng']),
            northeast: LatLng(boundsNe['lat'], boundsNe['lng']),
          ),
          25),
    );
    _setMarker(LatLng(lat, lng));
  }
}
