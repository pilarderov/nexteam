import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nexteam/login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    // Timer untuk pindah halaman setelah 3 detik
    Timer(
      const Duration(seconds: 3),
      () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Gradient background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF007BFF), Color(0xFF002F63)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Placeholder untuk Logo
              const Icon(
                Icons.groups, // Ganti dengan logo Anda
                size: 100,
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              // Teks "NEXTEAM"
              const Text(
                'NEXTEAM',
                style: TextStyle(
                  fontFamily: 'Serif', // Menggunakan font Serif
                  fontSize: 40,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}