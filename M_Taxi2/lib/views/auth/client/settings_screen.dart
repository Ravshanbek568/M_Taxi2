// Flutter va loyiha uchun kerakli kutubxonalarni import qilish
import 'package:flutter/material.dart';
import 'package:m_taksi/models/user_model.dart';
import 'package:m_taksi/core/theme/colors.dart';

// Sozlamalar ekrani uchun StatefulWidget
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key}); // Konstruktor

  @override
  State<SettingsScreen> createState() => _SettingsScreenState(); // State yaratish
}

// Sozlamalar ekrani stateni boshqaruvchi klass
class _SettingsScreenState extends State<SettingsScreen> {
  late UserModel _user; // Foydalanuvchi ma'lumotlari
  bool _isLoading = true; // Yuklanish holati
  bool _enablePasswordChange = false; // Parolni o'zgartirishni yoqish
  bool _enableCardChange = false; // Karta ma'lumotlarini o'zgartirishni yoqish
  bool _showCurrentPassword = false; // Joriy parolni ko'rsatish
  bool _showNewPassword = false; // Yangi parolni ko'rsatish
  bool _showConfirmPassword = false; // Tasdiqlash parolini ko'rsatish
  bool _showCvv = false; // CVV ni ko'rsatish
  bool _isCardExpired = false; // Karta muddati o'tganligi
  
