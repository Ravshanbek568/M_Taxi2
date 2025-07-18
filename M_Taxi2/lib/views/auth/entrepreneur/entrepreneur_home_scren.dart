// lib/views/home/entrepreneur_home_screen.dart
import 'package:flutter/material.dart';

class EntrepreneurHomeScreen extends StatelessWidget {
  const EntrepreneurHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Asosiy menyu')),
      body: const Center(child: Text('Xush kelibsiz!')),
    );
  }
}