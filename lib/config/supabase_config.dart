/// Konfigurasi Koneksi Database Supabase
/// 
/// CATATAN PENTING KEAMANAN UTS:
/// Sesuai aturan penugasan:
/// "Dilarang melakukan commit password, private key, service_role key, 
/// token rahasia, credential, atau keystore."
/// Kredensial tidak di-hardcode ke dalam repository Git demi menjaga keamanan data.
/// Kredensial dapat dimasukkan via parameter --dart-define atau diatur saat pengujian lokal.
class SupabaseConfig {
  /// Masukkan URL Project Supabase via --dart-define=SUPABASE_URL=... atau isi saat testing lokal
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'YOUR_SUPABASE_URL_HERE',
  );

  /// Masukkan Publishable / Anon Key via --dart-define=SUPABASE_PUBLISHABLE_KEY=... atau isi saat testing lokal
  static const String supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: 'YOUR_SUPABASE_PUBLISHABLE_KEY_HERE',
  );

  /// Cek otomatis apakah kredensial sudah diisi oleh pengguna
  static bool get isConfigured =>
      supabaseUrl.isNotEmpty &&
      supabasePublishableKey.isNotEmpty &&
      supabaseUrl != 'YOUR_SUPABASE_URL_HERE' &&
      supabasePublishableKey != 'YOUR_SUPABASE_PUBLISHABLE_KEY_HERE';
}
