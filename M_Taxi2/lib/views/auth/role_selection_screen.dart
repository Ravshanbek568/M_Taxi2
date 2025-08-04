import 'package:flutter/material.dart';
import 'package:m_taksi/core/theme/colors.dart'; // Loyihaning ranglarini olish uchun
// import 'package:m_taksi/views/auth/client/client_phone_screen.dart'; // Mijoz telefon ekrani
import 'package:m_taksi/views/auth/client/main_navigation/main_navigation.dart';
import 'package:m_taksi/views/auth/entrepreneur/entrepreneur_business_type_screen.dart'; // Tadbirkor biznes turi ekrani

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key}); // Widget konstruktori

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Butun ekran fonini oq qilish
      body: Center( // Barcha kontentni markazga joylashtirish
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Vertikal markazlash
          children: [
            // Asosiy ko'k rangli konteyner
            Container(
              width: 315, // Konteyner eni
              height: 315, // Konteyner balandligi
              margin: const EdgeInsets.only(bottom: 50), // Pastdagi rasm bilan oraliq
              decoration: BoxDecoration(
                color: AppColors.primaryColor, // Asosiy ko'k rang (#92CAFE)
                borderRadius: BorderRadius.circular(40), // 40px radiusli yumaloq burchaklar
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // Ichki kontentni markazlash
                children: [
                  // Sarlavha matni
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20), // Yon chetlardan 20px padding
                    child: Text(
                      "Kim sifatida ro'yxatdan o'tmoqchisiz?",
                      textAlign: TextAlign.center, // Matnni markazga tekislash
                      style: TextStyle(
                        fontSize: 20, // Shrift o'lchami
                        color: Colors.white, // Oq rang
                        fontWeight: FontWeight.bold, // Qalin shrift
                      ),
                    ),
                  ),
                  const SizedBox(height: 30), // Sarlavha va tugmalar orasidagi bo'sh joy
                  
                  // Tugmalar guruhi
                  Column(
                    children: [
                      // Mijoz tugmasi
                      _buildRoleButton(
                        text: "Mijoz", // Tugma matni
                        onPressed: () { // Tugma bosilganda
                          Navigator.push( // Yangi ekranga o'tish
                            context,
                            MaterialPageRoute(
                              // builder: (_) => const ClientPhoneScreen(), // Mijoz telefon ekrani
                              builder: (_) => const MainNavigationScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20), // Tugmalar orasidagi bo'sh joy
                      
                      // Tadbirkor tugmasi
                      _buildRoleButton(
                        text: "Tadbirkor",
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EntrepreneurBusinessTypeScreen(), // Tadbirkor biznes turi ekrani
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Pastki qismdagi rasm
            Image.asset(
              "assets/images/rasm4.png", // Rasm manzili
              width: 285, // Rasm eni
              height: 220, // Rasm balandligi
              fit: BoxFit.contain, // Rasmni o'zgarishsiz saqlab qolish
            ),
          ],
        ),
      ),
    );
  }

  // Tugma yasash uchun yordamchi funksiya
  Widget _buildRoleButton({
    required String text, // Tugma matni (majburiy)
    required VoidCallback onPressed, // Bosilganda ishlaydigan funksiya (majburiy)
  }) {
    return SizedBox(
      width: 250, // Tugma enini belgilash
      child: ElevatedButton(
        onPressed: onPressed, // Tugma bosilganda ishlaydigan funksiya
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white, // Tugma fon rangi (oq)
          padding: const EdgeInsets.symmetric(vertical: 15), // Ichki padding
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // 20px radiusli yumaloq burchaklar
          ),
        ),
        child: Text(
          text, // Tugma matni
          style: const TextStyle(
            color: AppColors.txtColor, // Matn rangi (asosiy ko'k)
            fontSize: 18, // Shrift o'lchami
            fontWeight: FontWeight.bold, // Qalin shrift
          ),
        ),
      ),
    );
  }
}