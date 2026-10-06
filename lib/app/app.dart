import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/app_config.dart';
import '../shared/widgets/app_background.dart';
import '../core/theme/app_theme.dart';
import 'router.dart';

class LaporanSdirbingakkumApp extends ConsumerWidget {
  const LaporanSdirbingakkumApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);

    if (!config.isConfigured) {
      return MaterialApp(
        title: 'SDIRBINGAKKUM',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const _ConfigurationGate(),
      );
    }

    return MaterialApp.router(
      title: 'SDIRBINGAKKUM',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}

class _ConfigurationGate extends StatelessWidget {
  const _ConfigurationGate();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: Center(
          child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.settings_outlined,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'KONFIGURASI APLIKASI BELUM LENGKAP',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'SUPABASE_PUBLISHABLE_KEY HARUS DIBERIKAN MELALUI DART-DEFINE PADA ENVIRONMENT CLOUD.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
