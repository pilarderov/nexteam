import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nexteam/home_page.dart';
import 'package:nexteam/agenda_page.dart';
import 'package:nexteam/anggota_page.dart';
import 'package:nexteam/profil_page.dart';

// 1. Model Data Pengumuman
class Announcement {
  final int? id;
  final String title;
  final String content;
  final String tag;
  final DateTime createdAt;

  Announcement({
    this.id,
    required this.title,
    required this.content,
    required this.tag,
    required this.createdAt,
  });

  // Factory dari JSON Supabase
  factory Announcement.fromMap(Map<String, dynamic> map) {
    return Announcement(
      id: map['id'],
      title: map['title'] ?? 'Tanpa Judul',
      content: map['content'] ?? '',
      tag: map['tag'] ?? 'Info',
      // Mengubah String ISO8601 dari Supabase ke DateTime
      createdAt: DateTime.parse(map['created_at']).toLocal(), 
    );
  }

  // Helper untuk menentukan warna Tag berdasarkan teks
  Color get tagColor {
    switch (tag) {
      case 'Penting': return Colors.red;
      case 'Update': return Colors.orange;
      case 'Info': return Colors.blue;
      default: return Colors.grey;
    }
  }

  // Helper untuk menghitung "Waktu Lalu" (Time Ago)
  String get timeAgo {
    final Duration diff = DateTime.now().difference(createdAt);
    if (diff.inDays > 0) return '${diff.inDays} hari lalu';
    if (diff.inHours > 0) return '${diff.inHours} jam lalu';
    if (diff.inMinutes > 0) return '${diff.inMinutes} menit lalu';
    return 'Baru saja';
  }
}

class PengumumanPage extends StatefulWidget {
  const PengumumanPage({super.key});

  @override
  State<PengumumanPage> createState() => _PengumumanPageState();
}

class _PengumumanPageState extends State<PengumumanPage> {
  
  // Stream data realtime dari tabel 'announcements'
  // Diurutkan berdasarkan created_at descending (terbaru di atas)
  final _announcementStream = Supabase.instance.client
      .from('announcements')
      .stream(primaryKey: ['id'])
      .order('created_at', ascending: false);

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
        page = const ProfilPage(); // Pastikan import sesuai
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

  // --- FUNGSI INSERT KE SUPABASE ---
  Future<void> _addAnnouncementToSupabase(String title, String content, String tag) async {
    try {
      await Supabase.instance.client.from('announcements').insert({
        'title': title,
        'content': content,
        'tag': tag,
        // created_at otomatis diisi oleh Supabase
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pengumuman berhasil diposting!')),
        );
        Navigator.pop(context); // Tutup dialog
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memposting: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- DIALOG UI ---
  void _showAddAnnouncementDialog(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController contentController = TextEditingController();
    
    // Variabel state untuk Dropdown Tag
    String selectedTag = 'Info';
    final List<String> tagOptions = ['Info', 'Penting', 'Update'];
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder( // Agar dropdown bisa berubah state-nya
          builder: (context, setStateDialog) {
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
                      // Input Judul
                      _buildInputDecorated(
                        icon: Icons.title,
                        child: TextField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            hintText: "Judul pengumuman...",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      
                      // Dropdown Tag (Penting/Info/Update)
                      _buildInputDecorated(
                        icon: Icons.label,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedTag,
                            isExpanded: true,
                            items: tagOptions.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setStateDialog(() => selectedTag = newValue!);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Input Isi
                      _buildInputDecorated(
                        icon: Icons.description,
                        child: TextField(
                          controller: contentController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            hintText: "Isi Pengumuman...",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Tombol DONE
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : () async {
                            if (titleController.text.isNotEmpty && contentController.text.isNotEmpty) {
                              setStateDialog(() => isLoading = true);
                              
                              await _addAnnouncementToSupabase(
                                titleController.text,
                                contentController.text,
                                selectedTag,
                              );
                              // Dialog ditutup di dalam fungsi insert jika sukses
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF89CFF0), // Biru muda
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                              : const Text(
                                  "POST",
                                  style: TextStyle(
                                    color: Colors.white, 
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

  // Helper Desain Input
  Widget _buildInputDecorated({required IconData icon, required Widget child}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFF89CFF0), width: 2),
              ),
            ),
            child: child,
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
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 180), // Ruang untuk header biru
                
                // STREAM BUILDER
                Expanded(
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _announcementStream,
                    builder: (context, snapshot) {
                      // 1. Loading
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final data = snapshot.data!;
                      
                      // 2. Kosong
                      if (data.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.notifications_off, size: 60, color: Colors.grey),
                              SizedBox(height: 10),
                              Text("Belum ada pengumuman.", style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        );
                      }

                      // 3. Ada Data
                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          // Konversi JSON ke Object
                          final item = Announcement.fromMap(data[index]);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 15.0),
                            child: _buildAnnouncementCard(item),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAnnouncementDialog(context),
        backgroundColor: const Color(0xFF0D99FF),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 180, 
      width: double.infinity,
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

  Widget _buildAnnouncementCard(Announcement item) {
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
              // Mengambil warna dari getter di model
              _buildTag(item.tag, item.tagColor),
              Row(
                children: [
                  Icon(Icons.access_time, color: Colors.grey[400], size: 16),
                  const SizedBox(width: 4),
                  // Menggunakan getter timeAgo
                  Text(
                    item.timeAgo,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            item.content,
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

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 3, 
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