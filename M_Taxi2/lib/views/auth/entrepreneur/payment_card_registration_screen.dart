import 'package:flutter/material.dart';
import 'package:m_taksi/core/theme/colors.dart';
import 'package:m_taksi/views/auth/entrepreneur/entrepreneur_terms_screen.dart'; // Entrepreneur shartlari ekrani importi

// /**
//  * TO'LOV KARTASI RO'YXATDAN O'TKAZISH EKRANI
//  * 
//  * Bu ekran foydalanuvchilarga to'lov kartasi ma'lumotlarini kiritish imkoniyatini beradi.
//  * Karta raqami, amal qilish muddati va CVV kodini o'z ichiga oladi.
//  */
class PaymentCardRegistrationScreen extends StatefulWidget {
  const PaymentCardRegistrationScreen({super.key});

  @override
  State<PaymentCardRegistrationScreen> createState() => _PaymentCardRegistrationScreenState();
}

// /**
//  * TO'LOV KARTASI RO'YXATDAN O'TKAZISH EKRANI HOLATI
//  * 
//  * Bu klass ekranning holatini boshqaradi va barcha mantiqiy funksiyalarni o'z ichiga oladi.
//  */
class _PaymentCardRegistrationScreenState extends State<PaymentCardRegistrationScreen> {
  // KARTA MA'LUMOTLARI UCHUN CONTROLLERLAR
  final TextEditingController _cardNumberController = TextEditingController(); // Karta raqami uchun controller
  final TextEditingController _expiryMonthController = TextEditingController(); // Oy (MM) uchun controller
  final TextEditingController _expiryYearController = TextEditingController(); // Yil (YYYY) uchun controller
  final TextEditingController _cvvController = TextEditingController(); // CVV kodi uchun controller

  // UI HOLATLARI
  String _selectedCardType = ''; // Tanlangan karta turi (humo, uzcard, visa, mastercard)
  bool _isCvvVisible = false; // CVV kodini ko'rsatish/yashirish holati
  bool _isExpiryValid = true; // Karta amal qilish muddati yaroqli/yaroqsizligi

  // /**
  //  * INITSTATE FUNKSIYASI
  //  * 
  //  * Widget yaratilganda bajariladigan funksiya.
  //  * Controllerlarga listenerlar qo'shiladi.
  //  */
  @override
  void initState() {
    super.initState();
    _cardNumberController.addListener(_formatCardNumber); // Karta raqamini formatlash uchun listener
    _expiryMonthController.addListener(_checkExpiry); // Amal qilish muddatini tekshirish uchun listener
    _expiryYearController.addListener(_checkExpiry); // Amal qilish muddatini tekshirish uchun listener
    _cvvController.addListener(_handleCvvVisibility); // CVV ko'rinishini boshqarish uchun listener
  }

  // /**
  //  * DISPOSE FUNKSIYASI
  //  * 
  //  * Widget yo'q qilinganda bajariladigan funksiya.
  //  * Controllerlarni tozalash va listenerlarni olib tashlash.
  //  */
  @override
  void dispose() {
    _cardNumberController.removeListener(_formatCardNumber);
    _expiryMonthController.removeListener(_checkExpiry);
    _expiryYearController.removeListener(_checkExpiry);
    _cvvController.removeListener(_handleCvvVisibility);
    
    _cardNumberController.dispose();
    _expiryMonthController.dispose();
    _expiryYearController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  // /**
  //  * KARTA RAQAMINI FORMATLASH FUNKSIYASI
  //  * 
  //  * Karta raqamini 4-4-4-4 formatiga keltiradi.
  //  * Har 4 ta raqamdan keyin probel qo'yiladi.
  //  */
  void _formatCardNumber() {
    // Faqat raqamlarni qoldiradi (boshqa belgilarni olib tashlaydi)
    final text = _cardNumberController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final newText = StringBuffer();

    // Har 4 ta raqamdan keyin probel qo'yamiz
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) newText.write(' ');
      newText.write(text[i]);
    }

    // Agar o'zgarish bo'lsa, yangi qiymatni o'rnatamiz
    if (_cardNumberController.text != newText.toString()) {
      _cardNumberController.value = TextEditingValue(
        text: newText.toString(),
        selection: TextSelection.collapsed(offset: newText.length),
      );
    }

