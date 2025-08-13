import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:m_taksi/views/auth/client/select_destination_page.dart';

/// MARKER OSTIDAGI ANIMATSIYALI SOYA WIDGETI
class YandexGoShadowEffect extends StatefulWidget {
  final double shadowSize;
  final Color shadowColor;
  final AnimationController animationController;

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
  late Animation<double> _shadowSizeAnimation;
  late Animation<double> _shadowOpacityAnimation;

  final double _maxShadowSize = 60.0;
  final double _minShadowOpacity = 0.1;

  @override
  void initState() {
    super.initState();

    // Kengayuvchi soya animatsiyasi
    _shadowSizeAnimation = Tween<double>(
      begin: widget.shadowSize,
      end: _maxShadowSize,
    ).animate(CurvedAnimation(
      parent: widget.animationController,
      curve: Curves.easeOut,
    ));

    // Tiniqlik animatsiyasi
    _shadowOpacityAnimation = Tween<double>(
      begin: 0.3,
      end: _minShadowOpacity,
    ).animate(CurvedAnimation(
      parent: widget.animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animationController,
      builder: (context, _) {
        return Container(
          width: _shadowSizeAnimation.value,
          height: _shadowSizeAnimation.value / 4,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.shadowColor
                .withAlpha((_shadowOpacityAnimation.value * 255).toInt()),
            boxShadow: [
              BoxShadow(
                color: widget.shadowColor
                    .withAlpha((_shadowOpacityAnimation.value * 255).round()),
                blurRadius: 3,
                spreadRadius: 5,
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
  LatLng? _currentLocation;
  String _currentAddress = "Manzil aniqlanmoqda...";
  bool _isMapMoving = false;
  bool _isLoadingAddress = false;
  late AnimationController _animationController;
  late Animation<double> _liftAnimation;
  String? _fullAddress; // Buyurtma berish uchun to'liq manzil

  // Andijon shahrini boshlang'ich nuqta sifatida belgilaymiz
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(40.8008333, 72.9881418),
    zoom: 17.0,
  );

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _liftAnimation = Tween<double>(begin: 0, end: 15).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Joylashuvni aniqlaymiz
    _determinePosition();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// FOYDALANUVCHINING JOYLASHUVINI ANIQLAYDI VA MANZILNI TOPADI
  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showLocationServiceDisabledAlert();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showLocationPermissionDeniedAlert();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showLocationPermissionPermanentlyDeniedAlert();
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      _currentLocation = LatLng(position.latitude, position.longitude);
      await _getAddressFromLatLng(_currentLocation!);

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
      _isLoadingAddress = true;
    });

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        
        // 1. To'liq manzilni tayyorlaymiz (buyurtma berishda ishlatish uchun)
        _fullAddress = [
          place.street,
          place.thoroughfare,
          place.subLocality,
          place.locality
        ].where((part) => part != null && part.isNotEmpty).join(', ');
        
        // 2. Foydalanuvchiga ko'rsatish uchun manzilni tayyorlaymiz
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
        _isLoadingAddress = false;
      });
    }
  }

  /// XARITA HARAKATI BOSHLANGANDA
  void _onCameraMove() {
    if (!_isMapMoving) {
      _isMapMoving = true;
      _animationController.forward();
    }
  }

  /// XARITA TO'XTAGANDA
  void _onCameraIdle() async {
    if (_isMapMoving) {
      _isMapMoving = false;
      _animationController.reverse();
      
      final controller = await _controllerGoogleMaps.future;
      final visibleRegion = await controller.getVisibleRegion();
      final centerLatLng = LatLng(
        (visibleRegion.northeast.latitude + visibleRegion.southwest.latitude) / 2,
        (visibleRegion.northeast.longitude + visibleRegion.southwest.longitude) / 2,
      );
      
      await _getAddressFromLatLng(centerLatLng);
    }
  }

  /// JOYIMNI MARKAZGA OLIB KELISH
  Future<void> _goToCurrentLocation() async {
    if (_currentLocation == null) return;

    final controller = await _controllerGoogleMaps.future;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _currentLocation!, zoom: 17),
      ),
    );
    
    await _getAddressFromLatLng(_currentLocation!);
  }

  /// BOTTOM PANELDAGI HAR BIR TUGMA UCHUN BIR XIL STIL
  Widget _buildButton(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
          // GOOGLE MAP
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _initialCameraPosition,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (controller) =>
                _controllerGoogleMaps.complete(controller),
            onCameraMove: (position) => _onCameraMove(),
            onCameraIdle: () => _onCameraIdle(),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height / 2.5,
            ),
          ),

          // MARKER VA SOYA
          Align(
            alignment: Alignment(0.0, -0.5),
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Padding(
                  padding: EdgeInsets.only(bottom: _liftAnimation.value + 65),
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Transform.translate(
                        offset: Offset(0, -_liftAnimation.value),
                        child: Image.asset(
                          'assets/images/men.png',
                          width: 80,
                          height: 80,
                        ),
                      ),
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
              onPressed: () => Navigator.pop(context),
              backgroundColor: Colors.white,
              child: const Icon(Icons.arrow_back, color: Colors.blue),
            ),
          ),

          // LOKATSIYA TUGMASI
          Positioned(
            top: 25,
            right: 15,
            child: FloatingActionButton(
              onPressed: _goToCurrentLocation,
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location, color: Colors.blue),
            ),
          ),

          // BOTTOM BAR
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
              padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildButton(Icons.wifi, "Signal jo'natish"),
                      _buildButton(Icons.local_taxi, "Avtomatik taksi"),
                      _buildButton(Icons.groups, "Haydovchilar"),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Joriy manzil containeri
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
                                  _currentAddress,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,  // qatorni bir qator qilish uchun 
                                  overflow: TextOverflow.ellipsis,
                                ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // Yo'nalishni kiriting containeri
                  GestureDetector(
                    onTap: () {
                      if (_currentLocation != null) {
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