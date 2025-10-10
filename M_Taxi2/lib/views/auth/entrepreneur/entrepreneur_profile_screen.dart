import 'package:flutter/material.dart';
import 'package:m_taksi/core/theme/colors.dart';
import 'package:m_taksi/views/auth/entrepreneur/entrepreneur_car_info_screen.dart';

class EntrepreneurProfileScreen extends StatefulWidget {
  final bool isEditMode; // 🔹 YANGI: Tahrirlash rejimi

  const EntrepreneurProfileScreen({
    super.key,
    this.isEditMode = false, // 🔹 Default: ro'yxatdan o'tish rejimi
  });

  @override
  State<EntrepreneurProfileScreen> createState() => _EntrepreneurProfileScreenState();
}

class _EntrepreneurProfileScreenState extends State<EntrepreneurProfileScreen> {
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _enablePassword = false;

  @override
  void initState() {
    super.initState();
    // 🔹 YANGI: Agar tahrirlash rejimi bo'lsa, mavjud ma'lumotlarni yuklash
    if (widget.isEditMode) {
      _loadProfileData();
    }
  }

  // 🔹 YANGI: Profil ma'lumotlarini yuklash (misol uchun)
  void _loadProfileData() {
    // Bu yerda API yoki local databasedan ma'lumotlarni yuklaysiz
    _companyNameController.text = "Namuna Kompaniya";
    _firstNameController.text = "Ali";
    _lastNameController.text = "Valiyev";
    _phoneController.text = "+998901234567";
    _emailController.text = "ali@kompaniya.uz";
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isFormValid() {
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
    return _companyNameController.text.isNotEmpty &&
        _firstNameController.text.isNotEmpty &&
        _lastNameController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        _emailController.text.isNotEmpty;
  }

  // 🔹 YANGI: Tugma bosilganda bajariladigan harakat
  void _onSubmit() {
    if (widget.isEditMode) {
      // 🔹 Tahrirlash rejimi: Sozlamalarga qaytish
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profil ma'lumotlari yangilandi")),
      );
    } else {
      // 🔹 Ro'yxatdan o'tish rejimi: Keyingi ekranga o'tish
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const EntrepreneurCarInfoScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 145,
                      height: 145,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey,
                      ),
                      child: const Icon(Icons.business, size: 60),
                    ),
                    GestureDetector(
                      onTap: _showImagePickerDialog,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.yellow,
                        ),
                        child: const Icon(Icons.camera_alt),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // 🔹 YANGI: Rejimga qarab sarlavha
                Text(
                  widget.isEditMode 
                      ? "Profil ma'lumotlarini tahrirlash"
                      : "Kompaniya profilingizni yarating",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  _buildInputField("Kompaniya nomi", controller: _companyNameController),
                  _buildInputField("Foydalanuvchi ismi", controller: _firstNameController),
                  _buildInputField("Foydalanuvchi familiyasi", controller: _lastNameController),
                  _buildInputField("Telefon raqamingiz", controller: _phoneController),
                  _buildInputField("Email", controller: _emailController),
                  const SizedBox(height: 10),
                  
                  // 🔹 YANGI: Tahrirlash rejimida parol qismini yashirish
                  if (!widget.isEditMode) ...[
                    Row(
                      children: [
                        Checkbox(
                          value: _enablePassword,
                          onChanged: (value) {
                            setState(() {
                              _enablePassword = value!;
                              if (!_enablePassword) {
                                _passwordController.clear();
                                _confirmPasswordController.clear();
                              }
                            });
                          },
                        ),
                        const Text("Parol qo'yishni xoxlaysizmi?"),
                      ],
                    ),
                    const SizedBox(height: 10),
                    
                    if (_enablePassword) ...[
                      _buildPasswordField("Parolni kiriting", 
                        controller: _passwordController,
                        showPassword: _showPassword,
                        onToggleVisibility: () {
                          setState(() {
                            _showPassword = !_showPassword;
                          });
                        },
                      ),
                      _buildPasswordField("Parolni takrorlang", 
                        controller: _confirmPasswordController,
                        showPassword: _showConfirmPassword,
                        onToggleVisibility: () {
                          setState(() {
                            _showConfirmPassword = !_showConfirmPassword;
                          });
                        },
                      ),
                      if (_passwordController.text.isNotEmpty && 
                          _confirmPasswordController.text.isNotEmpty &&
                          _passwordController.text != _confirmPasswordController.text)
                        const Text(
                          "Parollar mos kelmadi!",
                          style: TextStyle(color: Colors.red),
                        ),
                    ],
                  ],
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            // 🔹 YANGI: Rejimga qarab tugma matni
            SizedBox(
              width: 315,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.txtColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: _isFormValid() ? _onSubmit : null,
                child: Text(
                  widget.isEditMode ? "Saqlash" : "Tasdiqlash", // 🔹 Tugma matni
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Rasm tanlang"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
            },
            child: const Text("Galereya"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
            },
            child: const Text("Kamera"),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String hint, {required TextEditingController controller}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15),
        ),
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }

  Widget _buildPasswordField(
    String hint, {
    required TextEditingController controller,
    required bool showPassword,
    required VoidCallback onToggleVisibility,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey),
      ),
      child: TextField(
        controller: controller,
        obscureText: !showPassword,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15),
          suffixIcon: IconButton(
            icon: Icon(
              showPassword ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey,
            ),
            onPressed: onToggleVisibility,
          ),
        ),
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }
}