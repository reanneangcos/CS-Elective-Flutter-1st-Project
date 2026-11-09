/// Supabase connection settings.
///
/// Either paste your project's values into the defaults below, or pass them
/// at run time:
///
///   flutter run --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
///               --dart-define=SUPABASE_ANON_KEY=eyJhbGciOi...
///
/// Find both in Supabase Dashboard → Project Settings → API (the "anon" /
/// "publishable" key — never the service_role / secret key).
class SupabaseConfig {
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://mozbxzffuwytjbnxmwsj.supabase.co',
  );

  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_vfIq2U0GoWyQ4rzYKQvvhw_gQq7JeX1',
  );

  static bool get isConfigured =>
      url.isNotEmpty && anonKey.isNotEmpty;
}
