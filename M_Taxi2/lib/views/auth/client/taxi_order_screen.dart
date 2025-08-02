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
  LatLng? _selectedLocationA;
  LatLng? _selectedLocationB;
  LatLng? _currentUserLocation;
  bool _isLocationLoading = false;
  bool _isDirectionInputOpen = false;
  Set<Marker> _markers = {};
  final TextEditingController _searchController = TextEditingController();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(40.8008333, 72.9881418),
    zoom: 17.0,
  );

  @override
  void initState() {
    super.initState();
    _selectedLocationA = _kGooglePlex.target;
    _updateMarkers();
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
        _selectedLocationA = _currentUserLocation;
        _updateMarkers();
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

  void _updateMarkers() {
    setState(() {
      _markers = {};
      
      if (_selectedLocationA != null) {
        _markers.add(
          Marker(
            markerId: const MarkerId('point_A'),
            position: _selectedLocationA!,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            anchor: const Offset(0.5, 1.0),
            infoWindow: const InfoWindow(title: 'Qayerdan'),
            zIndexInt: 2,
            flat: true,
          ),
        );
      }
      
      if (_selectedLocationB != null) {
        _markers.add(
          Marker(
            markerId: const MarkerId('point_B'),
            position: _selectedLocationB!,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            anchor: const Offset(0.5, 1.0),
            infoWindow: const InfoWindow(title: 'Qayerga'),
            zIndexInt: 2,
            flat: true,
          ),
        );
      }
    });
  }

  void _openDirectionInput() {
    setState(() {
      _isDirectionInputOpen = true;
    });
  }

  void _closeDirectionInput() {
    setState(() {
      _isDirectionInputOpen = false;
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
            myLocationButtonEnabled: false,
            initialCameraPosition: _kGooglePlex,
            markers: _markers,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMaps.complete(controller);
            },
            onCameraMove: (CameraPosition position) {
              if (_isDirectionInputOpen && _selectedLocationB == null) {
                setState(() {
                  _selectedLocationB = position.target;
                  _updateMarkers();
                });
              }
            },
            onCameraIdle: () {
              debugPrint("Tanlangan joy: ${_selectedLocationA?.latitude}, ${_selectedLocationA?.longitude}");
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

          // Search bar (top)
          if (_isDirectionInputOpen)
            Positioned(
              top: 30,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((0.2 * 255).round()),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: _closeDirectionInput,
                      ),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: "Manzilni kiriting",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Pastki panel
          if (!_isDirectionInputOpen)
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
                        _buildButton(Icons.wifi, "Signal jo'natish", enabled: false),
                        _buildButton(Icons.local_taxi, "Avtomatik taksi", enabled: false),
                        _buildButton(Icons.groups, "Haydovchilar", enabled: false),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _openDirectionInput,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Yo'nalishni kiriting",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                            const Icon(Icons.arrow_forward, color: Colors.blue),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Direction input bottom panel
          if (_isDirectionInputOpen)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
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
                    _buildLocationInput("Qayerdan", _selectedLocationA != null ? "Belgilangan" : "Belgilanmagan"),
                    const SizedBox(height: 16),
                    _buildLocationInput("Qayerga", _selectedLocationB != null ? "Belgilangan" : "Belgilanmagan"),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {
                          // Handle "Boshlash" button press
                        },
                        child: const Text(
                          "Boshlash",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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

  Widget _buildLocationInput(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Column _buildButton(IconData icon, String label, {bool enabled = true}) {
    return Column(
      children: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: enabled ? Colors.white.withAlpha(51) : Colors.white.withAlpha(25),
              border: Border.all(
                color: enabled ? Colors.white : Colors.white.withAlpha((0.5 * 255).round()),
                width: 4,
              ),
            ),
            child: Icon(
              icon,
              size: 30,
              color: enabled ? Colors.white : Colors.white.withAlpha((0.5 * 255).round()),
            ),
          ),
          onPressed: enabled ? () {} : null,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: enabled ? Colors.white : Colors.white.withAlpha((0.5 * 255).round()),
          ),
        ),
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
