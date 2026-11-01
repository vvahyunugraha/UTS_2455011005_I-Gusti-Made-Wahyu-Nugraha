/// Konfigurasi Koneksi Database Supabase
/// 
/// CATATAN PENTING UTS:
/// 1. Masukkan Project URL dan Publishable / Anon Key yang didapat dari Dashboard Supabase.
/// 2. JANGAN PERNAH memasukkan 'service_role key' ke file ini demi keamanan sesuai rubrik penilaian!
class SupabaseConfig {
  /// Masukkan URL Project Supabase Anda di sini
  /// Contoh: 'https://abcdefghijklmno.supabase.co'
  static const String supabaseUrl = 'YOUR_SUPABASE_URL_HERE';

  /// Masukkan Project Publishable / Anon Public Key Anda di sini
  /// Contoh: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'
  static const String supabasePublishableKey = 'YOUR_SUPABASE_PUBLISHABLE_KEY_HERE';

  /// Cek otomatis apakah kredensial sudah diisi oleh pengguna
  static bool get isConfigured =>
      supabaseUrl != 'YOUR_SUPABASE_URL_HERE' &&
      supabasePublishableKey != 'YOUR_SUPABASE_PUBLISHABLE_KEY_HERE' &&
      supabaseUrl.trim().isNotEmpty &&
      supabasePublishableKey.trim().isNotEmpty;
}
