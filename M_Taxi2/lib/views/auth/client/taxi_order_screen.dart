import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

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

  bool _isMapMoving = false;

  late AnimationController _animationController;
  late Animation<double> _liftAnimation;

  // Andijon shahrini boshlang‘ich nuqta sifatida belgilaymiz
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

  /// FOYDALANUVCHINING JOYLASHUVINI ANIQLAYDI
  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition(
      locationSettings:
          const LocationSettings(accuracy: LocationAccuracy.high),
    );

    _currentLocation = LatLng(position.latitude, position.longitude);

    final controller = await _controllerGoogleMaps.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _currentLocation!, zoom: 17),
      ),
    );

    setState(() {});
  }

  /// XARITA HARAKATI BOSHLANGANDA
  void _onCameraMove() {
    if (!_isMapMoving) {
      _isMapMoving = true;
      _animationController.forward();
    }
  }

  /// XARITA TO‘XTAGANDA
  void _onCameraIdle() {
    if (_isMapMoving) {
      _isMapMoving = false;
      _animationController.reverse();
    }
  }

  /// JOYIMNI MARKAZGA OLIB KELISH
  Future<void> _goToCurrentLocation() async {
    if (_currentLocation == null) return;

    final controller = await _controllerGoogleMaps.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _currentLocation!, zoom: 17),
      ),
    );
  }

/// BOTTOM PANELDAGI HAR BIR TUGMA UCHUN BIR XIL STIL
Widget _buildButton(IconData icon, String label) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      CircleAvatar(
        radius: 28, // 🔵 Doira o‘lchamini oshirish uchun radiusni oshirdik (default 20)
        backgroundColor: Colors.white,
        child: Icon(
          icon,
          color: Colors.blue,
          size: 28, // 🔵 Icon o‘lchamini ham doiraga moslab oshirdik (default 24)
        ),
      ),
      const SizedBox(height: 6),
      Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14, // 🔵 Matn o‘lchamini biroz oshirdik (default 12)
        ),
      ),
    ],
  );
}

  /// UI NI QURISH
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🔵 GOOGLE MAP
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _initialCameraPosition,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false, // Zoom +/- tugmalari o'chirildi
            onMapCreated: (controller) =>
                _controllerGoogleMaps.complete(controller),
            onCameraMove: (position) => _onCameraMove(),
            onCameraIdle: () => _onCameraIdle(),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height / 2.5,
            ),
          ),

          // 🔵 MARKER VA SOYA
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

          // 🔵 LOKATSIYA TUGMASI
          Positioned(
            top: 30,
            right: 20,
            child: FloatingActionButton(
              onPressed: _goToCurrentLocation,
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location, color: Colors.blue),
            ),
          ),

          // ✅ BOTTOM BAR QO‘SHILGAN QISMI
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
                    color: const Color(0x33000000),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: "Yo'nalishni kiriting",
                        border: InputBorder.none,
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