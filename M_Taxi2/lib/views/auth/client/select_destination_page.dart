// Flutterning Material Design kutubxonasi (UI elementlari uchun)
import 'package:flutter/material.dart';

// Google Maps Flutter kutubxonasi (xarita ishlatish uchun)
import 'package:google_maps_flutter/google_maps_flutter.dart';
// Qurilma joylashuvini olish uchun Geolocator kutubxonasi
import 'package:geolocator/geolocator.dart';
// Geokodlash (manzilni koordinatalarga aylantirish) uchun kutubxona
import 'package:geocoding/geocoding.dart';
// HTTP so'rovlar uchun kutubxona
import 'package:http/http.dart' as http;
// JSON dekodlash uchun
import 'dart:convert';

/// SAQLANGAN MANZIL KLASSI
class SaqlanganManzil {
  final String nom;
  final LatLng koordinatalar;
  final String manzil;

  SaqlanganManzil({
    required this.nom,
    required this.koordinatalar,
    required this.manzil,
  });
}

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

// Manzil tanlash uchun sahifa (A nuqtadan B nuqtaga borish)
class SelectDestinationPage extends StatefulWidget {
  // A nuqta koordinatalari (boshlang'ich nuqta)
  final LatLng aPoint;

  // Konstruktor: SelectDestinationPage yaratishda A nuqta majburiy bo'ladi
  const SelectDestinationPage({super.key, required this.aPoint});

  // State obyektini yaratish (bu yerda UI va logika ishlanadi)
  @override
  State<SelectDestinationPage> createState() => _SelectDestinationPageState();
}

