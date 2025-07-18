import 'package:flutter/material.dart';
import 'package:m_taksi/core/theme/colors.dart'; // Loyiha ranglari uchun kutubxona
import 'package:m_taksi/views/auth/entrepreneur/entrepreneur_phone_screen.dart'; // Tadbirkor telefon raqami sahifasi

/// Tadbirkorlik turini tanlash sahifasi
class EntrepreneurBusinessTypeScreen extends StatelessWidget {
  /// Biznes turlari ro'yxati (o'zgarmas qiymat)
  static const List<String> businessTypes = [
    "Mahaliy taksi",
    "Do'kondor",
    "Yuk tashuvchi Taksi",
    "Sartarosh",
    "Shaharlararo taksi",
    "Hunarmand usta",
    "Kafe yoki restoran sohibi",
    "Xo'jalik molari",
  ];

  const EntrepreneurBusinessTypeScreen({super.key}); // Konstruktor

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Oq fon rangi
      body: Stack(
        children: [
          // Pastki qismdagi fon rasmi (ekran balandligining 55%)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.55,
              child: Image.asset(
                'assets/images/rasm8.png', // Rasm manbai
                fit: BoxFit.cover, // Rasmni to'liq qoplash
                width: double.infinity, // Kengligi to'liq
              ),
            ),
          ),
          
          // Orqaga qaytish tugmasi
          Positioned(
            top: 40,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context), // Oldingi sahifaga qaytish
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withAlpha(51), // Yarim shaffof oq fon
                  shape: BoxShape.circle, // Doira shakli
                ),
                child: const Icon(
                  Icons.arrow_back, // Orqaga ikonkasi
                  color: Colors.black,
                ),
              ),
            ),
          ),
          
          // Yuqori qismdagi tanlov paneli
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.56,
              child: Center(
                child: Container(
                  width: 350, // Konteyner kengligi
                  height: 350, // Konteyner balandligi
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withAlpha(51), // 20% shaffoflik
                    borderRadius: BorderRadius.circular(44), // Yumaloq burchaklar
                  ),
                  padding: const EdgeInsets.all(24), // Ichki joy
                  child: Column(
                    children: [
                      // Sarlavha matni
                      const Text(
                        "Tadbirkorligingiz yo'nalishini ko'rsating",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20), // Bo'sh joy
                      
                      // Biznes turi tugmalari
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 2, // 2 ustun
                          childAspectRatio: 160/50, // Tugma nisbati (eni/bo'yi)
                          mainAxisSpacing: 12, // Vertikal oraliq
                          crossAxisSpacing: 12, // Gorizontal oraliq
                          padding: EdgeInsets.zero, // Qo'shimcha joy qo'ymaslik
                          children: businessTypes.map((type) => 
                            BusinessTypeButton(
                              title: type,
                              onPressed: () {
                                // "Mahaliy taksi" tugmasi bosilganda telefon raqam sahifasiga o'tish
                                if (type == "Mahaliy taksi") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const EntrepreneurPhoneScreen(),
                                    ),
                                  );
                                }
                                // Boshqa biznes turlari uchun ham shu logikani qo'shishingiz mumkin
                              },
                            ),
                          ).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Biznes turi tugmasi uchun maxsus widget
class BusinessTypeButton extends StatelessWidget {
  final String title; // Tugma matni
  final VoidCallback onPressed; // Bosilganda bajariladigan funksiya

  const BusinessTypeButton({
    required this.title,
    required this.onPressed,
    super.key, // Widget kaliti
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170, // Aniq kenglik
      height: 50, // Aniq balandlik
      child: ElevatedButton(
        onPressed: onPressed, // Bosilganda funksiya
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white, // Oq fon
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Yumaloq burchaklar
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4), // Ichki joy
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 12, // Matn o'lchami
            color: AppColors.txtColor, // Matn rangi
            fontWeight: FontWeight.bold, // Qalin matn
          ),
          textAlign: TextAlign.center, // Markazga tekislash
          maxLines: 1, // Faqat 1 qator
          overflow: TextOverflow.ellipsis, // Matn sig'masidan "..." qo'yish
        ),
      ),
    );
  }
}