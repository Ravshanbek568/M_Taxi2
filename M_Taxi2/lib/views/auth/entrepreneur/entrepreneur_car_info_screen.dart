import 'package:flutter/material.dart';
import 'package:m_taksi/core/theme/colors.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// PaymentCardRegistrationScreen import qilinishi
import 'package:m_taksi/views/auth/entrepreneur/payment_card_registration_screen.dart';

/// Tadbirkor uchun avtomobil ma'lumotlarini kiritish ekrani
class EntrepreneurCarInfoScreen extends StatefulWidget {
  final bool isEditMode; // 🔹 YANGI: Tahrirlash rejimi

  const EntrepreneurCarInfoScreen({
    super.key,
    this.isEditMode = false, // 🔹 Default: ro'yxatdan o'tish rejimi
  });

  @override
  State<EntrepreneurCarInfoScreen> createState() => _EntrepreneurCarInfoScreenState();
}

class _EntrepreneurCarInfoScreenState extends State<EntrepreneurCarInfoScreen> {
  // Avtomobil ma'lumotlari uchun text controllerlar
  final TextEditingController _carModelController = TextEditingController();
  final TextEditingController _carNumberController = TextEditingController();
  final TextEditingController _carColorController = TextEditingController();
  final TextEditingController _fuelTypeController = TextEditingController();
  
  // Hujjatlar rasmlari uchun fayllar
  File? _driverLicenseImage;    // Haydovchilik guvohnomasi rasmi
  File? _techPassportImage;    // Texnik pasport rasmi
  File? _carSideViewImage;     // Avtomobil yon ko'rinishi
  File? _carFrontViewImage;    // Avtomobil old ko'rinishi
  
  // Rasm tanlash uchun ImagePicker obyekti
  final ImagePicker _picker = ImagePicker();

  // Yoqilg'i turlari ro'yxati
  final List<String> _fuelTypes = [
    'Benzin',
    'Elektr',
    'Metan + Benzin',
    'Propan + Benzin',
    'Elektr + Benzin'
  ];

  // Avtomobil brendlari va modellari ro'yxati
  final Map<String, List<String>> _carModels = {
    'Chevrolet': ['Damas', 'Matiz', 'Lacetti', 'Spark', 'Nexia'],
    'Daewoo': ['Matiz', 'Nexia', 'Gentra', 'Tico'],
    'Kia': ['Cerato', 'Optima', 'Rio', 'Sportage'],
    'Hyundai': ['Accent', 'Elantra', 'Sonata', 'Tucson'],
    'Lada': ['Granta', 'Vesta', 'Niva', 'XRAY'],
    'BMW': ['X5', 'X6', '3 series', '5 series'],
    'Boshqa': ['Boshqa model']
  };

