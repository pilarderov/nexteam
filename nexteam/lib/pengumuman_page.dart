import 'package:flutter/material.dart';
import 'package:nexteam/home_page.dart';
import 'package:nexteam/agenda_page.dart';
import 'package:nexteam/anggota_page.dart';
import 'package:nexteam/profil_page.dart';

class PengumumanPage extends StatelessWidget {
  const PengumumanPage({super.key});

  // --- FUNGSI NAVIGASI LENGKAP ---
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
        return; // Sudah di halaman ini
      case 4:
        page = const ProfilPage();
        break;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      body: Stack(
        children: [
          _buildHeader(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 100, left: 20, right: 20, bottom: 20),
              child: Column(
                children: [
                  _buildAnnouncementCard(
                    title: 'Pendaftaran Anggota Baru Dibuka!',
                    content: 'Kami membuka kesempatan bagi mahasiswa baru untuk bergabung dengan BEM.\nPendaftaran dibuka mulai 5–15 Oktober 2025.',
                    tag: 'Penting',
                    tagColor: Colors.red,
                    time: '2 jam lalu',
                  ),
                  const SizedBox(height: 15),
                  _buildAnnouncementCard(
                    title: 'Perubahan Jadwal Rapat Umum',
                    content: 'Rapat umum yang dijadwalkan pada tanggal 8 Oktober dipindahkan ke tanggal 10 Oktober 2025 pukul 14.00 WIB.',
                    tag: 'Update',
                    tagColor: Colors.orange,
                    time: '5 jam lalu',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  // WIDGET BUILDER UNTUK HEADER
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
            'Pengumuman',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Informasi terbaru',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET BUILDER UNTUK KARTU PENGUMUMAN
  Widget _buildAnnouncementCard({
    required String title,
    required String content,
    required String tag,
    required Color tagColor,
    required String time,
  }) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTag(tag, tagColor),
              Row(
                children: [
                  Icon(Icons.access_time, color: Colors.grey[400], size: 16),
                  const SizedBox(width: 4),
                  Text(
                    time,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Baca Selengkapnya',
            style: TextStyle(
              color: Colors.blue[700],
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET BUILDER UNTUK TAG
  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // WIDGET BUILDER UNTUK BOTTOM NAVIGATION BAR
  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 3, // 3 = Pengumuman
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