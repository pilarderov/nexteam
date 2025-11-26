import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nexteam/home_page.dart';
import 'package:nexteam/agenda_page.dart';
import 'package:nexteam/pengumuman_page.dart';
import 'package:nexteam/profil_page.dart';

// Model Data Anggota (Update ada factory fromMap)
class Member {
  final int? id; // ID dari database (opsional untuk insert)
  final String initial;
  final String name;
  final String role;
  final String nim;

  Member({
    this.id,
    required this.initial,
    required this.name,
    required this.role,
    required this.nim,
  });

  // Helper untuk mengubah data JSON Supabase ke Object Member
  factory Member.fromMap(Map<String, dynamic> map) {
    String name = map['name'] ?? 'Unknown';
    // Ambil huruf depan untuk inisial
    String initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    
    return Member(
      id: map['id'],
      initial: initial,
      name: name,
      role: map['role'] ?? '-',
      nim: map['nim'] ?? '-',
    );
  }
}

class AnggotaPage extends StatefulWidget {
  const AnggotaPage({super.key});

  @override
  State<AnggotaPage> createState() => _AnggotaPageState();
}

class _AnggotaPageState extends State<AnggotaPage> {
  final TextEditingController _searchController = TextEditingController();
  
  // Stream untuk mengambil data real-time dari Supabase
  final _membersStream = Supabase.instance.client
      .from('members')
      .stream(primaryKey: ['id'])
      .order('name', ascending: true);

  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- LOGIC NAVIGATION ---
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
        // page = const ProfilPage(); // Pastikan import sesuai
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

  // --- FUNGSI BARU: INSERT KE SUPABASE ---
  Future<void> _addMemberToSupabase(String name, String role, String nim) async {
    try {
      await Supabase.instance.client.from('members').insert({
        'name': name,
        'role': role,
        'nim': nim,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Anggota berhasil ditambahkan!')),
        );
        Navigator.pop(context); // Tutup dialog
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambah anggota: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- DIALOG UI ---
  void _showAddMemberDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController roleController = TextEditingController();
    final TextEditingController nimController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder( // Pakai StatefulBuilder agar tombol bisa loading
          builder: (context, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                constraints: const BoxConstraints(maxHeight: 500),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Input Nama
                      _buildInputDecorated(
                        icon: Icons.edit,
                        hintText: "Masukkan Nama...",
                        controller: nameController,
                      ),
                      const SizedBox(height: 15),
                      // Input Jabatan
                      _buildInputDecorated(
                        icon: Icons.person_outline,
                        hintText: "Isi Jabatan...",
                        controller: roleController,
                      ),
                      const SizedBox(height: 15),
                      // Input NIM
                      _buildInputDecorated(
                        icon: Icons.numbers,
                        hintText: "Isi NIM...",
                        controller: nimController,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 25),

                      // Tombol DONE
                      SizedBox(
                        width: 150,
                        child: ElevatedButton(
                          onPressed: isLoading 
                            ? null 
                            : () async {
                              if (nameController.text.isNotEmpty && 
                                  roleController.text.isNotEmpty && 
                                  nimController.text.isNotEmpty) {
                                
                                setStateDialog(() => isLoading = true);
                                
                                // Panggil fungsi simpan ke Supabase
                                await _addMemberToSupabase(
                                  nameController.text, 
                                  roleController.text, 
                                  nimController.text
                                );

                                // (Dialog ditutup di dalam fungsi _addMemberToSupabase jika sukses)
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Semua data wajib diisi")),
                                );
                              }
                            },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF89CFF0),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 0,
                          ),
                          child: isLoading 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator())
                            : const Text(
                              "DONE",
                              style: TextStyle(
                                color: Colors.blue,
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
          }
        );
      },
    );
  }

  // Helper Widget Input (Sama seperti sebelumnya)
  Widget _buildInputDecorated({
    required IconData icon, 
    required String hintText, 
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF89CFF0),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.blue[800], size: 24),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFF89CFF0), width: 2),
              ),
            ),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      body: Stack(
        children: [
          _buildHeader(),
          
          // LISTVIEW DIGANTI DENGAN STREAMBUILDER
          Padding(
            padding: const EdgeInsets.only(top: 170.0),
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _membersStream,
              builder: (context, snapshot) {
                // 1. Loading State
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                // 2. Data Kosong
                final rawData = snapshot.data!;
                if (rawData.isEmpty) {
                  return const Center(child: Text("Belum ada anggota."));
                }

                // 3. Filter Data (Search Logic)
                final members = rawData.map((data) => Member.fromMap(data)).where((member) {
                  return member.name.toLowerCase().contains(_searchQuery);
                }).toList();

                if (members.isEmpty) {
                  return const Center(child: Text("Tidak ditemukan."));
                }

                // 4. Tampilkan List
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    return _buildMemberCard(members[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMemberDialog(context),
        backgroundColor: const Color(0xFF0D99FF),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
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
          Expanded( // Pakai Expanded biar teks panjang tidak overflow
            child: Column(
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
          ),
        ],
      ),
    );
  }
}