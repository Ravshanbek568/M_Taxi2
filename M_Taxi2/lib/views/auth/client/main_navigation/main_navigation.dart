import 'package:flutter/material.dart';
import 'package:m_taksi/views/auth/client/main_navigation/favorites_screen.dart';
import 'package:m_taksi/views/auth/client/main_navigation/messages_screen.dart';
import 'package:m_taksi/views/auth/client/main_navigation/notifications_screen.dart';
import 'package:m_taksi/views/auth/client/main_navigation/search_screen.dart';
import 'package:m_taksi/views/auth/client/client_home_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final Color _selectedColor = Colors.blue;
  final Color _unselectedColor = Colors.grey[700]!;

  final List<Widget> _screens = [
    const ClientHomeScreen(), // Asosiy sahifa
    const SearchScreen(),     // Qidiruv
    const MessagesScreen(),   // Xabarlar
    const NotificationsScreen(), // Bildirishnomalar
    const FavoritesScreen(),  // Tanlanganlar
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 25).withAlpha(25),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          selectedItemColor: _selectedColor,
          unselectedItemColor: _unselectedColor,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          elevation: 10,
          iconSize: 28,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Asosiy'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Qidiruv'),
            BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Xabarlar'),
            BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Bildirishnomalar'),
            BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Tanlanganlar'),
          ],
        ),
      ),
    );
  }
}