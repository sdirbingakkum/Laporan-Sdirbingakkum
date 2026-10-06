import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    usePathUrlStrategy();
  }

  const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://ybepaqmrrgsaeqnqrsrf.supabase.co',
  );
  const publishableKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  if (publishableKey.isNotEmpty) {
    await Supabase.initialize(url: supabaseUrl, publishableKey: publishableKey);
  }

  runApp(const ProviderScope(child: LaporanSdirbingakkumApp()));
}
