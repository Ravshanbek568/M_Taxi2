import 'dart:async'; // Timer uchun import qo'shildi
import 'package:flutter/material.dart';
import 'package:m_taksi/core/theme/colors.dart';
import 'package:m_taksi/views/auth/client/client_profile_screen.dart';

class ClientVerifyScreen extends StatefulWidget {
  const ClientVerifyScreen({super.key});

  @override
  State<ClientVerifyScreen> createState() => _ClientVerifyScreenState();
}

class _ClientVerifyScreenState extends State<ClientVerifyScreen> {
  // Kod katakchalari uchun controllerlar va focus nodelari
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  String smsCode = ""; // SMS kodi uchun umumiy o'zgaruvchi
  
  // Sanoq uchun o'zgaruvchilar
  int _remainingSeconds = 180; // 3 daqiqa = 180 soniya
  late Timer _timer; // Sanoq uchun timer
  bool _canResendCode = false; // Yangi kod jo'natish mumkinligi

  @override
  void initState() {
    super.initState();
    // Sanoqni boshlash
    _startTimer();
    
    // Har bir controller uchun listener qo'shamiz
    for (int i = 0; i < _controllers.length; i++) {
      _controllers[i].addListener(() {
        if (_controllers[i].text.length == 1 && i < _controllers.length - 1) {
          // Keyingi katakchaga fokus qilamiz
          FocusScope.of(context).requestFocus(_focusNodes[i + 1]);
        }
        // SMS kodini yangilaymiz
        smsCode = _controllers.map((c) => c.text).join();
        if (smsCode.length == 6) {
          // Kod to'liq kiritilganda klaviaturani yopamiz
          FocusScope.of(context).unfocus();
        }
      });
    }
  }

  // Sanoqni boshlash funksiyasi
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _canResendCode = true;
          _timer.cancel(); // Sanoq tugaganda timerni to'xtatamiz
        }
      });
    });
  }

  // Yangi kod jo'natish funksiyasi
  void _resendCode() {
    setState(() {
      _remainingSeconds = 180; // Sanoqni qayta boshlash
      _canResendCode = false;
      // Barcha katakchalarni tozalash
      for (var controller in _controllers) {
        controller.clear();
      }
      // Focusni birinchi katakchaga qaytarish
      FocusScope.of(context).requestFocus(_focusNodes[0]);
      // Yangi timer boshlash
      _startTimer();
      // Bu yerda yangi SMS kod jo'natish logikasi bo'lishi kerak
    });
  }

  @override
  void dispose() {
    // Timer va boshqa resurslarni tozalash
    _timer.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  // Soniyalarni daqiqa:soniya formatiga o'tkazish
  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20), // Yon chetlardan 20px padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Barcha elementlarni markazga tekislash
          children: [
            // YUQORIDAN 50PX BO'SH JOY
            const SizedBox(height: 50),
            
            // ASOSIY SARLAVHA (MARKAZDA)
            const Text(
              "Telefoningizni tekshiring",
              textAlign: TextAlign.center, // Matnni markazga tekislash
              style: TextStyle(
                fontSize: 24, // Shrift o'lchami
                color: Colors.white, // Oq rang
                fontWeight: FontWeight.bold, // Qalin shrift
              ),
            ),
            const SizedBox(height: 30), // 30px bo'sh joy
            
            // KOD HAQIDA KO'RSATMA (MARKAZDA)
            const Text(
              "Kelgan kodni kiriting",
              textAlign: TextAlign.center, // Matnni markazga tekislash
              style: TextStyle(
                fontSize: 16, // Shrift o'lchami
                color: Colors.white, // Oq rang
              ),
            ),
            const SizedBox(height: 55), // 55px bo'sh joy
            
            // 6-XONALI KOD KIRITISH JOYI (AVTOMATIK O'TISH BILAN)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 45), // Yon chetlardan 45px joy
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Kod maydonlarini teng taqsimlash
                children: List.generate(
                  6, // 6 ta maydon
                  (index) => SizedBox(
                    width: 40, // Har bir maydon eni
                    child: TextField(
                      controller: _controllers[index], // Har bir katak uchun controller
                      focusNode: _focusNodes[index], // Har bir katak uchun focus node
                      keyboardType: TextInputType.number, // Raqamli klaviatura
                      textAlign: TextAlign.center, // Matnni markazga tekislash
                      maxLength: 1, // Maksimal 1 belgi
                      style: const TextStyle(
                        color: Colors.white, // Matn rangi
                        fontSize: 24, // Shrift o'lchami
                      ),
                      decoration: const InputDecoration(
                        counterText: "", // Hisoblagichni olib tashlash
                        border: InputBorder.none, // Chegara yo'q
                        contentPadding: EdgeInsets.zero, // Ichki padding yo'q
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white), // Oq chiziqcha
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white), // Oq chiziqcha fokusda
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isEmpty && index > 0) {
                          // Belgi o'chirilganda oldingi katakchaga o'tamiz
                          FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20), // 20px bo'sh joy
            
            // QOLGAN VAQT KO'RSATKICHI
            Text(
              _formatTime(_remainingSeconds), // Formatlangan vaqt
              style: TextStyle(
                color: Colors.white.withAlpha(178), // Yarim shaffof oq rang
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 40), // 20px bo'sh joy
            
            // YANGI KOD SO'ROVCHI MATNLARI (MARKAZDA)
            const Center(
              child: Text(
                "Hech qanday kod olmadingizmi?",
                textAlign: TextAlign.center, // Matnni markazga tekislash
                style: TextStyle(
                  color: Colors.white, // Oq rang
                  fontSize: 18, // Shrift o'lchami
                ),
              ),
            ),
            TextButton(
              onPressed: _canResendCode ? _resendCode : null, // Faqat vaqt tugaganda bosiladi
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero, // Ichki paddingni olib tashlash
                minimumSize: Size.zero, // Minimal o'lcham
                tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Bosish maydonini qisqartirish
              ),
              child: Text(
                "Yangi kod jo'natish",
                textAlign: TextAlign.center, // Matnni markazga tekislash
                style: TextStyle(
                  color: _canResendCode ? AppColors.txtColor : Colors.white.withAlpha(178),
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 50),
            
            // TASDIQLASH TUGMASI
            SizedBox(
              width: 315, // 315px eni
              height: 50, // 50px balandligi
              child: ElevatedButton(
                onPressed: () {
                  // Kodni tekshirish logikasi
                  if (smsCode.length == 6) {
                    Navigator.push( // Keyingi ekranga o'tish
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ClientProfileScreen(), // Profil ekrani
                      ),
                    );
                  } else {
                    // Kod to'liq kiritilmagan holatda xabar ko'rsatish
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Iltimos, 6 xonali kodni to'liq kiriting"),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // Tugma fon rangi
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24), // 24px yumaloq burchaklar
                  ),
                ),
                child: const Text(
                  "Tasdiqlash",
                  style: TextStyle(
                    color: AppColors.txtColor, // Matn rangi
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