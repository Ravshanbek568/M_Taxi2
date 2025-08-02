import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class TaxiOrderScreen extends StatefulWidget {
  const TaxiOrderScreen({super.key});

  @override
  State<TaxiOrderScreen> createState() => _TaxiOrderScreenState();
}

class _TaxiOrderScreenState extends State<TaxiOrderScreen> {
  final Completer<GoogleMapController> _controllerGoogleMaps = Completer();
  LatLng? _selectedLocation;
  LatLng? _currentUserLocation;
  bool _isLocationLoading = false;
  Set<Marker> _markers = {};

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(40.8008333, 72.9881418),
    zoom: 17.0,
  );

  @override
  void initState() {
    super.initState();
    _selectedLocation = _kGooglePlex.target;
    _updateMarker();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    if (!mounted) return;
    setState(() => _isLocationLoading = true);

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lokatsiya xizmati yoqilmagan!')),
      );
      setState(() => _isLocationLoading = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lokatsiya ruxsati berilmadi!')),
        );
        setState(() => _isLocationLoading = false);
        return;
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() {
        _currentUserLocation = LatLng(position.latitude, position.longitude);
        _selectedLocation = _currentUserLocation;
        _updateMarker();
      });

      final GoogleMapController controller = await _controllerGoogleMaps.future;
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(_currentUserLocation!, 17.0),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Joylashuvni olishda xato: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLocationLoading = false);
      }
    }
  }

  void _updateMarker() {
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('meeting_point'),
          position: _selectedLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          anchor: const Offset(0.5, 1.0),
          infoWindow: const InfoWindow(title: 'Uchrashuv joyi'),
          zIndexInt: 2,
          flat: true,
        ),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            myLocationEnabled: true,  // Standart lokatsiya ko'rsatuvchi yoqilgan
            myLocationButtonEnabled: false,  // Standart joylashuv tugmasi o'chirilgan
            initialCameraPosition: _kGooglePlex,
            markers: _markers,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMaps.complete(controller);
            },
            onCameraMove: (CameraPosition position) {
              setState(() {
                _selectedLocation = position.target;
                _updateMarker();
              });
            },
            onCameraIdle: () {
              debugPrint("Tanlangan joy: ${_selectedLocation?.latitude}, ${_selectedLocation?.longitude}");
            },
          ),

          if (_isLocationLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),

          // Joylashuv tugmasi (yuqori o'ng burchakda)
          Positioned(
            top: 30,
            right: 15,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              onPressed: _getUserLocation,
              child: const Icon(Icons.gps_fixed, color: Colors.blue),
            ),
          ),

          // Pastki panel (asl holatida qoldirilgan)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade600,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x33000000),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildButton(Icons.wifi, "Signal jo'natish"),
                      _buildButton(Icons.local_taxi, "Avtomatik taksi"),
                      _buildButton(Icons.groups, "Haydovchilar"),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: "Yo'nalishni kiriting",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Column _buildButton(IconData icon, String label, {VoidCallback? onPressed}) {
    return Column(
      children: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withAlpha(51),
              border: Border.all(color: Colors.white, width: 4),
            ),
            child: Icon(icon, size: 30, color: Colors.white),
          ),
          onPressed: onPressed,
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}





















// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// class TaxiOrderScreen extends StatelessWidget {
//   const TaxiOrderScreen({super.key});


// Completer<GoogleMapController> _controllerGoogleMaps = Completer();

// GoogleMapController?  _newControllerGoogleMap;
  

//  static const CameraPosition _kGooglePlex = CameraPosition(
//     target: LatLng(37.42796133580664, -122.085749655962),
//     zoom: 14.4746,
//   );


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//       title: Text("m-taxi")
//     ),

//     body: Stack(children: [GoogleMap(

//     mapType: MapType.normal,
//     myLocationButtonEnabled: true,
//     initialCameraPosition: _kGooglePlex,
//     onMapCreated: (GoogleMapController controller)
//     {  
//     _controllerGoogleMaps.complete(controller);
//      _newControllerGoogleMap = controller;
//     },

//           )
//       ],),
//     );
//   }
// }
