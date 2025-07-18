import 'package:flutter/material.dart';
import 'package:m_taksi/core/theme/colors.dart'; // Ranglar theme fayli
import 'package:m_taksi/views/onboarding_screen.dart'; // Keyingi ekran

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToOnboarding(); // Ekran yaratilganda navigatsiya funksiyasini chaqirish
  }

  // Onboarding ekraniga o'tish funksiyasi
  Future<void> _navigateToOnboarding() async {
    // 3 soniya kutish
    await Future.delayed(const Duration(seconds: 3));
    
    // Agar widget hali ekranda bo'lsa (o'chirilmagan bo'lsa)
    if (!mounted) return;
    
    // Onboarding ekraniga o'tish (joriy ekranni almashtirish)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const OnboardingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Markaziy logo qismi
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 250, // Logo kengligi
                  height: 250, // Logo balandligi
                  padding: const EdgeInsets.all(20), // Logo atrofidagi bo'sh joy
                  child: Image.asset(
                    'assets/images/logo.png', // Logo rasmi manzili
                    fit: BoxFit.contain, // Rasmni konteynerga moslashtirish
                  ),
                ),
              ],
            ),
          ),
          
          // Pastki matn qismi
          Positioned(
            left: 0, // Chap chekkadan masofa
            right: 0, // O'ng chekkadan masofa
            bottom: 280, // Pastdan masofa
            child: Center(
              child: Text(
                "Qulay va erkin muloqot uchun", // Ko'rsatiladigan matn
                style: TextStyle(
                  fontFamily: 'Hauora', // Shrift turi
                  fontSize: 16, // Shrift o'lchami
                  fontWeight: FontWeight.w600, // Shrift qalinligi
                  color: AppColors.txtColor, // Matn rangi (theme fayldan olinadi)
                ),
                textAlign: TextAlign.center, // Matnni markazga tekislash
              ),
            ),
          ),
        ],
      ),
    );
  }
}