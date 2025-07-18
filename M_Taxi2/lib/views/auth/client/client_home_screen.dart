import 'package:flutter/material.dart';
import 'package:m_taksi/views/auth/client/settings_screen.dart';
import 'package:m_taksi/views/auth/client/taxi_order_screen.dart'; // YANGI IMPORT QO'SHILDI

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  bool _isScrolled = false;

  // Tavsiya qilingan haydovchilar ro'yxati
  final List<Map<String, dynamic>> _recommendations = [
    {
      'avatar': 'assets/images/driver1.jpg',
      'name': 'Aliyev Sardor',
      'service': 'Haydovchi',
      'days': 'Dushanbadan - Jumagacha',
      'hours': '08:00 - 20:00',
      'rating': 4.8,
    },
    {
      'avatar': 'assets/images/driver2.jpg',
      'name': 'Xasanov Jasur',
      'service': 'Yuk tashish',
      'days': 'Dushanbadan - Shanbagacha',
      'hours': '09:00 - 18:00',
      'rating': 4.9,
    },
    {
      'avatar': 'assets/images/driver3.jpg',
      'name': 'Karimov Shoxrux',
      'service': 'Shaxarlararo taksi',
      'days': 'Dushanbadan - Yakshanbagacha',
      'hours': '07:00 - 22:00',
      'rating': 4.7,
    },
    {
      'avatar': 'assets/images/driver4.jpg',
      'name': 'Omonova Dilfuza',
      'service': 'Yetkazib berish',
      'days': 'Dushanbadan - Shanbagacha',
      'hours': '10:00 - 19:00',
      'rating': 4.9,
    },
    {
      'avatar': 'assets/images/driver5.jpg',
      'name': 'Toshmatov Bahodir',
      'service': 'Maxsus transport',
      'days': 'Dushanbadan - Jumagacha',
      'hours': '08:00 - 18:00',
      'rating': 4.6,
    },
  ];

  // Mashhur haydovchilar ro'yxati
  final List<Map<String, dynamic>> _popularDrivers = [
    {
      'avatar': 'assets/images/driver6.jpg',
      'name': 'Rahimov Shoxrux',
      'service': 'Ekspress yetkazib berish',
      'days': 'Dushanbadan - Yakshanbagacha',
      'hours': '08:00 - 22:00',
      'rating': 4.9,
    },
    {
      'avatar': 'assets/images/driver7.jpg',
      'name': 'Usmonova Dilbar',
      'service': 'Shaxsiy haydovchi',
      'days': 'Dushanbadan - Jumagacha',
      'hours': '07:00 - 19:00',
      'rating': 4.8,
    },
    {
      'avatar': 'assets/images/driver8.jpg',
      'name': 'Qodirov Aziz',
      'service': 'Yuk tashish xizmati',
      'days': 'Dushanbadan - Shanbagacha',
      'hours': '09:00 - 20:00',
      'rating': 4.7,
    },
    {
      'avatar': 'assets/images/driver9.jpg',
      'name': 'Nazarova Malika',
      'service': 'Shaxarlararo taksi',
      'days': 'Dushanbadan - Yakshanbagacha',
      'hours': '06:00 - 23:00',
      'rating': 4.9,
    },
    {
      'avatar': 'assets/images/driver10.jpg',
      'name': 'Turgunov Jamshid',
      'service': 'Maxsus transport',
      'days': 'Dushanbadan - Jumagacha',
      'hours': '08:00 - 18:00',
      'rating': 4.8,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F9),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: _isScrolled ? Colors.white : const Color(0xFFF8F9F9),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(28),
              ),
              boxShadow: _isScrolled
                  ? [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.1),
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
          ),
          toolbarHeight: 70,
          leading: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: IconButton(
              icon: const Icon(Icons.menu, color: Colors.black, size: 32),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => const SettingsScreen()));
              },
              padding: EdgeInsets.zero,
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        'Toshkent shahri',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Alimov Abdulloh',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 18),
              child: CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage('https://example.com/user-profile.jpg'),
                backgroundColor: Colors.grey[300],
              ),
            ),
          ],
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(28),
            ),
          ),
        ),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollUpdateNotification) {
            final bool newState = notification.metrics.pixels > 0;
            if (newState != _isScrolled) {
              setState(() {
                _isScrolled = newState;
              });
            }
          }
          return false;
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildServiceCategories(),
              _buildRecommendationsSection(),
              _buildPopularDriversSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCategories() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Xizmat toifalari',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildServiceItem(imagePath: 'assets/images/rasm9.png', label: 'Maxalliy taksi'),
              _buildServiceItem(imagePath: 'assets/images/rasm10.png', label: 'Yuk tashish hizmati'),
              _buildServiceItem(imagePath: 'assets/images/rasm11.png', label: 'Shaxarlar aro taksi'),
              _buildServiceItem(imagePath: 'assets/images/rasm12.png', label: 'Kafe & restoranlar'),
            ],
          ),
          
          const SizedBox(height: 30),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildServiceItem(imagePath: 'assets/images/rasm13.png', label: 'Xo\'jalik va qurilish molari'),
              _buildServiceItem(imagePath: 'assets/images/rasm14.png', label: 'Do\'konlar savdo uylari'),
              _buildServiceItem(imagePath: 'assets/images/rasm15.png', label: 'Sartaroshxona go\'zalik salo\'nlar'),
              _buildServiceItem(imagePath: 'assets/images/rasm16.png', label: 'Yetkazib berish'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem({required String imagePath, required String label}) {
    bool isPressed = false;
    
    return StatefulBuilder(
      builder: (context, setState) {
        return GestureDetector(
          onTapDown: (_) => setState(() => isPressed = true),
          onTapUp: (_) => setState(() => isPressed = false),
          onTapCancel: () => setState(() => isPressed = false),
          onTap: () {
          // "Maxalliy taksi" tugmasi bosilganda taxi_order_screen ga o'tish
          if (label == 'Maxalliy taksi') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TaxiOrderScreen()),
            );
          } else {
            // Boshqa tugmalar uchun oddiy debug print
            debugPrint('$label tanlandi');
          }
        },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            transform: Matrix4.identity()..scale(isPressed ? 0.95 : 1.0),
            child: Column(
              children: [
                Container(
                  width: 68,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromRGBO(0, 0, 0, 25).withAlpha(25),
                        spreadRadius: 1,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Image.asset(
                      imagePath,
                      width: 75,
                      height: 75,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: 64,
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecommendationsSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16, bottom: 12),
            child: Text(
              'Siz uchun tavsiyalar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 195,
            child: ListView.builder(
              padding: EdgeInsets.zero,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _recommendations.length,
              itemBuilder: (context, index) {
                return Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  margin: EdgeInsets.only(
                    left: index == 0 ? 16 : 8,
                    right: index == _recommendations.length - 1 ? 16 : 8,
                  ),
                  child: _buildBusinessCard(_recommendations[index], index, isRecommendation: true),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularDriversSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16, bottom: 12),
            child: Text(
              'Hozir mashhurlar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 195,
            child: ListView.builder(
              padding: EdgeInsets.zero,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _popularDrivers.length,
              itemBuilder: (context, index) {
                return Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  margin: EdgeInsets.only(
                    left: index == 0 ? 16 : 8,
                    right: index == _popularDrivers.length - 1 ? 16 : 8,
                  ),
                  child: _buildBusinessCard(_popularDrivers[index], index, isRecommendation: false),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessCard(Map<String, dynamic> recommendation, int index, {bool isRecommendation = true}) {
    final colors = isRecommendation 
      ? [
          const Color(0xFF0062FF),
          const Color(0xFF6CADFF),
          const Color(0xFF0062FF),
          const Color(0xFFFFE500),
          const Color(0xFF0062FF),
        ]
      : [
          const Color(0xFFFB1313),
          const Color(0xFF6CADFF),
          const Color(0xFFC37272),
          const Color(0xFF6CADFF),
          const Color(0xFF549554),
        ];

    final gradientColors = isRecommendation
      ? [
          [const Color(0xFF10F1FF), const Color(0xFF0139FE)],
          [const Color(0xFFA0D1FF), const Color(0xFF6CADFF)],
          [const Color(0xFF10F1FF), const Color(0xFF549554)],
          [const Color(0xFFFFF3B8), const Color(0xFFFFE500)],
          [const Color(0xFF10F1FF), const Color(0xFF0139FE)],
        ]
      : [
          [const Color(0xFFFFA1A1), const Color(0xFFFB1313)],
          [const Color(0xFFA0D1FF), const Color(0xFF0139FE)],
          [const Color(0xFFE8B5B5), const Color(0xFFC37272)],
          [const Color(0xFFA0D1FF), const Color(0xFF6CADFF)],
          [const Color(0xFFA0D1A0), const Color(0xFF549554)],
        ];

    return Container(
      width: 300,
      height: 190,
      decoration: BoxDecoration(
        color: colors[index % colors.length],
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 25).withAlpha(25),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: gradientColors[index % gradientColors.length],
              ),
            ),
          ),
          Positioned(
            left: -30,
            top: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: gradientColors[index % gradientColors.length][0].withAlpha(128),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: -20,
            bottom: -20,
            child: Transform.rotate(
              angle: 0.5,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: gradientColors[index % gradientColors.length][0].withAlpha(77),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        image: DecorationImage(
                          image: AssetImage(recommendation['avatar']),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        Text(
                          recommendation['rating'].toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recommendation['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        recommendation['service'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        recommendation['days'],
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        recommendation['hours'],
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 15,
            right: 15,
            child: GestureDetector(
              onTap: () => debugPrint('Xabar yuborish: ${recommendation['name']}'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.message, size: 14, color: colors[index % colors.length]),
                    const SizedBox(width: 5),
                    Text(
                      "Murojat qilish",
                      style: TextStyle(
                        color: colors[index % colors.length],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
