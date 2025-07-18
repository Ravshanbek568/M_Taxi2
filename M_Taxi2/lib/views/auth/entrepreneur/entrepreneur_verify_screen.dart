import 'dart:async'; // Vaqt hisoblash uchun kerakli kutubxona
import 'package:flutter/material.dart';
import 'package:m_taksi/core/theme/colors.dart'; // Loyiha ranglari
import 'package:m_taksi/views/auth/entrepreneur/entrepreneur_profile_screen.dart'; // Tadbirkor profil ekrani

class EntrepreneurVerifyScreen extends StatefulWidget {
  const EntrepreneurVerifyScreen({super.key}); // Widget konstruktori

  @override
  State<EntrepreneurVerifyScreen> createState() => _EntrepreneurVerifyScreenState();
}

class _EntrepreneurVerifyScreenState extends State<EntrepreneurVerifyScreen> {
  // 6 ta raqamli kod uchun controllerlar va fokuslar
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  String smsCode = ""; // Birlashtirilgan SMS kodi
  
  // Vaqt hisoblash uchun o'zgaruvchilar
  int _remainingSeconds = 180; // 3 daqiqa (180 soniya)
  late Timer _timer; // Vaqt hisoblovchi
  bool _canResendCode = false; // Yangi kod jo'natish imkoniyati

  @override
  void initState() {
    super.initState();
    _startTimer(); // Vaqt hisoblashni boshlash
    
    // Har bir raqam katakchasi uchun listener qo'shish
    for (int i = 0; i < _controllers.length; i++) {
      _controllers[i].addListener(() {
        if (_controllers[i].text.length == 1 && i < _controllers.length - 1) {
          // Avtomatik ravishda keyingi katakchaga o'tish
          FocusScope.of(context).requestFocus(_focusNodes[i + 1]);
        }
        // SMS kodini yangilash
        smsCode = _controllers.map((c) => c.text).join();
        if (smsCode.length == 6) {
          // Kod to'liq kiritilganda klaviaturani yopish
          FocusScope.of(context).unfocus();
        }
      });
    }
  }

  // Vaqt hisoblashni boshlash funksiyasi
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _canResendCode = true;
          _timer.cancel(); // Vaqt tugaganda to'xtatish
        }
      });
    });
  }

  // Yangi SMS kod jo'natish funksiyasi
  void _resendCode() {
    setState(() {
      _remainingSeconds = 180; // Vaqtni qayta boshlash
      _canResendCode = false;
      // Barcha katakchalarni tozalash
      for (var controller in _controllers) {
        controller.clear();
      }
      // Fokusni birinchi katakchaga qaytarish
      FocusScope.of(context).requestFocus(_focusNodes[0]);
      _startTimer(); // Yangi timer boshlash
      // Bu yerda SMS jo'natish API so'rovi bo'lishi kerak
    });
  }

  @override
  void dispose() {
    // Resurslarni tozalash
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
      backgroundColor: AppColors.primaryColor, // Asosiy ko'k fon rangi
      
      // APP BAR - ORQAGA QAYTISH TUGMASI
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Shaffof fon
        elevation: 0, // Soyani olib tashlash
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context), // Oldingi ekranga qaytish
        ),
      ),
      
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20), // Yon chetlardan joy
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Markazga tekislash
          children: [
            const SizedBox(height: 50), // Yuqoridan bo'sh joy
            
            // ASOSIY SARLAVHA
            const Text(
              "Telefoningizni tekshiring",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30), // Bo'sh joy
            
            // KOD HAQIDA KO'RSATMA
            const Text(
              "Kelgan kodni kiriting",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 55), // Bo'sh joy
            
            // 6-XONALI KOD KIRITISH MAYDONI
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 45),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  6,
                  (index) => SizedBox(
                    width: 40,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                      decoration: const InputDecoration(
                        counterText: "",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isEmpty && index > 0) {
                          // Belgi o'chirilganda oldingi katakchaga o'tish
                          FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20), // Bo'sh joy
            
            // QOLGAN VAQT KO'RSATKICHI
            Text(
              _formatTime(_remainingSeconds),
              style: TextStyle(
                color: Colors.white.withAlpha(178),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 40), // Bo'sh joy
            
            // YANGI KOD SO'ROVCHI MATNLARI
            const Center(
              child: Text(
                "Hech qanday kod olmadingizmi?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
            TextButton(
              onPressed: _canResendCode ? _resendCode : null,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                "Yangi kod jo'natish",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _canResendCode ? AppColors.txtColor : Colors.white.withAlpha(178),
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 50), // Bo'sh joy
            
            // TASDIQLASH TUGMASI
            SizedBox(
              width: 315,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (smsCode.length == 6) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EntrepreneurProfileScreen(), // Tadbirkor profil ekrani
                      ),
                    );
                  } else {
                    // Xabar ko'rsatish
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Iltimos, 6 xonali kodni to'liq kiriting"),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  "Tasdiqlash",
                  style: TextStyle(
                    color: AppColors.txtColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
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