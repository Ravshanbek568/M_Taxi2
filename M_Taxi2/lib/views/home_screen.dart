import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asosiy menyu'), // AppBar sarlavhasi
      ),
      body: const Center(
        child: Text('Ilovaning asosiy qismi'), // Markaziy matn
      ),
    );
  }
}