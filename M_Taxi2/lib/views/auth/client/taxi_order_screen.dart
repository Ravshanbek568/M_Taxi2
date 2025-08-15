// Dart asinxron operatsiyalari uchun kutubxona
import 'dart:async';
// Flutter UI kutubxonasi
import 'package:flutter/material.dart';
// Google Maps widgetlari uchun kutubxona
import 'package:google_maps_flutter/google_maps_flutter.dart';
// Geolokatsiya xizmatlari uchun kutubxona
import 'package:geolocator/geolocator.dart';
// Geokodlash (manzilni koordinatalarga aylantirish) uchun kutubxona
import 'package:geocoding/geocoding.dart';
// Yo'nalishni tanlash ekrani uchun import
import 'package:m_taksi/views/auth/client/select_destination_page.dart';

/// MARKER OSTIDAGI ANIMATSIYALI SOYA WIDGETI
class YandexGoShadowEffect extends StatefulWidget {
  final double shadowSize;          // Soyaning boshlang'ich o'lchami
  final Color shadowColor;          // Soyaning rangi
  final AnimationController animationController; // Animatsiya kontrolleri

  const YandexGoShadowEffect({
    super.key,
    required this.shadowSize,
    required this.shadowColor,
    required this.animationController,
  });

  @override
  State<YandexGoShadowEffect> createState() => _YandexGoShadowEffectState();
}

class _YandexGoShadowEffectState extends State<YandexGoShadowEffect> {
  late Animation<double> _shadowSizeAnimation;    // Soyaning o'lcham animatsiyasi
  late Animation<double> _shadowOpacityAnimation; // Soyaning tiniqlik animatsiyasi

  final double _maxShadowSize = 60.0;     // Soyaning maksimal o'lchami
  final double _minShadowOpacity = 0.1;   // Soyaning minimal tiniqligi

  @override
  void initState() {
    super.initState();

    // Kengayuvchi soya animatsiyasini sozlash
    _shadowSizeAnimation = Tween<double>(
      begin: widget.shadowSize,  // Boshlang'ich o'lcham
      end: _maxShadowSize,        // Yakuniy o'lcham
    ).animate(CurvedAnimation(
      parent: widget.animationController,
      curve: Curves.easeOut,      // Animatsiya egri chizig'i
    ));

    // Tiniqlik animatsiyasini sozlash
    _shadowOpacityAnimation = Tween<double>(
      begin: 0.3,               // Boshlang'ich tiniqlik
      end: _minShadowOpacity,    // Yakuniy tiniqlik
    ).animate(CurvedAnimation(
      parent: widget.animationController,
      curve: Curves.easeOut,      // Animatsiya egri chizig'i
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animationController,
      builder: (context, _) {
        return Container(
          width: _shadowSizeAnimation.value,      // Animatsiyadagi joriy kenglik
          height: _shadowSizeAnimation.value / 4, // Balandlik kenglikning 1/4 qismi
          decoration: BoxDecoration(
            shape: BoxShape.circle,              // Doira shakli
            color: widget.shadowColor.withAlpha(
              (_shadowOpacityAnimation.value * 255).toInt() // Tiniqlikni rangga aylantirish
            ),
            boxShadow: [
              BoxShadow(
                color: widget.shadowColor.withAlpha(
                  (_shadowOpacityAnimation.value * 255).round() // Soyaning rangi
                ),
                blurRadius: 3,    // Soyaning noaniqligi
                spreadRadius: 5,  // Soyaning tarqalishi
              ),
            ],
          ),
        );
      },
    );
  }
}

/// ASOSIY EKRAN: TaxiOrderScreen
class TaxiOrderScreen extends StatefulWidget {
  const TaxiOrderScreen({super.key});

