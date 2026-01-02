/// Supabase configuration
///
/// IMPORTANT: Replace these values with your actual Supabase project credentials
/// 1. Go to https://supabase.com/dashboard
/// 2. Select your project
/// 3. Go to Settings > API
/// 4. Copy the URL and anon/public key
class SupabaseConfig {
  /// Supabase project URL
  /// Example: https://xxxxxxxxxxxxx.supabase.co
  static const String supabaseUrl = 'https://ucehuhjjhomoxywpannd.supabase.co';

  /// Supabase anon/public key
  /// This is safe to use in client applications
  static const String supabaseAnonKey =
      'sb_publishable_DZ4sl4SfHIuUPGuf81RUjA_XvQFNJrV';

  /// Storage bucket name for receipts
  static const String receiptsBucket = 'receipts';

  /// Enable debug mode for development
  static const bool debugMode = true;
}
