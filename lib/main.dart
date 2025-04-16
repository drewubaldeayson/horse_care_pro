import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:horse_care_pro/providers/health_record_provider.dart';
import 'package:horse_care_pro/providers/training_record_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import providers
import 'providers/horse_auth_provider.dart';
import 'providers/horse_provider.dart';

import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        // Providers
        ChangeNotifierProvider(create: (context) => HorseAuthProvider()),
        ChangeNotifierProvider(create: (context) => HorseProvider()),
        ChangeNotifierProvider<HealthRecordProvider>(
          create: (context) => HealthRecordProvider(),
          lazy: true,
        ),
        ChangeNotifierProvider<TrainingRecordProvider>(
          create: (context) => TrainingRecordProvider(),
          lazy: true,
        ),
      ],
      child: HorseCareProApp(),
    ),
  );
}

class HorseCareProApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Horse Care Pro',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<HorseAuthProvider>(context);

    return authProvider.user != null ? HomeScreen() : LoginScreen();
  }
}
