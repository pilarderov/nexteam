import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nexteam/home_page.dart';
import 'package:nexteam/anggota_page.dart';
import 'package:nexteam/pengumuman_page.dart';
import 'package:nexteam/profil_page.dart';

// 1. Model Data Agenda (Updated with Supabase Factory)
class AgendaItem {
  final int? id;
  final String title;
  final String description;
  final DateTime date;
  final TimeOfDay startTime;
  final bool isAllDay;

  AgendaItem({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.startTime,
    required this.isAllDay,
  });

  // Factory untuk mengubah JSON Supabase menjadi Object Flutter
  factory AgendaItem.fromMap(Map<String, dynamic> map) {
    // Parsing Waktu (Format Supabase "HH:MM:SS" ke TimeOfDay)
    TimeOfDay parseTime(String timeStr) {
      final parts = timeStr.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    return AgendaItem(
      id: map['id'],
      title: map['title'] ?? 'Tanpa Judul',
      description: map['description'] ?? '',
      // Parsing Tanggal (Format "YYYY-MM-DD")
      date: DateTime.parse(map['date']),
      startTime: parseTime(map['start_time'] ?? '00:00:00'),
      isAllDay: map['is_all_day'] ?? false,
    );
  }
}

class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  // Stream untuk mengambil data real-time dari tabel 'agendas'
  final _agendaStream = Supabase.instance.client
      .from('agendas')
      .stream(primaryKey: ['id'])
      .order('date', ascending: true); // Urutkan berdasarkan tanggal terdekat

