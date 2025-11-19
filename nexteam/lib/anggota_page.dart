import 'package:flutter/material.dart';
import 'package:nexteam/home_page.dart';
import 'package:nexteam/agenda_page.dart';
import 'package:nexteam/pengumuman_page.dart';
import 'package:nexteam/profil_page.dart';

class Member {
  final String initial;
  final String name;
  final String role;
  final String nim;
  Member({required this.initial, required this.name, required this.role, required this.nim});
}

class AnggotaPage extends StatefulWidget {
  const AnggotaPage({super.key});

  @override
  State<AnggotaPage> createState() => _AnggotaPageState();
}

class _AnggotaPageState extends State<AnggotaPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<Member> _allMembers = [
    Member(initial: 'A', name: 'Ahmad', role: 'Ketua BEM', nim: '12345678'),
    Member(initial: 'B', name: 'Baim', role: 'Wakil Ketua BEM', nim: '12345678'),
    Member(initial: 'C', name: 'Caca', role: 'Sekretaris', nim: '12345678'),
    Member(initial: 'D', name: 'Donny', role: 'Bendahara', nim: '12345678'),
    Member(initial: 'E', name: 'Ehsan', role: 'Humas', nim: '12345678'),
    Member(initial: 'F', name: 'Fajar', role: 'Kadep PSDM', nim: '12345678'),
    Member(initial: 'G', name: 'Gita', role: 'Kadep Medkom', nim: '12345678'),
  ];
  List<Member> _filteredMembers = [];

  @override
  void initState() {
    super.initState();
    _filteredMembers = _allMembers;
    _searchController.addListener(_filterMembers);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterMembers);
    _searchController.dispose();
    super.dispose();
  }

  void _filterMembers() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredMembers = _allMembers;
      } else {
        _filteredMembers = _allMembers
            .where((member) => member.name.toLowerCase().contains(query))
            .toList();
      }
    });
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
        return; 
      case 3:
        page = const PengumumanPage(); 
        break;
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
          Padding(
            padding: const EdgeInsets.only(top: 170.0),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: _filteredMembers.length,
              itemBuilder: (context, index) {
                return _buildMemberCard(_filteredMembers[index]);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 2, 
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

  // --- KODE LENGKAP BUILDER ANGGOTA ---
  
  Widget _buildHeader() {
    return Container(
      height: 200, 
      padding: const EdgeInsets.only(left: 25, right: 25, top: 60),
      decoration: const BoxDecoration(
        color: Color(0xFF0D99FF),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Anggota',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari anggota...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(Member member) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFF0D99FF),
            child: Text(
              member.initial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                member.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                member.role,
                style: const TextStyle(
                  color: Color(0xFF0D99FF),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'NIM: ${member.nim}',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}