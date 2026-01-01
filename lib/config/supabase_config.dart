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
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';

  /// Supabase anon/public key
  /// This is safe to use in client applications
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  /// Storage bucket name for receipts
  static const String receiptsBucket = 'receipts';

  /// Enable debug mode for development
  static const bool debugMode = true;
}
