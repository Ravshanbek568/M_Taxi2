import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SelectDestinationPage extends StatefulWidget {
  final LatLng aPoint; // Starting point (A)

  const SelectDestinationPage({super.key, required this.aPoint});

  @override
  State<SelectDestinationPage> createState() => _SelectDestinationPageState();
}

class _SelectDestinationPageState extends State<SelectDestinationPage>
    with SingleTickerProviderStateMixin {
  late GoogleMapController _mapController;
  late AnimationController _animationController;
  late Animation<double> _liftAnimation;
  LatLng? _bPoint; // Destination point (B)

  @override
  void initState() {
    super.initState();

    // Initialize marker animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _liftAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onCameraIdle() async {
    // Get center point of the map when camera stops moving
    final center = await _mapController.getLatLng(
      ScreenCoordinate(
        x: MediaQuery.of(context).size.width ~/ 2,
        y: MediaQuery.of(context).size.height ~/ 2,
      ),
    );

    setState(() {
      _bPoint = center;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Destination"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: widget.aPoint,
              zoom: 15,
            ),
            onCameraIdle: _onCameraIdle,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),

          // Animated marker
          Align(
            alignment: Alignment.center,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Padding(
                  padding: EdgeInsets.only(bottom: _liftAnimation.value + 35),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Marker shadow
                      Container(
                        width: 45,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(0, 0, 0, 0.25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      // Marker icon
                      Image.asset(
                        'assets/images/final.png',
                        width: 50,
                        height: 50,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Search bar
          Positioned(
            top: 20,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(25), // 10% opacity
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: "Enter destination",
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: Colors.blue),
                ),
                readOnly: true,
              ),
            ),
          ),

          // Bottom panel with location info
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Location info box
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(25), // 10% opacity
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Starting point
                      Text(
                        "📍 From: ${widget.aPoint.latitude.toStringAsFixed(5)}, ${widget.aPoint.longitude.toStringAsFixed(5)}",
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      // Destination point
                      Text(
                        "📍 To: ${_bPoint != null ? "${_bPoint!.latitude.toStringAsFixed(5)}, ${_bPoint!.longitude.toStringAsFixed(5)}" : "Not selected"}",
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Confirm button
                ElevatedButton.icon(
                  onPressed: _bPoint == null
                      ? null
                      : () {
                          Navigator.pop(context, _bPoint);
                        },
                  icon: const Icon(Icons.check),
                  label: const Text("Confirm"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}