  // Navigasi Bottom Bar
  void _onNavTapped(BuildContext context, int index) {
    Widget page;
    switch (index) {
      case 0:
        page = const HomePage();
        break;
      case 1:
        return; // Sudah di halaman ini
      case 2:
        page = const AnggotaPage();
        break;
      case 3:
        page = const PengumumanPage();
        break;
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
  Future<void> _addAgendaToSupabase({
    required String title,
    required String description,
    required DateTime date,
    required bool isAllDay,
    required TimeOfDay time,
  }) async {
    try {
      // Format TimeOfDay ke String "HH:MM:00" untuk Supabase
      final String formattedTime = 
          "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00";
      
      // Format DateTime ke String "YYYY-MM-DD"
      final String formattedDate = date.toIso8601String().split('T')[0];

      await Supabase.instance.client.from('agendas').insert({
        'title': title,
        'description': description,
        'date': formattedDate,
        'start_time': formattedTime,
        'is_all_day': isAllDay,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Agenda berhasil disimpan!')),
        );
        Navigator.pop(context); // Tutup dialog setelah sukses
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- DIALOG TAMBAH AGENDA ---
  void _showAddAgendaDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descController = TextEditingController();
    
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = const TimeOfDay(hour: 17, minute: 0); // Default jam 5 sore
    bool isAllDay = false;
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                constraints: const BoxConstraints(maxHeight: 650),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Input Judul
                      _buildInputDecorated(
                        icon: Icons.calendar_today,
                        child: TextField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            hintText: 'Masukkan judul kegiatan...',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      
                      // Input Keterangan
                      _buildInputDecorated(
                        icon: Icons.description,
                        child: TextField(
                          controller: descController,
                          decoration: const InputDecoration(
                            hintText: 'Keterangan...',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Toggle All-day
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.access_time, color: Colors.grey, size: 20),
                              SizedBox(width: 8),
                              Text("All-day", style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Switch(
                            value: isAllDay,
                            activeColor: const Color(0xFF0D99FF),
                            onChanged: (val) {
                              setStateDialog(() => isAllDay = val);
                            },
                          ),
                        ],
                      ),
                      
                      const Divider(),

                      // Tampilan Tanggal & Waktu
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                             Text(
                              "${selectedDate.day}-${selectedDate.month}-${selectedDate.year}", 
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            // Widget Pemilih Jam Sederhana (Klik untuk ubah)
                            InkWell(
                              onTap: () async {
                                final TimeOfDay? picked = await showTimePicker(
                                  context: context,
                                  initialTime: selectedTime,
                                );
                                if (picked != null) {
                                  setStateDialog(() => selectedTime = picked);
                                }
                              },
                              child: Text(
                                "${selectedTime.format(context)}", // Menampilkan jam yang dipilih
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Kalender
                      SizedBox(
                        height: 300,
                        width: 300,
                        child: CalendarDatePicker(
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                          onDateChanged: (newDate) {
                            setStateDialog(() => selectedDate = newDate);
                          },
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Tombol DONE (Simpan ke DB)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : () async {
                            if (titleController.text.isNotEmpty) {
                              setStateDialog(() => isLoading = true);
                              
                              await _addAgendaToSupabase(
                                title: titleController.text,
                                description: descController.text.isEmpty ? "-" : descController.text,
                                date: selectedDate,
                                isAllDay: isAllDay,
                                time: selectedTime,
                              );
                              
                              // Dialog ditutup otomatis di dalam fungsi _addAgendaToSupabase jika sukses
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF89CFF0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: isLoading 
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white)) 
                              : const Text(
                                  "DONE",
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
      },
    );
  }

  // Helper Widget Input
  Widget _buildInputDecorated({required IconData icon, required Widget child}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF89CFF0),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.blue[900], size: 24),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.blue, width: 1)),
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
                const SizedBox(height: 180), 
                
                // KARTU TANGGAL (Statis, bisa dibuat dinamis kalau mau)
                _buildDateCard(),
                const SizedBox(height: 20),

                // STREAMBUILDER UNTUK DATA REALTIME
                Expanded(
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _agendaStream,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      final agendas = snapshot.data!;
                      
                      if (agendas.isEmpty) {
                        return const Center(child: Text("Belum ada agenda kegiatan."));
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.only(bottom: 100),
                        itemCount: agendas.length,
                        itemBuilder: (context, index) {
                          // Convert JSON ke Object AgendaItem
                          final item = AgendaItem.fromMap(agendas[index]);
                          return _buildEventCard(item);
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
        onPressed: _showAddAgendaDialog,
        backgroundColor: const Color(0xFF0D99FF),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  // --- UI WIDGETS ---

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
            'Agenda Kegiatan',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Kelola Jadwal',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateCard() {
    // Mengambil tanggal hari ini secara otomatis
    final now = DateTime.now();
    final List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'];
    final List<String> days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    
    // Logic sederhana untuk hari Indonesia (DateTime.weekday 1=Senin, 7=Minggu)
    String dayName = days[now.weekday - 1];
    String monthName = months[now.month - 1];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
           Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$monthName ${now.year}', style: const TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 4),
              Text('$dayName, ${now.day}', style: const TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0D99FF),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.calendar_today_outlined, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(AgendaItem item) {
    // Format tanggal untuk display (DD-MM-YYYY)
    String dateString = "${item.date.day}-${item.date.month}-${item.date.year}";
    
    // Format jam untuk display
    String timeString = item.isAllDay 
        ? "Sepanjang hari" 
        : "${item.startTime.hour.toString().padLeft(2,'0')}:${item.startTime.minute.toString().padLeft(2,'0')} - Selesai";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _buildStatusChip(item.date),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_month, size: 14, color: Colors.grey),
              const SizedBox(width: 5),
              Text(dateString, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              const SizedBox(width: 15),
              const Icon(Icons.access_time, size: 14, color: Colors.grey),
              const SizedBox(width: 5),
              Text(timeString, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          Text(item.description, style: TextStyle(color: Colors.grey[800], fontSize: 14)),
        ],
      ),
    );
  }

  // Widget Status Chip: Cek apakah event sudah lewat atau belum
  Widget _buildStatusChip(DateTime eventDate) {
    bool isPast = eventDate.isBefore(DateTime.now().subtract(const Duration(days: 1)));
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPast ? Colors.grey[200] : Colors.green[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isPast ? 'Selesai' : 'Akan Datang',
        style: TextStyle(
          color: isPast ? Colors.grey[600] : Colors.green[800],
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 1,
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