  // TextField controllerlari
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryMonthController = TextEditingController();
  final TextEditingController _expiryYearController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  
  String _selectedCardType = ''; // Tanlangan karta turi

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Foydalanuvchi ma'lumotlarini yuklash
    // Kontrollerlarga listenerlar qo'shish
    _cardNumberController.addListener(_formatCardNumber);
    _expiryMonthController.addListener(_validateCardExpiry);
    _expiryYearController.addListener(_validateCardExpiry);
  }

  @override
  void dispose() {
    // Kontrollerlardan listenerlarni olib tashlash
    _cardNumberController.removeListener(_formatCardNumber);
    _expiryMonthController.removeListener(_validateCardExpiry);
    _expiryYearController.removeListener(_validateCardExpiry);
    super.dispose();
  }

  // Foydalanuvchi ma'lumotlarini yuklash funksiyasi
  Future<void> _loadUserData() async {
    try {
      final user = await UserModel.loadFromPrefs(); // Ma'lumotlarni yuklash
      if (mounted) { // Widget mount bo'lganligini tekshirish
        setState(() {
          _user = user;
          _isLoading = false; // Yuklanish tugadi
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _user = UserModel(); // Yangi user yaratish
          _isLoading = false; // Yuklanish tugadi
        });
      }
    }
  }

  // Karta raqamini formatlash funksiyasi (xxxx xxxx xxxx xxxx)
  void _formatCardNumber() {
    // Faqat raqamlarni qoldirish
    final text = _cardNumberController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final newText = StringBuffer();

    // Har 4 ta raqamdan keyin probel qo'yish
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) newText.write(' ');
      newText.write(text[i]);
    }

    // Agar o'zgarish bo'lsa, yangi qiymatni o'rnatish
    if (_cardNumberController.text != newText.toString()) {
      _cardNumberController.value = TextEditingValue(
        text: newText.toString(),
        selection: TextSelection.collapsed(offset: newText.length),
      );
    }

    _determineCardType(text); // Karta turini aniqlash
  }

  // Karta turini aniqlash funksiyasi
  void _determineCardType(String cardNumber) {
    if (cardNumber.startsWith('9860')) {
      setState(() => _selectedCardType = 'humo');
    } else if (cardNumber.startsWith('5614') || cardNumber.startsWith('8600')) {
      setState(() => _selectedCardType = 'uzcard');
    } else if (cardNumber.startsWith('4400')) {
      setState(() => _selectedCardType = 'visa');
    } else if (cardNumber.startsWith('5500')) {
      setState(() => _selectedCardType = 'mastercard');
    } else {
      setState(() => _selectedCardType = ''); // Noma'lum karta
    }
  }

  // Karta amal qilish muddatini tekshirish
  void _validateCardExpiry() {
    if (_expiryMonthController.text.length == 2 && 
        _expiryYearController.text.length == 4) {
      final now = DateTime.now();
      final month = int.tryParse(_expiryMonthController.text) ?? 0;
      final year = int.tryParse(_expiryYearController.text) ?? 0;
      
      // Oy noto'g'ri kiritilgan bo'lsa
      if (month < 1 || month > 12) {
        _showSnackBar('Noto\'g\'ri oy');
        return;
      }
      
      // Karta muddati o'tganligini tekshirish
      setState(() {
        _isCardExpired = year < now.year || (year == now.year && month < now.month);
      });
    } else {
      setState(() {
        _isCardExpired = false;
      });
    }
  }

  // SnackBar ko'rsatish funksiyasi
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2), // 2 soniya ko'rsatish
      ),
    );
  }

  // Profilni saqlash funksiyasi
  Future<void> _saveProfile() async {
    if (!mounted) return; // Widget mount bo'lmagan bo'lsa
    
    // Profil maydonlarini to'ldirilganligini tekshirish
    if ((_user.firstName ?? '').isEmpty ||
        (_user.lastName ?? '').isEmpty ||
        (_user.phone ?? '').isEmpty ||
        (_user.address ?? '').isEmpty ||
        (_user.email ?? '').isEmpty) {
      _showSnackBar('Maydonlarni to\'liq to\'ldirishingiz shart');
      return;
    }

    // Parol o'zgartirish bo'limi tekshiruvi
    if (_enablePasswordChange) {
      if (_currentPasswordController.text.isEmpty ||
          _newPasswordController.text.isEmpty ||
          _confirmPasswordController.text.isEmpty) {
        _showSnackBar('Maydonlarni to\'liq to\'ldirishingiz shart');
        return;
      }

      if (_newPasswordController.text.length < 4) {
        _showSnackBar('Parol kamida 4 ta belgidan iborat bo\'lishi kerak');
        return;
      }

      if (_newPasswordController.text != _confirmPasswordController.text) {
        _showSnackBar('Parollar mos kelmadi');
        return;
      }
    }

    // Karta ma'lumotlari tekshiruvi
    if (_enableCardChange) {
      if (_cardNumberController.text.replaceAll(' ', '').length != 16) {
        _showSnackBar('Karta raqamini to\'liq kiriting');
        return;
      }

      if (_expiryMonthController.text.isEmpty || _expiryYearController.text.isEmpty) {
        _showSnackBar('Maydonlarni to\'liq to\'ldirishingiz shart');
        return;
      }

      if (_cvvController.text.length != 3) {
        _showSnackBar('CVV 3 raqamdan iborat bo\'lishi kerak');
        return;
      }

      if (_isCardExpired) {
        _showSnackBar('Karta muddati o\'tgan');
        return;
      }
    }

    try {
      // Parolni yangilash
      if (_enablePasswordChange) {
        _user.password = _newPasswordController.text;
      }
      
      // Karta ma'lumotlarini yangilash
      if (_enableCardChange) {
        _user.cardNumber = _cardNumberController.text;
        _user.cardExpiry = '${_expiryMonthController.text}/${_expiryYearController.text}';
      }
      
      await _user.saveToPrefs(); // Ma'lumotlarni saqlash
      if (mounted) {
        _showSnackBar('Profil yangilandi!'); // Muvaffaqiyatli yangilandi
        setState(() {
          _enablePasswordChange = false;
          _enableCardChange = false;
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Xatolik yuz berdi!'); // Xatolik xabari
      }
    }
  }

  // Rasm tanlash dialogini ko'rsatish
  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Rasm tanlang"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Galereyadan rasm tanlash (keyinchalik to'ldiriladi)
              },
              child: const Text("Galereya"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Kamera orqali rasm olish (keyinchalik to'ldiriladi)
              },
              child: const Text("Kamera"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()), // Yuklanish indikatori
      );
    }

    return Scaffold(
      backgroundColor: AppColors.primaryColor, // Asosiy rang
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Shaffof appbar
        elevation: 0, // Soyasiz
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.txtColor1),
          onPressed: () => Navigator.pop(context), // Orqaga tugmasi
        ),
        title: Text(
          'Sozlamalar',
          style: TextStyle(color: AppColors.txtColor1), // Sarlavha
        ),
      ),
      body: SingleChildScrollView( // Scroll qilinadigan kontent
        padding: const EdgeInsets.symmetric(horizontal: 20), // Yon padding
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildAvatarSection(), // Avatar qismi
            const SizedBox(height: 30),
            _buildProfileForm(), // Profil formasi
            const SizedBox(height: 30),
            _buildCardChangeSection(), // Karta o'zgartirish bo'limi
            const SizedBox(height: 30),
            _buildSaveButton(), // Saqlash tugmasi
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Avatar qismini yaratish
  Widget _buildAvatarSection() {
    return Center(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 145,
                height: 145,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                  image: _user.avatarUrl != null
                      ? DecorationImage( // Agar avatar bo'lsa
                          image: NetworkImage(_user.avatarUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _user.avatarUrl == null
                    ? const Icon(Icons.person, size: 60, color: Colors.white)
                    : null, // Agar avatar bo'lmasa
              ),
              GestureDetector(
                onTap: _showImagePickerDialog, // Rasm tanlash dialogi
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.yellow, // Sariq rangda kamera tugmasi
                  ),
                  child: const Icon(Icons.camera_alt),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Rasmni o\'zgartirish',
              style: TextStyle(color: AppColors.txtColor1, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  // Profil formasi widgeti
  Widget _buildProfileForm() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.txtColor1, // Oq fon
        borderRadius: BorderRadius.circular(10), // Qirralari yumaloq
      ),
      child: Column(
        children: [
          // Barcha input maydonlari
          _buildInputField("Ism", _user.firstName ?? '', (value) => _user.firstName = value),
          _buildInputField("Familiya", _user.lastName ?? '', (value) => _user.lastName = value),
          _buildInputField("Telefon", _user.phone ?? '', (value) => _user.phone = value),
          _buildInputField("Manzil", _user.address ?? '', (value) => _user.address = value),
          _buildInputField("Email", _user.email ?? '', (value) => _user.email = value),
          const SizedBox(height: 10),
          
          // Parolni o'zgartirish checkboxi
          Row(
            children: [
              Checkbox(
                value: _enablePasswordChange,
                onChanged: (value) {
                  setState(() {
                    _enablePasswordChange = value!;
                    if (!_enablePasswordChange) {
                      // Parol maydonlarini tozalash
                      _currentPasswordController.clear();
                      _newPasswordController.clear();
                      _confirmPasswordController.clear();
                    }
                  });
                },
              ),
              const Text(
                "Parolni o'zgartirishni xohlaysizmi?",
                style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
              ),
            ],
          ),
          
          // Agar parol o'zgartirish yoqilgan bo'lsa
          if (_enablePasswordChange) ...[
            const SizedBox(height: 15),
            // Joriy parol maydoni
            _buildPasswordField(
              "Joriy parol", 
              _currentPasswordController,
              _showCurrentPassword,
              () => setState(() => _showCurrentPassword = !_showCurrentPassword),
            ),
            const SizedBox(height: 15),
            // Yangi parol maydoni
            _buildPasswordField(
              "Yangi parol", 
              _newPasswordController,
              _showNewPassword,
              () => setState(() => _showNewPassword = !_showNewPassword),
            ),
            const SizedBox(height: 15),
            // Parolni tasdiqlash maydoni
            _buildPasswordField(
              "Yangi parolni takrorlang", 
              _confirmPasswordController,
              _showConfirmPassword,
              () => setState(() => _showConfirmPassword = !_showConfirmPassword),
            ),
          ],
        ],
      ),
    );
  }

  // Parol maydoni widgeti
  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    bool showPassword,
    VoidCallback onToggleVisibility,
  ) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color.fromARGB(255, 0, 0, 0)),
      ),
      child: TextField(
        controller: controller,
        obscureText: !showPassword, // Parolni yashirish/ko'rsatish
        style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(color: Color.fromARGB(179, 32, 32, 32)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          suffixIcon: IconButton( // Ko'rish tugmasi
            icon: Icon(
              showPassword ? Icons.visibility : Icons.visibility_off,
              color: const Color.fromARGB(255, 0, 0, 0),
            ),
            onPressed: onToggleVisibility,
          ),
        ),
      ),
    );
  }

  // Karta o'zgartirish bo'limi widgeti
  Widget _buildCardChangeSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.txtColor1,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Karta ma'lumotlarini o'zgartirish checkboxi
          Row(
            children: [
              Checkbox(
                value: _enableCardChange,
                onChanged: (value) {
                  setState(() {
                    _enableCardChange = value!;
                    if (!_enableCardChange) {
                      // Maydonlarni tozalash
                      _cardNumberController.clear();
                      _expiryMonthController.clear();
                      _expiryYearController.clear();
                      _cvvController.clear();
                      _isCardExpired = false;
                    }
                  });
                },
              ),
              Text(
                _user.cardNumber == null 
                  ? "Ilovaga kartani bog'laysizmi?"
                  : "Karta ma'lumotlarini o'zgartirasizmi?",
                style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
              ),
            ],
          ),
          
          // Agar karta o'zgartirish yoqilgan bo'lsa
          if (_enableCardChange) ...[
            const SizedBox(height: 20),
            _buildCardNumberField(), // Karta raqami maydoni
            const SizedBox(height: 15),
            Row(
              children: [
                // Oy maydoni
                Expanded(
                  child: _buildExpiryField("Oy (MM)", _expiryMonthController, 2),
                ),
                const SizedBox(width: 10),
                // Yil maydoni
                Expanded(
                  child: _buildExpiryField("Yil (YYYY)", _expiryYearController, 4),
                ),
                const SizedBox(width: 10),
                // CVV maydoni
                Expanded(
                  child: _buildCvvField(),
                ),
              ],
            ),
            // Agar karta muddati o'tgan bo'lsa
            if (_isCardExpired)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Karta muddati o\'tgan',
                  style: TextStyle(
                    color: Colors.red, // Qizil rangda xabar
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  // Saqlash tugmasi widgeti
  Widget _buildSaveButton() {
    return SizedBox(
      width: 300, // Kengligi
      child: ElevatedButton(
        onPressed: _saveProfile, // Saqlash funksiyasi
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white, // Oq fon
          foregroundColor: AppColors.txtColor, // Matn rangi
          minimumSize: const Size(double.infinity, 50), // Minimal o'lcham
        ),
        child: const Text(
          'Saqlash',
          style: TextStyle(fontSize: 18), // Matn o'lchami
        ),
      ),
    );
  }

  // Oddiy input maydoni widgeti
  Widget _buildInputField(String label, String value, Function(String) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color.fromARGB(255, 0, 0, 0)),
      ),
      child: TextField(
        controller: TextEditingController(text: value), // Boshlang'ich qiymat
        style: const TextStyle(color: Color.fromARGB(255, 10, 10, 10)),
        decoration: InputDecoration(
          hintText: label, // Yorliq
          hintStyle: const TextStyle(color: Color.fromARGB(179, 32, 32, 32)),
          border: InputBorder.none, // Chegarasiz
          contentPadding: const EdgeInsets.symmetric(horizontal: 15),
        ),
        onChanged: onChanged, // O'zgarishlarni qabul qilish
      ),
    );
  }

  // Karta raqami maydoni widgeti
  Widget _buildCardNumberField() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color.fromARGB(255, 0, 0, 0)),
      ),
      child: Stack(
        children: [
          TextField(
            controller: _cardNumberController,
            keyboardType: TextInputType.number, // Raqamli klaviatura
            maxLength: 19, // Maksimal uzunlik (16 raqam + 3 probel)
            style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
            decoration: InputDecoration(
              hintText: 'Kartangiz raqami kirgazing',
              hintStyle: const TextStyle(color: Color.fromARGB(179, 32, 32, 32)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(
                left: _selectedCardType.isNotEmpty ? 90 : 90, // Karta logosi uchun joy
                right: 15,
                top: 15,
                bottom: 12,
              ),
              counterText: '', // Hisoblagichni olib tashlash
            ),
          ),
          // Agar karta turi tanlangan bo'lsa, logoni ko'rsatish
          if (_selectedCardType.isNotEmpty)
            Positioned(
              left: 18,
              top: 0,
              child: Image.asset(
                'assets/images/${_selectedCardType}_logo.png',
                width: 50,
                height: 50,
              ),
            ),
        ],
      ),
    );
  }

  // Amal qilish muddati maydoni widgeti
  Widget _buildExpiryField(String hint, TextEditingController controller, int maxLength) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color.fromARGB(255, 0, 0, 0)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number, // Raqamli klaviatura
        maxLength: maxLength, // Maksimal belgilar soni
        style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
        decoration: InputDecoration(
          hintText: hint, // Yorliq
          hintStyle: const TextStyle(color: Color.fromARGB(179, 32, 32, 32)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          counterText: '', // Hisoblagichni olib tashlash
        ),
      ),
    );
  }

  // CVV maydoni widgeti
  Widget _buildCvvField() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color.fromARGB(255, 0, 0, 0)),
      ),
      child: TextField(
        controller: _cvvController,
        keyboardType: TextInputType.number, // Raqamli klaviatura
        obscureText: !_showCvv, // Yashirish/ko'rsatish
        maxLength: 3, // 3 ta raqam
        style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
        decoration: InputDecoration(
          hintText: 'CVV',
          hintStyle: const TextStyle(color: Color.fromARGB(179, 32, 32, 32)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          counterText: '', // Hisoblagichni olib tashlash
          suffixIcon: IconButton( // Ko'rish tugmasi
            icon: Icon(
              _showCvv ? Icons.visibility : Icons.visibility_off,
              color: const Color.fromARGB(255, 0, 0, 0),
            ),
            onPressed: () {
              setState(() => _showCvv = !_showCvv); // Holatni o'zgartirish
              if (_showCvv) {
                // 3 soniyadan keyin yashirish
                Future.delayed(const Duration(seconds: 3), () {
                  if (mounted) {
                    setState(() => _showCvv = false);
                  }
                });
              }
            },
          ),
        ),
      ),
    );
  }
}