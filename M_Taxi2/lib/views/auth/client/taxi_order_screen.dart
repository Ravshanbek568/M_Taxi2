import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TaxiOrderScreen extends StatefulWidget {
  const TaxiOrderScreen({super.key});

  @override
  State<TaxiOrderScreen> createState() => _TaxiOrderScreenState();
}

class _TaxiOrderScreenState extends State<TaxiOrderScreen> {
  final Completer<GoogleMapController> _controllerGoogleMaps = Completer();
  LatLng? _selectedLocation;
  bool _isMarkerAnimating = false;
  Timer? _animationTimer;
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
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }

  void _startMarkerAnimation() {
    if (_isMarkerAnimating) return;
    
    setState(() => _isMarkerAnimating = true);
    
    _animationTimer?.cancel();
    _animationTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isMarkerAnimating = false);
      }
    });
  }

  void _updateMarker() {
    setState(() {
      _markers = {
        Marker(
          markerId: MarkerId('meeting_point'),
          position: _selectedLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          anchor: Offset(0.5, 1.0), // Marker oyog'ining pastki qismi joyni belgilaydi
          infoWindow: InfoWindow(title: 'Uchrashuv joyi'),
          onTap: () {
            // Marker bosilganda amal
          },
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
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            initialCameraPosition: _kGooglePlex,
            markers: _markers,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMaps.complete(controller);
            },
            onCameraMove: (CameraPosition position) {
              _startMarkerAnimation();
              setState(() {
                _selectedLocation = position.target;
                _updateMarker();
              });
            },
            onCameraIdle: () {
              // Xarita harakati to'xtaganda markerning pastki qismidagi joyni tanlash
              debugPrint("Tanlangan joy: ${_selectedLocation?.latitude}, ${_selectedLocation?.longitude}");
            },
          ),

          // Animatsion halqa effekti
          if (_isMarkerAnimating)
            Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.withAlpha((0.2 * 255).toInt()),
                  border: Border.all(color: Colors.blue, width: 2),
                ),
              ),
            ),

          // Pastki panel
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

  Column _buildButton(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withAlpha(51),
            border: Border.all(color: Colors.white, width: 4),
          ),
          child: Icon(icon, size: 30, color: Colors.white),
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
