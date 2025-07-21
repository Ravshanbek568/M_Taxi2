import 'package:flutter/material.dart';

class TaxiOrderScreen extends StatelessWidget {
  const TaxiOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage('https://example.com/user-avatar.jpg'),
              backgroundColor: Colors.grey[300],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLocationSection(),
            const SizedBox(height: 20),
            _buildDestinationInput(),
            const SizedBox(height: 20),
            _buildCarTypeSelection(),
            const SizedBox(height: 20),
            _buildPaymentMethodSelection(),
            const SizedBox(height: 30),
            _buildOrderButton(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildLocationSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.location_on, color: Colors.green),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Joriy joylashuv',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Toshkent shahri, Yunusobod tumani'),
                ],
              ),
            ),
            Icon(Icons.refresh, color: Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildDestinationInput() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Borish manzili',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                hintText: 'Manzilni kiriting',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                _buildAddressChip('Uy', 'Yunusobod 12-kvartal'),
                _buildAddressChip('Ish', 'Beruniy ko\'chasi'),
                _buildAddressChip('Do\'kon', 'Chorsu bozori'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressChip(String label, String address) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        // Manzilni avtomatik kiritish
      },
    );
  }

  Widget _buildCarTypeSelection() {
    final List<Map<String, dynamic>> carTypes = [
      {'type': 'Standart', 'price': '10,000', 'icon': Icons.directions_car},
      {'type': 'Komfort', 'price': '15,000', 'icon': Icons.airport_shuttle},
      {'type': 'Biznes', 'price': '20,000', 'icon': Icons.car_rental},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            'Taksi turi',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: carTypes.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final car = carTypes[index];
              return _buildCarTypeCard(
                car['type'] as String,
                car['price'] as String,
                car['icon'] as IconData,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCarTypeCard(String type, String price, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: 8),
            Text(type),
            const SizedBox(height: 4),
            Text('$price so\'m', style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSelection() {
    const methods = ['Naqd pul', 'Karta', 'Payme', 'Click'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            "To'lov usuli",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: methods.map((method) {
            return ChoiceChip(
              label: Text(method),
              selected: method == 'Naqd pul',
              onSelected: (_) {},
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildOrderButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          // Buyurtma qilish logikasi
        },
        child: const Text(
          'TAKSI CHAQIRISH',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(77), // withOpacity o'rniga withAlpha
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBottomNavItem(Icons.home, 'Bosh'),
          _buildBottomNavItem(Icons.history, 'Tarix'),
          _buildBottomNavItem(Icons.notifications, 'Bildirish'),
          _buildBottomNavItem(Icons.person, 'Profil'),
        ],
      ),
    );
    
  }

  Widget _buildBottomNavItem(IconData icon, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 24),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}