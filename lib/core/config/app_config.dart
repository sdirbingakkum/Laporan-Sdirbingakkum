import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppConfig {
  const AppConfig({required this.supabaseUrl, required this.publishableKey});

  static AppConfig fromEnvironment() {
    const url = String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: 'https://ybepaqmrrgsaeqnqrsrf.supabase.co',
    );
    const key = String.fromEnvironment(
      'SUPABASE_PUBLISHABLE_KEY',
      defaultValue: 'sb_publishable_2G1L_dvjx5o99fTwcgvwYw_zDrzc0N-',
    );

    return const AppConfig(supabaseUrl: url, publishableKey: key);
  }

  final String supabaseUrl;
  final String publishableKey;

  bool get isConfigured =>
      supabaseUrl.trim().isNotEmpty && publishableKey.trim().isNotEmpty;
}

final appConfigProvider = Provider<AppConfig>((ref) {
  return AppConfig.fromEnvironment();
});