// SelectDestinationPage sahifasining State (holat) klassi
class _SelectDestinationPageState extends State<SelectDestinationPage>
        // Animatsiya ishlatish uchun SingleTickerProviderStateMixin ulanyapti
        with
        SingleTickerProviderStateMixin {
  // Google Map boshqaruvchisi uchun o'zgaruvchi
  late GoogleMapController _mapController;

  // Marker uchun animatsiya controlleri
  late AnimationController _animationController;

  // Markerning tebranish (ko'tarilish/pasayish) animatsiyasi
  late Animation<double> _liftAnimation;

  // B nuqta (foydalanuvchi tanlagan manzil koordinatasi)
  LatLng? _bPoint;

  // Xarita harakatlanayotganligini bildiradi
  bool _isMapMoving = false;

  // Ko'rinadigan manzil matni
  String _currentAddress = "Manzil tanlanmagan";

  // To'liq manzil (yashirin, faqat buyurtma berish uchun)
  String _fullAddress = "";

  // Qidiruv maydoni uchun controller
  final TextEditingController _searchController = TextEditingController();

  // Qidiruv maydoni fokus uchun
  final FocusNode _searchFocusNode = FocusNode();

  // Takliflar ro'yxati
  List<String> _suggestions = [];

  // Klaviatura chiqqanda takliflar ro'yxatini ko'rsatish
  bool _showSuggestions = false;

  // SAQLANGAN MANZILLAR RO'YXATI - final qilindi
  final List<SaqlanganManzil> _saqlanganManzillar = [];

  // Sahifa ishga tushganda chaqiriladigan metod
  @override
  void initState() {
    super.initState();

    // Animatsiya controllerini yaratish (300ms davom etadi)
    _animationController = AnimationController(
      vsync: this, // animatsiya uchun sinxronlash
      duration: const Duration(milliseconds: 300), // davomiylik
    );

    // Markerning yuqoriga ko'tarilishi (0 dan 15 pikselgacha)
    _liftAnimation = Tween<double>(begin: 0.0, end: 15.0).animate(
      // Animatsiyani silliq qilish uchun CurvedAnimation
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Qidiruv maydoni fokusini kuzatish
    _searchFocusNode.addListener(() {
      setState(() {
        _showSuggestions =
            _searchFocusNode.hasFocus && _searchController.text.isNotEmpty;
      });
    });
  }

  // Sahifa yopilganda chaqiriladigan metod
  @override
  void dispose() {
    // Animatsiya controllerini tozalash
    _animationController.dispose();
    // Controllerlarni tozalash
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // Xarita yaratilganda ishlaydigan metod
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller; // xarita boshqaruvchisini olish
  }

  // Xarita harakatlanishini boshlaganda
  void _onCameraMoveStarted() {
    if (!_isMapMoving) {
      _isMapMoving = true;
      _animationController.forward(); // Animatsiyani boshlash
    }
  }

  // MANZILNI FORMATLASH FUNKSIYASI
  String _formatAddress(Placemark place) {
    // 1. Agar ko'cha kodi formatida bo'lsa (masalan, "RX3Q+C84")
    if ((place.street != null &&
            place.street!.contains('+') &&
            place.street!.length < 10) ||
        (place.thoroughfare != null &&
            place.thoroughfare!.contains('+') &&
            place.thoroughfare!.length < 10)) {
      // Shahar nomi aniqlangan bo'lsa
      if (place.locality != null && place.locality!.isNotEmpty) {
        return " Koordinatangiz (${place.locality})";
      } else {
        return " Koordinatangiz";
      }
    }

    // 2. Oddiy manzil - faqat kerakli qismlarni olish
    List<String> parts = [];

    if (place.street != null && place.street!.isNotEmpty) {
      parts.add(place.street!);
    }
    if (place.thoroughfare != null && place.thoroughfare!.isNotEmpty) {
      parts.add(place.thoroughfare!);
    }
    if (place.locality != null && place.locality!.isNotEmpty) {
      parts.add(place.locality!);
    }

    String result = parts.join(', ');

    // 3. Agar manzil juda uzun bo'lsa qisqartirish
    if (result.length > 35) {
      result = '${result.substring(0, 35)}...';
    }

    return result.isNotEmpty ? result : "Manzil aniqlanmadi";
  }

  // KOORDINATADAN MANZIL OLISH FUNKSIYASI
  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        // 1. To'liq manzilni tayyorlash (buyurtma berishda ishlatish uchun)
        _fullAddress = [
          place.street,
          place.thoroughfare,
          place.subLocality,
          place.locality,
        ].where((part) => part != null && part.isNotEmpty).join(', ');

        // 2. Formatlangan manzilni olish
        String displayAddress = _formatAddress(place);

        // UI ni yangilash
        setState(() {
          _currentAddress = displayAddress;
        });
      } else {
        setState(() {
          _currentAddress = "Manzil aniqlanmadi";
          _fullAddress = "";
        });
      }
    } catch (e) {
      setState(() {
        _currentAddress = "Manzilni olishda xatolik";
        _fullAddress = "";
      });
    }
  }

  // MANZIL QIDIRISH FUNKSIYASI (OpenStreetMap Nominatim API bilan)
  void _searchAddress(String query) async {
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/search?'
          'format=json&q=$query&countrycodes=uz&limit=5&accept-language=uz',
        ),
        headers: {'User-Agent': 'MTaxiApp'}, // User-Agent majburiy
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _suggestions =
              data
                  .map<String>((item) => item['display_name'] as String)
                  .toList();
          _showSuggestions = _searchFocusNode.hasFocus;
        });
      }
    } catch (e) {
      // Agar API ishlamasa, test ma'lumotlari ishlatish
      setState(() {
        _suggestions = [
          "$query ko'chasi, Toshkent",
          "$query mahallasi, Toshkent",
          "$query tumani, Toshkent",
        ];
        _showSuggestions = _searchFocusNode.hasFocus;
      });
    }
  }

  // TAKLIFNI TANLASH FUNKSIYASI
  void _onSuggestionSelected(String suggestion) async {
    if (!mounted) return;

    setState(() {
      _searchController.text = suggestion;
      _suggestions.clear();
      _showSuggestions = false;
      _currentAddress = "Manzil aniqlanmoqda...";
    });

    try {
      // Tanlangan manzilni koordinatalarga aylantirish
      List<Location> locations = await locationFromAddress(suggestion);

      if (!mounted) return;

      if (locations.isNotEmpty) {
        final location = locations.first;
        final newPosition = LatLng(location.latitude, location.longitude);

        // Kamerani yangi joyga o'tkazish
        _mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: newPosition, zoom: 15),
          ),
        );

        // Manzilni qayta ishlash va ko'rsatish
        List<Placemark> placemarks = await placemarkFromCoordinates(
          newPosition.latitude,
          newPosition.longitude,
        );

        if (!mounted) return;

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];

          // To'liq manzilni saqlash (buyurtma uchun)
          _fullAddress = suggestion;

          // Formatlangan manzilni olish
          String displayAddress = _formatAddress(place);

          // B nuqtani yangilash
          setState(() {
            _bPoint = newPosition;
            _currentAddress = displayAddress;
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _currentAddress = "Manzilni aniqlab bo'lmadi";
      });
    }

    if (mounted) {
      _searchFocusNode.unfocus(); // Klaviaturni yopish
    }
  }

  // KAMERA TO'XTAGANDA MARKAZIY NUQTANI OLISH
  void _onCameraIdle() async {
    if (_isMapMoving) {
      _isMapMoving = false;
      _animationController.reverse(); // Animatsiyani teskari aylantirish

      if (!mounted) return;

      // Ekranning markaziy koordinatasini olish
      final center = await _mapController.getLatLng(
        ScreenCoordinate(
          x: MediaQuery.of(context).size.width ~/ 2,
          y: MediaQuery.of(context).size.height ~/ 2,
        ),
      );

      // Manzilni olish
      await _getAddressFromLatLng(center);

      // B nuqtani markaz koordinatalariga tenglab qo'yish
      setState(() {
        _bPoint = center;
      });
    }
  }

  // FOYDALANUVCHINI JORIY JOYLASHUVIGA OLIB BORISH FUNKSIYASI
  void _goToCurrentLocation() async {
    if (!mounted) return;

    try {
      // Joylashuv xizmati yoqilganini tekshirish
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        _showSnackbar("Joylashuv xizmati o'chirilgan");
        return;
      }

      // Qurilmaning joriy joylashuvini olish
      Position position = await Geolocator.getCurrentPosition();

      if (!mounted) return;

      // Kamerani shu joyga siljitish
      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 15,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showSnackbar("Xatolik: ${e.toString()}");
    }
  }

  // SNACKBAR KO'RSATISH UCHUN ALOHIDA FUNKSIYA
  void _showSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  // SAQLANGAN MANZILLARNI KO'RSATISH UCHUN DIALOG
  void _showSavedLocationsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Tanlangan manzillar"),
          content: SizedBox(
            // ✅ Container o'rniga SizedBox
            width: double.maxFinite,
            height: 300,
            child:
                _saqlanganManzillar.isEmpty
                    ? Center(child: Text("Hech qanday saqlangan manzil yo'q"))
                    : ListView.builder(
                      itemCount: _saqlanganManzillar.length,
                      itemBuilder: (context, index) {
                        final location = _saqlanganManzillar[index];
                        return ListTile(
                          leading: Icon(Icons.location_on),
                          title: Text(location.nom),
                          subtitle: Text(location.manzil),
                          onTap: () {
                            // Tanlangan manzilga o'tish
                            _mapController.animateCamera(
                              CameraUpdate.newCameraPosition(
                                CameraPosition(
                                  target: location.koordinatalar,
                                  zoom: 15,
                                ),
                              ),
                            );
                            Navigator.pop(context);
                          },
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                _saqlanganManzillar.removeAt(index);
                              });
                            },
                          ),
                        );
                      },
                    ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Yopish"),
            ),
          ],
        );
      },
    );
  }

  // MANZILNI SAQLASH FUNKSIYASI
  void _saveCurrentLocation() {
    if (_bPoint == null) {
      _showSnackbar("Avval manzil tanlang");
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController nameController = TextEditingController();
        return AlertDialog(
          title: Text("Manzilni saqlash"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Manzil nomi",
                  hintText: "Masalan: Uy, Ofis, Do'kon",
                ),
              ),
              SizedBox(height: 10), // Container o'rniga SizedBox ishlatildi
              Text(
                _currentAddress,
                style: TextStyle(color: Colors.grey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Bekor qilish"),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isEmpty) {
                  _showSnackbar("Manzil nomini kiriting");
                  return;
                }

                setState(() {
                  _saqlanganManzillar.add(
                    SaqlanganManzil(
                      nom: nameController.text,
                      koordinatalar: _bPoint!,
                      manzil:
                          _fullAddress.isNotEmpty
                              ? _fullAddress
                              : _currentAddress,
                    ),
                  );
                });

                Navigator.pop(context);
                _showSnackbar("Manzil saqlandi");
              },
              child: Text("Saqlash"),
            ),
          ],
        );
      },
    );
  }

  // UI (FOYDALANUVCHI INTERFEYSI)NI CHIZISH
  @override
  Widget build(BuildContext context) {
    // Klaviatura balandligini aniqlash
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = bottomPadding > 0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // GOOGLE MAPS KO'RINISHI
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: widget.aPoint,
              zoom: 15,
            ),
            onCameraIdle: _onCameraIdle,
            onCameraMoveStarted: _onCameraMoveStarted,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),

          // MARKER VA SOYA ANIMATSIYASI
          Align(
            alignment: Alignment(0.0, -0.0),
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
                        offset: Offset(0, -_liftAnimation.value),
                        child: Image.asset(
                          'assets/images/final.png',
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

          // CHAP YUQORIDA ORQAGA QAYTISH TUGMASI
          Positioned(
            top: 30,
            left: 15,
            child: SizedBox(
              width: 50,
              height: 50,
              child: FloatingActionButton(
                onPressed: () => Navigator.pop(context),
                backgroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back, color: Colors.blue),
              ),
            ),
          ),

          // O'NG YUQORIDA "JORIY JOYLASHUV" TUGMASI
          Positioned(
            top: 30,
            right: 15,
            child: SizedBox(
              width: 50,
              height: 50,
              child: FloatingActionButton(
                onPressed: _goToCurrentLocation,
                backgroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.my_location, color: Colors.blue),
              ),
            ),
          ),

          // QIDIRUV MAYDONI (DESTINATION YOZISH UCHUN)
          Positioned(
            top: 30,
            left: 70,
            right: 70,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(25),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: const InputDecoration(
                  hintText: "Manzilni kiriting",
                  border: InputBorder.none,
                ),
                onChanged: _searchAddress,
              ),
            ),
          ),

          // TAKLIFLAR RO'YXATI (FAQAT KERAK BO'LGANDA KO'RINADI)
          if (_showSuggestions && _suggestions.isNotEmpty)
            Positioned(
              top: 80,
              left: 70,
              right: 70,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(100),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_suggestions[index]),
                      onTap: () => _onSuggestionSelected(_suggestions[index]),
                    );
                  },
                ),
              ),
            ),

          // ZOOM TUGMALARI (O'NG TOMONDA)
          Positioned(
            right: 15,
            bottom: 220, // Yuqoridagi tugmalardan pastroqda
            child: Column(
              children: [
                // ZOOM IN (YAQINLASHTIRISH) TUGMASI
                SizedBox(
                  width: 45,
                  height: 45,
                  child: FloatingActionButton(
                    onPressed: () {
                      _mapController.getZoomLevel().then((currentZoom) {
                        _mapController.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(
                              target: _bPoint ?? widget.aPoint,
                              zoom:
                                  currentZoom +
                                  1, // Zoom levelni 1 ga oshiramiz
                            ),
                          ),
                        );
                      });
                    },
                    backgroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.add, color: Colors.blue, size: 24),
                  ),
                ),
                SizedBox(height: 10), // Tugmalar orasidagi bo'shliq
                // ZOOM OUT (UZOQLASHTIRISH) TUGMASI
                SizedBox(
                  width: 45,
                  height: 45,
                  child: FloatingActionButton(
                    onPressed: () {
                      _mapController.getZoomLevel().then((currentZoom) {
                        _mapController.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(
                              target: _bPoint ?? widget.aPoint,
                              zoom:
                                  currentZoom -
                                  1, // Zoom levelni 1 ga kamaytiramiz
                            ),
                          ),
                        );
                      });
                    },
                    backgroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.remove,
                      color: Colors.blue,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // SAQLANGAN MANZILLAR TUGMASI (PASTKI O'NGDA)
          Positioned(
            bottom: 160,
            right: 15,
            child: SizedBox(
              width: 50,
              height: 50,
              child: FloatingActionButton(
                onPressed: _showSavedLocationsDialog,
                backgroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.bookmark, color: Colors.blue),
              ),
            ),
          ),

          // MANZILNI SAQLASH TUGMASI (PASTKI CHAPDA)
          // if (_bPoint != null)
          //   Positioned(
          //     bottom: 160,
          //     left: 15,
          //     child: SizedBox(
          //       width: 50,
          //       height: 50,
          //       child: FloatingActionButton(
          //         onPressed: _saveCurrentLocation,
          //         backgroundColor: Colors.white,
          //         elevation: 2,
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(12),
          //         ),
          //         child: const Icon(Icons.save, color: Colors.blue),
          //       ),
          //     ),
          //   ),

          // PASTKI PANEL (MANZIL + "TAYYOR" TUGMASI)
          Positioned(
            bottom: isKeyboardVisible ? 30 : 30,
            left: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // MANZIL KO'RSATADIGAN CONTAINER (SAQLASH BEGISI BILAN)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(25),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // MANZIL MATNI (kengaytirilgan)
                      Expanded(
                        child: Text(
                          _currentAddress,
                          style: const TextStyle(fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // MANZILNI SAQLASH BEGISI (o'ng tarafda) - GestureDetector bilan
                      if (_bPoint != null)
                        GestureDetector(
                          onTap: _saveCurrentLocation,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Icon(
                              Icons.bookmark_add,
                              color: Colors.blue,
                              size: 24,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // "TAYYOR" TUGMASI
                ElevatedButton(
                  onPressed:
                      _bPoint == null
                          ? null
                          : () => Navigator.pop(context, {
                            'point': _bPoint,
                            'address':
                                _fullAddress.isNotEmpty
                                    ? _fullAddress
                                    : _currentAddress,
                          }),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 120,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Tayyor"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
