import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // Kita buat singleton agar instance-nya sama di seluruh aplikasi
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final SupabaseClient _client = Supabase.instance.client;

  // --- Authentication Services ---

  // 1. Sign Up (Register)
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: {'username': username}, // Metadata user
    );
  }

  // 2. Sign In (Login)
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // 3. Sign Out (Logout)
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // 4. Cek User yang sedang login
  User? get currentUser => _client.auth.currentUser;
  
  // 5. Ambil Session (Token)
  Session? get currentSession => _client.auth.currentSession;
}