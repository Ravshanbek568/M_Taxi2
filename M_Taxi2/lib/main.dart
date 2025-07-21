import 'package:flutter/material.dart';
import 'package:m_taksi/core/theme/colors.dart';
import 'package:m_taksi/views/auth/entrepreneur/entrepreneur_business_type_screen.dart';
import 'package:m_taksi/views/auth/entrepreneur/entrepreneur_car_info_screen.dart';
// import 'package:m_taksi/views/auth/entrepreneur/entrepreneur_home_screen.dart';
import 'package:m_taksi/views/auth/entrepreneur/entrepreneur_phone_screen.dart';
import 'package:m_taksi/views/auth/entrepreneur/entrepreneur_profile_screen.dart';
import 'package:m_taksi/views/auth/entrepreneur/entrepreneur_terms_screen.dart';
import 'package:m_taksi/views/auth/entrepreneur/entrepreneur_verify_screen.dart';
import 'package:m_taksi/views/auth/entrepreneur/payment_card_registration_screen.dart';
// import 'package:m_taksi/views/auth/entrepreneur/role_selection_screen.dart';
import 'package:m_taksi/views/home_screen.dart';
import 'package:m_taksi/views/onboarding_screen.dart';
import 'package:m_taksi/views/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'M-Taxi Ilovasi',
      theme: ThemeData(
        primaryColor: AppColors.primaryColor,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: AppColors.secondaryColor,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(),
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        // '/role-selection': (context) => const RoleSelectionScreen(),
        '/entrepreneur-phone': (context) => const EntrepreneurPhoneScreen(),
        '/entrepreneur-verify': (context) => const EntrepreneurVerifyScreen(),
        '/entrepreneur-profile': (context) => const EntrepreneurProfileScreen(),
        '/business-type': (context) => const EntrepreneurBusinessTypeScreen(),
        '/car-info': (context) => const EntrepreneurCarInfoScreen(),
        '/payment-card': (context) => const PaymentCardRegistrationScreen(),
        '/terms': (context) => const EntrepreneurTermsScreen(),
        '/home': (context) => const HomeScreen(),
        // '/entrepreneur-home': (context) => const EntrepreneurHomeScreen(),
      },
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => Scaffold(
          body: Center(
            child: Text('Sahifa topilmadi: ${settings.name}'),
          ),
        ),
      ),
    );
  }
}