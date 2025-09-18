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

    _shadowSizeAnimation = Tween<double>(
      begin: widget.shadowSize,
      end: _maxShadowSize,
    ).animate(
      CurvedAnimation(
        parent: widget.animationController,
        curve: Curves.easeOut,
      ),
    );

    _shadowOpacityAnimation = Tween<double>(
      begin: 0.3,
      end: _minShadowOpacity,
    ).animate(
      CurvedAnimation(
        parent: widget.animationController,
        curve: Curves.easeOut,
      ),
    );
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
            color: widget.shadowColor.withAlpha(
              (_shadowOpacityAnimation.value * 255).toInt(),
            ),
            boxShadow: [
              BoxShadow(
                color: widget.shadowColor.withAlpha(
                  (_shadowOpacityAnimation.value * 255).round(),
                ),
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

/// Baholash ekrani uchun widget
class RatingDialog extends StatefulWidget {
  final Function(int, String) onRatingSubmitted;
  final Function onCancel;

  const RatingDialog({
    super.key,
    required this.onRatingSubmitted,
    required this.onCancel,
  });

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  int _selectedRating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Haydovchini baholang"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Haydovchi haqida izoh qoldiring", style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedRating = index + 1;
                    });
                  },
                  child: Icon(
                    index < _selectedRating ? Icons.star : Icons.star_border,
                    color: index < _selectedRating ? Colors.amber : Colors.grey,
                    size: 40,
                  ),
                );
              }),
            ),
            SizedBox(height: 20),
            
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                labelText: "Izoh (ixtiyoriy)",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () {
            widget.onCancel();
            Navigator.pop(context);
          },
          child: Text("Bekor qilish"),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : () async {
            if (_selectedRating > 0) {
              setState(() => _isSubmitting = true);
              await widget.onRatingSubmitted(_selectedRating, _commentController.text);
              
              if (!mounted) return;
              setState(() => _isSubmitting = false);
              
              if (context.mounted) {
                Navigator.pop(context);
              }
            }
          },
          child: _isSubmitting 
              ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : Text("Jo'natish"),
        ),
      ],
    );
  }
}

/// Signal parametrlari uchun class
class SignalParameters {
  final int passengerCount;
  final String carType;
  final String? specialRequest;
  final bool needHelpWithLuggage;
  final String paymentPreference;

  SignalParameters({
    required this.passengerCount,
    required this.carType,
    this.specialRequest,
    this.needHelpWithLuggage = false,
    this.paymentPreference = "Naqt",
  });
}

/// Haydovchi ma'lumotlari uchun class
class DriverInfo {
  final String name;
  final String carModel;
  final String carColor;
  final String carNumber;
  final double rating;
  final int completedRides;
  final String phoneNumber;
  final String licenseInfo;
  final LatLng currentLocation;
  final int eta;

  DriverInfo({
    required this.name,
    required this.carModel,
    required this.carColor,
    required this.carNumber,
    required this.rating,
    required this.completedRides,
    required this.phoneNumber,
    required this.licenseInfo,
    required this.currentLocation,
    required this.eta,
  });
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
  String? _fullAddress;

  // Tanlangan manzil ma'lumotlari
  LatLng? _selectedDestination;
  String? _selectedDestinationAddress;

  // Saqlangan manzil ma'lumotlari
  LatLng? _savedPickupLocation;
  String? _savedPickupAddress;

  // Marshrut chizish uchun
  final Set<maps.Polyline> _polylines = {};
  static const Color _routeColor = Colors.blue;
  static const int _routeWidth = 5;

  // Tugmalarning faollik holati
  bool _isSignalButtonActive = false;
  bool _isAutoTaxiButtonActive = false;
  bool _isDriversButtonActive = false;

  // Qidiruv jarayoni
  bool _isSearching = false;
  Timer? _searchAnimationTimer;
  double _searchZoomLevel = 17.0;
  int _foundTaxisCount = 0;
  
  // Tugma ko'rsatish o'zgaruvchilari
  bool _showSignalButton = false;
  bool _showAutoTaxiButton = false;

  // Avtomatik taksi parametrlari
  String _selectedServiceType = "Ekonom";
String _selectedPaymentType = "Naqt";
bool _needLuggageHelp = false;
final List<String> _selectedSpecialRequests = [];

  // Buyurtma holati
  bool _isOrderPlaced = false;
  bool _isOrderAccepted = false;
  Map<String, dynamic>? _orderDetails;
  Timer? _orderAcceptanceTimer;

  // Signal jo'natish holatlari
  bool _isSendingSignal = false;
  bool _isWaitingForDriver = false;
  bool _isDriverAccepted = false;
  bool _isServiceStarted = false;
  Timer? _signalTimer;
  Timer? _driverResponseTimer;
  Timer? _serviceTimer;
  int _estimatedArrivalTime = 5;
  double _tripProgress = 0.0;

  // Haydovchi markeri uchun
  Marker? _driverMarker;
  BitmapDescriptor? _driverIcon;

  // Signal parametrlari
  SignalParameters _signalParameters = SignalParameters(
    passengerCount: 1,
    carType: "Yengil",
  );

  // Tanlangan haydovchi
  DriverInfo? _selectedDriver;

  // Qo'shimcha holatlar
  bool _isFindingNearestDriver = false;
  List<DriverInfo> _availableDrivers = [];
  double _signalPrice = 0.0;

