import 'package:flutter/material.dart';
import 'package:m_taksi/core/theme/colors.dart'; // Loyiha ranglari uchun kutubxona
import 'package:m_taksi/views/auth/client/client_payment_card_registration_screen.dart'; // To'lov karta sahifasi uchun import

// Mijoz profilingizni yaratish uchun ekran
class ClientProfileScreen extends StatefulWidget {
  const ClientProfileScreen({super.key}); // Konstruktor

  @override
  State<ClientProfileScreen> createState() => _ClientProfileScreenState(); // Holatni yaratish
}

// Profil ekrani holati
class _ClientProfileScreenState extends State<ClientProfileScreen> {
  // TextField controllerlari
  final TextEditingController _firstNameController = TextEditingController(); // Ism uchun
  final TextEditingController _lastNameController = TextEditingController(); // Familiya uchun
  final TextEditingController _phoneController = TextEditingController(); // Telefon raqam uchun
  final TextEditingController _emailController = TextEditingController(); // Email uchun
  final TextEditingController _passwordController = TextEditingController(); // Parol uchun
  final TextEditingController _confirmPasswordController = TextEditingController(); // Parolni tasdiqlash uchun

  // UI holatlari
  bool _showPassword = false; // Parolni ko'rsatish/yashirish
  bool _showConfirmPassword = false; // Tasdiqlash parolini ko'rsatish/yashirish
  bool _enablePassword = false; // Parol qo'yishni tanlash

