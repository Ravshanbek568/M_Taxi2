import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:permission_handler/permission_handler.dart';

class TaxiOrderScreen extends StatefulWidget {
  const TaxiOrderScreen({super.key});

  @override
  State<TaxiOrderScreen> createState() => _TaxiOrderScreenState();
}

class _TaxiOrderScreenState extends State<TaxiOrderScreen> {
  // GPS holati
  Position? _currentPosition;
  bool _isLoadingLocation = false;
  String _locationError = '';

  // Tanlangan parametrlar
  String _selectedCarType = 'Standart';
  String _selectedPaymentMethod = 'Naqd pul';
  String _promoCode = '';
  String _destinationAddress = '';

  // Taksi turlari
  final List<Map<String, dynamic>> _carTypes = [
    {'type': 'Standart', 'price': '10,000 so\'m', 'waitTime': '3 min', 'icon': Icons.directions_car},
    {'type': 'Komfort', 'price': '15,000 so\'m', 'waitTime': '5 min', 'icon': Icons.airport_shuttle},
    {'type': 'Biznes', 'price': '20,000 so\'m', 'waitTime': '7 min', 'icon': Icons.car_rental},
    {'type': 'Mikroavtobus', 'price': '25,000 so\'m', 'waitTime': '10 min', 'icon': Icons.airport_shuttle},
  ];

  // To'lov usullari
  final List<String> _paymentMethods = [
    'Naqd pul',
    'Karta orqali',
    'Payme',
    'Click',
    'Uzum'
  ];

  // Sevimli manzillar
  final List<Map<String, dynamic>> _savedAddresses = [
    {'name': 'Uy', 'address': 'Yunusobod 12-kvartal'},
    {'name': 'Ish', 'address': 'Mirzo Ulug\'bek tumani'},
    {'name': 'Sevimli', 'address': 'Chorsu bozori'},
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // Joriy lokatsiyani olish
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = '';
    });

    try {
      // Ruxsatlarni tekshirish
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationError = 'GPS xizmati o\'chirilgan. Iltimos, yoqib qo\'ying.';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationError = 'Lokatsiya ruxsatlari rad etildi';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationError = 'Lokatsiya ruxsatlari doimiy ravishda rad etildi. Sozlamalardan yoqing';
        });
        return;
      }

      // Lokatsiyani olish
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
      });
    } catch (e) {
      setState(() {
        _locationError = 'Lokatsiyani aniqlashda xatolik: ${e.toString()}';
        _isLoadingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Taksi chaqirish'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // GPS Lokatsiya qismi
            _buildLocationSection(),
            const SizedBox(height: 20),
            
            // Manzil kiritish
            _buildAddressInput(),
            const SizedBox(height: 20),
            
            // Taksi turini tanlash
            _buildCarTypeSelection(),
            const SizedBox(height: 20),
            
            // To'lov usulini tanlash
            _buildPaymentMethodSelection(),
            const SizedBox(height: 20),
            
            // Promokod kiritish
            _buildPromoCodeInput(),
            const SizedBox(height: 30),
            
            // Buyurtma tugmasi
            _buildOrderButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Joriy joylashuv',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            
            if (_isLoadingLocation)
              const Center(child: CircularProgressIndicator()),
              
            if (_locationError.isNotEmpty)
              Text(
                _locationError,
                style: const TextStyle(color: Colors.red),
              ),
              
            if (_currentPosition != null)
              Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: _getCurrentLocation,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Lokatsiyani yangilash'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressInput() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Manzilni kiriting',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                hintText: 'Borish manzili',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _destinationAddress = value;
                });
              },
            ),
            const SizedBox(height: 10),
            const Text(
              'Sevimli manzillar',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _savedAddresses.map((address) {
                return ChoiceChip(
                  label: Text('${address['name']}: ${address['address']}'),
                  selected: false,
                  onSelected: (selected) {
                    setState(() {
                      _destinationAddress = address['address'];
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarTypeSelection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Taksi turini tanlang',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _carTypes.length,
              itemBuilder: (context, index) {
                final carType = _carTypes[index];
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedCarType == carType['type'] 
                        ? Theme.of(context).primaryColor 
                        : Colors.white,
                    foregroundColor: _selectedCarType == carType['type'] 
                        ? Colors.white 
                        : Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: Theme.of(context).primaryColor),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedCarType = carType['type'] as String;
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(carType['icon'] as IconData, size: 20),
                      const SizedBox(width: 8),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(carType['type'] as String),
                          Text(
                            '${carType['price']} • ${carType['waitTime']}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSelection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'To\'lov usulini tanlang',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _paymentMethods.map((method) {
                return ChoiceChip(
                  label: Text(method),
                  selected: _selectedPaymentMethod == method,
                  onSelected: (selected) {
                    setState(() {
                      _selectedPaymentMethod = method;
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoCodeInput() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Promokod (ixtiyoriy)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                hintText: 'Promokodni kiriting',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.discount),
                  onPressed: () {
                    // Promokodni tekshirish logikasi
                  },
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _promoCode = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          if (_currentPosition == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Iltimos, lokatsiyangizni aniqlang')),
            );
            return;
          }
          
          if (_destinationAddress.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Iltimos, manzilni kiriting')),
            );
            return;
          }
          
          // Buyurtma qilish logikasi
          _placeOrder();
        },
        child: const Text(
          'TAKSI CHAQIRISH',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _placeOrder() {
    // Bu yerda buyurtma serverga yuboriladi
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buyurtma qabul qilindi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 16),
            Text('Taksi turi: $_selectedCarType'),
            Text('To\'lov usuli: $_selectedPaymentMethod'),
            if (_promoCode.isNotEmpty) Text('Promokod: $_promoCode'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}