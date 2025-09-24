import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class EntrepreneurHomeScreen extends StatefulWidget {
  const EntrepreneurHomeScreen({super.key});

  @override
  State<EntrepreneurHomeScreen> createState() => _EntrepreneurHomeScreenState();
}

class _EntrepreneurHomeScreenState extends State<EntrepreneurHomeScreen> {
  final LatLng _initialPosition = const LatLng(40.7828647, 72.3442279); // Andijon markazi
  final Set<Marker> _markers = {};

  // 🔹 Haydovchi holati
  String _driverStatus = "Available"; 

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _markers.add(
        Marker(
          markerId: const MarkerId("entrepreneur_location"),
          position: _initialPosition,
          infoWindow: const InfoWindow(
            title: "Sizning joylashuvingiz",
            snippet: "Entrepreneur faoliyati",
          ),
        ),
      );
    });
  }

  // 🔹 Foydalanuvchi info paneli (avatar + ism-familiya + lavozim)
  Widget _buildUserInfoPanel() {
    return Positioned(
      top: 40,
      right: 15,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(
                "https://i.pravatar.cc/150?img=3"), // foydalanuvchi avatari
          ),
          const SizedBox(height: 8),
          const Text(
            "Ravshanbek Alimov",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          // const Text(
          //   "Haydovchi",
          //   style: TextStyle(
          //     color: Colors.grey,
          //     fontSize: 12,
          //   ),
          // ),
        ],
      ),
    );
  }

  // 🔹 Status paneli (haydovchi holati)
  Widget _buildStatusPanel() {
    return Positioned(
      top: 120, // foydalanuvchi paneli ostida
      right: 15,
      child: DropdownButton<String>(
        value: _driverStatus,
        items: const [
          DropdownMenuItem(value: "Available", child: Text("🟢 Mavjud")),
          DropdownMenuItem(value: "On a ride", child: Text("🟡 Yo‘lda")),
          DropdownMenuItem(value: "Busy", child: Text("🔴 Band")),
          DropdownMenuItem(value: "Queue Mode", child: Text("📍 Navbatda")),
        ],
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _driverStatus = value;
            });
          }
        },
      ),
    );
  }

  // 🔹 Pastki menyu tugmalari
  Widget _bottomMenuButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.blue.shade600,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 14.5,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),

          // 🔹 Foydalanuvchi info paneli
          _buildUserInfoPanel(),

          // 🔹 Status paneli
          _buildStatusPanel(),

          // 🔹 Pastki menyu
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _bottomMenuButton(Icons.store, "Xizmatlar", () {}),
                  _bottomMenuButton(Icons.bar_chart, "Statistika", () {}),
                  _bottomMenuButton(Icons.notifications, "Buyurtmalar", () {}),
                  _bottomMenuButton(Icons.settings, "Sozlamalar", () {}),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
