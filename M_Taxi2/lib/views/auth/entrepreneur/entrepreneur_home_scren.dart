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

  // 🔹 Yangi xabarlar soni
  int _unreadMessagesCount = 3;

  // 🔹 Tanlangan mijoz
  Map<String, dynamic>? _selectedCustomer;

  // 🔹 TextField controllerlari
  final TextEditingController _adminMessageController = TextEditingController();
  final TextEditingController _customerMessageController = TextEditingController();

  // 🔹 FocusNode lar
  final FocusNode _adminFocusNode = FocusNode();
  final FocusNode _customerFocusNode = FocusNode();

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
      "orderActive": false, // Buyurtma aktiv emas
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
  final List<Map<String, dynamic>> _localRequests = [
    {
      "name": "Mijoz 1", 
      "location": "Xonobod", 
      "distance": "1.2 km"
    },
    {
      "name": "Mijoz 2", 
      "location": "Asaka yo'li", 
      "distance": "2.5 km"
    },
    {
      "name": "Mijoz 3", 
      "location": "Andijon markazi", 
      "distance": "3.0 km"
    },
    {
      "name": "Mijoz 4", 
      "location": "Qo'rg'ontepa", 
      "distance": "4.1 km"
    },
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

  @override
  void initState() {
    super.initState();
    // 🔹 Klaviatura ochilishi va yopilishini kuzatish
    _adminFocusNode.addListener(_onKeyboardChanged);
    _customerFocusNode.addListener(_onKeyboardChanged);
  }

  @override
  void dispose() {
    _adminMessageController.dispose();
    _customerMessageController.dispose();
    _adminFocusNode.dispose();
    _customerFocusNode.dispose();
    super.dispose();
  }

  void _onKeyboardChanged() {
    // 🔹 Klaviatura holati o'zgarganda rebuild qilish
    if (mounted) {
      setState(() {});
    }
  }

  // ========== YANGI XABARLAR KONTEYNERI ==========

  // 🔹 Xabarlar konteyneri
  Widget _buildChatContainer() {
    // 🔹 Agar mijoz tanlangan bo'lsa, yozishma oynasini ko'rsatish
    if (_selectedCustomer != null) {
      return _buildChatConversation(_selectedCustomer!);
    }

    return Column(
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
                        _selectedCustomer = null;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _chatType == "Mijozlar"
                            ? Colors.blue.shade600
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Mijozlar",
                        style: TextStyle(
                          color: _chatType == "Mijozlar" 
                              ? Colors.white 
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 🔹 Admin chat tugmasi
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
                        color: _chatType == "Admin"
                            ? Colors.blue.shade600
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Admin",
                        style: TextStyle(
                          color: _chatType == "Admin" 
                              ? Colors.white 
                              : Colors.black,
                        ),
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
                    _selectedCustomer = null;
                  });
                },
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // 🔹 Chat kontenti
        Expanded(
          child: _chatType == "Mijozlar" 
              ? _buildCustomersList()
              : _buildAdminChat(),
        ),
      ],
    );
  }

  // 🔹 Mijozlar ro'yxati
  Widget _buildCustomersList() {
    // 🔹 Faqat aktiv buyurtmasi bor mijozlarni filtrlash
    final activeCustomers = _customers.where((customer) => customer["orderActive"] == true).toList();

    return Column(
      children: [
        // 🔹 Sarlavha
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

        // 🔹 Mijozlar ro'yxati
        Expanded(
          child: activeCustomers.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        "Hozircha aktiv mijozlar yo'q",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Buyurtma qabul qilingach, mijoz bilan yozishish mumkin",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.grey),
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

  // 🔹 Mijoz chat elementi
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
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
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
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
              ),
            ),
            if (customer["unread"] > 0)
              const Icon(Icons.mark_chat_unread, color: Colors.red, size: 16),
          ],
        ),
        onTap: () {
          setState(() {
            _selectedCustomer = customer;
            // 🔹 O'qilgan xabarlarni nolga tushirish
            customer["unread"] = 0;
            _updateUnreadCount();
          });
        },
      ),
    );
  }

  // 🔹 Admin bilan chat - YANGILANGAN
  Widget _buildAdminChat() {
    return Column(
      children: [
        // 🔹 Admin ma'lumotlari
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

        // 🔹 Xabarlar ro'yxati - Expanded bilan
Expanded(
  child: _adminMessages.isEmpty
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
              SizedBox(height: 8),
              Text(
                "Administrator bilan yozishingiz mumkin",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        )
      : SingleChildScrollView(
          reverse: true, // 🔹 Pastga yangi xabarlar joylashishi uchun
          child: Column(
            children: [
              const SizedBox(height: 16),
              ..._adminMessages.map((message) => _buildMessageBubble(message)),
              const SizedBox(height: 16),
            ],
          ),
        ),
),

        // 🔹 XABAR YOZISH MAYDONI - YANGILANGAN
        _buildMessageInputField(
          controller: _adminMessageController,
          focusNode: _adminFocusNode,
          hintText: "Type your message",
          onSend: _sendMessageToAdmin,
        ),
      ],
    );
  }

  // 🔹 Yozishma oynasi - YANGILANGAN
  Widget _buildChatConversation(Map<String, dynamic> customer) {
    final messages = _customerMessages[customer["id"]] ?? [];

    return Column(
      children: [
        // 🔹 Mijoz sarlavhasi
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

     // 🔹 Yozishma tarixi - Expanded bilan
Expanded(
  child: messages.isEmpty
      ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                "Hozircha xabarlar yo'q",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                "Mijoz bilan yozishishni boshlang",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        )
      : SingleChildScrollView(
          reverse: true, // 🔹 Pastga yangi xabarlar joylashishi uchun
          child: Column(
            children: [
              const SizedBox(height: 16),
              ...messages.map((message) => _buildMessageBubble(message)),
              const SizedBox(height: 16),
            ],
          ),
        ),
),

      // 🔹 XABAR YOZISH MAYDONI - YANGILANGAN
      _buildMessageInputField(
        controller: _customerMessageController,
        focusNode: _customerFocusNode,
        hintText: "Type your message",
        onSend: () => _sendMessageToCustomer(customer["id"]),
        showQuickReplies: true,
        onQuickReply: (text) => _sendQuickReplyToCustomer(customer["id"], text),
      ),
    ],
  );
}

  // 🔹 XABAR YOZISH MAYDONI - YANGI FUNKSIYA
  Widget _buildMessageInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required VoidCallback onSend,
    bool showQuickReplies = false,
    Function(String)? onQuickReply,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
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
                  onPressed: () {
                    // Emoji tanlash funksiyasi
                  },
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
                        onPressed: () {
                          // Fayl biriktirish funksiyasi
                        },
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

  // 🔹 Tezkor javob tugmasi
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
        child: Text(
          text,
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  // 🔹 Xabar pufagi
  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isSent = message["type"] == "sent";
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
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
                    style: TextStyle(color: isSent ? Colors.white : Colors.black),
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

  // 🔹 Yangi xabarlar sonini yangilash
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

  // 🔹 Tezkor javob yuborish
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

      // 🔹 Mijozning oxirgi xabarini yangilash
      for (var customer in _customers) {
        if (customer["id"] == customerId) {
          customer["lastMessage"] = text;
          customer["time"] = "hozir";
          break;
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Xabar yuborildi"),
        backgroundColor: Colors.green,
      ),
    );
  }

  // 🔹 Mijozga xabar yuborish
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

      // 🔹 Mijozning oxirgi xabarini yangilash
      for (var customer in _customers) {
        if (customer["id"] == customerId) {
          customer["lastMessage"] = message;
          customer["time"] = "hozir";
          break;
        }
      }
      
      // 🔹 TextField ni tozalash
      _customerMessageController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Xabar yuborildi"),
        backgroundColor: Colors.green,
      ),
    );
  }

  // 🔹 Administratoga xabar yuborish
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
      
      // 🔹 TextField ni tozalash
      _adminMessageController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Administratorga xabar yuborildi"),
        backgroundColor: Colors.green,
      ),
    );
  }

  // 🔹 Hozirgi vaqtni olish
  String _getCurrentTime() {
    final now = DateTime.now();
    return "${now.hour}:${now.minute.toString().padLeft(2, '0')}";
  }

  // 🔹 Mijozga qo'ng'iroq qilish
  void _callCustomer(String phone) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$phone raqamiga qo'ng'iroq qilinmoqda...")),
    );
  }

  // 🔹 Administratorga qo'ng'iroq qilish
  void _callAdmin() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Administratorga qo'ng'iroq qilinmoqda...")),
    );
  }

  // 🔹 Pastki konteynerlarni qurish - YANGILANGAN
  Widget _buildBottomContainer() {
    if (_activeBottomContainer.isEmpty) return const SizedBox.shrink();

    double containerHeight = MediaQuery.of(context).size.height * 0.7;
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
      default:
        content = const SizedBox.shrink();
    }

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
              color: Colors.black.withAlpha((0.3 * 255).toInt()),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: content,
      ),
    );
  }

  // 🔹 Pastki menyu tugmasi (YANGI XABARLAR SONI QO'SHILGAN)
  Widget _bottomMenuButton(String label, IconData icon, String id) {
    final hasNotification = id == "chat" && _unreadMessagesCount > 0;
    
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
                  color: _activeBottomContainer == id
                      ? Colors.blue.shade600
                      : Colors.blue.shade100,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha((0.1 * 255).toInt()),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: _activeBottomContainer == id
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
                      _unreadMessagesCount > 9 ? "9+" : _unreadMessagesCount.toString(),
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
              fontWeight: _activeBottomContainer == id
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: _activeBottomContainer == id
                  ? Colors.blue.shade800
                  : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  // ========== MAVJUT QISMLARI ==========

  // 🔹 Foydalanuvchi ma'lumotlari paneli
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

  // 🔹 Onlayn/Offlayn holat paneli
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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.1 * 255).toInt()),
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

  // 🔹 Ish rejimini tanlash paneli
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

  // 🔹 Mahalliy taxi paneli
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.1 * 255).toInt()),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
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
                        req["name"]?.toString() ?? "Noma'lum mijoz",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        "${req["location"]?.toString() ?? "Noma'lum manzil"} • ${req["distance"]?.toString() ?? "Noma'lum masofa"}"
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
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            child: const Text("Qabul", style: TextStyle(fontSize: 12)),
                          ),
                          const SizedBox(width: 4),
                          ElevatedButton(
                            onPressed: () {
                              _rejectLocalOrder(index);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            child: const Text("Rad", style: TextStyle(fontSize: 12)),
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

  // 🔹 Holat tugmasi
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

  // 🔹 Statistika konteyneri
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
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
  }

  // 🔹 Buyurtmalar konteyneri
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
        Expanded(
          child: _mode == "RconneX Taxi"
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
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
  }

  // 🔹 Sozlamalar konteyneri
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
  }

  // 🔹 Statistika kartasi
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
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

  // 🔹 Buyurtma kartasi
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                    Icon(Icons.directions_car, color: Colors.grey.shade600, size: 14),
                    const SizedBox(width: 4),
                    Text(order["distance"]),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.grey.shade600, size: 14),
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
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text("Qabul qilish", style: TextStyle(color: Colors.white)),
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

  // 🔹 Statistika qatori
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

  // 🔹 Asosiy UI qurilishi - YANGILANGAN
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
          _buildOnlineStatusPanel(),
          _buildModeSelector(),
          _buildLocalTaxiPanel(),
          
          // 🔹 Bottom container klaviatura ostida ko'rinishi uchun
          Positioned(
            bottom: 100, // 🔹 Pastki menyu balandligi
            left: 0,
            right: 0,
            child: _buildBottomContainer(),
          ),

          // 🔹 Pastki menyu
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 100,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.2 * 255).toInt()),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
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

  // 🔹 FUNKTSIYALAR
  void _acceptLocalOrder(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Buyurtma qabul qilish"),
        content: Text("${_localRequests[index]['name']} ning buyurtmasini qabul qilishni tasdiqlaysizmi?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Bekor qilish"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("${_localRequests[index]['name']} buyurtmasi qabul qilindi")),
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
      builder: (context) => AlertDialog(
        title: const Text("Buyurtmani rad etish"),
        content: Text("${_localRequests[index]['name']} ning buyurtmasini rad etishni tasdiqlaysizmi?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Bekor qilish"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("${_localRequests[index]['name']} buyurtmasi rad etildi")),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$orderId buyurtmasi rad etildi")),
    );
  }

  void _navigateToSetting(String setting) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$setting sozlamasiga o'tilmoqda...")),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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