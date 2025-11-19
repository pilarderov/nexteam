import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nexteam/login_page.dart';
import 'package:nexteam/home_page.dart'; // Pastikan import HomePage ada

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- BAGIAN INI YANG PENTING ---
  await Supabase.initialize(
    url: 'https://oppezrfofblpmlchjtou.supabase.co', // <--- Ganti dengan Project URL kamu
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9wcGV6cmZvZmJscG1sY2hqdG91Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM1MzA2MzcsImV4cCI6MjA3OTEwNjYzN30.XMofrLTVZVOImnxZ8RxAdoI7TFau9uowL7bTz4JDpa4', // <--- Ganti dengan Anon Key kamu
  );
  // -------------------------------

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nexteam',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      // Logic: Cek apakah user sudah login saat aplikasi dibuka
      home: Supabase.instance.client.auth.currentUser != null
          ? const HomePage() 
          : const LoginPage(),
    );
  }
}