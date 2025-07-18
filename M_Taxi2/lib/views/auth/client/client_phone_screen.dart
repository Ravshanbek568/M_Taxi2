import 'package:flutter/material.dart';
import 'package:m_taksi/core/theme/colors.dart'; // Loyiha ranglari uchun
import 'package:m_taksi/views/auth/client/client_verify_screen.dart'; // Keyingi ekran

class ClientPhoneScreen extends StatelessWidget {
  const ClientPhoneScreen({super.key}); // Widget konstruktori

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
            // YUQORIDAN 240PX BO'SH JOY
            const SizedBox(height: 150),
            
            // ASOSIY SARLAVHA (MARKAZDA)
            const Text(
              "Telefon raqamingizni kiriting",
              textAlign: TextAlign.center, // Matnni markazga tekislash
              style: TextStyle(
                fontSize: 26, // Shrift o'lchami
                color: Colors.white, // Oq rang
              ),
            ),
            const SizedBox(height: 20), // 10px bo'sh joy
            
            // IZOH MATNI (MARKAZDA)
            const Text(
              "Biz sizga raqamni tasdiqlash uchun SMS xabar yuboramiz",
              textAlign: TextAlign.center, // Matnni markazga tekislash
              style: TextStyle(
                color: Colors.white, // Och oq rang
              ),
            ),
            const SizedBox(height: 18), // 20px bo'sh joy
            
            // TELEFON RAQAMI KIRITISH MAYDONI
            Container(
               width: 315, // 315px eni (o'zgartirildi)
                height: 50, // 50px balandligi (o'zgartirildi) 
               decoration: BoxDecoration(
                color: Colors.transparent, // Shaffof fon (oq emas)
                borderRadius: BorderRadius.circular(24), // 24px yumaloq burchaklar
                border: Border.all(
                  color: Colors.white, // Oq rangli chegara
                  width: 1.5, // 1px qalinlikdagi chiziq
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
            const SizedBox(height: 65), // 60px bo'sh joy
            
            // KOD HAQIDA OGOHLANTIRISH (MARKAZDA)
            const Text(
              "Kod kelishi uchun bu yerga bosing",
              textAlign: TextAlign.center, // Matnni markazga tekislash
              style: TextStyle(
                color: Colors.white, // Oq rang
                fontSize: 18, // Shrift o'lchami
              ),
            ),
            const SizedBox(height: 20), // 20px bo'sh joy
            
            // "KEYINGISI" TUGMASI (3 TA XATO TUZATILGAN)
            SizedBox(
              width: 315, // 315px eni
              height: 50, // 50px balandligi
              child: ElevatedButton(
                onPressed: () {
                  // Keyingi ekranga o'tish
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ClientVerifyScreen(), // Kod tasdiqlash ekrani
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // Tugma fon rangi
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24), // 20px yumaloq burchaklar
                  ), // <-- Qavs to'g'ri yopildi (1-xato tuzatildi)
                ),
                child: const Text( // <-- 'child' parametri to'g'ri ishlatildi (2-xato tuzatildi)
                  "Keyingisi",
                  style: TextStyle(
                    color: AppColors.txtColor, // Ko'k matn rangi
                    fontSize: 20, // Shrift o'lchami
                    fontWeight: FontWeight.bold, // Qalin shrift
                  ), // <-- Qavs to'g'ri yopildi (3-xato tuzatildi)
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}