  @override
  State<TaxiOrderScreen> createState() => _TaxiOrderScreenState();
}

class _TaxiOrderScreenState extends State<TaxiOrderScreen>
    with SingleTickerProviderStateMixin {
  final Completer<GoogleMapController> _controllerGoogleMaps = Completer();
  LatLng? _currentLocation;          // Joriy joylashuv koordinatalari
  String _currentAddress = "Manzil aniqlanmoqda..."; // Joriy manzil matni
  bool _isMapMoving = false;         // Xarita harakatlanayotganligi
  bool _isLoadingAddress = false;    // Manzil yuklanayotganligi
  late AnimationController _animationController; // Animatsiya kontrolleri
  late Animation<double> _liftAnimation;         // Marker ko'tarilish animatsiyasi
  String? _fullAddress;             // Buyurtma berish uchun to'liq manzil

  // Andijon shahrini boshlang'ich nuqta sifatida belgilash
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(40.8008333, 72.9881418), // Andijon koordinatalari
    zoom: 17.0,                             // Boshlang'ich zoom darajasi
  );

  @override
  void initState() {
    super.initState();

    // Animatsiya kontrollerini ishga tushirish
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300), // Animatsiya davomiyligi
    );

    // Marker ko'tarilish animatsiyasi
    _liftAnimation = Tween<double>(begin: 0, end: 15).animate(
      CurvedAnimation(
        parent: _animationController, 
        curve: Curves.easeOut // Animatsiya egri chizig'i
      ),
    );

    // Joylashuvni aniqlash funksiyasini chaqirish
    _determinePosition();
  }

  @override
  void dispose() {
    _animationController.dispose(); // Animatsiya kontrollerini tozalash
    super.dispose();
  }

  /// FOYDALANUVCHINING JOYLASHUVINI ANIQLASH VA MANZILNI TOPISH
  Future<void> _determinePosition() async {
    // Lokatsiya xizmatlari yoqilganligini tekshirish
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showLocationServiceDisabledAlert(); // Agar yoqilmagan bo'lsa ogohlantirish
      return;
    }

    // Lokatsiya ruxsatlarini tekshirish
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission(); // Ruxsat so'rash
      if (permission == LocationPermission.denied) {
        _showLocationPermissionDeniedAlert(); // Agar rad etilsa ogohlantirish
        return;
      }
    }

    // Agar ruxsat doimiy ravishda rad etilgan bo'lsa
    if (permission == LocationPermission.deniedForever) {
      _showLocationPermissionPermanentlyDeniedAlert();
      return;
    }

    try {
      // Joriy joylashuvni olish
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      // Joylashuvni saqlash va manzilni olish
      _currentLocation = LatLng(position.latitude, position.longitude);
      await _getAddressFromLatLng(_currentLocation!);

      // Xaritani joriy joylashuvga o'tkazish
      final controller = await _controllerGoogleMaps.future;
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _currentLocation!, zoom: 17),
        ),
      );
    } catch (e) {
      _showErrorSnackbar("Joylashuvni aniqlashda xatolik yuz berdi");
    }
  }

  /// LATLNG DAN TO'LIQ MANZILNI OLISH (YANGILANGAN VERSIYA)
  Future<void> _getAddressFromLatLng(LatLng position) async {
    setState(() {
      _isLoadingAddress = true; // Yuklanish holatini o'rnatish
    });

    try {
      // Koordinatalardan manzil ma'lumotlarini olish
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        
        // 1. To'liq manzilni tayyorlash (buyurtma berishda ishlatish uchun)
        _fullAddress = [
          place.street,       // Ko'cha nomi
          place.thoroughfare, // Asosiy yo'l
          place.subLocality,  // Mahalla
          place.locality      // Shahar
        ].where((part) => part != null && part.isNotEmpty).join(', ');
        
        // 2. Foydalanuvchiga ko'rsatish uchun manzilni tayyorlash
        String displayAddress;
        
        // Agar shahar nomi aniqlangan bo'lsa
        if (place.locality != null && place.locality!.isNotEmpty) {
          // Ko'cha/uy raqami kodlardan iborat bo'lsa (masalan, "RX2P+4FR")
          if ((place.street != null && place.street!.contains('+') && place.street!.length < 10) ||
              (place.thoroughfare != null && place.thoroughfare!.contains('+') && place.thoroughfare!.length < 10)) {
            displayAddress = "Ko'rdinatangiz (${place.locality})";
          } 
          // To'liq manzil mavjud bo'lsa
          else {
            displayAddress = _fullAddress!;
          }
        } 
        // Shahar nomi ham aniqlanmagan bo'lsa
        else {
          displayAddress = "Ko'rdinatangiz";
        }

        // UI ni yangilash
        setState(() {
          _currentAddress = displayAddress;
        });
      } else {
        setState(() {
          _currentAddress = "Manzil aniqlanmadi";
          _fullAddress = null;
        });
      }
    } catch (e) {
      setState(() {
        _currentAddress = "Manzilni olishda xatolik";
        _fullAddress = null;
      });
      _showErrorSnackbar("Manzilni olishda xatolik yuz berdi");
    } finally {
      setState(() {
        _isLoadingAddress = false; // Yuklanish holatini o'chirish
      });
    }
  }

  /// XARITA HARAKATI BOSHLANGANDA
  void _onCameraMove() {
    if (!_isMapMoving) {
      _isMapMoving = true;            // Harakat holatini o'rnatish
      _animationController.forward();  // Animatsiyani boshlash
    }
  }

  /// XARITA TO'XTAGANDA
  void _onCameraIdle() async {
    if (_isMapMoving) {
      _isMapMoving = false;            // Harakat holatini o'chirish
      _animationController.reverse();   // Animatsiyani teskari aylantirish
      
      // Xarita markazini aniqlash
      final controller = await _controllerGoogleMaps.future;
      final visibleRegion = await controller.getVisibleRegion();
      final centerLatLng = LatLng(
        (visibleRegion.northeast.latitude + visibleRegion.southwest.latitude) / 2,
        (visibleRegion.northeast.longitude + visibleRegion.southwest.longitude) / 2,
      );
      
      // Yangi markaz uchun manzilni olish
      await _getAddressFromLatLng(centerLatLng);
    }
  }

  /// JOYIMNI MARKAZGA OLIB KELISH
  Future<void> _goToCurrentLocation() async {
    if (_currentLocation == null) return;

    // Xaritani joriy joylashuvga o'tkazish
    final controller = await _controllerGoogleMaps.future;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _currentLocation!, zoom: 17),
      ),
    );
    
    // Manzilni yangilash
    await _getAddressFromLatLng(_currentLocation!);
  }

  /// BOTTOM PANELDAGI HAR BIR TUGMA UCHUN BIR XIL STIL
  Widget _buildButton(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Tugma ikonkasi
        CircleAvatar(
          radius: 28,
          backgroundColor: Colors.white,
          child: Icon(
            icon,
            color: Colors.blue,
            size: 28,
          ),
        ),
        const SizedBox(height: 6),
        // Tugma matni
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  /// XATO XABARNOMALARI
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Lokatsiya xizmati o'chirilganligi haqida ogohlantirish
  void _showLocationServiceDisabledAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Lokatsiya xizmati o'chirilgan"),
        content: const Text("Iltimos, joylashuv xizmatini yoqing"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  // Lokatsiya ruxsati rad etilganligi haqida ogohlantirish
  void _showLocationPermissionDeniedAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Ruxsat rad etildi"),
        content: const Text("Iltimos, ilova uchun joylashuv ruxsatini bering"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  // Lokatsiya ruxsati doimiy ravishda rad etilganligi haqida ogohlantirish
  void _showLocationPermissionPermanentlyDeniedAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Ruxsat doimiy ravishda rad etildi"),
        content: const Text("Sozlamalarga borib, ruxsatni qo'lda yoqing"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // GOOGLE XARITA KO'RINISHI
          GoogleMap(
            mapType: MapType.normal,              // Xarita turi
            initialCameraPosition: _initialCameraPosition, // Boshlang'ich pozitsiya
            myLocationEnabled: true,              // Joriy joylashuvni ko'rsatish
            myLocationButtonEnabled: false,       // Standart joylashuv tugmasini o'chirish
            zoomControlsEnabled: false,           // Zoom tugmalarini o'chirish
            onMapCreated: (controller) =>
                _controllerGoogleMaps.complete(controller), // Kontroller yaratilganda
            onCameraMove: (position) => _onCameraMove(),    // Xarita harakatlanganda
            onCameraIdle: () => _onCameraIdle(),            // Xarita to'xtaganda
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height / 2.5, // Pastki padding
            ),
          ),

          // MARKER VA SOYA ANIMATSIYASI
          Align(
            alignment: Alignment(0.0, -0.5),      // Markerni markazga joylash
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Padding(
                  padding: EdgeInsets.only(bottom: _liftAnimation.value + 65),
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      // Marker rasmi
                      Transform.translate(
                        offset: Offset(0, -_liftAnimation.value), // Ko'tarilish effekti
                        child: Image.asset(
                          'assets/images/men.png', // Marker rasmi
                          width: 80,
                          height: 80,
                        ),
                      ),
                      // Marker soyasi
                      Positioned(
                        bottom: 0,
                        child: YandexGoShadowEffect(
                          shadowSize: 40,
                          shadowColor: Colors.black,
                          animationController: _animationController,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // ORQAGA QAYTISH TUGMASI (Chap tomonda)
          Positioned(
            top: 25,
            left: 15,
            child: FloatingActionButton(
              onPressed: () => Navigator.pop(context), // Oldingi ekranga qaytish
              backgroundColor: Colors.white,
              child: const Icon(Icons.arrow_back, color: Colors.blue),
            ),
          ),

          // LOKATSIYA TUGMASI (O'ng tomonda)
          Positioned(
            top: 25,
            right: 15,
            child: FloatingActionButton(
              onPressed: _goToCurrentLocation, // Joriy joylashuvga o'tish
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location, color: Colors.blue),
            ),
          ),

          // PASTKI PANEL (Bottom Bar)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade600,           // Fon rangi
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),           // Ustki qirralarni yumaloq
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),     // Soyya effekti
                  ),
                ],
              ),
              padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  // Tugmalar qatori
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildButton(Icons.wifi, "Signal jo'natish"),
                      _buildButton(Icons.local_taxi, "Avtomatik taksi"),
                      _buildButton(Icons.groups, "Haydovchilar"),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // JORIY MANZIL KONTEYNERI
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 5),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.blue, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _isLoadingAddress
                              ? Row( // Yuklanish holatida ko'rsatiladigan widget
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      "Manzil aniqlanmoqda...",
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                )
                              : Text( // Yuklanish tugaganda ko'rsatiladigan manzil
                                  _currentAddress,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // YO'NALISHNI KIRITISH KONTEYNERI
                  GestureDetector(
                    onTap: () {
                      if (_currentLocation != null) {
                        // Yo'nalishni tanlash ekraniga o'tish
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SelectDestinationPage(
                              aPoint: _currentLocation!,
                            ),
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey, size: 24),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              "Yo'nalishni kiriting",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// class TaxiOrderScreen extends StatelessWidget {
//   const TaxiOrderScreen({super.key});


// Completer<GoogleMapController> _controllerGoogleMaps = Completer();

// GoogleMapController?  _newControllerGoogleMap;
  

//  static const CameraPosition _kGooglePlex = CameraPosition(
//     target: LatLng(37.42796133580664, -122.085749655962),
//     zoom: 14.4746,
//   );


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//       title: Text("m-taxi")
//     ),

//     body: Stack(children: [GoogleMap(

//     mapType: MapType.normal,
//     myLocationButtonEnabled: true,
//     initialCameraPosition: _kGooglePlex,
//     onMapCreated: (GoogleMapController controller)
//     {  
//     _controllerGoogleMaps.complete(controller);
//      _newControllerGoogleMap = controller;
//     },

//           )
//       ],),
//     );
//   }
// }