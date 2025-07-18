import 'package:flutter/material.dart';
import 'package:m_taksi/views/auth/role_selection_screen.dart';

// OnboardingScreen - ilovaga kirish sahifasi, foydalanuvchiga ilova haqida ma'lumot beradi
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

// OnboardingScreen uchun state classi
class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentPageIndex = 0; // Joriy ko'rsatilayotgan sahifa indeksi
  final PageController _pageController = PageController(); // Sahifalar navigatsiyasi uchun controller

  // Onboarding sahifalari ro'yxati
  final List<OnboardingPage> _pages = [
    OnboardingPage(
      image: 'assets/images/rasm1.png',
      title: 'M-Taksi ilovasiga xush kelibsiz',
      description: 'Qulay va xavfsiz safar uchun eng yaxshi taksi xizmati',
    ),
    OnboardingPage(
      image: 'assets/images/rasm2.png',
      title: 'Tez va ishonchli xizmat',
      description: 'Eng yaqin taksi bir necha daqiqada siz bilan',
    ),
    OnboardingPage(
      image: 'assets/images/rasm3.png',
      title: 'Boshlash tayyormisiz?',
      description: 'Ilovadan toʻliq foydalanishni boshlang',
    ),
  ];

  // Keyingi sahifaga o'tish funksiyasi
  void _goToNextPage() {
    if (_currentPageIndex < _pages.length - 1) {
      // Agar oxirgi sahifa bo'lmasa, keyingi sahifaga o'tamiz
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300), // Animatsiya davomiyligi
        curve: Curves.ease, // Animatsiya turi
      );
    } else {
      // Agar oxirgi sahifa bo'lsa, asosiy sahifaga o'tamiz
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RoleSelectScreen()),
      );
    }
  }

  @override
  void dispose() {
    // Controller ni tozalash
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ekran o'lchamlarini olish
    final screenHeight = MediaQuery.of(context).size.height; // Ekran balandligi
    final screenWidth = MediaQuery.of(context).size.width;  // Ekran eni

    return Scaffold(
      backgroundColor: Colors.white, // Sahifa fon rangi
      body: Stack(
        children: [
          // Onboarding sahifalari uchun PageView
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) => setState(() => _currentPageIndex = index),
            itemBuilder: (context, index) => SingleOnboardingPage(
              page: _pages[index],
              screenHeight: screenHeight,
              screenWidth: screenWidth,
            ),
          ),
          
          // Pastki qismdagi kontent uchun Positioned widgeti
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: screenHeight * 0.35, // Ekran balandligining 30% ni egallaydi (oldingi 0.4 dan 0.3 ga o'zgartirildi)
              decoration: const BoxDecoration(
                color: Color(0xFF92CAFE), // Ko'k rang fon
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30), // Yuqori chap tomonga radius
                  topRight: Radius.circular(30), // Yuqori o'ng tomonga radius
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Sarlavha va tavsif uchun Padding
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
                    child: Column(
                      children: [
                        // Sahifa sarlavhasi
                        Text(
                          _pages[_currentPageIndex].title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Hauora',
                          ),
                        ),
                        const SizedBox(height: 10), // Bo'sh joy
                        // Sahifa tavsifi
                        Text(
                          _pages[_currentPageIndex].description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Hauora',
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Tugma va indikatorlar uchun Column
                  Column(
                    children: [
                      // Keyingi/Boshlash tugmasi
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          width: screenWidth * 0.8, // Ekran enining 80%
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withAlpha(128), // Soyqa rang
                                spreadRadius: 2,
                                blurRadius: 10,
                                offset: const Offset(0, 5), // Soyqa pozitsiyasi
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _goToNextPage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white, // Tugma fon rangi
                              foregroundColor: Colors.blue, // Matn rangi
                              padding: const EdgeInsets.symmetric(vertical: 16), // Tugma paddingi
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30), // Tugma radiusi
                              ),
                            ),
                            child: Text(
                              _currentPageIndex == _pages.length - 1 ? 'Boshlash' : 'Keyingi',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Hauora',
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      // Sahifalar indikatori
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _pages.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentPageIndex == index 
                                  ? Colors.white // Joriy sahifa - oq rang
                                  : Colors.white.withAlpha(128), // Boshqa sahifalar - shaffofroq
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20), // Pastki padding
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Bitta onboarding sahifasi uchun widget
class SingleOnboardingPage extends StatelessWidget {
  final OnboardingPage page; // Sahifa ma'lumotlari
  final double screenHeight; // Ekran balandligi
  final double screenWidth;  // Ekran eni
  
  const SingleOnboardingPage({
    super.key, 
    required this.page,
    required this.screenHeight,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    // Rasmni ko'rsatish uchun SizedBox
    return SizedBox(
      height: screenHeight * 0.7, // Ekran balandligining 70% ni egallaydi (oldingi 0.6 dan 0.7 ga o'zgartirildi)
      width: screenWidth, // Ekran eniga to'la
      child: Align(
        alignment: Alignment.topCenter, // Rasmni yuqoriga tekislash
        child: Image.asset(
          page.image, // Rasm manbasi
          fit: BoxFit.cover, // Rasmni quti bo'yicha to'ldirish
        ),
      ),
    );
  }
}

// Onboarding sahifasi ma'lumotlari uchun model
class OnboardingPage {
  final String image;    // Rasm manbasi
  final String title;    // Sahifa sarlavhasi
  final String description; // Sahifa tavsifi

  OnboardingPage({
    required this.image,
    required this.title,
    required this.description,
  });
}