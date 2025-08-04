import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

/// YandexGoShadowEffect widgeti: marker ostidagi animatsiyali soya effekti
class YandexGoShadowEffect extends StatefulWidget {
  final double shadowSize;   // Soyaning boshlang‘ich kengligi
  final Color shadowColor;   // Soyaning rangi
  final AnimationController animationController; // Tashqi animation controller
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

    // Soyaning kengayishi va tiniqligi animatsiyasi
    _shadowSizeAnimation = Tween<double>(
      begin: widget.shadowSize,
      end: _maxShadowSize,
    ).animate(CurvedAnimation(
      parent: widget.animationController,
      curve: Curves.easeOut,
    ));

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
            color: widget.shadowColor.withAlpha((_shadowOpacityAnimation.value * 255).toInt()),
            boxShadow: [
              BoxShadow(
                color: widget.shadowColor.withAlpha((_shadowOpacityAnimation.value * 255).round()),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Asosiy TaxiOrderScreen widgeti
class TaxiOrderScreen extends StatefulWidget {
  const TaxiOrderScreen({super.key});

  @override
  State<TaxiOrderScreen> createState() => _TaxiOrderScreenState();
}

class _TaxiOrderScreenState extends State<TaxiOrderScreen> with SingleTickerProviderStateMixin {
  final Completer<GoogleMapController> _controllerGoogleMaps = Completer();

  // Foydalanuvchi joylashuvi uchun LatLng
  LatLng? _currentLocation;

  // Xarita harakati davomida markerning ko‘tarilish holati
  bool _isMapMoving = false;

  // AnimationController marker va soyani animatsiyasi uchun
  late AnimationController _animationController;
  late Animation<double> _liftAnimation;

  // Dastlabki kamera joylashuvi (Andijon)
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(40.8008333, 72.9881418),
    zoom: 17.0,
  );

  @override
  void initState() {
    super.initState();

    // Marker ko‘tarilish animatsiyasi uchun controller va tween
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _liftAnimation = Tween<double>(begin: 0, end: 15).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Foydalanuvchi joyini olish
    _determinePosition();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Foydalanuvchi joylashuvini aniqlash
  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // GPS o‘chirilgan bo‘lsa
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Ruxsat berilmasa
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    _currentLocation = LatLng(position.latitude, position.longitude);

    final controller = await _controllerGoogleMaps.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: _currentLocation!, zoom: 17)));

    setState(() {});
  }

  /// Xarita harakati boshlanganda chaqiriladi
  void _onCameraMove() {
    if (!_isMapMoving) {
      _isMapMoving = true;
      _animationController.forward(); // Marker tepaga ko‘tariladi va soya kattalashadi
    }
  }

  /// Xarita harakati tugaganda chaqiriladi
  void _onCameraIdle() {
    if (_isMapMoving) {
      _isMapMoving = false;
      _animationController.reverse(); // Marker pastga tushadi va soya kichrayadi
    }
  }

  /// Maxsus tugma bosilganda foydalanuvchi joyiga xaritani olib borish
  Future<void> _goToCurrentLocation() async {
    if (_currentLocation == null) return;

    final controller = await _controllerGoogleMaps.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: _currentLocation!, zoom: 17)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Maps widget
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _initialCameraPosition,
            myLocationEnabled: true,
            myLocationButtonEnabled: false, // O‘zimiz tugma qilamiz
            onMapCreated: (controller) => _controllerGoogleMaps.complete(controller),
            onCameraMove: (position) => _onCameraMove(),
            onCameraIdle: () => _onCameraIdle(),
          ),

          // Marker va soyani animatsiya bilan markazda joylash
          Center(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Padding(
                  // Marker balandligining ko‘tarilishi uchun padding
                  padding: EdgeInsets.only(bottom: _liftAnimation.value + 65), // 65 marker balandligi yarmi + soyani joylashuvi
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      // Marker rasmi (men.png)
                      Transform.translate(
                        offset: Offset(0, -_liftAnimation.value), // Markerni ko‘tarish animatsiyasi
                        child: Image.asset(
                          'assets/images/men.png',
                          width: 80,
                          height: 80,
                        ),
                      ),

                      // Soyani marker tayoqchasining ostiga joylash va animatsiya qilish
                      Positioned(
                        bottom: 0, // marker ostiga joylash
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

          // Maxsus tugma: yuqori o‘ng burchakdan 30px pastda
          Positioned(
            top: 30,
            right: 20,
            child: FloatingActionButton(
              onPressed: _goToCurrentLocation,
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location, color: Colors.blue),
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