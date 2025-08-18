// Flutterning Material Design kutubxonasi (UI elementlari uchun)
import 'package:flutter/material.dart';
// Google Maps Flutter kutubxonasi (xarita ishlatish uchun)
import 'package:google_maps_flutter/google_maps_flutter.dart';
// Qurilma joylashuvini olish uchun Geolocator kutubxonasi
import 'package:geolocator/geolocator.dart';

// Manzil tanlash uchun sahifa (A nuqtadan B nuqtaga borish)
class SelectDestinationPage extends StatefulWidget {
  // A nuqta koordinatalari (boshlang‘ich nuqta)
  final LatLng aPoint;

  // Konstruktor: SelectDestinationPage yaratishda A nuqta majburiy bo‘ladi
  const SelectDestinationPage({super.key, required this.aPoint});

  // State obyektini yaratish (bu yerda UI va logika ishlanadi)
  @override
  State<SelectDestinationPage> createState() => _SelectDestinationPageState();
}

// SelectDestinationPage sahifasining State (holat) klassi
class _SelectDestinationPageState extends State<SelectDestinationPage>
    // Animatsiya ishlatish uchun SingleTickerProviderStateMixin ulanyapti
    with SingleTickerProviderStateMixin {
  
  // Google Map boshqaruvchisi uchun o‘zgaruvchi
  late GoogleMapController _mapController;

  // Marker uchun animatsiya controlleri
  late AnimationController _animationController;

  // Markerning tebranish (ko‘tarilish/pasayish) animatsiyasi
  late Animation<double> _liftAnimation;

  // B nuqta (foydalanuvchi tanlagan manzil koordinatasi)
  LatLng? _bPoint;

  // Sahifa ishga tushganda chaqiriladigan metod
  @override
  void initState() {
    super.initState();
    
    // Animatsiya controllerini yaratish (600ms davom etadi)
    _animationController = AnimationController(
      vsync: this, // animatsiya uchun sinxronlash
      duration: const Duration(milliseconds: 600), // davomiylik
    )
    // Animatsiyani qayta-qayta ishlatish (orqaga qaytish bilan)
    ..repeat(reverse: true);

    // Markerning yuqoriga ko‘tarilishi (0 dan 10 pikselgacha)
    _liftAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      // Animatsiyani silliq qilish uchun CurvedAnimation
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  // Sahifa yopilganda chaqiriladigan metod
  @override
  void dispose() {
    // Animatsiya controllerini tozalash
    _animationController.dispose();
    super.dispose();
  }

  // Xarita yaratilganda ishlaydigan metod
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller; // xarita boshqaruvchisini olish
  }

  // Kamera to‘xtaganda markaziy nuqtani olish
  void _onCameraIdle() async {
    if (!mounted) return; // agar widget o‘chirilgan bo‘lsa chiqib ketadi
    
    // Ekranning markaziy koordinatasini olish
    final center = await _mapController.getLatLng(
      ScreenCoordinate(
        x: MediaQuery.of(context).size.width ~/ 2,   // gorizontal markaz
        y: MediaQuery.of(context).size.height ~/ 2,  // vertikal markaz
      ),
    );

    // B nuqtani markaz koordinatalariga tenglab qo‘yish
    setState(() {
      _bPoint = center;
    });
  }

  // Foydalanuvchini joriy joylashuviga olib borish funksiyasi
  void _goToCurrentLocation() async {
    if (!mounted) return; // widget mavjud bo‘lmasa chiqib ketadi
    
    try {
      // Joylashuv xizmati yoqilganini tekshirish
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        // Agar joylashuv o‘chirilgan bo‘lsa xabar chiqarish
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Joylashuv xizmati o'chirilgan")),
        );
        return; // funksiyani tugatish
      }

      // Qurilmaning joriy joylashuvini olish
      Position position = await Geolocator.getCurrentPosition();
      
      // Kamerani shu joyga siljitish
      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude), // yangi joy
            zoom: 15, // kattalashtirish darajasi
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      // Agar xatolik bo‘lsa, snackbar orqali ko‘rsatish
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Xatolik: ${e.toString()}")),
      );
    }
  }

  // UI (foydalanuvchi interfeysi)ni chizish
  @override
  Widget build(BuildContext context) {
    return Scaffold( // Asosiy sahifa konteyneri
      body: Stack( // Vidjetlarni ustma-ust joylashtirish
        children: [
          // Google Maps ko‘rsatish
          GoogleMap(
            onMapCreated: _onMapCreated, // yaratilganda
            initialCameraPosition: CameraPosition(
              target: widget.aPoint, // boshlang‘ich joylashuv A nuqta
              zoom: 15,              // kattalashtirish darajasi
            ),
            onCameraIdle: _onCameraIdle, // kamera to‘xtaganda
            myLocationEnabled: true,     // foydalanuvchi joylashuvi ko‘rinadi
            myLocationButtonEnabled: false, // standart tugma yashiriladi
            zoomControlsEnabled: false,     // zoom tugmalari ko‘rsatilmaydi
          ),

          // Markazda marker qo‘yish (tebranish animatsiyasi bilan)
          Align(
            alignment: Alignment.center, // markazga joylashtirish
            child: AnimatedBuilder(
              animation: _animationController, // animatsiyani kuzatish
              builder: (context, child) {
                return Padding(
                  padding: EdgeInsets.only(bottom: _liftAnimation.value + 35),
                  child: Stack(
                    children: [
                      // Marker ostidagi soya
                      Container(
                        width: 45,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(0, 0, 0, 0.25), // qora soya
                          borderRadius: BorderRadius.circular(20), // yumaloqlash
                        ),
                      ),
                      // Marker rasmi
                      Image.asset(
                        'assets/images/final.png', // marker rasmi
                        width: 50,
                        height: 50,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Chap yuqorida orqaga qaytish tugmasi
          Positioned(
            top: 30,
            left: 15,
            child: SizedBox(
              width: 50,
              height: 50,
              child: FloatingActionButton(
                onPressed: () => Navigator.pop(context), // orqaga qaytish
                backgroundColor: Colors.white,
                elevation: 0, // soya yo‘q
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // burchaklarni yumaloqlash
                ),
                child: const Icon(Icons.arrow_back, color: Colors.blue), // orqaga icon
              ),
            ),
          ),

          // O‘ng yuqorida "joriy joylashuv" tugmasi
          Positioned(
            top: 30,
            right: 15,
            child: SizedBox(
              width: 50,
              height: 50,
              child: FloatingActionButton(
                onPressed: _goToCurrentLocation, // bosilganda hozirgi joyga borish
                backgroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.my_location, color: Colors.blue), // joylashuv icon
              ),
            ),
          ),

          // Qidiruv maydoni (destination yozish uchun)
          Positioned(
            top: 30,
            left: 70,
            right: 70,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16), // ichki bo‘sh joy
              decoration: BoxDecoration(
                color: Colors.white, // oq fon
                borderRadius: BorderRadius.circular(30), // yumaloqlash
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(25), // qora soyali fon
                    blurRadius: 8, // xiralik darajasi
                    spreadRadius: 2, // yoyilish darajasi
                  ),
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: "Enter destination", // kirish uchun hint
                  border: InputBorder.none, // chegarasi yo‘q
                  prefixIcon: Icon(Icons.search, color: Colors.blue), // lupa icon
                ),
              ),
            ),
          ),

          // Pastki panel (A va B manzil + "Tayyor" tugmasi)
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min, // faqat kerakli balandlik
              children: [
                // A va B nuqtalarni ko‘rsatadigan container
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white, // oq fon
                    borderRadius: BorderRadius.circular(16), // yumaloqlash
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(25), // qora soya
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // chapga yozish
                    children: [
                      // A nuqta (boshlanish nuqtasi)
                      Text(
                        "📍 From: ${widget.aPoint.latitude.toStringAsFixed(5)}, "
                        "${widget.aPoint.longitude.toStringAsFixed(5)}",
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8), // bo‘sh joy
                      // B nuqta (foydalanuvchi tanlagan joy)
                      Text(
                        "📍 To: ${_bPoint != null ? 
                          "${_bPoint!.latitude.toStringAsFixed(5)}, "
                          "${_bPoint!.longitude.toStringAsFixed(5)}" 
                          : "Not selected"}",
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10), // bo‘sh joy
                // "Tayyor" tugmasi
                ElevatedButton.icon(
                  onPressed: _bPoint == null
                      ? null // agar B nuqta tanlanmagan bo‘lsa tugma ishlamaydi
                      : () => Navigator.pop(context, _bPoint), // B nuqtani qaytarish
                  icon: const Icon(Icons.check), // belgi icon
                  label: const Text("Tayyor"), // tugma yozuvi
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 120, vertical: 18), // tugma o‘lchami
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)), // yumaloq tugma
                    backgroundColor: Colors.blue.shade600, // fon rangi
                    foregroundColor: Colors.white, // matn rangi
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