  @override
  void dispose() {
    // Controllerlarni xotiradan tozalash
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Form to'g'ri to'ldirilganligini tekshirish
  bool _isFormValid() {
    if (_enablePassword) {
      // Parol tanlangan holatda tekshirish
      return _firstNameController.text.isNotEmpty && // Ism kiritilganligi
          _lastNameController.text.isNotEmpty && // Familiya kiritilganligi
          _phoneController.text.isNotEmpty && // Telefon kiritilganligi
          _emailController.text.isNotEmpty && // Email kiritilganligi
          _passwordController.text.isNotEmpty && // Parol kiritilganligi
          _confirmPasswordController.text.isNotEmpty && // Tasdiqlash paroli kiritilganligi
          (_passwordController.text == _confirmPasswordController.text); // Parollar mosligi
    }
    // Parol tanlanmagan holatda tekshirish
    return _firstNameController.text.isNotEmpty &&
        _lastNameController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        _emailController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor, // Asosiy fon rangi
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Shaffof appbar
        elevation: 0, // Soyasiz
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // Orqaga tugmasi
          onPressed: () => Navigator.pop(context), // Orqaga qaytish funksiyasi
        ),
      ),
      body: SingleChildScrollView( // Aylanadigan kontent
        padding: const EdgeInsets.symmetric(horizontal: 20), // Yon chetlardan joy
        child: Column(
          children: [
            const SizedBox(height: 20), // Bo'sh joy
            // Profil rasmi va sarlavha
            Column(
              children: [
                // Profil rasmi uchun stack
                Stack(
                  alignment: Alignment.bottomRight, // Elementlarni o'ng pastga joylash
                  children: [
                    // Profil rasmi uchun konteyner
                    Container(
                      width: 145,
                      height: 145,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle, // Doira shakli
                        color: Colors.grey, // Rasm yo'qligida fon rangi
                      ),
                      child: const Icon(Icons.person, size: 60), // Standart profil ikonkasi
                    ),
                    // Rasm qo'shish tugmasi
                    GestureDetector(
                      onTap: _showImagePickerDialog, // Rasm tanlash dialogini ochish
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.yellow, // Sariq fon
                        ),
                        child: const Icon(Icons.camera_alt), // Kamera ikonkasi
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10), // Kichik bo'sh joy
                // Sarlavha matni
                const Text(
                  "Profilingizni yarating",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30), // Katta bo'sh joy
            // Ma'lumotlar formasi
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20), // Ichki joy
              decoration: BoxDecoration(
                color: Colors.white, // Oq fon
                borderRadius: BorderRadius.circular(10), // Yumaloq burchaklar
              ),
              child: Column(
                children: [
                  // Ism maydoni
                  _buildInputField("Foydalanuvchi ismi", controller: _firstNameController),
                  // Familiya maydoni
                  _buildInputField("Foydalanuvchi familiyasi", controller: _lastNameController),
                  // Telefon maydoni
                  _buildInputField("Telefon raqamingiz", controller: _phoneController),
                  // Email maydoni
                  _buildInputField("Email", controller: _emailController),
                  const SizedBox(height: 10), // Bo'sh joy
                  // Parol qo'yishni tanlash uchun checkbox
                  Row(
                    children: [
                      Checkbox(
                        value: _enablePassword, // Holat
                        onChanged: (value) { // O'zgarish funksiyasi
                          setState(() {
                            _enablePassword = value!;
                            if (!_enablePassword) {
                              // Parol qo'yish bekor qilinganda maydonlarni tozalash
                              _passwordController.clear();
                              _confirmPasswordController.clear();
                            }
                          });
                        },
                      ),
                      const Text("Parol qo'yishni xoxlaysizmi?"), // Matn
                    ],
                  ),
                  const SizedBox(height: 10), // Bo'sh joy
                  // Parol maydonlari (faqat tanlangan bo'lsa)
                  if (_enablePassword) ...[
                    // Parol maydoni
                    _buildPasswordField("Parolni kiriting", 
                      controller: _passwordController,
                      showPassword: _showPassword,
                      onToggleVisibility: () { // Ko'rish tugmasi funksiyasi
                        setState(() {
                          _showPassword = !_showPassword;
                        });
                      },
                    ),
                    // Parolni tasdiqlash maydoni
                    _buildPasswordField("Parolni takrorlang", 
                      controller: _confirmPasswordController,
                      showPassword: _showConfirmPassword,
                      onToggleVisibility: () { // Ko'rish tugmasi funksiyasi
                        setState(() {
                          _showConfirmPassword = !_showConfirmPassword;
                        });
                      },
                    ),
                    // Parollar mos kelmasa xabar
                    if (_passwordController.text.isNotEmpty && 
                        _confirmPasswordController.text.isNotEmpty &&
                        _passwordController.text != _confirmPasswordController.text)
                      const Text(
                        "Parollar mos kelmadi!",
                        style: TextStyle(color: Colors.red), // Qizil rangda xabar
                      ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 30), // Katta bo'sh joy
            // Tasdiqlash tugmasi
            SizedBox(
              width: 315, // Kenglik
              height: 50, // Balandlik
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // Oq fon
                  foregroundColor: AppColors.txtColor, // Matn rangi
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24), // Yumaloq burchaklar
                  ),
                ),
                onPressed: _isFormValid() ? () {
                  // Form to'g'ri to'ldirilgan bo'lsa to'lov karta sahifasiga o'tish
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ClientPaymentCardScreen(),
                    ),
                  );
                } : null, // Form to'g'ri emas bo'lsa tugmani o'chirib qo'yish
                child: const Text(
                  "Tasdiqlash",
                  style: TextStyle(fontSize: 20), // Katta shrift
                ),
              ),
            ),
            const SizedBox(height: 20), // Pastki bo'sh joy
          ],
        ),
      ),
    );
  }

  // Rasm tanlash dialogini ko'rsatish
  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Rasm tanlang"), // Sarlavha
        actions: [
          // Galereyadan tanlash tugmasi
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Dialogni yopish
              // Galereyadan rasm tanlash logikasi
            },
            child: const Text("Galereya"),
          ),
          // Kamera tugmasi
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Dialogni yopish
              // Kamera orqali rasm olish logikasi
            },
            child: const Text("Kamera"),
          ),
        ],
      ),
    );
  }

  // Oddiy input maydoni uchun widget
  Widget _buildInputField(String hint, {required TextEditingController controller}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15), // Pastki margin
      height: 50, // Balandlik
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10), // Yumaloq burchaklar
        border: Border.all(color: Colors.grey), // Chegara
      ),
      child: TextField(
        controller: controller, // Controller
        decoration: InputDecoration(
          hintText: hint, // Ko'rsatkich matni
          border: InputBorder.none, // Chegarasiz
          contentPadding: const EdgeInsets.symmetric(horizontal: 15), // Ichki joy
        ),
        onChanged: (value) {
          setState(() {}); // UI ni yangilash
        },
      ),
    );
  }

  // Parol maydoni uchun widget
  Widget _buildPasswordField(
    String hint, {
    required TextEditingController controller,
    required bool showPassword,
    required VoidCallback onToggleVisibility,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15), // Pastki margin
      height: 50, // Balandlik
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10), // Yumaloq burchaklar
        border: Border.all(color: Colors.grey), // Chegara
      ),
      child: TextField(
        controller: controller, // Controller
        obscureText: !showPassword, // Parolni yashirish
        decoration: InputDecoration(
          hintText: hint, // Ko'rsatkich matni
          border: InputBorder.none, // Chegarasiz
          contentPadding: const EdgeInsets.symmetric(horizontal: 15), // Ichki joy
          suffixIcon: IconButton( // Ko'rish tugmasi
            icon: Icon(
              showPassword ? Icons.visibility : Icons.visibility_off, // Ikonka
              color: Colors.grey, // Kulrang rang
            ),
            onPressed: onToggleVisibility, // Bosilganda funksiya
          ),
        ),
        onChanged: (value) {
          setState(() {}); // UI ni yangilash
        },
      ),
    );
  }
}