  // Kameraga kirish ruxsati
  bool _cameraPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    // Dastur ishga tushganda kameraga ruxsat so'raymiz
    _requestCameraPermission();
    // 🔹 YANGI: Agar tahrirlash rejimi bo'lsa, mavjud ma'lumotlarni yuklash
    if (widget.isEditMode) {
      _loadCarData();
    }
  }

  @override
  void dispose() {
    // Controllerlarni xotiradan tozalaymiz
    _carModelController.dispose();
    _carNumberController.dispose();
    _carColorController.dispose();
    _fuelTypeController.dispose();
    super.dispose();
  }

  // 🔹 YANGI: Avtomobil ma'lumotlarini yuklash (misol uchun)
  void _loadCarData() {
    // Bu yerda API yoki local databasedan ma'lumotlarni yuklaysiz
    _carModelController.text = "Chevrolet Lacetti";
    _carNumberController.text = "01 A 123 AA";
    _carColorController.text = "Oq";
    _fuelTypeController.text = "Benzin";
  }

  /// Kameraga kirish ruxsatini so'rash
  Future<void> _requestCameraPermission() async {
    // Demo uchun har doim ruxsat bor deb qo'ydik
    setState(() {
      _cameraPermissionGranted = true;
    });
  }

  /// Form to'g'ri to'ldirilganligini tekshirish
  bool _isFormValid() {
    return _carModelController.text.isNotEmpty &&
        _carNumberController.text.isNotEmpty &&
        _carColorController.text.isNotEmpty &&
        _fuelTypeController.text.isNotEmpty &&
        _driverLicenseImage != null &&
        _techPassportImage != null &&
        _carSideViewImage != null &&
        _carFrontViewImage != null;
  }

  /// Rasm tanlash funksiyasi
  Future<void> _pickImage(int documentType) async {
    // Agar kameraga ruxsat bo'lmasa
    if (!_cameraPermissionGranted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kameraga kirish ruxsati yo\'q')),
      );
      return;
    }

    try {
      // Kameradan rasm olamiz
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      
      // Agar rasm tanlangan bo'lsa va widget hali o'chirilmagan bo'lsa
      if (image != null && mounted) {
        setState(() {
          // Tanlangan rasm turiga qarab mos o'zgaruvchiga saqlaymiz
          switch(documentType) {
            case 1: _driverLicenseImage = File(image.path); break;
            case 2: _techPassportImage = File(image.path); break;
            case 3: _carSideViewImage = File(image.path); break;
            case 4: _carFrontViewImage = File(image.path); break;
          }
        });
      }
    } catch (e) {
      // Xatolik yuz berganda
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rasm olishda xatolik: $e')),
      );
    }
  }

  /// Avtomobil modelini tanlash dialogi
  Future<void> _showCarModelDialog() async {
    String? selectedBrand;  // Tanlangan brend
    String? selectedModel;  // Tanlangan model
    bool customModel = false; // "Boshqa" tanlanganligi

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Avtomobil modelini tanlang'),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Brend tanlash uchun dropdown
                      DropdownButton<String>(
                        hint: const Text('Brendni tanlang'),
                        value: selectedBrand,
                        items: _carModels.keys.map((String brand) {
                          return DropdownMenuItem<String>(
                            value: brand,
                            child: Text(brand),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedBrand = newValue;
                            selectedModel = null;
                            customModel = newValue == 'Boshqa';
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      
                      // Model tanlash uchun dropdown (agar brend tanlangan bo'lsa)
                      if (selectedBrand != null && !customModel)
                        DropdownButton<String>(
                          hint: const Text('Modelni tanlang'),
                          value: selectedModel,
                          items: _carModels[selectedBrand]!.map((String model) {
                            return DropdownMenuItem<String>(
                              value: model,
                              child: Text(model),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedModel = newValue;
                            });
                          },
                        ),
                      
                      // Agar "Boshqa" tanlangan bo'lsa, modelni qo'lda kiritish uchun maydon
                      if (customModel)
                        TextField(
                          decoration: const InputDecoration(
                            hintText: 'Avtomobil marka va modelini kiriting',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            selectedModel = value;
                          },
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                // Bekor qilish tugmasi
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Bekor qilish'),
                ),
                // Tasdiqlash tugmasi
                TextButton(
                  onPressed: () {
                    if (selectedBrand != null && 
                        (selectedModel != null || customModel)) {
                      Navigator.pop(context);
                      _carModelController.text = customModel 
                          ? selectedModel!
                          : '$selectedBrand ${selectedModel ?? _carModels[selectedBrand]![0]}';
                    }
                  },
                  child: const Text('Tasdiqlash'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Yoqilg'i turini tanlash dialogi
  Future<void> _showFuelTypeDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Yoqilg\'i turini tanlang'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _fuelTypes.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_fuelTypes[index]),
                  onTap: () {
                    _fuelTypeController.text = _fuelTypes[index];
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  // 🔹 YANGI: Tugma bosilganda bajariladigan harakat
  void _onSubmit() {
    if (_isFormValid()) {
      if (widget.isEditMode) {
        // 🔹 Tahrirlash rejimi: Sozlamalarga qaytish
        Navigator.pop(context); // 🔹 Faqat avtomobil sahifasini yopish
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Avtomobil ma'lumotlari yangilandi"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // 🔹 Ro'yxatdan o'tish rejimi: Keyingi ekranga o'tish
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PaymentCardRegistrationScreen(),
          ),
        );
      }
    } else {
      // Agar forma to'liq to'ldirilmagan bo'lsa
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Iltimos, barcha maydonlarni to\'ldiring va hujjatlarni yuklang'),
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
        // 🔹 YANGI: Rejimga qarab sarlavha
        title: Text(
          widget.isEditMode 
              ? "Avtomobil ma'lumotlarini tahrirlash"
              : "Avtomobil ma'lumotlari",
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Avtomobil rasmi
            Center(
              child: Image.asset(
                'assets/images/rasm5.png',
                height: 200,
                width: 250,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 10),
            
            // Sarlavha
            Center(
              child: Text(
                widget.isEditMode
                    ? "Avtomobil ma'lumotlarini yangilang"
                    : "Avtomobil ma'lumotlarini kiriting",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Ma'lumotlar formasi
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  // Avtomobil modeli maydoni
                  GestureDetector(
                    onTap: _showCarModelDialog,
                    child: AbsorbPointer(
                      child: _buildInputField(
                        "Avtomobil marka va rusumi", 
                        controller: _carModelController,
                      ),
                    ),
                  ),
                  
                  // Davlat raqami maydoni
                  _buildInputField(
                    "Avtomobil davlat raqami", 
                    controller: _carNumberController,
                  ),
                  
                  // Rangi maydoni
                  _buildInputField(
                    "Avtomobil rangi", 
                    controller: _carColorController,
                  ),
                  
                  // Yoqilg'i turi maydoni
                  GestureDetector(
                    onTap: _showFuelTypeDialog,
                    child: AbsorbPointer(
                      child: _buildInputField(
                        "Yoqilg'i turi", 
                        controller: _fuelTypeController,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Hujjatlar sarlavhasi
            Center(
              child: Text(
                widget.isEditMode
                    ? "Avtomobil hujjatlarini yangilang"
                    : "Avtomobil hujjatlarini kiriting",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 15),
            
            // Hujjatlar uchun 4 ta kvadrat
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildDocumentSquare("Haydovchilik guvohnomasi", _driverLicenseImage, 1),
                _buildDocumentSquare("Texnik pasport", _techPassportImage, 2),
                _buildDocumentSquare("Yon ko'rinish", _carSideViewImage, 3),
                _buildDocumentSquare("Old ko'rinish", _carFrontViewImage, 4),
              ],
            ),
            const SizedBox(height: 30),
            
            // Tasdiqlash tugmasi
            Center(
              child: SizedBox(
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
                  // 🔹 YANGILANDI: _onSubmit metodini chaqiramiz
                  onPressed: _isFormValid() ? _onSubmit : null,
                  child: Text(
                    widget.isEditMode ? "Saqlash" : "Tasdiqlash", // 🔹 Tugma matni
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Hujjat kvadrati uchun widget
  Widget _buildDocumentSquare(String title, File? image, int documentType) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _pickImage(documentType),
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey),
              image: image != null ? DecorationImage(
                image: FileImage(image),
                fit: BoxFit.cover,
              ) : null,
            ),
            child: image == null 
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                      const SizedBox(height: 10),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  )
                : null,
          ),
        ),
      ],
    );
  }

  /// Input maydoni uchun widget
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
      ),
    );
  }
}