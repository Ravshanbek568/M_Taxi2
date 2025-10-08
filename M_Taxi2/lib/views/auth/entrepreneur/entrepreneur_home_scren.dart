import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:m_taksi/views/auth/help_screen.dart';

// Import qilishlar - bu yerda sizning mavjud fayllaringizni import qiling
import 'entrepreneur_profile_screen.dart';
import 'entrepreneur_car_info_screen.dart';
import 'payment_card_registration_screen.dart';
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

  // 🔹 Yangi xabarlar soni
  int _unreadMessagesCount = 3;

  // 🔹 Yangi buyurtmalar soni
  int _newOrdersCount = 2;

  // 🔹 Tanlangan mijoz
  Map<String, dynamic>? _selectedCustomer;

  // 🔹 TextField controllerlari
  final TextEditingController _adminMessageController = TextEditingController();
  final TextEditingController _customerMessageController =
      TextEditingController();

  // 🔹 FocusNode lar
  final FocusNode _adminFocusNode = FocusNode();
  final FocusNode _customerFocusNode = FocusNode();

  // 🔹 ScrollController lar
  final ScrollController _adminScrollController = ScrollController();
  final ScrollController _customerScrollController = ScrollController();

  // 🔹 Vaqt oralig'i filtrlari
  String _currentFilter = "month";

  // 🔹 Buyurtmalar filtri
  String _orderFilter = "all";

  // 🔹 Til sozlamalari
  String _selectedLanguage = "O'zbekcha";
  
  // 🔹 Tema sozlamalari
  String _selectedTheme = "Tungi";

  // 🔹 Admin bilan yozishma
  final List<Map<String, dynamic>> _adminMessages = [
    {
      "type": "received",
      "text": "Assalomu alaykum! Yangi yangiliklar bor.",
      "time": "09:15",
      "sender": "Admin",
    },
    {
      "type": "sent",
      "text": "Va alaykum assalom! Qanday yangiliklar?",
      "time": "09:16",
      "sender": "Siz",
    },
  ];

  // 🔹 Mijozlar ro'yxati (faqat aktiv buyurtmasi bor mijozlar)
  final List<Map<String, dynamic>> _customers = [
    {
      "id": "1",
      "name": "Ali Valiyev",
      "phone": "+998901234567",
      "lastMessage": "Salom, qachon kelolasiz?",
      "time": "10:30",
      "unread": 2,
      "orderId": "#RCX-001",
      "orderActive": true,
    },
    {
      "id": "2",
      "name": "Dilshod Rashidov",
      "phone": "+998907654321",
      "lastMessage": "Manzilni to'g'ri tushundimmi?",
      "time": "09:45",
      "unread": 0,
      "orderId": "#RCX-002",
      "orderActive": true,
    },
    {
      "id": "3",
      "name": "Shahzod Bekmurodov",
      "phone": "+998901112233",
      "lastMessage": "Rahmat, kutaman",
      "time": "Yesterday",
      "unread": 0,
      "orderId": "#RCX-003",
      "orderActive": false,
    },
  ];

  // 🔹 Mijozlar bilan yozishmalar
  final Map<String, List<Map<String, dynamic>>> _customerMessages = {
    "1": [
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
    ],
    "2": [
      {
        "type": "received",
        "text": "Manzilni to'g'ri tushundimmi?",
        "time": "09:45",
        "sender": "Dilshod Rashidov",
      },
      {
        "type": "sent",
        "text": "Ha, to'g'ri. 10 daqiqada yetib boraman",
        "time": "09:46",
        "sender": "Siz",
      },
    ],
  };

  // 🔹 Yangilangan statistika ma'lumotlari
  final Map<String, dynamic> _stats = {
    "monthly_orders": 156,
    "total_distance": 2450,
    "monthly_earnings": 8250000,
    "rating": 4.8,
    "completed_trips": 142,
    "canceled_trips": 14,
    "orders_change": "+12%",
    "distance_change": "+8%",
    "earnings_change": "+15%",
    "reviews_count": 142,
    "working_hours": 8,
    "avg_earnings": 58000,
    "customers_count": 45,
    "online_hours": 180,
    "acceptance_rate": 92,
  };

  // 🔹 RconneX buyurtmalari ro'yxati - YANGILANGAN
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
      "type": "new", // yangi
      "createdAt": DateTime.now().subtract(const Duration(minutes: 5)),
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
      "type": "new", // yangi
      "createdAt": DateTime.now().subtract(const Duration(minutes: 10)),
    },
    {
      "id": "#RCX-003",
      "customer": "Ali Valiyev",
      "from": "Qo'rg'ontepa",
      "to": "Andijon markazi",
      "distance": "15.3 km",
      "price": "30,000 so'm",
      "time": "20 min",
      "status": "active",
      "type": "active", // faol
      "createdAt": DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      "id": "#RCX-004",
      "customer": "Olimjon Sobirov",
      "from": "Bozor",
      "to": "Asaka yo'li",
      "distance": "7.8 km",
      "price": "16,000 so'm",
      "time": "12 min",
      "status": "completed",
      "type": "completed", // yakunlangan
      "createdAt": DateTime.now().subtract(const Duration(days: 1)),
    },
    {
      "id": "#RCX-005",
      "customer": "Javohir Rasulov",
      "from": "Xonobod",
      "to": "Qo'rg'ontepa",
      "distance": "18.1 km",
      "price": "35,000 so'm",
      "time": "25 min",
      "status": "rejected",
      "type": "rejected", // rad etilgan
      "createdAt": DateTime.now().subtract(const Duration(days: 2)),
    },
  ];

  // 🔹 YANGILANGAN SOZLAMALAR RO'YXATI - BILDIRISHNOMALAR OLIB TASHLANDI
  final List<Map<String, dynamic>> _settingsItems = [
    {
      "icon": Icons.person,
      "title": "Profil ma'lumotlari",
      "subtitle": "Shaxsiy ma'lumotlarni yangilash",
      "type": "navigation",
      "screen": "profile"
    },
    {
      "icon": Icons.car_repair,
      "title": "Mashina ma'lumotlari",
      "subtitle": "Transport vositasini yangilash",
      "type": "navigation", 
      "screen": "car_info"
    },
    {
      "icon": Icons.credit_card,
      "title": "To'lov tizimi",
      "subtitle": "Karta va naqd pul sozlamalari",
      "type": "navigation",
      "screen": "payment"
    },
    {
      "icon": Icons.settings_applications,
      "title": "Ilova sozlamalari",
      "subtitle": "Til va tema sozlamalari",
      "type": "settings"
    },
    {
      "icon": Icons.help,
      "title": "Yordam va qo'llab-quvvatlash",
      "subtitle": "Savol va takliflar",
      "type": "navigation",
      "screen": "help_screen" // 🔹 YANGILANDI: help_screen.dart ga o'tish
    },
  ];

  // 🔹 Sinov uchun mahalliy so'rovlar ro'yxati
  final List<Map<String, dynamic>> _localRequests = [
    {"name": "Mijoz 1", "location": "Xonobod", "distance": "1.2 km"},
    {"name": "Mijoz 2", "location": "Asaka yo'li", "distance": "2.5 km"},
    {"name": "Mijoz 3", "location": "Andijon markazi", "distance": "3.0 km"},
    {"name": "Mijoz 4", "location": "Qo'rg'ontepa", "distance": "4.1 km"},
  ];

  // 🔹 Xarita yaratilganda chaqiriladigan funksiya
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
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _adminFocusNode.addListener(_onKeyboardChanged);
    _customerFocusNode.addListener(_onKeyboardChanged);

    // 🔹 ScrollController larni tinglash
    _adminScrollController.addListener(_scrollListener);
    _customerScrollController.addListener(_scrollListener);

    // 🔹 Yangi buyurtmalar sonini hisoblash
    _updateNewOrdersCount();
  }

  @override
  void dispose() {
    _adminMessageController.dispose();
    _customerMessageController.dispose();
    _adminFocusNode.dispose();
    _customerFocusNode.dispose();
    _adminScrollController.dispose();
    _customerScrollController.dispose();
    super.dispose();
  }

  void _onKeyboardChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _scrollListener() {
    // 🔹 Scroll qilinganda klaviatura yopilishi
    if (_adminFocusNode.hasFocus) {
      _adminFocusNode.unfocus();
    }
    if (_customerFocusNode.hasFocus) {
      _customerFocusNode.unfocus();
    }
  }

  // 🔹 Xabar yuborilganda pastga skroll qilish
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _adminScrollController.animateTo(
        _adminScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      _customerScrollController.animateTo(
        _customerScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  // 🔹 Yangi buyurtmalar sonini yangilash
  void _updateNewOrdersCount() {
    int count = _rconnexOrders.where((order) => order["type"] == "new").length;
    setState(() {
      _newOrdersCount = count;
    });
  }

  // 🔹 Buyurtma qabul qilish
  void _acceptOrder(String orderId) {
    setState(() {
      var order = _rconnexOrders.firstWhere((order) => order["id"] == orderId);
      order["type"] = "active";
      order["status"] = "active";
      _updateNewOrdersCount();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$orderId buyurtmasi qabul qilindi"),
        backgroundColor: Colors.green,
      ),
    );
  }

  // 🔹 Buyurtmani rad etish
  void _rejectOrder(String orderId) {
    setState(() {
      var order = _rconnexOrders.firstWhere((order) => order["id"] == orderId);
      order["type"] = "rejected";
      order["status"] = "rejected";
      _updateNewOrdersCount();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$orderId buyurtmasi rad etildi"),
        backgroundColor: Colors.red,
      ),
    );
  }

  // 🔹 Buyurtmani yakunlash
  void _completeOrder(String orderId) {
    setState(() {
      var order = _rconnexOrders.firstWhere((order) => order["id"] == orderId);
      order["type"] = "completed";
      order["status"] = "completed";
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$orderId buyurtmasi yakunlandi"),
        backgroundColor: Colors.blue,
      ),
    );
  }

  // ========== YANGILANGAN BUYURTMALAR KONTEYNERI ==========

  Widget _buildOrdersContainer() {
    return Column(
      children: [
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

        // 🔹 Filtr tugmalari
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildOrderFilterChip("Barchasi", "all"),
                const SizedBox(width: 8),
                _buildOrderFilterChip("Yangi", "new"),
                const SizedBox(width: 8),
                _buildOrderFilterChip("Faol", "active"),
                const SizedBox(width: 8),
                _buildOrderFilterChip("Yakunlangan", "completed"),
                const SizedBox(width: 8),
                _buildOrderFilterChip("Rad etilgan", "rejected"),
              ],
            ),
          ),
        ),

        const Divider(height: 1),
        Expanded(
          child:
              _mode == "RconneX Taxi"
                  ? _buildRconnexOrdersList()
                  : _buildLocalTaxiOrders(),
        ),
      ],
    );
  }

  // 🔹 Buyurtma filtri chipi
  Widget _buildOrderFilterChip(String label, String value) {
    final isSelected = _orderFilter == value;
    final hasNewOrders = value == "new" && _newOrdersCount > 0;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (hasNewOrders) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              child: Text(
                _newOrdersCount > 9 ? "9+" : _newOrdersCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      selected: isSelected,
      onSelected: (bool selected) {
        setState(() {
          _orderFilter = value;
        });
      },
      backgroundColor: Colors.grey.shade100,
      selectedColor: Colors.blue.shade100,
      checkmarkColor: Colors.blue.shade600,
      labelStyle: TextStyle(
        color: isSelected ? Colors.blue.shade600 : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  // 🔹 RconneX buyurtmalari ro'yxati
  Widget _buildRconnexOrdersList() {
    List<Map<String, dynamic>> filteredOrders = _rconnexOrders;

    if (_orderFilter != "all") {
      filteredOrders =
          _rconnexOrders
              .where((order) => order["type"] == _orderFilter)
              .toList();
    }

    // 🔹 Vaqt bo'yicha tartiblash (yangi buyurtmalar birinchi)
    filteredOrders.sort((a, b) => b["createdAt"].compareTo(a["createdAt"]));

    return filteredOrders.isEmpty
        ? _buildEmptyOrdersState()
        : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredOrders.length,
          itemBuilder: (context, index) {
            return _buildEnhancedOrderCard(filteredOrders[index]);
          },
        );
  }

  // 🔹 Bo'sh buyurtmalar holati
  Widget _buildEmptyOrdersState() {
    String message = "";
    IconData icon = Icons.list_alt;

    switch (_orderFilter) {
      case "new":
        message = "Hozircha yangi buyurtmalar yo'q";
        icon = Icons.new_releases_outlined;
        break;
      case "active":
        message = "Hozircha faol buyurtmalar yo'q";
        icon = Icons.directions_car_outlined;
        break;
      case "completed":
        message = "Hozircha yakunlangan buyurtmalar yo'q";
        icon = Icons.check_circle_outline;
        break;
      case "rejected":
        message = "Hozircha rad etilgan buyurtmalar yo'q";
        icon = Icons.cancel_outlined;
        break;
      default:
        message = "Hozircha buyurtmalar yo'q";
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 🔹 Takomillashtirilgan buyurtma kartasi
  Widget _buildEnhancedOrderCard(Map<String, dynamic> order) {
    Color statusColor = Colors.grey;
    Color cardColor = Colors.white;
    String statusText = "";

    switch (order["type"]) {
      case "new":
        statusColor = Colors.orange;
        cardColor = Colors.orange.shade50;
        statusText = "YANGI";
        break;
      case "active":
        statusColor = Colors.blue;
        cardColor = Colors.blue.shade50;
        statusText = "FAOL";
        break;
      case "completed":
        statusColor = Colors.green;
        cardColor = Colors.green.shade50;
        statusText = "YAKUNLANGAN";
        break;
      case "rejected":
        statusColor = Colors.red;
        cardColor = Colors.red.shade50;
        statusText = "RAD ETILGAN";
        break;
    }

    // 🔹 Vaqt formati
    String timeAgo = _getTimeAgo(order["createdAt"]);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Sarlavha qismi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order["id"],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),

                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // 🔹 Mijoz ma'lumotlari
            Row(
              children: [
                Icon(Icons.person, color: Colors.grey.shade600, size: 16),
                const SizedBox(width: 6),
                Text(
                  order["customer"],
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // 🔹 Manzil ma'lumotlari
            _buildLocationRow("📍 Dan:", order["from"], Colors.green),
            _buildLocationRow("🎯 Gacha:", order["to"], Colors.red),

            const SizedBox(height: 12),

            // 🔹 Statistika qatori
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildOrderStat(
                  "Masofa",
                  order["distance"],
                  Icons.directions_car,
                ),
                _buildOrderStat("Vaqt", order["time"], Icons.access_time),
                _buildOrderStat("Narx", order["price"], Icons.attach_money),
              ],
            ),

            const SizedBox(height: 12),

            // 🔹 Vaqt va amallar qatori
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  timeAgo,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),

                // 🔹 Harakat tugmalari
                if (order["type"] == "new")
                  _buildActionButtons(order["id"], true, false)
                else if (order["type"] == "active")
                  _buildActionButtons(order["id"], false, true)
                else
                  _buildActionButtons(order["id"], false, false),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Manzil qatori
  Widget _buildLocationRow(String prefix, String location, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            prefix,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              location,
              style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Buyurtma statistikasi
  Widget _buildOrderStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  // 🔹 Harakat tugmalari
  Widget _buildActionButtons(String orderId, bool isNew, bool isActive) {
    if (isNew) {
      return Row(
        children: [
          ElevatedButton(
            onPressed: () => _acceptOrder(orderId),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text("Qabul qilish"),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () => _rejectOrder(orderId),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text("Rad etish"),
          ),
        ],
      );
    } else if (isActive) {
      return ElevatedButton(
        onPressed: () => _completeOrder(orderId),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: const Text("Yakunlash"),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  // 🔹 Mahalliy taxi buyurtmalari
  Widget _buildLocalTaxiOrders() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_taxi, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            "Mahalliy Taxi rejimi faol",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Buyurtmalar avtomatik ravishda qabul qilinadi",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 🔹 Vaqtni formatlash
  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return "Hozirgina";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes} daqiqa oldin";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} soat oldin";
    } else {
      return "${difference.inDays} kun oldin";
    }
  }

  // ========== CHAT KONTEYNERI ==========

  Widget _buildChatContainer() {
    if (_selectedCustomer != null) {
      return _buildChatConversation(_selectedCustomer!);
    }

    return Column(
      children: [
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
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _chatType = "Mijozlar";
                        _selectedCustomer = null;
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
                        style: TextStyle(
                          color:
                              _chatType == "Mijozlar"
                                  ? Colors.white
                                  : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _chatType = "Admin";
                        _selectedCustomer = null;
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
                      child: Text(
                        "Admin",
                        style: TextStyle(
                          color:
                              _chatType == "Admin"
                                  ? Colors.white
                                  : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 24),
                onPressed: () {
                  setState(() {
                    _activeBottomContainer = "";
                    _selectedCustomer = null;
                  });
                },
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child:
              _chatType == "Mijozlar"
                  ? _buildCustomersList()
                  : _buildAdminChat(),
        ),
      ],
    );
  }

  Widget _buildCustomersList() {
    final activeCustomers =
        _customers
            .where((customer) => customer["orderActive"] == true)
            .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.info, color: Colors.blue, size: 16),
              const SizedBox(width: 8),
              const Text(
                "Faqat faol buyurtmalar bilan aloqa bog'lash mumkun",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        Expanded(
          child:
              activeCustomers.isEmpty
                  ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Hozircha aktiv mijozlar yo'q",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: activeCustomers.length,
                    itemBuilder: (context, index) {
                      final customer = activeCustomers[index];
                      return _buildCustomerChatItem(customer);
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildCustomerChatItem(Map<String, dynamic> customer) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: 1,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Text(
            customer["name"][0],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Row(
          children: [
            Text(
              customer["name"],
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            if (customer["unread"] > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  customer["unread"].toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              customer["lastMessage"],
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              "Buyurtma: ${customer["orderId"]}",
              style: TextStyle(
                color: Colors.green.shade600,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              customer["time"],
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
            ),
            if (customer["unread"] > 0)
              const Icon(Icons.mark_chat_unread, color: Colors.red, size: 16),
          ],
        ),
        onTap: () {
          setState(() {
            _selectedCustomer = customer;
            customer["unread"] = 0;
            _updateUnreadCount();
          });
        },
      ),
    );
  }

  // 🔹 Admin bilan chat
  Widget _buildAdminChat() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.blue.shade50,
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.support_agent, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Administrator",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "Qo'llab-quvvatlash xizmati",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.phone, color: Colors.green),
                onPressed: _callAdmin,
              ),
            ],
          ),
        ),
        Expanded(
          child:
              _adminMessages.isEmpty
                  ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          "Hozircha xabarlar yo'q",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                  : ListView.builder(
                    controller: _adminScrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _adminMessages.length,
                    itemBuilder: (context, index) {
                      final message = _adminMessages[index];
                      return _buildMessageBubble(message);
                    },
                  ),
        ),
        // 🔹 Xabar yozish maydoni
        _buildMessageInputField(
          controller: _adminMessageController,
          focusNode: _adminFocusNode,
          hintText: "Xabar yozing...",
          onSend: _sendMessageToAdmin,
        ),
      ],
    );
  }

  // 🔹 Yozishma oynasi
  Widget _buildChatConversation(Map<String, dynamic> customer) {
    final messages = _customerMessages[customer["id"]] ?? [];

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _selectedCustomer = null;
                  });
                },
              ),
              CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                child: Text(
                  customer["name"][0],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer["name"],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "Buyurtma: ${customer["orderId"]}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.phone, color: Colors.green),
                onPressed: () => _callCustomer(customer["phone"]),
              ),
            ],
          ),
        ),
        Expanded(
          child:
              messages.isEmpty
                  ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Hozircha xabarlar yo'q",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                  : ListView.builder(
                    controller: _customerScrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return _buildMessageBubble(message);
                    },
                  ),
        ),
        // 🔹 Xabar yozish maydoni
        _buildMessageInputField(
          controller: _customerMessageController,
          focusNode: _customerFocusNode,
          hintText: "Xabar yozing...",
          onSend: () => _sendMessageToCustomer(customer["id"]),
          showQuickReplies: true,
          onQuickReply:
              (text) => _sendQuickReplyToCustomer(customer["id"], text),
        ),
      ],
    );
  }

  // 🔹 XABAR YOZISH MAYDONI
  Widget _buildMessageInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required VoidCallback onSend,
    bool showQuickReplies = false,
    Function(String)? onQuickReply,
  }) {
    final mediaQuery = MediaQuery.of(context);
    final bottomInsets = mediaQuery.viewInsets.bottom;
    final isKeyboardVisible = bottomInsets > 0;

    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 8,
        bottom: isKeyboardVisible ? bottomInsets + 8 : 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        children: [
          if (showQuickReplies)
            Container(
              height: 40,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildQuickReplyButton("Ketyapman", onQuickReply),
                  _buildQuickReplyButton("5 daqiqada", onQuickReply),
                  _buildQuickReplyButton("Yetib keldim", onQuickReply),
                  _buildQuickReplyButton("Kutib turing", onQuickReply),
                ],
              ),
            ),
          Row(
            children: [
              // 🔹 Emoji tugmasi
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Text('😊', style: TextStyle(fontSize: 18)),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  iconSize: 20,
                ),
              ),
              const SizedBox(width: 8),

              // 🔹 Xabar yozish maydoni
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    textInputAction: TextInputAction.send,
                    decoration: InputDecoration(
                      hintText: hintText,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.attach_file, color: Colors.grey),
                        onPressed: () {},
                      ),
                    ),
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        onSend();
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // 🔹 Yuborish tugmasi
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue.shade600,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white, size: 18),
                  onPressed: () {
                    if (controller.text.trim().isNotEmpty) {
                      onSend();
                    }
                  },
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickReplyButton(String text, Function(String)? onQuickReply) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ElevatedButton(
        onPressed: () => onQuickReply?.call(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade50,
          foregroundColor: Colors.blue.shade800,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.blue.shade200),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),
        child: Text(text, style: const TextStyle(fontSize: 12)),
      ),
    );
  }

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
          Flexible(
            child: Container(
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
                    style: TextStyle(
                      color: isSent ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message["time"],
                    style: TextStyle(
                      fontSize: 10,
                      color: isSent ? Colors.white70 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isSent) const SizedBox(width: 8),
        ],
      ),
    );
  }

  void _updateUnreadCount() {
    int totalUnread = 0;
    for (var customer in _customers) {
      totalUnread += customer["unread"] as int;
    }
    setState(() {
      _unreadMessagesCount = totalUnread;
    });
  }

  // ========== CHAT FUNKTSIYALARI ==========

  void _sendQuickReplyToCustomer(String customerId, String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      if (_customerMessages[customerId] == null) {
        _customerMessages[customerId] = [];
      }
      _customerMessages[customerId]!.add({
        "type": "sent",
        "text": text,
        "time": _getCurrentTime(),
        "sender": "Siz",
      });

      for (var customer in _customers) {
        if (customer["id"] == customerId) {
          customer["lastMessage"] = text;
          customer["time"] = "hozir";
          break;
        }
      }
    });

    // 🔹 Yangi xabardan so'ng pastga skroll qilish
    _scrollToBottom();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Xabar yuborildi"),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _sendMessageToCustomer(String customerId) {
    final message = _customerMessageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      if (_customerMessages[customerId] == null) {
        _customerMessages[customerId] = [];
      }
      _customerMessages[customerId]!.add({
        "type": "sent",
        "text": message,
        "time": _getCurrentTime(),
        "sender": "Siz",
      });

      for (var customer in _customers) {
        if (customer["id"] == customerId) {
          customer["lastMessage"] = message;
          customer["time"] = "hozir";
          break;
        }
      }

      _customerMessageController.clear();
    });

    // 🔹 Yangi xabardan so'ng pastga skroll qilish
    _scrollToBottom();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Xabar yuborildi"),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _sendMessageToAdmin() {
    final message = _adminMessageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _adminMessages.add({
        "type": "sent",
        "text": message,
        "time": _getCurrentTime(),
        "sender": "Siz",
      });

      _adminMessageController.clear();
    });

    // 🔹 Yangi xabardan so'ng pastga skroll qilish
    _scrollToBottom();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Administratorga xabar yuborildi"),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return "${now.hour}:${now.minute.toString().padLeft(2, '0')}";
  }

  void _callCustomer(String phone) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$phone raqamiga qo'ng'iroq qilinmoqda...")),
    );
  }

  void _callAdmin() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Administratorga qo'ng'iroq qilinmoqda...")),
    );
  }

  // ========== STATISTIKA KONTEYNERI ==========

  Widget _buildStatsContainer() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Statistika",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  // 🔹 Filtr tugmasi
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.filter_list, color: Colors.blue),
                    onSelected: (value) {
                      _filterStats(value);
                    },
                    itemBuilder:
                        (context) => [
                          PopupMenuItem(
                            value: "today",
                            child: Row(
                              children: [
                                Icon(
                                  Icons.today,
                                  color:
                                      _currentFilter == "today"
                                          ? Colors.blue
                                          : Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                const Text("Bugun"),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: "week",
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_view_week,
                                  color:
                                      _currentFilter == "week"
                                          ? Colors.blue
                                          : Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                const Text("Hafta"),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: "month",
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color:
                                      _currentFilter == "month"
                                          ? Colors.blue
                                          : Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                const Text("Oy"),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: "year",
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_view_month,
                                  color:
                                      _currentFilter == "year"
                                          ? Colors.blue
                                          : Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                const Text("Yil"),
                              ],
                            ),
                          ),
                        ],
                  ),
                  const SizedBox(width: 8),
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
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 🔹 Asosiy ko'rsatkichlar gridi
                _buildMainStatsGrid(),
                const SizedBox(height: 20),

                // 🔹 Daromad grafigi
                _buildEarningsChart(),
                const SizedBox(height: 20),

                // 🔹 Faoliyat statistikasi
                _buildActivityStats(),
                const SizedBox(height: 20),

                // 🔹 Batafsil statistika
                _buildDetailedStats(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 🔹 Asosiy statistika kartalari
  Widget _buildMainStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: [
        _buildEnhancedStatCard(
          "Oylik buyurtmalar",
          "${_stats['monthly_orders']} ta",
          Icons.shopping_cart_outlined,
          Colors.blue,
          _stats['orders_change'] ?? "+12%",
          Colors.green,
        ),
        _buildEnhancedStatCard(
          "Umumiy masofa",
          "${_stats['total_distance']} km",
          Icons.directions_car_outlined,
          Colors.green,
          _stats['distance_change'] ?? "+8%",
          Colors.green,
        ),
        _buildEnhancedStatCard(
          "Oylik daromad",
          _formatCurrency(_stats['monthly_earnings']),
          Icons.attach_money_outlined,
          Colors.orange,
          _stats['earnings_change'] ?? "+15%",
          Colors.green,
        ),
        _buildEnhancedStatCard(
          "Reyting",
          _stats['rating'].toString(),
          Icons.star_outline,
          Colors.amber,
          "${_stats['reviews_count'] ?? 142} ta baho",
          Colors.blue,
        ),
      ],
    );
  }

  // 🔹 Takomillashtirilgan statistika kartasi
  Widget _buildEnhancedStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
    Color subtitleColor,
  ) {
    final isPercentage = subtitle.contains('%');
    final isPositive = isPercentage && subtitle.contains('+');

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: color.withValues(alpha: 0.2),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.05),
              color.withValues(alpha: 0.02),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),

                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                if (isPercentage)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isPositive
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isPositive
                                ? Colors.green.shade100
                                : Colors.red.shade100,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPositive
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: 12,
                          color: isPositive ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 10,
                            color: isPositive ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            if (!isPercentage)
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: subtitleColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 🔹 Daromad grafigi
  Widget _buildEarningsChart() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Daromad statistikasi",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getFilterText(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "So'nggi ${_getPeriodText()} daromad o'zgarishi",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            Container(
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bar_chart,
                      size: 48,
                      color: Colors.blue.shade300,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Grafik ko'rsatilmoqda: ${_getFilterText()}",
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Daromad: ${_formatCurrency(_stats['monthly_earnings'])}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildChartLegend("Min", "12,000 so'm", Colors.red),
                _buildChartLegend("O'rtacha", "58,000 so'm", Colors.blue),
                _buildChartLegend("Maks", "125,000 so'm", Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Faoliyat statistikasi
  Widget _buildActivityStats() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Faoliyat ko'rsatkichlari",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildProgressStat(
              "Buyurtma qabul qilish",
              _stats['acceptance_rate'] ?? 92,
              Colors.green,
              "%",
            ),
            _buildProgressStat(
              "Bajarilgan sayohatlar",
              _stats['completed_trips'],
              Colors.blue,
              "ta",
            ),
            _buildProgressStat(
              "Onlayn vaqt",
              _stats['online_hours'],
              Colors.orange,
              "soat",
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Progress barlı statistika
  Widget _buildProgressStat(
    String label,
    dynamic value,
    Color color,
    String suffix,
  ) {
    final intValue = value is int ? value : int.tryParse(value.toString()) ?? 0;
    final percentage = intValue / 100.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "$value$suffix",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage > 1 ? 1.0 : percentage,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.7)],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Batafsil statistika
  Widget _buildDetailedStats() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Batafsil statistika",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDetailedStatRow(
              "Bajarilgan sayohatlar",
              "${_stats['completed_trips']} ta",
              Icons.check_circle,
              Colors.green,
            ),
            _buildDetailedStatRow(
              "Bekor qilingan sayohatlar",
              "${_stats['canceled_trips']} ta",
              Icons.cancel,
              Colors.red,
            ),
            _buildDetailedStatRow(
              "Mijozlar soni",
              "${_stats['customers_count']} ta",
              Icons.people,
              Colors.purple,
            ),
            _buildDetailedStatRow(
              "O'rtacha baho",
              _stats['rating'].toString(),
              Icons.star,
              Colors.amber,
            ),
            _buildDetailedStatRow(
              "Ish vaqti",
              "${_stats['working_hours']} soat",
              Icons.access_time,
              Colors.blue,
            ),
            _buildDetailedStatRow(
              "O'rtacha daromad",
              "${_formatCurrency(_stats['avg_earnings'])}/kun",
              Icons.currency_exchange,
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Batafsil statistika qatori
  Widget _buildDetailedStatRow(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),

              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Grafik legendasi
  Widget _buildChartLegend(String title, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 16,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
        Text(value, style: TextStyle(fontSize: 9, color: Colors.grey.shade600)),
      ],
    );
  }

  // 🔹 Yordamchi funksiyalar
  String _formatCurrency(dynamic amount) {
    final number =
        amount is int ? amount : int.tryParse(amount.toString()) ?? 0;
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M so\'m';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K so\'m';
    }
    return number.toString();
  }

  String _getFilterText() {
    switch (_currentFilter) {
      case "today":
        return "Bugun";
      case "week":
        return "Hafta";
      case "month":
        return "Oy";
      case "year":
        return "Yil";
      default:
        return "Oy";
    }
  }

  String _getPeriodText() {
    switch (_currentFilter) {
      case "today":
        return "1 kun";
      case "week":
        return "7 kun";
      case "month":
        return "30 kun";
      case "year":
        return "12 oy";
      default:
        return "30 kun";
    }
  }

  void _filterStats(String period) {
    setState(() {
      _currentFilter = period;
    });

    // Filtirlash animatsiyasi
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Statistika ${_getFilterText().toLowerCase()} boʻyicha filtrlandi",
        ),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // ========== YANGILANGAN SOZLAMALAR KONTEYNERI ==========

  Widget _buildSettingsContainer() {
    return Column(
      children: [
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
        Expanded(
          child: ListView.builder(
            itemCount: _settingsItems.length,
            itemBuilder: (context, index) {
              final item = _settingsItems[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: Icon(item["icon"], color: Colors.blue.shade600),
                  title: Text(
                    item["title"],
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(item["subtitle"]),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _navigateToSetting(item);
                  },
                ),
              );
            },
          ),
        ),
        // Container(
        //   padding: const EdgeInsets.all(16),
        //   child: ElevatedButton(
        //     onPressed: _logout,
        //     style: ElevatedButton.styleFrom(
        //       backgroundColor: Colors.red.shade600,
        //       foregroundColor: Colors.white,
        //       minimumSize: const Size(double.infinity, 50),
        //     ),
        //     child: const Text("Chiqish"),
        //   ),
        // ),
      ],
    );
  }

  // 🔹 Ilova sozlamalari konteyneri
  Widget _buildAppSettingsContainer() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _activeBottomContainer = "settings";
                  });
                },
              ),
              const SizedBox(width: 8),
              const Text(
                "Ilova sozlamalari",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 🔹 Til sozlamalari
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Til sozlamalari",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildLanguageOption("O'zbekcha", "O'zbekcha", Icons.language),
                      _buildLanguageOption("Русский", "Ruscha", Icons.language),
                      _buildLanguageOption("English", "Inglizcha", Icons.language),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // 🔹 Tema sozlamalari
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Ilova temasi",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildThemeOption("Tungi", "Qorong'i tema", Icons.nightlight_round),
                      _buildThemeOption("Kunduzgi", "Och ranglar", Icons.wb_sunny),
                      _buildThemeOption("Avtomatik", "Tizim temasi", Icons.settings),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 🔹 Til variantini yaratish
  Widget _buildLanguageOption(String title, String subtitle, IconData icon) {
    final isSelected = _selectedLanguage == title;
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: isSelected ? Colors.blue.shade50 : Colors.white,
      child: ListTile(
        leading: Icon(icon, color: isSelected ? Colors.blue : Colors.grey),
        title: Text(title, style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.blue : Colors.black,
        )),
        subtitle: Text(subtitle),
        trailing: isSelected 
            ? const Icon(Icons.check_circle, color: Colors.blue)
            : null,
        onTap: () {
          setState(() {
            _selectedLanguage = title;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Til $title ga o'zgartirildi")),
          );
        },
      ),
    );
  }

  // 🔹 Tema variantini yaratish
  Widget _buildThemeOption(String title, String subtitle, IconData icon) {
    final isSelected = _selectedTheme == title;
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: isSelected ? Colors.blue.shade50 : Colors.white,
      child: ListTile(
        leading: Icon(icon, color: isSelected ? Colors.blue : Colors.grey),
        title: Text(title, style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.blue : Colors.black,
        )),
        subtitle: Text(subtitle),
        trailing: isSelected 
            ? const Icon(Icons.check_circle, color: Colors.blue)
            : null,
        onTap: () {
          setState(() {
            _selectedTheme = title;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Tema $title ga o'zgartirildi")),
          );
        },
      ),
    );
  }

  // ========== BOTTOM CONTAINER FUNKTSIYALARI ==========

  Widget _buildBottomContainer() {
    if (_activeBottomContainer.isEmpty) return const SizedBox.shrink();

    final mediaQuery = MediaQuery.of(context);
    final bottomInsets = mediaQuery.viewInsets.bottom;
    final isKeyboardVisible = bottomInsets > 0;

    // 🔹 Konteyner balandligini klaviatura holatiga qarab sozlash
    double containerHeight =
        isKeyboardVisible
            ? mediaQuery.size.height * 0.95
            : mediaQuery.size.height * 0.7;

    Widget content;

    switch (_activeBottomContainer) {
      case "chat":
        content = _buildChatContainer();
        break;
      case "stats":
        content = _buildStatsContainer();
        break;
      case "orders":
        content = _buildOrdersContainer();
        break;
      case "settings":
        content = _buildSettingsContainer();
        break;
      case "app_settings":
        content = _buildAppSettingsContainer();
        break;
      default:
        content = const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: containerHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),

            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: content,
    );
  }

  // 🔹 Pastki menyu tugmasi - YANGILANGAN (buyurtmalar soni ko'rsatiladi)
  Widget _bottomMenuButton(String label, IconData icon, String id) {
    final hasNotification = id == "chat" && _unreadMessagesCount > 0;
    final hasNewOrders = id == "orders" && _newOrdersCount > 0;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (_activeBottomContainer == id) {
            _activeBottomContainer = "";
          } else {
            _activeBottomContainer = id;
          }
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color:
                      _activeBottomContainer == id
                          ? Colors.blue.shade600
                          : Colors.blue.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color:
                      _activeBottomContainer == id
                          ? Colors.white
                          : Colors.blue.shade800,
                ),
              ),
              if (hasNotification)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      _unreadMessagesCount > 9
                          ? "9+"
                          : _unreadMessagesCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              if (hasNewOrders)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      _newOrdersCount > 9 ? "9+" : _newOrdersCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
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

  // ========== QOLGAN WIDGETLAR ==========

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

  Widget _buildOnlineStatusPanel() {
    return Positioned(
      top: 50,
      left: 15,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isOnline = !_isOnline;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _isOnline ? Colors.green : Colors.red,
            borderRadius: BorderRadius.circular(20),
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
              if (_mode == "Mahalliy Taxi") {
                _activeBottomContainer = "";
              }
            });
          }
        },
      ),
    );
  }

  Widget _buildLocalTaxiPanel() {
    if (_mode != "Mahalliy Taxi") return const SizedBox.shrink();

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 320,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const Text(
              "📍 Yaqin mijozlar:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _localRequests.length,
                itemBuilder: (context, index) {
                  final req = _localRequests[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: Text(
                          "${index + 1}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(
                        req["name"]?.toString() ?? "Noma'lum mijoz",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        "${req["location"]?.toString() ?? "Noma'lum manzil"} • ${req["distance"]?.toString() ?? "Noma'lum masofa"}",
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              _acceptLocalOrder(index);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text("Qabul"),
                          ),
                          const SizedBox(width: 4),
                          ElevatedButton(
                            onPressed: () {
                              _rejectLocalOrder(index);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text("Rad"),
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
        ),
        child: Text(
          status,
          style: TextStyle(color: isActive ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  // ========== ASOSIY BUILD METODI ==========

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomInsets = mediaQuery.viewInsets.bottom;
    final isKeyboardVisible = bottomInsets > 0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
          _buildOnlineStatusPanel(),
          _buildModeSelector(),
          _buildLocalTaxiPanel(),

          // 🔹 BOTTOM CONTAINER - Klaviatura ustida
          Positioned(
            bottom: isKeyboardVisible ? 0 : 100,
            left: 0,
            right: 0,
            child: _buildBottomContainer(),
          ),

          /// 🔹 PASTKI MENYU - Klaviatura ochiq bo'lsa yashirinadi
          if (!isKeyboardVisible)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 100,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: 0.25,
                      ), // Soyaning rangi va tiniqligi
                      blurRadius: 10, // Soya tarqalish darajasi
                      offset: const Offset(
                        0,
                        -2,
                      ), // Soyaning joylashuvi (y yuqoriga)
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
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

  // ========== QOLGAN FUNKTSIYALAR ==========

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

  void _navigateToSetting(Map<String, dynamic> setting) {
    final type = setting["type"] ?? "navigation";
    final title = setting["title"] ?? "";
    final screen = setting["screen"] ?? "";

    if (type == "settings" && title == "Ilova sozlamalari") {
      setState(() {
        _activeBottomContainer = "app_settings";
      });
    } else if (type == "navigation") {
      // 🔹 MAVJUD SCREENLARGA O'TISH
      switch (screen) {
        case "profile":
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EntrepreneurProfileScreen(),
            ),
          );
          break;
        case "car_info":
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EntrepreneurCarInfoScreen(),
            ),
          );
          break;
        case "payment":
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentCardRegistrationScreen(),
            ),
          );
          break;
        case "help_screen":
        // 🔹 YANGILANDI: help_screen.dart fayliga o'tish
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HelpScreen(),
          ),
        );
          break;
        default:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("$title sahifasi tayyorlanmoqda...")),
          );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$title sozlamasiga o'tilmoqda...")),
      );
    }
  }

  // void _logout() {
  //   showDialog(
  //     context: context,
  //     builder:
  //         (context) => AlertDialog(
  //           title: const Text("Chiqish"),
  //           content: const Text("Ilovadan chiqishni tasdiqlaysizmi?"),
  //           actions: [
  //             TextButton(
  //               onPressed: () => Navigator.pop(context),
  //               child: const Text("Bekor qilish"),
  //             ),
  //             ElevatedButton(
  //               onPressed: () {
  //                 Navigator.pop(context);
  //                 ScaffoldMessenger.of(context).showSnackBar(
  //                   const SnackBar(content: Text("Chiqish amalga oshirildi")),
  //                 );
  //               },
  //               child: const Text("Chiqish"),
  //             ),
  //           ],
  //         ),
  //   );
  // }
}