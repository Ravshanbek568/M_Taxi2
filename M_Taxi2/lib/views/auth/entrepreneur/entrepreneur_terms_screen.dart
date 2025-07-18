import 'package:flutter/material.dart';
import 'package:m_taksi/core/theme/colors.dart';
import 'package:m_taksi/views/auth/entrepreneur/entrepreneur_home_scren.dart';

class EntrepreneurTermsScreen extends StatefulWidget {
  const EntrepreneurTermsScreen({super.key});

  @override
  State<EntrepreneurTermsScreen> createState() => _EntrepreneurTermsScreenState();
}

class _EntrepreneurTermsScreenState extends State<EntrepreneurTermsScreen> {
  bool _termsAccepted = false;
  bool _privacyAccepted = false;
  bool _gpsEnabled = false;

  void _goBack() {
    Navigator.pop(context);
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const EntrepreneurHomeScreen(),
      ),
    );
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
          onPressed: _goBack,
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Rasm
              Image.asset(
                'assets/images/rasm7.png',
                width: 386,
                height: 220,
              ),
              
              // Sarlavha
              const SizedBox(height: 15),
              const Text(
                "Ilova shartlarini qabul qilasizmi?",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              // Shartlar ro'yxati
              const SizedBox(height: 15),
              Container(
                width: 340,
                padding: const EdgeInsets.all(20), // Paddingni kamaytirdik
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    _buildTermItem(
                      "Xizmat ko'rsatish qoidalarini tasdiqlash",
                      _termsAccepted,
                      (value) => setState(() => _termsAccepted = value),
                    ),
                    const SizedBox(height: 15),
                    _buildTermItem(
                      "Maxfiylik siyosatini qabul qilish",
                      _privacyAccepted,
                      (value) => setState(() => _privacyAccepted = value),
                    ),
                    const SizedBox(height: 15),
                    _buildTermItem(
                      "GPS va bildirishnomalarni yoqish",
                      _gpsEnabled,
                      (value) => setState(() => _gpsEnabled = value),
                    ),
                  ],
                ),
              ),
              
              // Tasdiqlash tugmasi
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 35),
                child: ElevatedButton(
                  onPressed: (_termsAccepted && _privacyAccepted && _gpsEnabled)
                      ? _navigateToHome
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.txtColor,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    "Tasdiqlash",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTermItem(String text, bool value, Function(bool) onChanged) {
    return Row(
      children: [
        // Checkbox
        GestureDetector(
          onTap: () => onChanged(!value),
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.txtColor, width: 2),
              color: value ? AppColors.txtColor : Colors.white,
            ),
            child: value
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
          ),
        ),
        
        // Matn
        const SizedBox(width: 35),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16, // Font hajmini oshirdik
              color: Colors.black,
              fontWeight: FontWeight.w500, // Matnni qalinroq qildik
            ),
          ),
        ),
      ],
    );
  }
}