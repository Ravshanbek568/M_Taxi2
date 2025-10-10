import 'package:flutter/material.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final List<FAQItem> _faqItems = [
    FAQItem(
      question: "Buyurtma qanday qabul qilish kerak?",
      answer: "Buyurtmalar bo'limiga o'ting, yangi buyurtmalar ro'yxatidan keraklisini tanlang va 'Qabul qilish' tugmasini bosing. Buyurtma qabul qilingach, mijoz bilan bog'lanishingiz mumkin.",
    ),
    FAQItem(
      question: "Qanday qilib mashina ma'lumotlarini yangilash mumkin?",
      answer: "Sozlamalar > Mashina ma'lumotlari bo'limiga o'ting va yangi ma'lumotlarni kiriting. Barcha maydonlarni to'ldirib 'Saqlash' tugmasini bosing.",
    ),
    FAQItem(
      question: "To'lov tizimi qanday ishlaydi?",
      answer: "Siz mijozlardan naqd pul yoki kart orqali to'lov qabul qilishingiz mumkin. To'lovlar har kuni soat 18:00 da hisobingizga o'tkaziladi.",
    ),
    FAQItem(
      question: "Statistika qanday hisoblanadi?",
      answer: "Statistika sizning kunlik, haftalik va oylik faoliyatingiz asosida avtomatik ravishda hisoblanadi. Barcha ma'lumotlar haqiqiy vaqt rejimida yangilanadi.",
    ),
    FAQItem(
      question: "Ilovadan qanday foydalanish kerak?",
      answer: "Ilovani ishga tushirgach, xaritada joylashuvingizni ko'rasiz. Pastki menyudan turli funksiyalarga o'tishingiz mumkin: xabarlar, statistika, buyurtmalar va sozlamalar.",
    ),
  ];

  final List<GuideItem> _guideItems = [
    GuideItem(
      title: "Dastlabki sozlash",
      steps: [
        "Profil ma'lumotlaringizni to'ldiring",
        "Mashina ma'lumotlarini kiriting",
        "To'lov tizimini sozlang",
        "Ilova sozlamalarini o'zingizga moslang",
      ],
    ),
    GuideItem(
      title: "Buyurtma qabul qilish",
      steps: [
        "Buyurtmalar bo'limiga o'ting",
        "Yangi buyurtmalar ro'yxatini ko'ring",
        "Kerakli buyurtmani tanlang",
        "'Qabul qilish' tugmasini bosing",
        "Mijoz bilan bog'laning",
      ],
    ),
    GuideItem(
      title: "Mijozlar bilan muloqot",
      steps: [
        "Xabarlar bo'limiga o'ting",
        "Mijozni tanlang",
        "Xabar yozing yoki tezkor javoblardan foydalaning",
        "Qo'ng'iroq qilish uchun telefon tugmasini bosing",
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Yordam va Qo'llab-quvvatlash",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // // 🔹 Qidiruv maydoni
          // _buildSearchField(),
          // const SizedBox(height: 20),

          // 🔹 Tezkor yordam bo'limi
          _buildQuickHelpSection(),
          const SizedBox(height: 24),

          // 🔹 Ko'p so'raladigan savollar
          _buildFAQSection(),
          const SizedBox(height: 24),

          // 🔹 Foydalanish qo'llanmasi
          _buildUserGuideSection(),
          const SizedBox(height: 24),

          // 🔹 Qo'llab-quvvatlash
          _buildSupportSection(),
          const SizedBox(height: 24),

          // 🔹 Qo'shimcha ma'lumotlar
          _buildAdditionalInfoSection(),
        ],
      ),
    );
  }
