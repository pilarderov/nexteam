import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nexteam/home_page.dart';
import 'package:nexteam/agenda_page.dart';
import 'package:nexteam/anggota_page.dart';
import 'package:nexteam/pengumuman_page.dart';
import 'package:nexteam/login_page.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  // Data Profil (State) - Default Value sebelum data dimuat
  String _name = 'Loading...'; 
  String _role = '-';
  String _email = '-';
  String _phone = '-';
  String _nim = '-';
  bool _isLoading = true;

  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _getProfile();
  }

  // --- 1. AMBIL DATA PROFIL DARI SUPABASE ---
  Future<void> _getProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      setState(() => _email = user.email ?? '-');

      // Ambil data dari tabel 'profiles'
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle(); // maybeSingle mengembalikan null jika data belum ada

      if (data != null) {
        setState(() {
          _name = data['full_name'] ?? 'User';
          _role = data['role'] ?? '-';
          _phone = data['phone'] ?? '-';
          _nim = data['nim'] ?? '-';
        });
      } else {
        // Jika belum ada di tabel profiles, ambil dari metadata saat Sign Up
        setState(() {
          _name = user.userMetadata?['username'] ?? 'User Baru';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat profil: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- 2. UPDATE PROFIL KE SUPABASE ---
  Future<void> _updateProfile({
    required String fullName,
    required String phone,
    required String nim,
    required String role,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      // Upsert: Update jika ID ada, Insert jika tidak ada
      await _supabase.from('profiles').upsert({
        'id': user.id, // Kunci utama (Wajib sama dengan Auth ID)
        'full_name': fullName,
        'phone': phone,
        'nim': nim,
        'role': role,
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Update State Lokal agar tampilan langsung berubah
      setState(() {
        _name = fullName;
        _phone = phone;
        _nim = nim;
        _role = role;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui!')),
        );
        Navigator.pop(context); // Tutup Dialog
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal update: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- 3. LOGOUT DARI SUPABASE ---
  Future<void> _logOut(BuildContext context) async {
    await _supabase.auth.signOut();
    
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  void _onNavTapped(BuildContext context, int index) {
    Widget page;
    switch (index) {
      case 0:
        page = const HomePage();
        break;
      case 1:
        page = const AgendaPage();
        break;
      case 2:
        page = const AnggotaPage();
        break;
      case 3:
        page = const PengumumanPage();
        break;
      case 4:
        return; 
      default:
        return;
    }
    
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  // --- DIALOG EDIT PROFIL ---
  void _showEditProfileDialog(BuildContext context) {
    // Controller diisi data saat ini
    final nameController = TextEditingController(text: _name);
    final phoneController = TextEditingController(text: _phone);
    final nimController = TextEditingController(text: _nim);
    final roleController = TextEditingController(text: _role);
    
    // Email biasanya tidak diedit sembarangan di profil biasa karena terkait Login, 
    // jadi kita buat Read Only atau tidak ditampilkan di form edit.

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Edit Profil", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 20),

                  // Input Nama (Saya tambahkan ini agar user bisa ganti nama)
                  _buildGreyInput(
                    icon: Icons.person,
                    label: "Nama Lengkap",
                    controller: nameController,
                    hint: "Nama Anda...",
                  ),
                  const SizedBox(height: 15),

                  // Input Telepon
                  _buildGreyInput(
                    icon: Icons.phone_outlined,
                    label: "Telepon",
                    controller: phoneController,
                    hint: "08xxx...",
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 15),

                  // Input NIM
                  _buildGreyInput(
                    icon: Icons.numbers,
                    label: "NIM",
                    controller: nimController,
                    hint: "NIM Anda...",
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 15),

                  // Input Jabatan
                  _buildGreyInput(
                    icon: Icons.work_outline,
                    label: "Jabatan",
                    controller: roleController,
                    hint: "Ketua/Anggota...",
                  ),
                  const SizedBox(height: 25),

                  // Tombol DONE
                  SizedBox(
                    width: 150,
                    child: ElevatedButton(
                      onPressed: () {
                         _updateProfile(
                           fullName: nameController.text,
                           phone: phoneController.text,
                           nim: nimController.text,
                           role: roleController.text,
                         );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF89CFF0),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "DONE",
                        style: TextStyle(
                          color: Color(0xFF0D99FF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper Widget
  Widget _buildGreyInput({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0D99FF), size: 28),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                SizedBox(
                  height: 24,
                  child: TextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.only(bottom: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : Stack(
          children: [
            _buildHeader(),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 100, left: 20, right: 20, bottom: 20),
                child: Column(
                  children: [
                    _buildProfileHeaderCard(),
                    const SizedBox(height: 20),
                    
                    // Email Read Only (Ambil langsung dari Auth)
                    _buildInfoCard(
                      icon: Icons.email_outlined,
                      title: 'Email (Tidak dapat diedit)',
                      value: _email, 
                    ),
                    const SizedBox(height: 15),
                    _buildInfoCard(
                      icon: Icons.phone_outlined,
                      title: 'Telepon',
                      value: _phone,
                    ),
                    const SizedBox(height: 15),
                    _buildInfoCard(
                      icon: Icons.tag,
                      title: 'NIM',
                      value: _nim,
                    ),
                    const SizedBox(height: 15),
                    _buildInfoCard(
                      icon: Icons.work_outline,
                      title: 'Jabatan',
                      value: _role,
                    ),
                    const SizedBox(height: 30),
                    
                    _buildEditButton(context),
                    const SizedBox(height: 15),
                    _buildLogoutButton(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 180, 
      padding: const EdgeInsets.only(left: 25, right: 25, top: 60),
      decoration: const BoxDecoration(
        color: Color(0xFF0D99FF),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profil Saya',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: const Color(0xFF0D99FF),
            child: Text(
              _name.isNotEmpty ? _name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            _name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _role,
            style: const TextStyle(
              color: Color(0xFF0D99FF),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'BEM Fakultas Teknik',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 28),
          const SizedBox(width: 15),
          Expanded( // Tambahkan Expanded biar teks panjang tidak overflow
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showEditProfileDialog(context),
        icon: const Icon(Icons.edit, color: Colors.white, size: 20),
        label: const Text(
          'Edit Profil',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0D99FF),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
        ),
      ),
    );
  }
  
  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _logOut(context),
        icon: const Icon(Icons.logout, color: Colors.red, size: 20),
        label: const Text(
          'Log Out',
          style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          side: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }
  
  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 4, 
      onTap: (index) => _onNavTapped(context, index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF0D99FF),
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Agenda'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Anggota'),
        BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Pengumuman'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
      ],
    );
  }
}