  // Maxsus so'rovlar ro'yxati
  final List<String> _specialRequests = [
    "Bolalar o'rindiq",
    "Hayvonlar bilan",
    "Katta bagaj",
    "Nosoz a'zo",
    "Tez yetkazib berish",
    "Suv yoki gazeta",
  ];

  // To'lov usullari
  final List<String> _paymentMethods = [
    "Naqt",
    "Karta orqali",
    "Ilova orqali",
    "Click",
    "Payme",
    "Uzumbank"
  ];

  // Andijon shahrini boshlang'ich nuqta
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
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _loadDriverIcon();
    _determinePosition();
    _createDemoDrivers();
    _calculateSignalPrice();
  }

  // Demo haydovchilar yaratish
  void _createDemoDrivers() {
    _availableDrivers = [
      DriverInfo(
        name: "Ali Valiyev",
        carModel: "Cobalt",
        carColor: "Oq",
        carNumber: "01 A 123 AA",
        rating: 4.8,
        completedRides: 1247,
        phoneNumber: "+998901234567",
        licenseInfo: "AB1234567",
        currentLocation: LatLng(40.805, 72.990),
        eta: 5,
      ),
      DriverInfo(
        name: "Hasan Hasanov",
        carModel: "Nexia",
        carColor: "Qora",
        carNumber: "01 B 456 BB",
        rating: 4.5,
        completedRides: 892,
        phoneNumber: "+998901234568",
        licenseInfo: "AB7654321",
        currentLocation: LatLng(40.802, 72.985),
        eta: 3,
      ),
      DriverInfo(
        name: "Olim Olimov",
        carModel: "Gentra",
        carColor: "Kumush",
        carNumber: "01 C 789 CC",
        rating: 4.9,
        completedRides: 1563,
        phoneNumber: "+998901234569",
        licenseInfo: "AB9876543",
        currentLocation: LatLng(40.798, 72.992),
        eta: 7,
      ),
    ];
  }

  // Signal narxini hisoblash
  void _calculateSignalPrice() {
    double basePrice = 10000.0;
    double carTypeMultiplier = _signalParameters.carType == "Yengil" ? 1.0 : 1.2;
    double passengerMultiplier = _signalParameters.passengerCount * 0.1;
    double luggageMultiplier = _signalParameters.needHelpWithLuggage ? 1.1 : 1.0;
    
    setState(() {
      _signalPrice = (basePrice * carTypeMultiplier * (1 + passengerMultiplier) * luggageMultiplier).roundToDouble();
    });
  }

  // Avtomatik taksi narxini hisoblash
  double _calculateAutoTaxiPrice() {
    double basePrice = 12000.0;
    double serviceMultiplier = _selectedServiceType == "Ekonom" ? 1.0 : 
                             _selectedServiceType == "Standart" ? 1.2 : 
                             _selectedServiceType == "Komfort" ? 1.5 : 2.0;
    
    return basePrice * serviceMultiplier;
  }

  // Haydovchi ikonkasi yuklash
  void _loadDriverIcon() async {
    final icon = await BitmapDescriptor.asset(
      ImageConfiguration(size: Size(48, 48)),
      'assets/images/car_icon.png',
    );
    setState(() {
      _driverIcon = icon;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchAnimationTimer?.cancel();
    _orderAcceptanceTimer?.cancel();
    _signalTimer?.cancel();
    _driverResponseTimer?.cancel();
    _serviceTimer?.cancel();
    super.dispose();
  }

  /// FOYDALANUVCHINING JOYLASHUVINI ANIQLASH
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
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
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

  /// SelectDestinationPage dan natijani qayta ishlash
  void _handleDestinationSelection() async {
    if (_currentLocation != null) {
      if (_savedPickupLocation == null && _savedPickupAddress == null) {
        _savedPickupLocation = _currentLocation;
        _savedPickupAddress = _currentAddress;
      }

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SelectDestinationPage(aPoint: _currentLocation!),
        ),
      );

      if (result != null && mounted) {
        setState(() {
          _selectedDestination = result['point'] as LatLng;
          _selectedDestinationAddress = result['address'] as String;
        });

        _goToSelectedDestination();
        _drawRoute();
        _updateButtonsState();
      }
    }
  }

  /// Tugmalarning holatini yangilash
  void _updateButtonsState() {
    setState(() {
      bool hasBothLocations = _savedPickupLocation != null && _selectedDestination != null;
      _isSignalButtonActive = hasBothLocations;
      _isAutoTaxiButtonActive = hasBothLocations;
      _isDriversButtonActive = hasBothLocations;
    });
  }

  /// Marshrut chizish funksiyasi
  Future<void> _drawRoute() async {
    if (_savedPickupLocation == null || _selectedDestination != null) return;

    try {
      final String url =
          'https://maps.googleapis.com/maps/api/directions/json?'
          'origin=${_savedPickupLocation!.latitude},${_savedPickupLocation!.longitude}'
          '&destination=${_selectedDestination!.latitude},${_selectedDestination!.longitude}'
          '&key=AIzaSyCqIB5c5qFVJaz1dKdp2aO1hOuIY-9800E';

      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      if (data['status'] == 'OK') {
        List<LatLng> points = _decodePolyline(
          data['routes'][0]['overview_polyline']['points'],
        );

        setState(() {
          _polylines.clear();
          _polylines.add(
            maps.Polyline(
              polylineId: maps.PolylineId('route'),
              points: points,
              color: _routeColor,
              width: _routeWidth,
            ),
          );
        });
      } else {
        _showErrorSnackbar("Marshrut topilmadi");
      }
    } catch (e) {
      _showErrorSnackbar("Marshrut chizishda xatolik");
    }
  }

  /// Polylineni dekodlash funksiyasi
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

  /// Tanlangan manzilni tozalash funksiyasi
  void _clearSelectedDestination() {
    setState(() {
      _selectedDestination = null;
      _selectedDestinationAddress = null;
      _polylines.clear();
      _savedPickupLocation = null;
      _savedPickupAddress = null;
      _isSignalButtonActive = false;
      _isAutoTaxiButtonActive = false;
      _isDriversButtonActive = false;
      _cancelSearch();
      _resetSignalState();
    });
  }
  
  /// Signal holatlarini tozalash
  void _resetSignalState() {
    _signalTimer?.cancel();
    _driverResponseTimer?.cancel();
    _serviceTimer?.cancel();
    
    setState(() {
      _isSendingSignal = false;
      _isWaitingForDriver = false;
      _isDriverAccepted = false;
      _isServiceStarted = false;
      _driverMarker = null;
      _estimatedArrivalTime = 5;
      _tripProgress = 0.0;
      _isFindingNearestDriver = false;
      _selectedDriver = null;
    });
  }

  /// LATLNG DAN TO'LIQ MANZILNI OLISH
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

        _fullAddress = [
          place.street,
          place.thoroughfare,
          place.subLocality,
          place.locality,
        ].where((part) => part != null && part.isNotEmpty).join(', ');

        String displayAddress;

        if (place.locality != null && place.locality!.isNotEmpty) {
          if ((place.street != null && place.street!.contains('+') && place.street!.length < 10) ||
              (place.thoroughfare != null && place.thoroughfare!.contains('+') && place.thoroughfare!.length < 10)) {
            displayAddress = "Ko'rdinatangiz (${place.locality})";
          } else {
            displayAddress = _fullAddress!;
          }
        } else {
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

  /// Xaritani zoom qilish
  Future<void> _animateCameraZoom(double zoomLevel) async {
    final controller = await _controllerGoogleMaps.future;
    final targetZoom = zoomLevel.clamp(12.0, 17.0);
    controller.animateCamera(CameraUpdate.zoomTo(targetZoom));
  }

  /// Signal jo'natish funksiyasi
  void _sendSignal() {
    if (!_isSignalButtonActive) return;
    _showAdvancedSignalOptionsDialog();
  }

  /// Avtomatik taksi funksiyasi
  void _orderAutoTaxi() {
    if (!_isAutoTaxiButtonActive) return;
    _showAutoTaxiOptionsDialog();
  }

  /// Haydovchilarni ko'rsatish funksiyasi
  void _showAvailableDrivers() {
    if (!_isDriversButtonActive) return;
    _showDriversListDialog();
  }

  /// Kengaytirilgan signal parametrlari dialogi
  void _showAdvancedSignalOptionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Signal parametrlari", style: TextStyle(fontSize: 20)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: Text("Yo'lovchilar soni", style: TextStyle(fontWeight: FontWeight.bold)),
                      trailing: DropdownButton<int>(
                        value: _signalParameters.passengerCount,
                        onChanged: (value) {
                          setState(() {
                            _signalParameters = SignalParameters(
                              passengerCount: value!,
                              carType: _signalParameters.carType,
                              specialRequest: _signalParameters.specialRequest,
                              needHelpWithLuggage: _signalParameters.needHelpWithLuggage,
                              paymentPreference: _signalParameters.paymentPreference,
                            );
                          });
                          _calculateSignalPrice();
                        },
                        items: [1, 2, 3, 4, 5, 6].map((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text("$value kishi"),
                          );
                        }).toList(),
                      ),
                    ),

                    ListTile(
                      title: Text("Mashina turi", style: TextStyle(fontWeight: FontWeight.bold)),
                      trailing: DropdownButton<String>(
                        value: _signalParameters.carType,
                        onChanged: (value) {
                          setState(() {
                            _signalParameters = SignalParameters(
                              passengerCount: _signalParameters.passengerCount,
                              carType: value!,
                              specialRequest: _signalParameters.specialRequest,
                              needHelpWithLuggage: _signalParameters.needHelpWithLuggage,
                              paymentPreference: _signalParameters.paymentPreference,
                            );
                          });
                          _calculateSignalPrice();
                        },
                        items: ["Yengil", "Istalgan", "Komfort", "Biznes", "Miniyen", "Mikroavtobus"].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),

                    ListTile(
                      title: Text("To'lov usuli", style: TextStyle(fontWeight: FontWeight.bold)),
                      trailing: DropdownButton<String>(
                        value: _signalParameters.paymentPreference,
                        onChanged: (value) {
                          setState(() {
                            _signalParameters = SignalParameters(
                              passengerCount: _signalParameters.passengerCount,
                              carType: _signalParameters.carType,
                              specialRequest: _signalParameters.specialRequest,
                              needHelpWithLuggage: _signalParameters.needHelpWithLuggage,
                              paymentPreference: value!,
                            );
                          });
                        },
                        items: _paymentMethods.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),

                    SwitchListTile(
                      title: Text("Bagaj yordami kerak", style: TextStyle(fontWeight: FontWeight.bold)),
                      value: _signalParameters.needHelpWithLuggage,
                      onChanged: (value) {
                        setState(() {
                            _signalParameters = SignalParameters(
                              passengerCount: _signalParameters.passengerCount,
                              carType: _signalParameters.carType,
                              specialRequest: _signalParameters.specialRequest,
                              needHelpWithLuggage: value,
                              paymentPreference: _signalParameters.paymentPreference,
                            );
                        });
                        _calculateSignalPrice();
                        },
                    ),

                    ExpansionTile(
                      title: Text("Maxsus so'rovlar", style: TextStyle(fontWeight: FontWeight.bold)),
                      children: _specialRequests.map((request) {
                        return RadioListTile<String>(
                          title: Text(request),
                          value: request,
                          groupValue: _signalParameters.specialRequest,
                          onChanged: (value) {
                            setState(() {
                              _signalParameters = SignalParameters(
                                passengerCount: _signalParameters.passengerCount,
                                carType: _signalParameters.carType,
                                specialRequest: value,
                                needHelpWithLuggage: _signalParameters.needHelpWithLuggage,
                                paymentPreference: _signalParameters.paymentPreference,
                              );
                            });
                          },
                        );
                      }).toList(),
                    ),

                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Taxminiy narx:", style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("${_signalPrice.toStringAsFixed(0)} so'm", 
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Bekor qilish", style: TextStyle(color: Colors.red)),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _findNearestDriver();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text("Haydovchi qidirish", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Eng yaqin haydovchini qidirish
  void _findNearestDriver() {
    setState(() {
      _isFindingNearestDriver = true;
    });

    Timer(Duration(seconds: 2), () {
      if (_availableDrivers.isNotEmpty) {
        _availableDrivers.sort((a, b) => a.eta.compareTo(b.eta));
        _selectedDriver = _availableDrivers.first;
        
        setState(() {
          _isFindingNearestDriver = false;
        });

        _showDriverSelectionDialog();
      }
    });
  }

  /// Haydovchi tanlash dialogi
  void _showDriverSelectionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Topildi! Eng yaqin haydovchi", style: TextStyle(fontSize: 18)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_selectedDriver != null) ...[
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue,
                    child: Text(
                      _selectedDriver!.name.substring(0, 1),
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(_selectedDriver!.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text("${_selectedDriver!.carModel} • ${_selectedDriver!.carColor} • ${_selectedDriver!.carNumber}"),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      Text(" ${_selectedDriver!.rating}"),
                      SizedBox(width: 10),
                      Icon(Icons.directions_car, size: 16),
                      Text(" ${_selectedDriver!.completedRides} ta safar"),
                    ],
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Yetib borish: ${_selectedDriver!.eta} daqiqa",
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text("Narx: ${_signalPrice.toStringAsFixed(0)} so'm", 
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _findNearestDriver();
              },
              child: Text("Boshqa haydovchi", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _sendMessageToNearestDriver();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: Text("Tasdiqlash", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  /// Kengaytirilgan signal jo'natish
  void _sendMessageToNearestDriver() {
    if (_selectedDriver == null) return;

    setState(() {
      _isSendingSignal = true;
      _isWaitingForDriver = false;
      _isDriverAccepted = false;
      _showSignalButton = false;
    });

    _signalTimer = Timer(Duration(seconds: 3), () {
      setState(() {
        _isSendingSignal = false;
        _isWaitingForDriver = true;
      });

      _driverResponseTimer = Timer(Duration(seconds: 5), () {
        setState(() {
          _isWaitingForDriver = false;
          _isDriverAccepted = true;
        });

        _addDriverMarker();
        _startService();
        });
    });
  }

  /// Avtomatik taksi parametrlarini so'rash dialogi
  void _showAutoTaxiOptionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Avtomatik taksi parametrlari", style: TextStyle(fontSize: 20)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Xizmat turi
                    ListTile(
                      title: Text("Xizmat turi", style: TextStyle(fontWeight: FontWeight.bold)),
                      trailing: DropdownButton<String>(
                        value: _selectedServiceType,
                        onChanged: (value) {
                          setState(() {
                            _selectedServiceType = value!;
                          });
                        },
                        items: ["Ekonom", "Standart", "Komfort", "Biznes"].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                    
                    // To'lov turi
                    ListTile(
                      title: Text("To'lov turi", style: TextStyle(fontWeight: FontWeight.bold)),
                      trailing: DropdownButton<String>(
                        value: _selectedPaymentType,
                        onChanged: (value) {
                          setState(() {
                            _selectedPaymentType = value!;
                          });
                        },
                        items: _paymentMethods.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                    
                    // Bagaj yordami
                    SwitchListTile(
                      title: Text("Bagaj yordami kerak", style: TextStyle(fontWeight: FontWeight.bold)),
                      value: _needLuggageHelp,
                      onChanged: (value) {
                        setState(() {
                          _needLuggageHelp = value;
                        });
                      },
                    ),
                    
                    // Maxsus so'rovlar
                    ExpansionTile(
                      title: Text("Maxsus so'rovlar", style: TextStyle(fontWeight: FontWeight.bold)),
                      children: _specialRequests.map((request) {
                        return CheckboxListTile(
                          title: Text(request),
                          value: _selectedSpecialRequests.contains(request),
                          onChanged: (value) {
                            setState(() {
                              if (value!) {
                                _selectedSpecialRequests.add(request);
                              } else {
                                _selectedSpecialRequests.remove(request);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    
                    // Taxminiy narx
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Taxminiy narx:", style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("${_calculateAutoTaxiPrice().toStringAsFixed(0)} so'm", 
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                        ],
                      ),
                    ),
                    
            // Haydovchi uchun izoh
Padding(
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  child: TextField(
    onChanged: (value) {
      // _driverComment o'rniga mahalliy o'zgaruvchi ishlatish
      // Bu yerda siz commentni kerakli joyga saqlashingiz mumkin
      // Masalan, _selectedDriverComment deb yangi o'zgaruvchi yaratishingiz mumkin
    },
    decoration: InputDecoration(
      labelText: "Haydovchi uchun izoh (ixtiyoriy)",
      border: OutlineInputBorder(),
    ),
    maxLines: 3,
  ),
),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Bekor qilish", style: TextStyle(color: Colors.red)),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _startAutoTaxiSearch();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text("Qidiruvni boshlash", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Haydovchilar ro'yxatini ko'rsatish dialogi
  void _showDriversListDialog() {
    List<Map<String, dynamic>> demoDrivers = [
      {
        'name': 'Ali Valiyev',
        'car': 'Cobalt',
        'color': 'Oq',
        'number': '01 A 123 AA',
        'rating': 4.8,
        'distance': '1.2 km',
        'price': '15,000 so\'m'
      },
      {
        'name': 'Hasan Hasanov',
        'car': 'Nexia',
        'color': 'Qora',
        'number': '01 B 456 BB',
        'rating': 4.5,
        'distance': '0.8 km',
        'price': '14,000 so\'m'
      },
      {
        'name': 'Olim Olimov',
        'car': 'Gentra',
        'color': 'Kumush',
        'number': '01 C 789 CC',
        'rating': 4.9,
        'distance': '2.1 km',
        'price': '16,000 so\'m'
      }
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Mavjud haydovchilar"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: demoDrivers.length,
              itemBuilder: (context, index) {
                final driver = demoDrivers[index];
                return ListTile(
                  leading: Icon(Icons.person, size: 40),
                  title: Text(driver['name']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${driver['car']} • ${driver['color']} • ${driver['number']}"),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          Text(" ${driver['rating']}"),
                          SizedBox(width: 10),
                          Icon(Icons.directions_car, size: 16),
                          Text(" ${driver['distance']}"),
                        ],
                      ),
                      Text("${driver['price']}", style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _selectDriver(driver);
                    },
                    child: Text("Tanlash"),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Bekor qilish"),
            ),
          ],
        );
      },
    );
  }

  /// Haydovchini tanlash funksiyasi
  void _selectDriver(Map<String, dynamic> driver) {
    _startSearchAnimation();
  }

  /// Avtomatik taksi qidiruvini boshlash
  void _startAutoTaxiSearch() {
    setState(() {
      _isSearching = true;
      _foundTaxisCount = 0;
      _showAutoTaxiButton = false;
    });

    _searchAnimationTimer = Timer.periodic(Duration(milliseconds: 800), (timer) {
      if (_searchZoomLevel > 12.0) {
        setState(() {
          _searchZoomLevel -= 0.3;
          _foundTaxisCount += 1;
        });
        _animateCameraZoom(_searchZoomLevel);
      } else {
        timer.cancel();
        _showDriverFoundDialog();
      }
    });
  }

  /// Topilgan haydovchi dialogini ko'rsatish
  void _showDriverFoundDialog() {
    // Taxminiy haydovchi ma'lumotlari
    Map<String, dynamic> foundDriver = {
      'name': 'Alijon Valiyev',
      'car': 'Cobalt',
      'color': 'Oq',
      'number': '01 A 250 AA',
      'rating': 4.8,
      'eta': '5 daqiqa',
      'price': '15,000 so\'m'
    };

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Topildi! Sizga mos haydovchi", style: TextStyle(fontSize: 18)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue,
                  child: Text(
                    foundDriver['name'].substring(0, 1),
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ),
                SizedBox(height: 10),
                Text(foundDriver['name'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text("${foundDriver['car']} • ${foundDriver['color']} • ${foundDriver['number']}"),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    Text(" ${foundDriver['rating']}"),
                    SizedBox(width: 10),
                    Icon(Icons.access_time, size: 16),
                    Text(" ${foundDriver['eta']}"),
                  ],
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Narx: ${foundDriver['price']}",
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _startAutoTaxiSearch(); // Yangi qidiruv
              },
              child: Text("Boshqa haydovchi", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _placeAutoTaxiOrder(foundDriver);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: Text("Tasdiqlash", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  /// Avtomatik taksi buyurtmasini berish
  void _placeAutoTaxiOrder(Map<String, dynamic> driver) {
    setState(() {
      _isOrderPlaced = true;
      _isOrderAccepted = false;
      _showAutoTaxiButton = false;
    });

    // Buyurtma qabul qilinishini simulyatsiya qilish
    _orderAcceptanceTimer = Timer(Duration(seconds: 3), () {
      setState(() {
        _isOrderAccepted = true;
        _orderDetails = {
          'driverName': driver['name'],
          'driverPhone': '+998901234567',
          'carModel': driver['car'],
          'carColor': driver['color'],
          'carNumber': driver['number'],
          'arrivalTime': driver['eta'],
          'orderTime': DateTime.now().toString(),
          'from': _savedPickupAddress,
          'to': _selectedDestinationAddress,
          'serviceType': _selectedServiceType,
          'paymentType': _selectedPaymentType,
          'price': driver['price'],
          'license': 'Andijon shahar tumani'
        };
      });
      
      // Haydovchi markerini qo'shish
      _addDriverMarker();
    });
  }

  /// Qidiruv animatsiyasini boshlash
  void _startSearchAnimation() {
    setState(() {
      _isSearching = true;
      _foundTaxisCount = 0;
      _showSignalButton = false;
    });

    _searchAnimationTimer = Timer.periodic(Duration(milliseconds: 800), (timer) {
      if (_searchZoomLevel > 12.0) {
        setState(() {
          _searchZoomLevel -= 0.3;
          _foundTaxisCount += 1;
        });
        _animateCameraZoom(_searchZoomLevel);
      } else {
        timer.cancel();
        setState(() {
          _isSearching = false;
          _showSignalButton = true;
        });
      }
    });
  }

  /// Qidiruvni bekor qilish
  void _cancelSearch() {
    _searchAnimationTimer?.cancel();
    setState(() {
      _isSearching = false;
      _searchZoomLevel = 17.0;
      _foundTaxisCount = 0;
      _showSignalButton = false;
      _showAutoTaxiButton = false;
    });
    _goToCurrentLocation();
  }

  /// Haydovchi markerini qo'shish
  void _addDriverMarker() {
    if (_savedPickupLocation != null && _driverIcon != null) {
      // Haydovchi manzilini simulyatsiya qilish (aslida serverdan keladi)
      final driverLocation = LatLng(
        _savedPickupLocation!.latitude + 0.005,
        _savedPickupLocation!.longitude + 0.005,
      );

      setState(() {
        _driverMarker = Marker(
          markerId: MarkerId('driver'),
          position: driverLocation,
          icon: _driverIcon!,
          infoWindow: InfoWindow(
            title: 'Haydovchingiz',
            snippet: 'Yetib borish: ${_orderDetails!['arrivalTime']}',
          ),
        );
      });
      
      _centerMapOnDriverAndClient();
    }
  }

  /// Xaritani haydovchi va mijoz o'rtasiga markazlashtirish
  void _centerMapOnDriverAndClient() async {
    if (_savedPickupLocation != null && _driverMarker != null) {
      final controller = await _controllerGoogleMaps.future;
      final double centerLat = (_savedPickupLocation!.latitude + _driverMarker!.position.latitude) / 2;
      final double centerLng = (_savedPickupLocation!.longitude + _driverMarker!.position.longitude) / 2;
      final double zoomLevel = 14.0;
      
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(centerLat, centerLng),
            zoom: zoomLevel,
          ),
        ),
      );
    }
  }

  /// Xizmatni boshlash
  void _startService() {
    _serviceTimer = Timer(Duration(seconds: 5), () {
      setState(() {
        _isServiceStarted = true;
        _estimatedArrivalTime = 3;
      });
      _updateTripProgress();
    });
  }

  /// Safar progressini yangilash
  void _updateTripProgress() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (_tripProgress < 1.0) {
        setState(() {
          _tripProgress += 0.05;
          _estimatedArrivalTime = (3 * (1 - _tripProgress)).ceil();
          if (_estimatedArrivalTime <= 0) {
            _estimatedArrivalTime = 0;
            timer.cancel();
            _showRatingDialogToUser();
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  /// Baholash dialogini ko'rsatish
  void _showRatingDialogToUser() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => RatingDialog(
        onRatingSubmitted: (rating, comment) {
          _handleRatingSubmission(rating, comment);
        },
        onCancel: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  /// Baholashni qayta ishlash
  void _handleRatingSubmission(int rating, String comment) {
    _showErrorSnackbar("Bahoyingiz jo'natildi: $rating yulduz${comment.isNotEmpty ? " va izoh: $comment" : ""}");
    
    setState(() {
      _isServiceStarted = false;
      _isDriverAccepted = false;
      _driverMarker = null;
      _tripProgress = 0.0;
    });
  }

  /// Xizmatni tugatish
  void _finishService() {
    _serviceTimer?.cancel();
    _showRatingDialogToUser();
  }

  /// Buyurtma berish funksiyasi
  void _placeOrder() {
    setState(() {
      _isOrderPlaced = true;
      _isOrderAccepted = false;
      _showAutoTaxiButton = false;
    });

    _orderAcceptanceTimer = Timer(Duration(seconds: 3), () {
      setState(() {
        _isOrderAccepted = true;
        _orderDetails = {
          'driverName': 'Ali Valiyev',
          'driverPhone': '+998901234567',
          'carModel': 'Cobalt',
          'carColor': 'Oq',
          'carNumber': '01 A 123 AA',
          'arrivalTime': '5 daqiqa',
          'orderTime': DateTime.now().toString(),
          'from': _savedPickupAddress,
          'to': _selectedDestinationAddress,
          'serviceType': _selectedServiceType,
          'paymentType': _selectedPaymentType,
          'price': '15,000 so\'m',
          'license': 'Andijon shahar tumani'
        };
      });
    });
  }


  /// Haydovchiga qo'ng'iroq qilish funksiyasi
  void _callDriver() {
    _showErrorSnackbar("Haydovchiga qo'ng'iroq qilinmoqda: ${_orderDetails?['driverPhone']}");
  }

  /// Buyurtma tafsilotlarini ko'rsatish funksiyasi
  void _showOrderDetails() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Buyurtma tafsilotlari"),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_orderDetails != null) ...[
                      _buildDetailItem("Haydovchi", _orderDetails!['driverName']),
                      _buildDetailItem("Buyurtma vaqti", _orderDetails!['orderTime']),
                      _buildDetailItem("Qayerdan", _orderDetails!['from']),
                      _buildDetailItem("Qayerga", _orderDetails!['to']),
                      _buildDetailItem("Mashina", "${_orderDetails!['carModel']} ${_orderDetails!['carColor']} ${_orderDetails!['carNumber']}"),
                      _buildDetailItem("Xizmat turi", _orderDetails!['serviceType']),
                      _buildDetailItem("To'lov turi", _orderDetails!['paymentType']),
                      _buildDetailItem("Narx", _orderDetails!['price']),
                      _buildDetailItem("Litsenziya", _orderDetails!['license']),
                    ],
                    SizedBox(height: 20),
                    // To'lov usulini o'zgartirish imkoniyati
                    Text("To'lov usulini o'zgartirish:", style: TextStyle(fontWeight: FontWeight.bold)),
                    DropdownButton<String>(
                      value: _orderDetails != null ? _orderDetails!['paymentType'] : _selectedPaymentType,
                      onChanged: (value) {
                        setState(() {
                          if (_orderDetails != null) {
                            _orderDetails!['paymentType'] = value!;
                          } else {
                            _selectedPaymentType = value!;
                          }
                        });
                      },
                      items: _paymentMethods.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
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
      },
    );
  }

  /// Haydovchi buyurtmasini bekor qilish
  void _cancelDriverOrder() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Buyurtmani bekor qilish"),
          content: Text("Rostan ham buyurtmani bekor qilmoqchimisiz?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Dialogni yopish
              },
              child: Text("Yo'q", style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Dialogni yopish
                _resetSignalState(); // Buyurtmani bekor qilish
                _showErrorSnackbar("Buyurtma bekor qilindi");
              },
              child: Text("Ha", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  /// Tafsilotlar elementi qurish
  Widget _buildDetailItem(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  /// Tugmalarni qurish
  Widget _buildButton(IconData icon, String label, bool isActive, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.white.withAlpha(204),
              shape: BoxShape.circle,
              boxShadow: [
                if (isActive)
                  BoxShadow(
                    color: Colors.blue.withAlpha(100),
                    blurRadius: 6,
                    spreadRadius: 1,
                    offset: Offset(0, 2),
                  )
                else
                  BoxShadow(
                    color: Colors.black.withAlpha(26),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
              ],
            ),
            child: Icon(icon, color: Colors.blue, size: 28),
          ),
          SizedBox(height: 6),
          Text(
            label, 
            style: TextStyle(
              color: Colors.white,
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
      builder: (context) => AlertDialog(
        title: Text("Lokatsiya xizmati o'chirilgan"),
        content: Text("Iltimos, joylashuv xizmatini yoqing"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
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
        title: Text("Ruxsat rad etildi"),
        content: Text("Iltimos, ilova uchun joylashuv ruxsatini bering"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
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
        title: Text("Ruxsat doimiy ravishda rad etildi"),
        content: Text("Sozlamalarga borib, ruxsatni qo'lda yoqing"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
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
            mapType: MapType.normal,
            initialCameraPosition: _initialCameraPosition,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (controller) => _controllerGoogleMaps.complete(controller),
            onCameraMove: (position) => _onCameraMove(),
            onCameraIdle: () => _onCameraIdle(),
            polylines: _polylines,
            markers: _driverMarker != null ? {_driverMarker!} : {},
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height / 2.5,
            ),
          ),

          // MARKER VA SOYA ANIMATSIYASI
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

          // ORQAGA QAYTISH TUGMASI
          Positioned(
            top: 25,
            left: 15,
            child: FloatingActionButton(
              onPressed: () => Navigator.pop(context),
              backgroundColor: Colors.white,
              child: Icon(Icons.arrow_back, color: Colors.blue),
            ),
          ),

          // LOKATSIYA TUGMASI
          Positioned(
            top: 25,
            right: 15,
            child: FloatingActionButton(
              onPressed: _goToCurrentLocation,
              backgroundColor: Colors.white,
              child: Icon(Icons.my_location, color: Colors.blue),
            ),
          ),

          // Qidiruv jarayonida bekor qilish tugmasi
          if (_isSearching)
            Positioned(
              top: 90,
              right: 15,
              child: FloatingActionButton(
                onPressed: _cancelSearch,
                backgroundColor: Colors.white,
                child: Icon(Icons.close, color: Colors.red),
              ),
            ),

          // Qidiruv natijasi - topilgan taksilar soni
          if (_isSearching)
            Positioned(
              top: 25,
              left: MediaQuery.of(context).size.width / 2 - 100,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                ),
                child: Text(
                  "Topildi: $_foundTaxisCount ta taksi",
                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              ),
            ),

          // PASTKI PANEL (Bottom Bar)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade600,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.1), blurRadius: 8, offset: Offset(0, -2))],
              ),
              padding: EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                
                  // Tugmalar qatori
                  if (!_isDriverAccepted && !_isServiceStarted)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildButton(Icons.wifi, "Signal jo'natish", _isSignalButtonActive, _sendSignal),
                      _buildButton(Icons.local_taxi, "Avtomatik taksi", _isAutoTaxiButtonActive, _orderAutoTaxi),
                      _buildButton(Icons.groups, "Haydovchilar", _isDriversButtonActive, _showAvailableDrivers),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Haydovchi qabul qilgandan keyingi interfeys
                  if (_isDriverAccepted && !_isServiceStarted)
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: 10),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Haydovchingiz yo'lda", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.person, size: 40, color: Colors.blue),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Alijon Valiyev", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  Text("Cobalt • Oq • 01 A 250 AA", style: TextStyle(fontSize: 14)),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.phone, color: Colors.green, size: 30),
                              onPressed: () => _callDriver(),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Yetib borish: $_estimatedArrivalTime daqiqa", style: TextStyle(fontSize: 14, color: Colors.green)),
                            Text("15,000 so'm", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: _showOrderDetails,
                              child: Text("Batafsil ma'lumot"),
                            ),
                            TextButton(
                              onPressed: _cancelDriverOrder,
                              child: Text("Bekor qilish", style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        LinearProgressIndicator(
                          value: _tripProgress,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      ],
                    ),
                  ),

                  // Xizmat boshlangandan keyingi interfeys
                  if (_isServiceStarted)
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: 10),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Safarda", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: Icon(Icons.expand_less),
                              onPressed: _showOrderDetails,
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.red, size: 20),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _savedPickupAddress ?? "Joriy manzil",
                                style: TextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(Icons.navigation, color: Colors.blue, size: 20),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _selectedDestinationAddress ?? "Boradigan manzil",
                                style: TextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Yetib borish: $_estimatedArrivalTime daqiqa", style: TextStyle(fontSize: 14, color: Colors.green)),
                            Text("Cobalt • 01 A 123 AA", style: TextStyle(fontSize: 14, color: Colors.grey)),
                          ],
                        ),
                        SizedBox(height: 10),
                        LinearProgressIndicator(
                          value: _tripProgress,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: _finishService,
                              child: Text("Xizmatni tugatish"),
                            ),
                            IconButton(
                              icon: Icon(Icons.star, color: Colors.green, size: 30), 
                              onPressed: _showRatingDialogToUser,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // JORIY MANZIL KONTEYNERI
                  if (!_isDriverAccepted && !_isServiceStarted)
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: 5),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.blue, size: 24),
                        SizedBox(width: 12),
                        Expanded(
                          child: _isLoadingAddress
                              ? Row(
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue),
                                    ),
                                    SizedBox(width: 12),
                                    Text("Manzil aniqlanmoqda...", style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                                  ],
                                )
                              : Text(
                                  _savedPickupAddress ?? _currentAddress,
                                  style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                        ),
                      ],
                    ),
                  ),

                  // YO'NALISHNI KIRITISH KONTEYNERI
                  if (!_isDriverAccepted && !_isServiceStarted)
                  SizedBox(height: 10),

                  if (!_isDriverAccepted && !_isServiceStarted)
                  GestureDetector(
                    onTap: _selectedDestinationAddress == null ? _handleDestinationSelection : null,
                    child: Container(
                      height: 50,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                      ),
                    child: Row(
                        children: [
                          Icon(
                            _selectedDestinationAddress != null ? Icons.location_on : Icons.search,
                            color: _selectedDestinationAddress != null ? Colors.blue : Colors.grey,
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Text(
                                _selectedDestinationAddress ?? "Yo'nalishni kiriting",
                                style: TextStyle(
                                  color: _selectedDestinationAddress != null ? Colors.black : Colors.grey,
                                  fontSize: 16,
                                  fontWeight: _selectedDestinationAddress != null ? FontWeight.w500 : FontWeight.normal,
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

                  SizedBox(height: 15),

                  // Signal jo'natish tugmasi
                  if (_isSignalButtonActive && _showSignalButton && !_isDriverAccepted && !_isServiceStarted)
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: 10),
                      child: ElevatedButton(
                        onPressed: _sendMessageToNearestDriver,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF13B58C),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: Text(
                          "Eng yaqin haydovchiga xabar jo'natish",
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

 // Signal holatini ko'rsatish
                  if (_isFindingNearestDriver || _isSendingSignal || _isWaitingForDriver)
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: 10),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _isFindingNearestDriver ? Colors.blue : 
                              _isSendingSignal ? Colors.blue : Colors.orange
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isFindingNearestDriver ? "Eng yaqin haydovchi qidirilmoqda..." :
                                  _isSendingSignal ? "Xabar jo'natilmoqda..." :
                                  "Haydovchidan javob kutilmoqda...",
                                  style: TextStyle(
                                    fontSize: 16, 
                                    color: _isFindingNearestDriver ? Colors.blue : 
                                           _isSendingSignal ? Colors.blue : Colors.orange
                                  ),
                                ),
                                if (_selectedDriver != null)
                                  Text(
                                    _isSendingSignal ? "Haydovchi: ${_selectedDriver!.name}" :
                                    "${_selectedDriver!.name} ${_selectedDriver!.eta} daqiqa masofada",
                                    style: TextStyle(
                                      fontSize: 14, 
                                      color: _isFindingNearestDriver ? Colors.blue.shade700 : 
                                             _isSendingSignal ? Colors.blue.shade700 : Colors.orange.shade700
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),



                  // Avtomatik taksi uchun buyurtma berish tugmasi
                  if (_isAutoTaxiButtonActive && _showAutoTaxiButton && !_isDriverAccepted && !_isServiceStarted)
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: 10),
                      child: ElevatedButton(
                        onPressed: _placeOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF13B58C),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: Text(
                          "Sizga mos haydovchini buyurtma qiling",
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                  // Buyurtma yuborilayotganida kutish animatsiyasi
                  if (_isOrderPlaced && !_isOrderAccepted && !_isDriverAccepted && !_isServiceStarted)
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: 10),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)),
                          SizedBox(height: 10),
                          Text("Buyurtma yuborilmoqda...", style: TextStyle(color: Colors.blue, fontSize: 16)),
                          SizedBox(height: 10),
                         
                        ],
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
