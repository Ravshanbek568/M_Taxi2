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
// Polylines uchun kutubxona
import 'package:google_maps_flutter/google_maps_flutter.dart' as maps;
// HTTP so'rovlari uchun kutubxona
import 'package:http/http.dart' as http;
import 'dart:convert';

/// MARKER OSTIDAGI ANIMATSIYALI SOYA WIDGETI
class YandexGoShadowEffect extends StatefulWidget {
  final double shadowSize; // Soyaning boshlang'ich o'lchami
  final Color shadowColor; // Soyaning rangi
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
  late Animation<double> _shadowSizeAnimation; // Soyaning o'lcham animatsiyasi
  late Animation<double>
  _shadowOpacityAnimation; // Soyaning tiniqlik animatsiyasi

  final double _maxShadowSize = 60.0; // Soyaning maksimal o'lchami
  final double _minShadowOpacity = 0.1; // Soyaning minimal tiniqligi

  @override
  void initState() {
    super.initState();

    // Kengayuvchi soya animatsiyasini sozlash
    _shadowSizeAnimation = Tween<double>(
      begin: widget.shadowSize, // Boshlang'ich o'lcham
      end: _maxShadowSize, // Yakuniy o'lcham
    ).animate(
      CurvedAnimation(
        parent: widget.animationController,
        curve: Curves.easeOut, // Animatsiya egri chizig'i
      ),
    );

    // Tiniqlik animatsiyasini sozlash
    _shadowOpacityAnimation = Tween<double>(
      begin: 0.3, // Boshlang'ich tiniqlik
      end: _minShadowOpacity, // Yakuniy tiniqlik
    ).animate(
      CurvedAnimation(
        parent: widget.animationController,
        curve: Curves.easeOut, // Animatsiya egri chizig'i
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animationController,
      builder: (context, _) {
        return Container(
          width: _shadowSizeAnimation.value, // Animatsiyadagi joriy kenglik
          height:
              _shadowSizeAnimation.value / 4, // Balandlik kenglikning 1/4 qismi
          decoration: BoxDecoration(
            shape: BoxShape.circle, // Doira shakli
            color: widget.shadowColor.withAlpha(
              (_shadowOpacityAnimation.value * 255)
                  .toInt(), // Tiniqlikni rangga aylantirish
            ),
            boxShadow: [
              BoxShadow(
                color: widget.shadowColor.withAlpha(
                  (_shadowOpacityAnimation.value * 255)
                      .round(), // Soyaning rangi
                ),
                blurRadius: 3, // Soyaning noaniqligi
                spreadRadius: 5, // Soyaning tarqalishi
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
  LatLng? _currentLocation; // Joriy joylashuv koordinatalari
  String _currentAddress = "Manzil aniqlanmoqda..."; // Joriy manzil matni
  bool _isMapMoving = false; // Xarita harakatlanayotganligi
  bool _isLoadingAddress = false; // Manzil yuklanayotganligi
  late AnimationController _animationController; // Animatsiya kontrolleri
  late Animation<double> _liftAnimation; // Marker ko'tarilish animatsiyasi
  String? _fullAddress; // Buyurtma berish uchun to'liq manzil

  // Tanlangan manzil ma'lumotlari
  LatLng? _selectedDestination; // Tanlangan manzil koordinatalari
  String? _selectedDestinationAddress; // Tanlangan manzil matni

  // YANGI: Saqlangan manzil ma'lumotlari
  LatLng? _savedPickupLocation; // Yo'nalishni tanlash bosilganda saqlanadigan nuqta
  String? _savedPickupAddress; // Saqlangan manzil matni

  // YANGI: Marshrut chizish uchun
  final Set<maps.Polyline> _polylines = {}; // Marshrut chiziqlari (FINAL qilindi)
  static const Color _routeColor = Colors.blue; // Marshrut rangi
  static const int _routeWidth = 5; // Marshrut kengligi

  // YANGI: Tugmalarning faollik holati
  bool _isSignalButtonActive = false;
  bool _isAutoTaxiButtonActive = false;
  bool _isDriversButtonActive = false;
  
  // YANGI: Qidiruv jarayoni
  bool _isSearching = false;
  Timer? _searchAnimationTimer;
  double _searchZoomLevel = 17.0;
  int _foundTaxisCount = 0;
  bool _showDriverFoundButton = false;

  // Andijon shahrini boshlang'ich nuqta sifatida belgilash
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(40.8008333, 72.9881418), // Andijon koordinatalari
    zoom: 17.0, // Boshlang'ich zoom darajasi
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
        curve: Curves.easeOut, // Animatsiya egri chizig'i
      ),
    );

    // Joylashuvni aniqlash funksiyasini chaqirish
    _determinePosition();
  }

  @override
  void dispose() {
    _animationController.dispose(); // Animatsiya kontrollerini tozalash
    _searchAnimationTimer?.cancel(); // Qidiruv animatsiyasini tozalash
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
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
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

  /// YANGI: SelectDestinationPage dan natijani qayta ishlash (YANGILANDI)
  void _handleDestinationSelection() async {
    if (_currentLocation != null) {
      // YANGI: faqat birinchi bosishda pickupni saqlab qo'yamiz
      if (_savedPickupLocation == null && _savedPickupAddress == null) {
        _savedPickupLocation = _currentLocation;
        _savedPickupAddress = _currentAddress;
      }

      // SelectDestinationPage ga o'tish va natijani kutish
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => SelectDestinationPage(aPoint: _currentLocation!),
        ),
      );

      // Agar result null bo'lmasa (ya'ni manzil tanlangan bo'lsa)
      if (result != null && mounted) {
        setState(() {
          _selectedDestination =
              result['point'] as LatLng; // Koordinatalarni saqlash
          _selectedDestinationAddress =
              result['address'] as String; // Manzil matnini saqlash
        });

        // Tanlangan manzilga xaritani markazlashtirish
        _goToSelectedDestination();
        
        // YANGI: Marshrut chizish
        _drawRoute();
        
        // YANGI: Tugmalarni faollashtirish
        _updateButtonsState();
      }
    }
  }

  /// YANGI: Tugmalarning holatini yangilash
  void _updateButtonsState() {
    setState(() {
      // Ikkala manzil ham kiritilgan bo'lsa tugmalarni faollashtirish
      bool hasBothLocations = _savedPickupLocation != null && _selectedDestination != null;
      _isSignalButtonActive = hasBothLocations;
      _isAutoTaxiButtonActive = hasBothLocations;
      _isDriversButtonActive = hasBothLocations;
    });
  }

  /// YANGI: Marshrut chizish funksiyasi
  Future<void> _drawRoute() async {
    if (_savedPickupLocation == null || _selectedDestination == null) return;
    
    try {
      // Google Directions API dan marshrut ma'lumotlarini olish
      final String url = 
          'https://maps.googleapis.com/maps/api/directions/json?'
          'origin=${_savedPickupLocation!.latitude},${_savedPickupLocation!.longitude}'
          '&destination=${_selectedDestination!.latitude},${_selectedDestination!.longitude}'
          '&key=AIzaSyCqIB5c5qFVJaz1dKdp2aO1hOuIY-9800E';  // API kalitingizni qo'ying
      
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);
      
      if (data['status'] == 'OK') {
        // Marshrut koordinatalarini olish
        List<LatLng> points = _decodePolyline(data['routes'][0]['overview_polyline']['points']);
        
        setState(() {
          _polylines.clear();
          _polylines.add(maps.Polyline(
            polylineId: maps.PolylineId('route'),
            points: points,
            color: _routeColor,
            width: _routeWidth,
          ));
        });
      } else {
        _showErrorSnackbar("Marshrut topilmadi");
      }
    } catch (e) {
      _showErrorSnackbar("Marshrut chizishda xatolik");
    }
  }
  
  /// YANGI: Polylineni dekodlash funksiyasi
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;
    
    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;
      
      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;
      
      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    
    return points;
  }

  /// Tanlangan manzilga xaritani markazlashtirish
  Future<void> _goToSelectedDestination() async {
    if (_selectedDestination != null) {
      final controller = await _controllerGoogleMaps.future;
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _selectedDestination!, zoom: 15),
        ),
      );
    }
  }

  /// YANGI: Tanlangan manzilni tozalash funksiyasi (YANGILANDI)
  void _clearSelectedDestination() {
    setState(() {
      _selectedDestination = null;
      _selectedDestinationAddress = null;
      
      // YANGI: Marshrutni tozalash
      _polylines.clear();

      // YANGI: pickupni ham tozalaymiz
      _savedPickupLocation = null;
      _savedPickupAddress = null;
      
      // YANGI: Tugmalarni faolsiz holatga keltirish
      _isSignalButtonActive = false;
      _isAutoTaxiButtonActive = false;
      _isDriversButtonActive = false;
      
      // YANGI: Qidiruvni to'xtatish
      _cancelSearch();
    });
  }

  /// LATLNG DAN TO'LIQ MANZILNI OLISH
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
          place.street, // Ko'cha nomi
          place.thoroughfare, // Asosiy yo'l
          place.subLocality, // Mahalla
          place.locality, // Shahar
        ].where((part) => part != null && part.isNotEmpty).join(', ');

        // 2. Foydalanuvchiga ko'rsatish uchun manzilni tayyorlash
        String displayAddress;

        // Agar shahar nomi aniqlangan bo'lsa
        if (place.locality != null && place.locality!.isNotEmpty) {
          // Ko'cha/uy raqami kodlardan iborat bo'lsa (masalan, "RX2P+4FR")
          if ((place.street != null &&
                  place.street!.contains('+') &&
                  place.street!.length < 10) ||
              (place.thoroughfare != null &&
                  place.thoroughfare!.contains('+') &&
                  place.thoroughfare!.length < 10)) {
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
      _isMapMoving = true; // Harakat holatini o'rnatish
      _animationController.forward(); // Animatsiyani boshlash
    }
  }

  /// XARITA TO'XTAGANDA
  void _onCameraIdle() async {
    if (_isMapMoving) {
      _isMapMoving = false; // Harakat holatini o'chirish
      _animationController.reverse(); // Animatsiyani teskari aylantirish

      // Xarita markazini aniqlash
      final controller = await _controllerGoogleMaps.future;
      final visibleRegion = await controller.getVisibleRegion();
      final centerLatLng = LatLng(
        (visibleRegion.northeast.latitude + visibleRegion.southwest.latitude) /
            2,
        (visibleRegion.northeast.longitude +
                visibleRegion.southwest.longitude) /
            2,
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

  /// YANGI: Xaritani zoom qilish (SEKINROQ, LEKIN RADIUSDA)
  Future<void> _animateCameraZoom(double zoomLevel) async {
    final controller = await _controllerGoogleMaps.future;
    
    // Faqat 12.0 dan pastga zoom qilmaymiz (radiusdan tashqariga chiqmaslik uchun)
    final targetZoom = zoomLevel.clamp(12.0, 17.0);
    
    controller.animateCamera(
      CameraUpdate.zoomTo(targetZoom),
    );
  }

  /// YANGI: Signal jo'natish funksiyasi
  void _sendSignal() {
    if (!_isSignalButtonActive) return;
    
    // Signal jo'natish parametrlarini so'rash dialogi
    _showSignalOptionsDialog();
  }

  /// YANGI: Signal parametrlarini so'rash dialogi
  void _showSignalOptionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        int passengerCount = 1;
        String carType = "Standart";
        bool hasLuggage = false;
        bool isDriverEmpty = true;
        
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Signal parametrlari"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Yo'lovchilar soni
                    ListTile(
                      title: Text("Yo'lovchilar soni"),
                      trailing: DropdownButton<int>(
                        value: passengerCount,
                        onChanged: (value) {
                          setState(() {
                            passengerCount = value!;
                          });
                        },
                        items: [1, 2, 3, 4, 5, 6].map((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text("$value"),
                          );
                        }).toList(),
                      ),
                    ),
                    
                    // Mashina turi
                    ListTile(
                      title: Text("Mashina turi"),
                      trailing: DropdownButton<String>(
                        value: carType,
                        onChanged: (value) {
                          setState(() {
                            carType = value!;
                          });
                        },
                        items: ["Standart", "Komfort", "Biznes", "Miniyan"].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                    
                    // Yuk borligi
                    SwitchListTile(
                      title: Text("Yuk bor"),
                      value: hasLuggage,
                      onChanged: (value) {
                        setState(() {
                          hasLuggage = value;
                        });
                      },
                    ),
                    
                    // Haydovchi bo'sh
                    SwitchListTile(
                      title: Text("Haydovchi bo'sh"),
                      value: isDriverEmpty,
                      onChanged: (value) {
                        setState(() {
                          isDriverEmpty = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Bekor qilish"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _startSearchAnimation(passengerCount, carType, hasLuggage, isDriverEmpty);
                  },
                  child: Text("Qidirushni boshlash"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// YANGI: Qidiruv animatsiyasini boshlash (YANGILANDI)
  void _startSearchAnimation(int passengerCount, String carType, bool hasLuggage, bool isDriverEmpty) {
    setState(() {
      _isSearching = true;
      _foundTaxisCount = 0;
      _showDriverFoundButton = false;
    });
    
    // Animatsiya timerini boshlash (SEKINROQ)
    _searchAnimationTimer = Timer.periodic(Duration(milliseconds: 800), (timer) {
      if (_searchZoomLevel > 12.0) { // 12.0 dan pastga tushmaymiz
        setState(() {
          _searchZoomLevel -= 0.3; // Sekinroq zoom
          _foundTaxisCount += 1; // Sekinroq taksi qo'shilishi
        });
        
        // Xaritani zoom out qilish
        _animateCameraZoom(_searchZoomLevel);
      } else {
        // Qidiruv tugaganda
        timer.cancel();
        setState(() {
          _isSearching = false;
          _showDriverFoundButton = true;
        });
      }
    });
  }

  /// YANGI: Qidiruvni bekor qilish
  void _cancelSearch() {
    _searchAnimationTimer?.cancel();
    setState(() {
      _isSearching = false;
      _searchZoomLevel = 17.0;
      _foundTaxisCount = 0;
      _showDriverFoundButton = false;
    });
    
    // Xaritani asl holatiga qaytarish
    _goToCurrentLocation();
  }

  /// YANGI: Eng yaqin haydovchiga xabar jo'natish
  void _sendMessageToNearestDriver() {
    // Bu yerda serverga so'rov jo'natiladi
    // Hozircha faqat demo xabar ko'rsatamiz
    _showErrorSnackbar("Eng yaqin haydovchiga xabar jo'natildi");
    
    // Keyin bosh sahifaga qaytish
    setState(() {
      _showDriverFoundButton = false;
    });
  }

  /// YANGI: Tugmalarni qurish (YANGILANDI - dastlabki ranglar bilan)
  Widget _buildButton(IconData icon, String label, bool isActive, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tugma ikonkasi (dastlabki holat: oq fon, ko'k icon)
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isActive ? Colors.blue : Colors.white, // Faol bo'lsa ko'k, bo'lmasa oq
              shape: BoxShape.circle,
              boxShadow: [
                if (isActive) // Faol bo'lsa ko'k soya
                  BoxShadow(
                    color: Colors.blue.withAlpha(150),
                    blurRadius: 8,
                    spreadRadius: 2,
                    offset: Offset(0, 2),
                  )
                else // Faol bo'lmasa engil soya
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
              ],
            ),
            child: Icon(
              icon, 
              color: isActive ? Colors.white : Colors.blue, // Faol bo'lsa oq icon, bo'lmasa ko'k
              size: 28,
            ),
          ),
          const SizedBox(height: 6),
          // Tugma matni
          Text(
            label, 
            style: TextStyle(
              color: isActive ? Colors.blue : Colors.white, // Faol bo'lsa ko'k, bo'lmasa oq
              fontSize: 14,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  /// XATO XABARNOMALARI
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // Lokatsiya xizmati o'chirilganligi haqida ogohlantirish
  void _showLocationServiceDisabledAlert() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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
      builder:
          (context) => AlertDialog(
            title: const Text("Ruxsat rad etildi"),
            content: const Text(
              "Iltimos, ilova uchun joylashuv ruxsatini bering",
            ),
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
      builder:
          (context) => AlertDialog(
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
            mapType: MapType.normal, // Xarita turi
            initialCameraPosition:
                _initialCameraPosition, // Boshlang'ich pozitsiya
            myLocationEnabled: true, // Joriy joylashuvni ko'rsatish
            myLocationButtonEnabled:
                false, // Standart joylashuv tugmasini o'chirish
            zoomControlsEnabled: false, // Zoom tugmalarini o'chirish
            onMapCreated:
                (controller) => _controllerGoogleMaps.complete(
                  controller,
                ), // Kontroller yaratilganda
            onCameraMove:
                (position) => _onCameraMove(), // Xarita harakatlanganda
            onCameraIdle: () => _onCameraIdle(), // Xarita to'xtaganda
            polylines: _polylines, // YANGI: Marshrut chiziqlarini qo'shish
            padding: EdgeInsets.only(
              bottom:
                  MediaQuery.of(context).size.height / 2.5, // Pastki padding
            ),
          ),

          // MARKER VA SOYA ANIMATSIYASI
          Align(
            alignment: Alignment(0.0, -0.5), // Markerni markazga joylash
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
                        offset: Offset(
                          0,
                          -_liftAnimation.value,
                        ), // Ko'tarilish effekti
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
              onPressed:
                  () => Navigator.pop(context), // Oldingi ekranga qaytish
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

          // YANGI: Qidiruv jarayonida bekor qilish tugmasi
          if (_isSearching)
            Positioned(
              top: 90,
              right: 15,
              child: FloatingActionButton(
                onPressed: _cancelSearch,
                backgroundColor: Colors.white,
                child: const Icon(Icons.close, color: Colors.red),
              ),
            ),

          // YANGI: Qidiruv natijasi - topilgan taksilar soni
          if (_isSearching)
            Positioned(
              top: 25,
              left: MediaQuery.of(context).size.width / 2 - 100,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                child: Text(
                  "Topildi: $_foundTaxisCount ta taksi",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          // PASTKI PANEL (Bottom Bar) - YANGILANDI
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade600,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  
                  // YANGI: Signal jo'natish tugmasi (faqat ikkala manzil kiritilganda)
                  if (_isSignalButtonActive && _showDriverFoundButton)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 15),
                      child: ElevatedButton(
                        onPressed: _sendMessageToNearestDriver,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Text(
                          "Eng yaqin haydovchiga xabar jo'natish",
                          style: TextStyle(
                            color: Colors.white, 
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  
                  // Tugmalar qatori
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildButton(Icons.wifi, "Signal jo'natish", _isSignalButtonActive, _sendSignal),
                      _buildButton(Icons.local_taxi, "Avtomatik taksi", _isAutoTaxiButtonActive, () {}),
                      _buildButton(Icons.groups, "Haydovchilar", _isDriversButtonActive, () {}),
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
                              ? Row(
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
                              : Text(
                                  _savedPickupAddress ?? _currentAddress,
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
                    onTap: _selectedDestinationAddress == null
                        ? _handleDestinationSelection
                        : null,
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                          Icon(
                            _selectedDestinationAddress != null ? Icons.location_on : Icons.search,
                            color: _selectedDestinationAddress != null ? Colors.blue : Colors.grey,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Text(
                                _selectedDestinationAddress ?? "Yo'nalishni kiriting",
                                style: TextStyle(
                                  color: _selectedDestinationAddress != null ? Colors.black : Colors.grey,
                                  fontSize: 16,
                                  fontWeight: _selectedDestinationAddress != null
                                      ? FontWeight.w500
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                          if (_selectedDestinationAddress != null)
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.grey),
                              onPressed: _clearSelectedDestination,
                            )
                          else
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