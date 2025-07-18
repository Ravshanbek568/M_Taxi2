import 'package:flutter/material.dart';
import 'package:m_taksi/core/theme/colors.dart'; // Loyiha ranglari uchun
import 'package:m_taksi/views/auth/entrepreneur/entrepreneur_verify_screen.dart'; // Tadbirkorlar uchun tasdiqlash ekrani

class EntrepreneurPhoneScreen extends StatelessWidget {
  const EntrepreneurPhoneScreen({super.key}); // Widget konstruktori

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ASOSIY EKRAN SOZLAMALARI
      backgroundColor: AppColors.primaryColor, // Asosiy ko'k fon rangi (#92CAFE)
      
      // APP BAR - ORQAGA QAYTISH TUGMASI
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Shaffof fon
        elevation: 0, // Soyani olib tashlash
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // Orqaga ikonkasi
          onPressed: () => Navigator.pop(context), // Oldingi ekranga qaytish
        ),
      ),
      
      // ASOSIY KONTENT
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20), // Yon chetlardan 20px padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // MARKAZGA TEKISLASH
          children: [
            // YUQORIDAN BO'SH JOY (150px)
            const SizedBox(height: 150),
            
            // ASOSIY SARLAVHA (MARKAZDA)
            const Text(
              "Telefon raqamingizni kiriting", // Tadbirkor uchun sarlavha
              textAlign: TextAlign.center, // Matnni markazga tekislash
              style: TextStyle(
                fontSize: 26, // Shrift o'lchami
                color: Colors.white, // Oq rang
                fontWeight: FontWeight.bold, // Qalin shrift
              ),
            ),
            const SizedBox(height: 20), // 20px bo'sh joy
            
            // IZOH MATNI (MARKAZDA)
            const Text(
              "Biz sizga raqamni tasdiqlash uchun SMS xabar yuboramiz", // SMS haqida ma'lumot
              textAlign: TextAlign.center, // Matnni markazga tekislash
              style: TextStyle(
                color: Colors.white, // Oq rang
                fontSize: 16, // Shrift o'lchami
              ),
            ),
            const SizedBox(height: 18), // 18px bo'sh joy
            
            // TELEFON RAQAMI KIRITISH MAYDONI
            Container(
              width: 315, // 315px eni
              height: 50, // 50px balandligi 
              decoration: BoxDecoration(
                color: Colors.transparent, // Shaffof fon
                borderRadius: BorderRadius.circular(24), // 24px yumaloq burchaklar
                border: Border.all(
                  color: Colors.white, // Oq rangli chegara
                  width: 1.5, // 1.5px qalinlikdagi chiziq
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 15), // Ichki padding
              child: const TextField(
                keyboardType: TextInputType.phone, // Raqam klaviaturasi
                textAlign: TextAlign.center, // Matnni markazga tekislash
                style: TextStyle(
                  color: Colors.white, // Matn rangi
                  fontSize: 24, // Shrift o'lchami
                ),
                decoration: InputDecoration(
                  border: InputBorder.none, // Standart chegara yo'q
                  hintText: "+998 XX XXX XX XX", // Namuna matn
                  hintStyle: TextStyle(
                    color: Colors.white54, // Namuna matn rangi
                    fontSize: 16, // Shrift o'lchami
                  ),
                ),
              ),
            ),
            const SizedBox(height: 65), // 65px bo'sh joy
            
            // KOD HAQIDA OGOHLANTIRISH (MARKAZDA)
            const Text(
              "Kod kelishi uchun bu yerga bosing", // SMS kod haqida eslatma
              textAlign: TextAlign.center, // Matnni markazga tekislash
              style: TextStyle(
                color: Colors.white, // Oq rang
                fontSize: 18, // Shrift o'lchami
              ),
            ),
            const SizedBox(height: 20), // 20px bo'sh joy
            
            // "KEYINGISI" TUGMASI
            SizedBox(
              width: 315, // 315px eni
              height: 50, // 50px balandligi
              child: ElevatedButton(
                onPressed: () {
                  // Keyingi ekranga o'tish (tadbirkor tasdiqlash ekraniga)
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EntrepreneurVerifyScreen(), // Tadbirkor tasdiqlash ekrani
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // Tugma fon rangi
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24), // 24px yumaloq burchaklar
                  ),
                ),
                child: const Text(
                  "Keyingisi", // Tugma matni
                  style: TextStyle(
                    color: AppColors.txtColor, // Ko'k matn rangi
                    fontSize: 20, // Shrift o'lchami
                    fontWeight: FontWeight.bold, // Qalin shrift
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}