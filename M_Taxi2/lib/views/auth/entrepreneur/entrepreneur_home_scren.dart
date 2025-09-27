import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// 🔹 Tadbirkor (entrepreneur) asosiy ekrani - holatni saqlaydigan widget
class EntrepreneurHomeScreen extends StatefulWidget {
  const EntrepreneurHomeScreen({super.key});

  @override
  State<EntrepreneurHomeScreen> createState() => _EntrepreneurHomeScreenState();
}

// 🔹 Asosiy ekranning holatini boshqaruvchi class
class _EntrepreneurHomeScreenState extends State<EntrepreneurHomeScreen> {
  // 🔹 Xaritaning boshlang'ich pozitsiyasi (Andijon markazi)
  final LatLng _initialPosition = const LatLng(40.7828647, 72.3442279);

  // 🔹 Xaritadagi markerlar to'plami
  final Set<Marker> _markers = {};

  // 🔹 Haydovchi tanlagan ish rejimi (RconneX yoki Mahalliy Taxi)
  String _mode = "RconneX Taxi";

  // 🔹 Mahalliy taxi holati (Bo'sh, Band, Navbatda, Yo'nalishda)
  String _localStatus = "Bo'sh";

  // 🔹 Onlayn/Offlayn holatni aniqlovchi flag
  bool _isOnline = true;

  // 🔹 Faol pastki konteynerni aniqlash (chat, stats, orders, settings)
  String _activeBottomContainer = "";

  // 🔹 Chat turini tanlash (Mijozlar yoki Admin)
  String _chatType = "Mijozlar";

  // 🔹 Chat xabarlari ro'yxati
  final List<Map<String, dynamic>> _messages = [
    {
      "type": "received",
      "text": "Salom, qachon kelolasiz?",
      "time": "10:30",
      "sender": "Ali Valiyev",
    },
    {
      "type": "sent",
      "text": "5 daqiqada yetib boraman",
      "time": "10:31",
      "sender": "Siz",
    },
    {
      "type": "received",
      "text": "Yaxshi, kutaman",
      "time": "10:32",
      "sender": "Ali Valiyev",
    },
  ];

  // 🔹 Statistika ma'lumotlari
  final Map<String, dynamic> _stats = {
    "monthly_orders": 156,
    "total_distance": 2450,
    "monthly_earnings": 8250000,
    "rating": 4.8,
    "completed_trips": 142,
    "canceled_trips": 14,
  };

  // 🔹 RconneX buyurtmalari ro'yxati
  final List<Map<String, dynamic>> _rconnexOrders = [
    {
      "id": "#RCX-001",
      "customer": "Dilshod Rashidov",
      "from": "Andijon markazi",
      "to": "Xonobod tumani",
      "distance": "12.5 km",
      "price": "25,000 so'm",
      "time": "15 min",
      "status": "waiting",
    },
    {
      "id": "#RCX-002",
      "customer": "Shahzod Bekmurodov",
      "from": "Asaka yo'li",
      "to": "Bozor",
      "distance": "8.2 km",
      "price": "18,000 so'm",
      "time": "10 min",
      "status": "waiting",
    },
  ];

  // 🔹 Sozlamalar ro'yxati
  final List<Map<String, dynamic>> _settingsItems = [
    {
      "icon": Icons.person,
      "title": "Profil ma'lumotlari",
      "subtitle": "Shaxsiy ma'lumotlarni yangilash",
    },
    {
      "icon": Icons.credit_card,
      "title": "To'lov tizimi",
      "subtitle": "Karta va naqd pul sozlamalari",
    },
    {
      "icon": Icons.notifications,
      "title": "Bildirishnomalar",
      "subtitle": "Xabarlarni boshqarish",
    },
    {
      "icon": Icons.security,
      "title": "Xavfsizlik",
      "subtitle": "Parol va kirish sozlamalari",
    },
    {
      "icon": Icons.car_repair,
      "title": "Mashina ma'lumotlari",
      "subtitle": "Transport vositasini yangilash",
    },
    {
      "icon": Icons.help,
      "title": "Yordam va qo'llab-quvvatlash",
      "subtitle": "Savol va takliflar",
    },
  ];