    _determineCardType(text); // Karta turini aniqlash funksiyasini chaqiramiz
  }

  // /**
  //  * KARTA TURINI ANIQLASH FUNKSIYASI
  //  * 
  //  * Karta raqamiga qarab turini aniqlaydi (humo, uzcard, visa, mastercard).
  //  * @param cardNumber - kiritilgan karta raqami
  //  */
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
      setState(() => _selectedCardType = '');
    }
  }

  // /**
  //  * KARTA MUDDATINI TEKSHIRISH FUNKSIYASI
  //  * 
  //  * Karta amal qilish muddati yaroqli yoki yaroqsizligini tekshiradi.
  //  */
  void _checkExpiry() {
    if (_expiryMonthController.text.length == 2 && _expiryYearController.text.length == 4) {
      final now = DateTime.now(); // Joriy sana
      final month = int.tryParse(_expiryMonthController.text) ?? 0; // Oy raqami
      final year = int.tryParse(_expiryYearController.text) ?? 0; // Yil raqami
      
      // Muddat o'tganligini tekshiramiz
      final isExpired = year < now.year || (year == now.year && month < now.month);
      setState(() => _isExpiryValid = !isExpired); // Holatni yangilaymiz
    }
  }

  // /**
  //  * CVV KODINI KO'RSATISH FUNKSIYASI
  //  * 
  //  * CVV kodini 1 soniyagina ko'rsatadi, keyin yashiradi.
  //  */
  void _handleCvvVisibility() {
    if (_cvvController.text.isNotEmpty) {
      setState(() => _isCvvVisible = true); // Ko'rsatamiz
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() => _isCvvVisible = false); // Yashiramiz
        }
      });
    }
  }

  // /**
  //  * BO'SH MAYDONLAR UCHUN DIALOG KO'RSATISH FUNKSIYASI
  //  * 
  //  * Agar foydalanuvchi hech qanday maydonni to'ldirmagan bo'lsa,
  //  * ma'lumotlarni keyinroq kiritishni so'raydigan dialog ko'rsatiladi.
  //  */
  void _showEmptyFieldsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), // Yumaloq burchakli dialog
          contentPadding: const EdgeInsets.all(20), // Ichki padding
          content: SizedBox(
            width: 280, // Dialog kengligi
            height: 240, // Dialog balandligi
            child: Column(
              mainAxisSize: MainAxisSize.min, // Kontentga mos balandlik
              children: [
                // Sarlavha matni
                const Text(
                  "Ma'lumotlarni keyinroq kiritmoqchimisiz?",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30), // Bo'sh joy
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Tugmalarni teng joylashtirish
                  children: [
                    // "Ha" tugmasi
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondaryColor, // Tugma rangi
                        minimumSize: const Size(100, 50), // Tugma o'lchami
                      ),
                      onPressed: () {
                        Navigator.pop(context); // Dialogni yopish
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EntrepreneurTermsScreen(), // Entrepreneur terms sahifasiga o'tish
                          ),
                        );
                      },
                      child: const Text(
                        "Ha",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    // "Yo'q" tugmasi
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300], // Tugma rangi
                        minimumSize: const Size(100, 50), // Tugma o'lchami
                      ),
                      onPressed: () => Navigator.pop(context), // Faqat dialogni yopish
                      child: const Text(
                        "Yo'q",
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // /**
  //  * TASDIQLASH TUGMASI BOSILGANDA BAJARILADIGAN FUNKSIYA
  //  * 
  //  * Barcha kiritilgan ma'lumotlarni tekshiradi va agar hammasi to'g'ri bo'lsa,
  //  * keyingi sahifaga o'tadi.
  //  */
  void _onConfirmPressed() {
    // Agar hech qanday maydon to'ldirilmagan bo'lsa
    if (_cardNumberController.text.isEmpty &&
        _expiryMonthController.text.isEmpty &&
        _expiryYearController.text.isEmpty &&
        _cvvController.text.isEmpty) {
      _showEmptyFieldsDialog(); // Bo'sh maydonlar uchun dialog ko'rsatamiz
      return;
    }

    // Karta raqami validatsiyasi (16 ta raqam bo'lishi kerak)
    if (_cardNumberController.text.isNotEmpty && 
        _cardNumberController.text.replaceAll(' ', '').length != 16) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Karta raqami noto\'g\'ri kiritilgan')));
      return;
    }

    // Muddat kiritilganligini tekshiramiz
    if ((_expiryMonthController.text.isNotEmpty || _expiryYearController.text.isNotEmpty) &&
        (_expiryMonthController.text.isEmpty || _expiryYearController.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Karta amal qilish muddati kiritilmagan')));
      return;
    }

    // Muddat amal qilishini tekshiramiz
    if (!_isExpiryValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Karta muddati o\'tib ketgan')));
      return;
    }

    // CVV kodini tekshiramiz (3 ta raqam bo'lishi kerak)
    if (_cvvController.text.isNotEmpty && _cvvController.text.length != 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CVV kodi noto\'g\'ri kiritilgan')));
      return;
    }

    // Agar hamma maydonlar to'g'ri to'ldirilgan bo'lsa
    if (_cardNumberController.text.isNotEmpty &&
        _expiryMonthController.text.isNotEmpty &&
        _expiryYearController.text.isNotEmpty &&
        _cvvController.text.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const EntrepreneurTermsScreen(), // Entrepreneur terms sahifasiga o'tamiz
        ),
      );
    }
  }

  // /**
  //  * WIDGETNI YARATISH FUNKSIYASI
  //  * 
  //  * UI ni qurish uchun asosiy funksiya.
  //  */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF92CAFE), // Asosiy fon rangi (moviy)
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Shaffof appbar
        elevation: 0, // Soyasiz
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // Orqaga tugmasi
          onPressed: () => Navigator.pop(context), // Orqaga qaytish funktsiyasi
        ),
      ),
      body: SingleChildScrollView( // Aylanadigan kontent
        padding: const EdgeInsets.only(top: 20), // Yuqori padding
        child: Column(
          children: [
            // Sarlavha matni
            const Text(
              'Sizga to\'lov qilishlari uchun',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10), // Bo'sh joy
            
            // Qo'shimcha yo'riqnoma matni
            const Text(
              'Karta ma\'lumotlarini kiriting',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20), // Bo'sh joy
            
            // Karta rasmi
            Image.asset(
              'assets/images/rasm6.png',
              width: 220,
              height: 220,
              fit: BoxFit.contain, // Rasmni moslashtirish
            ),
            const SizedBox(height: 30), // Bo'sh joy
            
            // KARTA RAQAMI MAYDONI
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40), // Yon tomonlardan joy
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Chapga tekislash
                children: [
                  const Text(
                    'Karta raqami',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 5), // Kichik bo'sh joy
                  SizedBox(
                    height: 50,
                    child: Stack( // Elementlarni ustma-ust joylash uchun
                      children: [
                        // Karta raqami input maydoni
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white, // Oq fon
                            borderRadius: BorderRadius.circular(20), // Yumaloq burchaklar
                          ),
                          child: TextField(
                            controller: _cardNumberController,
                            keyboardType: TextInputType.number, // Raqamli klaviatura
                            maxLength: 19, // 16 raqam + 3 probel
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.transparent, // Shaffof fon
                              border: InputBorder.none, // Chegara yo'q
                              hintText: '0000 0000 0000 0000', // Namuna matn
                              contentPadding: const EdgeInsets.only(
                                left: 115, // Karta logosi uchun joy
                                right: 15,
                                top: 15,
                                bottom: 12,
                              ),
                              counterText: '', // Hisoblagichni olib tashlash
                            ),
                          ),
                        ),
                        
                        // Karta logosi uchun fon
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            width: 85,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 176, 218, 178), // Yashil rang
                              borderRadius: BorderRadius.circular(15), // Yumaloq burchaklar
                            ),
                          ),
                        ),
                        
                        // Karta logosi (agar tanlangan bo'lsa)
                        if (_selectedCardType.isNotEmpty)
                          Positioned(
                            left: 12,
                            top: -5,
                            child: Image.asset(
                              'assets/images/${_selectedCardType}_logo.png',
                              width: 60,
                              height: 60,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20), // Bo'sh joy
            
            // MUDDAT VA CVV MAYDONLARI
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start, // Ustunlarni tepasiga tekislash
                    children: [
                      // AMAL QILISH MUDDATI MAYDONI
                      Expanded(
                        flex: 3, // Kenglikni oshirish uchun flex qiymati
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Amal qilish muddati',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 5), // Kichik bo'sh joy
                            Row(
                              children: [
                                // OY (MM) MAYDONI
                                Expanded(
                                  flex: 2, // Oy maydoni uchun kengroq joy
                                  child: SizedBox(
                                    height: 50,
                                    child: TextField(
                                      controller: _expiryMonthController,
                                      keyboardType: TextInputType.number,
                                      maxLength: 2, // 2 ta belgi
                                      decoration: _buildExpiryDecoration('MM', isMonth: true),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10), // Kichik bo'sh joy
                                
                                // YIL (YYYY) MAYDONI
                                Expanded(
                                  flex: 3, // Yil maydoni uchun kengroq joy
                                  child: SizedBox(
                                    height: 50,
                                    child: TextField(
                                      controller: _expiryYearController,
                                      keyboardType: TextInputType.number,
                                      maxLength: 4, // 4 ta belgi
                                      decoration: _buildExpiryDecoration('YYYY'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(width: 20), // Katta bo'sh joy
                      
                      // CVV MAYDONI
                      Expanded(
                        flex: 2, // Kenglikni kamaytirish
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'CVV',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 5), // Kichik bo'sh joy
                            SizedBox(
                              height: 50,
                              child: Stack(
                                alignment: Alignment.centerRight, // Elementlarni o'ngga tekislash
                                children: [
                                  // CVV input maydoni
                                  TextField(
                                    controller: _cvvController,
                                    keyboardType: TextInputType.number,
                                    maxLength: 3, // 3 ta belgi
                                    obscureText: !_isCvvVisible, // Yashirish holati
                                    decoration: _buildExpiryDecoration('***'),
                                  ),
                                  // Ko'z tugmasi
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: IconButton(
                                      padding: EdgeInsets.zero, // Paddingni olib tashlash
                                      iconSize: 20, // Icon o'lchamini kichiklashtirish
                                      icon: Icon(
                                        _isCvvVisible 
                                          ? Icons.visibility_off 
                                          : Icons.visibility,
                                        color: Colors.grey,
                                      ),
                                      onPressed: () {
                                        setState(() => _isCvvVisible = !_isCvvVisible); // Holatni o'zgartirish
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Xabar (agar muddat o'tib ketgan bo'lsa)
                  if (!_isExpiryValid)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        'Muddati o\'tib ketgan',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 45), // Katta bo'sh joy
            
            // TASDIQLASH TUGMASI
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ElevatedButton(
                onPressed: _onConfirmPressed, // Bosilganda funktsiya
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // Oq rang
                  foregroundColor: AppColors.txtColor, // Matn rangi 
                  minimumSize: const Size(double.infinity, 50), // Kenglik
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24), // Yumaloq burchaklar
                  ),
                ),
                child: const Text(
                  'Tasdiqlash',
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
    );
  }

  // /**
  //  * INPUT MAYDONLARI UCHUN UMUMIY BEZAK
  //  * 
  //  * @param hint - ko'rsatkich matni
  //  * @param isMonth - oy maydoni ekanligini bildiradi (agar true bo'lsa)
  //  * @return InputDecoration - yaratilgan bezak
  //  */
  InputDecoration _buildExpiryDecoration(String hint, {bool isMonth = false}) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white, // Oq fon
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20), // Yumaloq burchaklar
        borderSide: BorderSide.none, // Chegara yo'q
      ),
      hintText: hint, // Ko'rsatkich matni
      contentPadding: isMonth 
          ? const EdgeInsets.symmetric(horizontal: 15, vertical: 16) // Oy maydoni uchun kengroq padding
          : const EdgeInsets.symmetric(horizontal: 20, vertical: 16), // Vertikal paddingni oshirish
      counterText: '', // Hisoblagichni olib tashlash
      hintStyle: TextStyle(
        fontSize: isMonth ? 14 : null, // Oy maydoni uchun kattaroq shrift
      ),
    );
  }
}