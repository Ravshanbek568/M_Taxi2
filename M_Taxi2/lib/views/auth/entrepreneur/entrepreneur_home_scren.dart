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

  // 🔹 Haydovchi tanlagan rejim
  String _mode = "RconneX Taxi";

  // 🔹 Mahalliy taxi holati
  String _localStatus = "Bo'sh";

  // 🔹 Online/Offline holat
  bool _isOnline = true; // Online bo'lsa true, offline bo'lsa false

  // 🔹 Sinov uchun mijozlar ro‘yxati (signal orqali yuborilgan)
  final List<Map<String, String>> _localRequests = [
    {"name": "Mijoz 1", "location": "Xonobod", "distance": "1.2 km"},
    {"name": "Mijoz 2", "location": "Asaka yo‘li", "distance": "2.5 km"},
    {"name": "Mijoz 3", "location": "Andijon markazi", "distance": "3.0 km"},
    {"name": "Mijoz 4", "location": "Qo‘rg‘ontepa", "distance": "4.1 km"},
  ];

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

  // 🔹 Foydalanuvchi info paneli (yuqori o'ng)
  Widget _buildUserInfoPanel() {
    return Positioned(
      top: 40,
      right: 15,
      child: Column(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=3"),
          ),
          const SizedBox(height: 4),
          const Text(
            "Ravshanbek Alimov",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Online/Offline holat paneli (yuqori chap)
  Widget _buildOnlineStatusPanel() {
    return Positioned(
      top: 50,
      left: 15,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isOnline = !_isOnline; // holatni almashtirish
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _isOnline ? Colors.green : Colors.red,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _isOnline ? "Online" : "Offline",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  // 🔹 Rejim tanlash (RconneX yoki Mahalliy)
  Widget _buildModeSelector() {
    return Positioned(
      top: 120,
      right: 15,
      child: DropdownButton<String>(
        value: _mode,
        items: const [
          DropdownMenuItem(value: "RconneX Taxi", child: Text("🚖 RconneX Taxi")),
          DropdownMenuItem(value: "Mahalliy Taxi", child: Text("🚕 Mahalliy Taxi")),
        ],
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _mode = value;
            });
          }
        },
      ),
    );
  }

  // 🔹 Mahalliy taxi paneli
  Widget _buildLocalTaxiPanel() {
    if (_mode != "Mahalliy Taxi") return const SizedBox.shrink();

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 320,
        padding: const EdgeInsets.all(12),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Holat tugmalari
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statusButton("Bo'sh"),
                _statusButton("Band"),
                _statusButton("Navbatda"),
                _statusButton("Yo‘nalishda"),
              ],
            ),
            const SizedBox(height: 10),

            const Text("📍 Yaqin mijozlar:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            Expanded(
              child: ListView.builder(
                itemCount: _localRequests.length,
                itemBuilder: (context, index) {
                  final req = _localRequests[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(req["name"]!),
                      subtitle: Text("${req["location"]} • ${req["distance"]}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () {
                              // TODO: Qabul qilish — mijozni navbatga qo'shish va xaritada marshrut chizish
                            },
                            child: const Text("Qabul qilish"),
                          ),
                          TextButton(
                            onPressed: () {
                              // TODO: Rad etish — serverga rad qilish signalini jo'natish
                            },
                            child: const Text("Rad etish"),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Holat tugmalari uchun widget
  Widget _statusButton(String status) {
    final isActive = _localStatus == status;
    return GestureDetector(
      onTap: () {
        setState(() {
          _localStatus = status;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue.shade600 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          status,
          style: TextStyle(color: isActive ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  // 🔹 Pastki menyu
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

          _buildUserInfoPanel(),
          _buildOnlineStatusPanel(), // 🔹 Yangi qo'shildi
          _buildModeSelector(),
          _buildLocalTaxiPanel(),

          // 🔹 Pastki menyu
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 100,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
