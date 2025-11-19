import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nexteam/home_page.dart';
import 'package:nexteam/signup_page.dart';
import 'package:nexteam/services/supabase_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // 1. Controller untuk mengambil text dari inputan
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // 2. Panggil Service Supabase
  final _supabaseService = SupabaseService(); 
  
  bool _isLoading = false;

  // 3. Fungsi Login dengan Validasi Lengkap
  Future<void> _login() async {
    // Cek apakah kolom kosong
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email dan Password harus diisi!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Mulai Loading
    setState(() => _isLoading = true);
    
    try {
      // Panggil fungsi signIn dari Service
      await _supabaseService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Jika sukses, pindah ke Home
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } on AuthException catch (e) {
      // Menangkap Error dari Supabase
      if (mounted) {
        String pesanError = e.message;

        // Custom pesan jika akun tidak ditemukan / password salah
        if (e.message.contains('Invalid login credentials')) {
          pesanError = 'Akun tidak ditemukan atau password salah.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(pesanError), 
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            // Tombol pintas ke Sign Up jika error muncul
            action: SnackBarAction(
              label: 'DAFTAR SEKARANG',
              textColor: Colors.yellow,
              onPressed: () => _goToSignUp(),
            ),
          ),
        );
      }
    } catch (e) {
      // Error umum (koneksi, dll)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Terjadi kesalahan koneksi'), backgroundColor: Colors.red),
        );
      }
    } finally {
      // Stop Loading
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Fungsi pindah ke Sign Up
  void _goToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignUpPage()),
    );
  }

  // Helper UI: Background
  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF007BFF), Color(0xFF002F63)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  // Helper UI: Text Field (Sudah ditambah parameter controller)
  Widget _buildTextField({
    required String hint, 
    required TextEditingController controller, // Wajib ada controller
    bool obscureText = false
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: controller, // Pasang controller disini
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          _buildBackground(),

          // Konten Utama
          Center(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Welcome To Nexteam',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    // Input Email (Terhubung ke _emailController)
                    _buildTextField(
                      hint: 'Email', 
                      controller: _emailController
                    ),
                    
                    const SizedBox(height: 15),
                    
                    // Input Password (Terhubung ke _passwordController)
                    _buildTextField(
                      hint: 'Password', 
                      obscureText: true, 
                      controller: _passwordController
                    ),
                    
                    const SizedBox(height: 15),
                    
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.blue[700]),
                      ),
                    ),
                    
                    const SizedBox(height: 25),
                    
                    // Tombol Login
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        // Jika loading, tombol dimatikan (null)
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        // Logic Tampilan Tombol: Loading vs Teks
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white, 
                                  strokeWidth: 2
                                ),
                              )
                            : const Text(
                                'Login',
                                style: TextStyle(color: Colors.white, fontSize: 18),
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Link ke Sign Up
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have account? "),
                        GestureDetector(
                          onTap: () => _goToSignUp(),
                          child: Text(
                            'Signup',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}