  // 🔹 Sinov uchun mahalliy so'rovlar ro'yxati
  final List<Map<String, String>> _localRequests = [
    {"name": "Mijoz 1", "location": "Xonobod", "distance": "1.2 km"},
    {"name": "Mijoz 2", "location": "Asaka yo'li", "distance": "2.5 km"},
    {"name": "Mijoz 3", "location": "Andijon markazi", "distance": "3.0 km"},
    {"name": "Mijoz 4", "location": "Qo'rg'ontepa", "distance": "4.1 km"},
  ];

  // 🔹 Xarita yaratilganda chaqiriladigan funksiya
  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      // 🔹 Marker qo'shish - haydovchining joylashuvi
      _markers.add(
        Marker(
          markerId: const MarkerId("entrepreneur_location"),
          position: _initialPosition,
          infoWindow: const InfoWindow(
            title: "Sizning joylashuvingiz",
            snippet: "Entrepreneur faoliyati",
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    });
  }

  // 🔹 Foydalanuvchi ma'lumotlari paneli (yuqori o'ng burchak)
  Widget _buildUserInfoPanel() {
    return Positioned(
      top: 40,
      right: 15,
      child: Column(
        children: [
          // 🔹 Foydalanuvchi avatari
          const CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=3"),
          ),
          const SizedBox(height: 4),
          // 🔹 Foydalanuvchi ismi
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

  // 🔹 Onlayn/Offlayn holat paneli (yuqori chap burchak)
  Widget _buildOnlineStatusPanel() {
    return Positioned(
      top: 50,
      left: 15,
      child: GestureDetector(
        onTap: () {
          // 🔹 Holatni o'zgartirish
          setState(() {
            _isOnline = !_isOnline;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _isOnline ? Colors.green : Colors.red,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                // 0.1 opacity -> 0.1 * 255 ≈ 25.5 -> round() -> 26
                color: Colors.black.withAlpha((0.1 * 255).round()),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                _isOnline ? Icons.online_prediction : Icons.offline_bolt,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                _isOnline ? "Online" : "Offline",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Ish rejimini tanlash paneli (RconneX yoki Mahalliy Taxi)
  Widget _buildModeSelector() {
    return Positioned(
      top: 120,
      right: 15,
      child: DropdownButton<String>(
        value: _mode,
        items: const [
          DropdownMenuItem(
            value: "RconneX Taxi",
            child: Text("🚖 RconneX Taxi"),
          ),
          DropdownMenuItem(
            value: "Mahalliy Taxi",
            child: Text("🚕 Mahalliy Taxi"),
          ),
        ],
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _mode = value;
              // 🔹 Mahalliy Taxi rejimiga o'tganda buyurtmalar konteynerini yopish
              if (_mode == "Mahalliy Taxi") {
                _activeBottomContainer = "";
              }
            });
          }
        },
      ),
    );
  }

  // 🔹 Mahalliy taxi paneli (faqat Mahalliy Taxi rejimida ko'rinadi)
  Widget _buildLocalTaxiPanel() {
    // 🔹 Agar rejim Mahalliy Taxi bo'lmasa, hech narsa ko'rsatma
    if (_mode != "Mahalliy Taxi") return const SizedBox.shrink();

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 320,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              // 0.1 opacity -> 0.1 * 255 ≈ 25.5 -> round() -> 26
              color: Colors.black.withAlpha((0.1 * 255).round()),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Holat tugmalari qatori
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statusButton("Bo'sh"),
                _statusButton("Band"),
                _statusButton("Navbatda"),
                _statusButton("Yo'nalishda"),
              ],
            ),
            const SizedBox(height: 12),
            // 🔹 Yaqin mijozlar sarlavhasi
            const Text(
              "📍 Yaqin mijozlar:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            // 🔹 Mijozlar ro'yxati
            Expanded(
              child: ListView.builder(
                itemCount: _localRequests.length,
                itemBuilder: (context, index) {
                  final req = _localRequests[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    elevation: 2,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: Text(
                          "${index + 1}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(
                        req["name"]!,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text("${req["location"]} • ${req["distance"]}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 🔹 Qabul qilish tugmasi
                          ElevatedButton(
                            onPressed: () {
                              _acceptLocalOrder(index);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            child: const Text(
                              "Qabul",
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          const SizedBox(width: 4),
                          // 🔹 Rad etish tugmasi
                          ElevatedButton(
                            onPressed: () {
                              _rejectLocalOrder(index);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            child: const Text(
                              "Rad",
                              style: TextStyle(fontSize: 12),
                            ),
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

  // 🔹 Holat tugmasi uchun yordamchi widget
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
          color: isActive ? Colors.blue.shade600 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Colors.blue.shade600 : Colors.grey.shade300,
          ),
        ),
        child: Text(
          status,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // 🔹 Pastki menyu tugmasi uchun yordamchi widget
  Widget _bottomMenuButton(String label, IconData icon, String id) {
    return GestureDetector(
      onTap: () {
        setState(() {
          // 🔹 Agar tugma allaqachon faol bo'lsa, yopish
          if (_activeBottomContainer == id) {
            _activeBottomContainer = "";
          } else {
            // 🔹 Aks holda yangi konteynerni ochish
            _activeBottomContainer = id;
          }
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🔹 Tugma ikonkasi
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color:
                  _activeBottomContainer == id
                      ? Colors.blue.shade600
                      : Colors.blue.shade100,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  // 0.1 opacity -> 0.1 * 255 ≈ 25.5 -> round() -> 26
                  color: Colors.black.withAlpha((0.1 * 255).round()),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color:
                  _activeBottomContainer == id
                      ? Colors.white
                      : Colors.blue.shade800,
            ),
          ),
          const SizedBox(height: 6),
          // 🔹 Tugma yorlig'i
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight:
                  _activeBottomContainer == id
                      ? FontWeight.bold
                      : FontWeight.normal,
              color:
                  _activeBottomContainer == id
                      ? Colors.blue.shade800
                      : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Chat xabari uchun widget
  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isSent = message["type"] == "sent";
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isSent) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey.shade300,
              child: Text(
                message["sender"][0],
                style: const TextStyle(fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSent ? Colors.blue.shade600 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isSent)
                  Text(
                    message["sender"],
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                Text(
                  message["text"],
                  style: TextStyle(color: isSent ? Colors.white : Colors.black),
                ),
                const SizedBox(height: 2),
                Text(
                  message["time"],
                  style: TextStyle(
                    fontSize: 10,
                    color:
                        isSent
                            ? Colors.white.withAlpha((0.7 * 255).round())
                            : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          if (isSent) const SizedBox(width: 8),
        ],
      ),
    );
  }

  // 🔹 Statistika kartasi uchun widget
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(12),
        width: 110,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Buyurtma kartasi uchun widget
  Widget _buildOrderCard(Map<String, dynamic> order) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order["id"],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order["status"],
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Mijoz: ${order["customer"]}",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.green.shade600, size: 16),
                const SizedBox(width: 4),
                Expanded(child: Text("Dan: ${order["from"]}")),
              ],
            ),
            Row(
              children: [
                Icon(Icons.flag, color: Colors.red.shade600, size: 16),
                const SizedBox(width: 4),
                Expanded(child: Text("Gacha: ${order["to"]}")),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.directions_car,
                      color: Colors.grey.shade600,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(order["distance"]),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: Colors.grey.shade600,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(order["time"]),
                  ],
                ),
                Text(
                  order["price"],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _acceptOrder(order["id"]),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text(
                      "Qabul qilish",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _rejectOrder(order["id"]),
                    child: const Text("Rad etish"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Pastki konteynerlarni qurish
  Widget _buildBottomContainer() {
    // 🔹 Agar hech qanday konteyner faol bo'lmasa, hech narsa ko'rsatma
    if (_activeBottomContainer.isEmpty) return const SizedBox.shrink();

    double containerHeight = MediaQuery.of(context).size.height * 0.7;
    Widget content;

    // 🔹 Faol konteyner turiga qarab kontentni tanlash
    switch (_activeBottomContainer) {
      case "chat":
        content = Column(
          children: [
            // 🔹 Chat turini tanlash paneli
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Xabarlar",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      // 🔹 Mijozlar chat tugmasi
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _chatType = "Mijozlar";
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color:
                                _chatType == "Mijozlar"
                                    ? Colors.blue.shade600
                                    : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "Mijozlar",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 🔹 Admin chat tugmasi
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _chatType = "Admin";
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color:
                                _chatType == "Admin"
                                    ? Colors.blue.shade600
                                    : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Admin",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // 🔹 Yopish tugmasi
                  IconButton(
                    icon: const Icon(Icons.close, size: 24),
                    onPressed: () {
                      setState(() {
                        _activeBottomContainer = "";
                      });
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // 🔹 Chat oynasi
            Expanded(
              child: Column(
                children: [
                  // 🔹 Chat xabarlari
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        return _buildMessageBubble(_messages[index]);
                      },
                    ),
                  ),
                  // 🔹 Xabar yuborish paneli
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.grey.shade100,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: "Xabar yozing...",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        CircleAvatar(
                          backgroundColor: Colors.blue.shade600,
                          child: IconButton(
                            icon: const Icon(Icons.send, color: Colors.white),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
        break;

      case "stats":
        content = Column(
          children: [
            // 🔹 Sarlavha va yopish tugmasi
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Statistika",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 24),
                    onPressed: () {
                      setState(() {
                        _activeBottomContainer = "";
                      });
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // 🔹 Statistika ma'lumotlari
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // 🔹 Asosiy statistika kartalari
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildStatCard(
                          "Oylik buyurtmalar",
                          "${_stats['monthly_orders']} ta",
                          Icons.shopping_cart,
                          Colors.blue,
                        ),
                        _buildStatCard(
                          "Umumiy masofa",
                          "${_stats['total_distance']} km",
                          Icons.directions_car,
                          Colors.green,
                        ),
                        _buildStatCard(
                          "Oylik daromad",
                          "${_stats['monthly_earnings']} so'm",
                          Icons.attach_money,
                          Colors.orange,
                        ),
                        _buildStatCard(
                          "Reyting",
                          _stats['rating'].toString(),
                          Icons.star,
                          Colors.amber,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // 🔹 Qo'shimcha statistika
                    Card(
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Batafsil statistika",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildStatRow(
                              "Yakunlangan safarlar",
                              "${_stats['completed_trips']} ta",
                            ),
                            _buildStatRow(
                              "Bekor qilingan safarlar",
                              "${_stats['canceled_trips']} ta",
                            ),
                            _buildStatRow(
                              "O'rtacha baho",
                              _stats['rating'].toString(),
                            ),
                            _buildStatRow("Faol kunlar", "28 kun"),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
        break;

      case "orders":
        content = Column(
          children: [
            // 🔹 Sarlavha va yopish tugmasi
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Buyurtmalar",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 24),
                    onPressed: () {
                      setState(() {
                        _activeBottomContainer = "";
                      });
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // 🔹 Buyurtmalar ro'yxati (RconneX Taxi uchun)
            Expanded(
              child:
                  _mode == "RconneX Taxi"
                      ? Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // 🔹 Filtr tugmalari
                            Row(
                              children: [
                                FilterChip(
                                  label: const Text("Barchasi"),
                                  selected: true,
                                  onSelected: (bool value) {},
                                ),
                                const SizedBox(width: 8),
                                FilterChip(
                                  label: const Text("Yangi"),
                                  selected: false,
                                  onSelected: (bool value) {},
                                ),
                                const SizedBox(width: 8),
                                FilterChip(
                                  label: const Text("Jarayonda"),
                                  selected: false,
                                  onSelected: (bool value) {},
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // 🔹 Buyurtmalar ro'yxati
                            Expanded(
                              child: ListView.builder(
                                itemCount: _rconnexOrders.length,
                                itemBuilder: (context, index) {
                                  return _buildOrderCard(_rconnexOrders[index]);
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                      : Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.local_taxi,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "Mahalliy Taxi rejimi faol",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Mahalliy buyurtmalar avtomatik ravishda asosiy ekranda ko'rsatiladi",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
            ),
          ],
        );
        break;

      case "settings":
        content = Column(
          children: [
            // 🔹 Sarlavha va yopish tugmasi
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Sozlamalar",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 24),
                    onPressed: () {
                      setState(() {
                        _activeBottomContainer = "";
                      });
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // 🔹 Sozlamalar ro'yxati
            Expanded(
              child: ListView.builder(
                itemCount: _settingsItems.length,
                itemBuilder: (context, index) {
                  final item = _settingsItems[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    elevation: 1,
                    child: ListTile(
                      leading: Icon(item["icon"], color: Colors.blue.shade600),
                      title: Text(
                        item["title"],
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        item["subtitle"],
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        _navigateToSetting(item["title"]);
                      },
                    ),
                  );
                },
              ),
            ),
            // 🔹 Chiqish tugmasi
            Container(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("Chiqish", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        );
        break;

      default:
        content = const SizedBox.shrink();
    }

    // 🔹 Konteynerni ekranning pastki qismida ko'rsatish
    return Align(
      alignment: Alignment.bottomCenter,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: containerHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.3 * 255).round()),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: content,
      ),
    );
  }

  // 🔹 Statistika qatori uchun yordamchi widget
  Widget _buildStatRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // 🔹 Asosiy UI qurilishi
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🔹 Asosiy Google Xarita
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

          // 🔹 Foydalanuvchi ma'lumotlari paneli
          _buildUserInfoPanel(),

          // 🔹 Onlayn/Offlayn holat paneli
          _buildOnlineStatusPanel(),

          // 🔹 Rejim tanlovi paneli
          _buildModeSelector(),

          // 🔹 Mahalliy Taxi paneli (faqat Mahalliy Taxi rejimida ko'rinadi)
          _buildLocalTaxiPanel(),

          // 🔹 Pastki konteynerlar (chat, stats, orders, settings)
          _buildBottomContainer(),

          // 🔹 Pastki menyu paneli
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 100,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.2 * 255).round()),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // 🔹 Pastki menyu tugmalari
                  _bottomMenuButton("Xabarlar", Icons.chat, "chat"),
                  _bottomMenuButton("Statistika", Icons.bar_chart, "stats"),
                  _bottomMenuButton("Buyurtmalar", Icons.list_alt, "orders"),
                  _bottomMenuButton("Sozlamalar", Icons.settings, "settings"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 FUNKTSIYALAR

  void _acceptLocalOrder(int index) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Buyurtma qabul qilish"),
            content: Text(
              "${_localRequests[index]['name']} ning buyurtmasini qabul qilishni tasdiqlaysizmi?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Bekor qilish"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "${_localRequests[index]['name']} buyurtmasi qabul qilindi",
                      ),
                    ),
                  );
                },
                child: const Text("Tasdiqlash"),
              ),
            ],
          ),
    );
  }

  void _rejectLocalOrder(int index) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Buyurtmani rad etish"),
            content: Text(
              "${_localRequests[index]['name']} ning buyurtmasini rad etishni tasdiqlaysizmi?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Bekor qilish"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "${_localRequests[index]['name']} buyurtmasi rad etildi",
                      ),
                    ),
                  );
                },
                child: const Text("Rad etish"),
              ),
            ],
          ),
    );
  }

  void _acceptOrder(String orderId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$orderId buyurtmasi qabul qilindi")),
    );
  }

  void _rejectOrder(String orderId) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("$orderId buyurtmasi rad etildi")));
  }

  void _navigateToSetting(String setting) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$setting sozlamasiga o'tilmoqda...")),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Chiqish"),
            content: const Text("Ilovadan chiqishni tasdiqlaysizmi?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Bekor qilish"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Chiqish amalga oshirildi")),
                  );
                },
                child: const Text("Chiqish"),
              ),
            ],
          ),
    );
  }
}
