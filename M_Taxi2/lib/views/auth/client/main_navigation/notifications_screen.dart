import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirishnomalar'),
        automaticallyImplyLeading: false,
      ),
      body: ListView.builder(
        itemCount: 20,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: ListTile(
              leading: const Icon(Icons.notifications),
              title: Text('Bildirishnoma ${index + 1}'),
              subtitle: const Text('Bildirishnoma tafsilotlari...'),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {},
              ),
            ),
          );
        },
      ),
    );
  }
}