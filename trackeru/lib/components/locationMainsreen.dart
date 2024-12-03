import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trackeru/route/routes.dart';
import 'package:trackeru/utilities/showLogoutDialogue.dart';
import 'package:trackeru/views/setting_view.dart';

enum MenuAction { logout }

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final List<Marker> _markers = <Marker>[];
  String street = "";
  String postCode = "";
  String city = "";
  String country = "";

  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) async {
      await Geolocator.requestPermission();
    });

    return await Geolocator.getCurrentPosition();
  }

  Future<void> getAddressFromLatLong(Position position) async {
    try {
      final List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      street = placemarks[0].street!;
      city = placemarks[0].locality!;
      country = placemarks[0].country!;
      postCode = placemarks[0].postalCode!;
      // print(street);
    } catch (e) {
      print('Error: $e');
    }

    setState(() {});
  }

  Future<void> setInitialLocation() async {
    final Position position = await getUserCurrentLocation();

    getAddressFromLatLong(position);
    setState(() {});

    final CameraPosition cameraPosition = CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: 14,
    );

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  @override
  void initState() {
    super.initState();
    setInitialLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 15, 157, 152),
        title: const Text("Map"),
        // Hamburger menu icon
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
                // _toggleDrawer;
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: 150,
              child: DrawerHeader(
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 15, 157, 152),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      "TrackerU",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      FirebaseAuth.instance.currentUser?.email ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 50,
              child: ListTile(
                title: const Text("Settings"),
                onTap: () {
                  // Navigate to the settings screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingView(),
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            SizedBox(
              height: 50,
              child: ListTile(
                title: const Text("Log out"),
                onTap: () async {
                  final shouldLogout = await showLogOutDialog(context);

                  if (shouldLogout) {
                    await FirebaseAuth.instance.signOut();

                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      loginRoute,
                      (_) => false,
                    );
                  }
                },
              ),
            ),
            const Divider(),
          ],
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            // on below line creating google maps
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  _markers.isNotEmpty ? _markers[0].position.latitude : 0.0,
                  _markers.isNotEmpty ? _markers[0].position.longitude : 0.0,
                ),
                zoom: 14,
              ),
              markers: Set<Marker>.of(_markers),
              mapType: MapType.hybrid,
              myLocationEnabled: true,
              compassEnabled: true,
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              // padding: EdgeInsets.only(
              //   bottom: MediaQuery.of(context).size.height * 0.65,
              // ),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
          ),
          GestureDetector(
            child: DraggableScrollableSheet(
              initialChildSize: 0.1, // Initial size of the draggable sheet
              minChildSize: 0.1, // Minimum size of the draggable sheet
              maxChildSize: 0.9, // Maximum size of the draggable sheet
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      ListTile(
                        title: Text('Address: $street'),
                      ),
                      const Divider(), // Separator between list items
                      ListTile(
                        title: Text('$postCode, $city'),
                      ),
                      ListTile(
                        title: Text(country),
                      ),
                      ListTile(
                        title: Text('Additional Detail 3'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 16.0,
            right: 16.0,
            child: FloatingActionButton(
              onPressed: () async {
                getUserCurrentLocation().then((value) async {
                  _markers.add(
                    Marker(
                      markerId: const MarkerId("1"),
                      position: LatLng(value.latitude, value.longitude),
                      infoWindow: const InfoWindow(
                        title: 'My Current Location',
                      ),
                    ),
                  );

                  CameraPosition cameraPosition = CameraPosition(
                    target: LatLng(value.latitude, value.longitude),
                    zoom: 14,
                  );

                  final GoogleMapController controller =
                      await _controller.future;
                  controller.animateCamera(
                      CameraUpdate.newCameraPosition(cameraPosition));
                  setState(() {});
                });
              },
              child: const Icon(Icons.local_activity),
            ),
          ),
        ],
      ),
    );
  }
}
