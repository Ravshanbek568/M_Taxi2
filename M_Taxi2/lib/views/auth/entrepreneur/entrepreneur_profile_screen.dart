import 'package:flutter/material.dart';
import 'package:m_taksi/core/theme/colors.dart'; // Loyiha ranglari uchun
import 'package:m_taksi/views/auth/entrepreneur/entrepreneur_car_info_screen.dart'; // Avtomobil ma'lumotlari ekrani

class EntrepreneurProfileScreen extends StatefulWidget {
  const EntrepreneurProfileScreen({super.key});

  @override
  State<EntrepreneurProfileScreen> createState() => _EntrepreneurProfileScreenState();
}

class _EntrepreneurProfileScreenState extends State<EntrepreneurProfileScreen> {
  // Form uchun controllerlar - har bir input maydoni uchun alohida controller
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Parolni ko'rish holatlari - parolni yashirish/ko'rsatish uchun
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  
  // Parol qo'yishni tanlash uchun checkbox holati
  bool _enablePassword = false;

  @override
  void dispose() {
    // Controllerlarni tozalash - xotirani tozalash uchun
    _companyNameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Formni to'g'ri to'ldirilganligini tekshirish
  bool _isFormValid() {
    // Agar parol qo'yish tanlangan bo'lsa, barcha maydonlarni tekshiramiz
    if (_enablePassword) {
      return _companyNameController.text.isNotEmpty &&
          _firstNameController.text.isNotEmpty &&
          _lastNameController.text.isNotEmpty &&
          _phoneController.text.isNotEmpty &&
          _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty &&
          (_passwordController.text == _confirmPasswordController.text);
    }
    // Agar parol qo'yish tanlanmagan bo'lsa, faqat asosiy maydonlarni tekshiramiz
    return _companyNameController.text.isNotEmpty &&
        _firstNameController.text.isNotEmpty &&
        _lastNameController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        _emailController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor, // Asosiy fon rangi
      
      // APP BAR - ORQAGA QAYTISH TUGMASI
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Shaffof fon
        elevation: 0, // Soyani olib tashlash
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // Orqaga ikonkasi
          onPressed: () => Navigator.pop(context), // Oldingi ekranga qaytish
        ),
      ),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20), // Yon chetlardan padding
        child: Column(
          children: [
            const SizedBox(height: 20), // Yuqoridan bo'sh joy
            
            // PROFIL RASMI VA SARLAVHA
            Column(
              children: [
                // Profil rasmi - Stack yordamida rasm va kamera tugmasini ustma-ust qo'yamiz
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 145,
                      height: 145,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey, // Rasm yo'qligida fon rangi
                      ),
                      child: const Icon(Icons.business, size: 60), // Biznes ikonkasi
                    ),
                    // Rasm qo'shish tugmasi
                    GestureDetector(
                      onTap: _showImagePickerDialog, // Rasm tanlash dialogini ochish
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.yellow, // Sariq rangli aylana
                        ),
                        child: const Icon(Icons.camera_alt), // Kamera ikonkasi
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10), // Bo'sh joy
                
                // SARLAVHA MATNI
                const Text(
                  "Kompaniya profilingizni yarating",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30), // Bo'sh joy
            
            // MA'LUMOTLAR FORMASI
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white, // Oq fon
                borderRadius: BorderRadius.circular(10), // Yumaloq burchaklar
              ),
              child: Column(
                children: [
                  // Kompaniya nomi maydoni
                  _buildInputField("Kompaniya nomi", controller: _companyNameController),
                  // Foydalanuvchi ismi maydoni
                  _buildInputField("Foydalanuvchi ismi", controller: _firstNameController),
                  // Foydalanuvchi familiyasi maydoni
                  _buildInputField("Foydalanuvchi familiyasi", controller: _lastNameController),
                  // Telefon raqami maydoni
                  _buildInputField("Telefon raqamingiz", controller: _phoneController),
                  // Email maydoni
                  _buildInputField("Email", controller: _emailController),
                  const SizedBox(height: 10), // Bo'sh joy
                  
                  // PAROL QO'YISHNI TANLASH CHECKBOXI
                  Row(
                    children: [
                      Checkbox(
                        value: _enablePassword,
                        onChanged: (value) {
                          setState(() {
                            _enablePassword = value!;
                            if (!_enablePassword) {
                              // Agar parol qo'yish bekor qilinsa, parollarni tozalash
                              _passwordController.clear();
                              _confirmPasswordController.clear();
                            }
                          });
                        },
                      ),
                      const Text("Parol qo'yishni xoxlaysizmi?"),
                    ],
                  ),
                  const SizedBox(height: 10), // Bo'sh joy
                  
                  // FAQAT CHECKBOX TANLANGAN BO'LSA PAROL MAYDONLARINI KO'RSATISH
                  if (_enablePassword) ...[
                    // Parol maydoni
                    _buildPasswordField("Parolni kiriting", 
                      controller: _passwordController,
                      showPassword: _showPassword,
                      onToggleVisibility: () {
                        setState(() {
                          _showPassword = !_showPassword; // Parolni ko'rsatish/yashirish
                        });
                      },
                    ),
                    // Parolni takrorlash maydoni
                    _buildPasswordField("Parolni takrorlang", 
                      controller: _confirmPasswordController,
                      showPassword: _showConfirmPassword,
                      onToggleVisibility: () {
                        setState(() {
                          _showConfirmPassword = !_showConfirmPassword; // Parolni ko'rsatish/yashirish
                        });
                      },
                    ),
                    // PAROLLAR MOS KELMASA XABAR
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
            const SizedBox(height: 30), // Bo'sh joy
            
            // TASDIQLASH TUGMASI
            SizedBox(
              width: 315, // Tugma eni
              height: 50, // Tugma balandligi
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // Oq fon
                  foregroundColor: AppColors.txtColor, // Matn rangi
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24), // Yumaloq burchaklar
                  ),
                ),
                onPressed: _isFormValid() ? () {
                  // Form to'g'ri to'ldirilgan bo'lsa, avtomobil ma'lumotlari ekraniga o'tamiz
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EntrepreneurCarInfoScreen(),
                    ),
                  );
                } : null, // Form to'g'ri to'ldirilmagan bo'lsa tugma faol bo'lmaydi
                child: const Text(
                  "Tasdiqlash",
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(height: 20), // Bo'sh joy
          ],
        ),
      ),
    );
  }

  // RASM TANLASH DIALOGI
  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Rasm tanlang"),
        actions: [
          // Galereyadan rasm tanlash tugmasi
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Dialogni yopish
              // Bu yerda galereyadan rasm tanlash logikasi bo'lishi kerak
            },
            child: const Text("Galereya"),
          ),
          // Kamera orqali rasm olish tugmasi
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Dialogni yopish
              // Bu yerda kamera orqali rasm olish logikasi bo'lishi kerak
            },
            child: const Text("Kamera"),
          ),
        ],
      ),
    );
  }

  // ODDIY INPUT MAYDONI UCHUN WIDGET
  Widget _buildInputField(String hint, {required TextEditingController controller}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15), // Pastdan joy
      height: 50, // Balandligi
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10), // Yumaloq burchaklar
        border: Border.all(color: Colors.grey), // Kulrang chegara
      ),
      child: TextField(
        controller: controller, // Controller biriktirish
        decoration: InputDecoration(
          hintText: hint, // Yorliq matni
          border: InputBorder.none, // Standart chegarasiz
          contentPadding: const EdgeInsets.symmetric(horizontal: 15), // Ichki padding
        ),
        onChanged: (value) {
          setState(() {}); // Har bir o'zgarishda UI ni yangilash
        },
      ),
    );
  }

  // PAROL INPUT MAYDONI UCHUN WIDGET
  Widget _buildPasswordField(
    String hint, {
    required TextEditingController controller,
    required bool showPassword,
    required VoidCallback onToggleVisibility,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15), // Pastdan joy
      height: 50, // Balandligi
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10), // Yumaloq burchaklar
        border: Border.all(color: Colors.grey), // Kulrang chegara
      ),
      child: TextField(
        controller: controller, // Controller biriktirish
        obscureText: !showPassword, // Parolni yashirish/ko'rsatish
        decoration: InputDecoration(
          hintText: hint, // Yorliq matni
          border: InputBorder.none, // Standart chegarasiz
          contentPadding: const EdgeInsets.symmetric(horizontal: 15), // Ichki padding
          suffixIcon: IconButton( // Ko'z ikonkasi
            icon: Icon(
              showPassword ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey,
            ),
            onPressed: onToggleVisibility, // Bosilganda holatni o'zgartirish
          ),
        ),
        onChanged: (value) {
          setState(() {}); // Har bir o'zgarishda UI ni yangilash
        },
      ),
    );
  }
}