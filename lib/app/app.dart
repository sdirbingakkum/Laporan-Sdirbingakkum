import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/app_config.dart';
import '../core/theme/app_theme.dart';
import 'router.dart';

class LaporanSdirbingakkumApp extends ConsumerWidget {
  const LaporanSdirbingakkumApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Laporan Sdirbingakkum',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: ref.watch(appRouterProvider),
      builder: (context, child) {
        final config = ref.watch(appConfigProvider);
        if (!config.isConfigured) {
          return const _ConfigurationGate();
        }
        return child ?? const SizedBox.shrink();
      },
    );
  }
}

class _ConfigurationGate extends StatelessWidget {
  const _ConfigurationGate();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laporan Sdirbingakkum',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: Scaffold(
        body: Center(
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
                        'Konfigurasi aplikasi belum lengkap',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'SUPABASE_PUBLISHABLE_KEY harus diberikan melalui dart-define pada environment cloud.',
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
      ),
    );
  }
}