// // QIDIRUV FUNKSIYASI 
//   Widget _buildSearchField() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.1),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: TextField(
//         decoration: InputDecoration(
//           hintText: "Qidirish...",
//           prefixIcon: const Icon(Icons.search, color: Colors.grey),
//           border: InputBorder.none,
//           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//         ),
//         onChanged: (value) {
//           // Qidiruv funksiyasi
//         },
//       ),
//     );
//   }

  Widget _buildQuickHelpSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Tezkor Yordam",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,//qatorlar soni
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2, //bo'yiga katalig
          children: [
            _buildQuickHelpCard(
              "Buyurtmalar",
              Icons.shopping_cart,
              Colors.blue,
              () {
                _showQuickHelpDialog(
                  "Buyurtmalar bilan ishlash",
                  "Yangi buyurtmalarni qabul qilish, faol buyurtmalarni boshqarish va tarixni ko'rish uchun Buyurtmalar bo'limidan foydalaning.",
                );
              },
            ),
            _buildQuickHelpCard(
              "To'lovlar",
              Icons.payment,
              Colors.green,
              () {
                _showQuickHelpDialog(
                  "To'lov tizimi",
                  "To'lov usullarini sozlash, balansni ko'rish va to'lov tarixini tekshirish uchun To'lov tizimi bo'limiga o'ting.",
                );
              },
            ),
            _buildQuickHelpCard(
              "Xabarlar",
              Icons.chat,
              Colors.orange,
              () {
                _showQuickHelpDialog(
                  "Xabarlashuv",
                  "Mijozlar va administrator bilan xabarlashish, tezkor javoblardan foydalanish va chat tarixini ko'rish.",
                );
              },
            ),
            _buildQuickHelpCard(
              "Statistika",
              Icons.bar_chart,
              Colors.purple,
              () {
                _showQuickHelpDialog(
                  "Statistika",
                  "Faoliyatingiz statistikasini ko'rish, filtrlash va batafsil ma'lumotlarni olish uchun Statistika bo'limidan foydalaning.",
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickHelpCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Ko'p So'raladigan Savollar",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        ..._faqItems.map((faq) => _buildFAQItem(faq)),
      ],
    );
  }

  Widget _buildFAQItem(FAQItem faq) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ExpansionTile(
        leading: const Icon(Icons.help_outline, color: Colors.blue),
        title: Text(
          faq.question,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Text(
              faq.answer,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserGuideSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Foydalanish Qo'llanmasi",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        ..._guideItems.map((guide) => _buildGuideItem(guide)),
      ],
    );
  }

  Widget _buildGuideItem(GuideItem guide) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.menu_book, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Text(
                  guide.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...guide.steps.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        step,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.support_agent, size: 48, color: Colors.blue),
            const SizedBox(height: 16),
            const Text(
              "Qo'llab-quvvatlash Xizmati",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              "Biz sizga 24/7 yordam berishga tayyormiz",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _buildContactInfo(),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _makePhoneCall,
                    icon: const Icon(Icons.phone, size: 20),
                    label: const Text("Qo'ng'iroq"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Expanded(
                //   child: ElevatedButton.icon(
                //     onPressed: _sendEmail,
                //     icon: const Icon(Icons.email, size: 20),
                //     label: const Text("Email"),
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: Colors.blue,
                //       foregroundColor: Colors.white,
                //       padding: const EdgeInsets.symmetric(vertical: 12),
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(8),
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
            const SizedBox(height: 12),
            // ElevatedButton.icon(
            //   onPressed: _openLiveChat,
            //   icon: const Icon(Icons.chat, size: 20),
            //   label: const Text("Onlayn Chat"),
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Colors.orange,
            //     foregroundColor: Colors.white,
            //     padding: const EdgeInsets.symmetric(vertical: 12),
            //     minimumSize: const Size(double.infinity, 0),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(8),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildContactRow(Icons.phone, "+998 90 123 45 67"),
          const SizedBox(height: 8),
          _buildContactRow(Icons.email, "support@rconnex.uz"),
          const SizedBox(height: 8),
          _buildContactRow(Icons.access_time, "24/7 - Doimiy qo'llab-quvvatlash"),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.blue),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Qo'shimcha Ma'lumotlar",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 3,
          children: [
            _buildInfoCard("Maxfiylik Siyosati", Icons.security, () {
              _showInfoDialog("Maxfiylik Siyosati", 
                "Biz sizning shaxsiy ma'lumotlaringizni himoya qilamiz. Barcha ma'lumotlar shifrlangan holda saqlanadi va uchinchi shaxslarga o'tkazilmaydi.");
            }),
            _buildInfoCard("Foydalanish Shartlari", Icons.description, () {
              _showInfoDialog("Foydalanish Shartlari", 
                "Ilovadan foydalanish uchun siz foydalanish shartlariga rozilik bildirishingiz kerak. Batafsil ma'lumot ilova ichida mavjud.");
            }),
            _buildInfoCard("Ilova Haqida", Icons.info, () {
              _showInfoDialog("Ilova Haqida", 
                "RconneX Taxi - bu tadbirkorlar uchun maxsus ishlab chiqilgan ilova. Versiya: 1.0.0\n\n© 2024 RconneX. Barcha huquqlar himoyalangan.");
            }),
            _buildInfoCard("Yangiliklar", Icons.new_releases, () {
              _showInfoDialog("Yangiliklar", 
                "Eng so'nggi yangilanishlar:\n\n• Yangi interfeys\n• Tezlashtirilgan xaritalar\n• Yangi statistika tizimi\n• Takomillashtirilgan xavfsizlik");
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon, size: 18, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQuickHelpDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tushundim"),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(content),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Yopish"),
          ),
        ],
      ),
    );
  }

  void _makePhoneCall() {
    // Telefon qo'ng'irog'i funksiyasi
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Qo'ng'iroq qilinmoqda..."),
        backgroundColor: Colors.green,
      ),
    );
  }

  // void _sendEmail() {
  //   // Email yuborish funksiyasi
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(
  //       content: Text("Email yuborilmoqda..."),
  //       backgroundColor: Colors.blue,
  //     ),
  //   );
  // }

  // void _openLiveChat() {
  //   // Onlayn chat funksiyasi
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(
  //       content: Text("Onlayn chat ochilmoqda..."),
  //       backgroundColor: Colors.orange,
  //     ),
  //   );
  // }
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});
}

class GuideItem {
  final String title;
  final List<String> steps;

  GuideItem({required this.title, required this.steps});
}