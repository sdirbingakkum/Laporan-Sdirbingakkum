import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/adaptive_navigation_shell.dart';
import '../../auth/data/auth_repository.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Keluar dari sistem?'),
          content: const Text(
            'Sesi Anda akan diakhiri dan Anda akan kembali ke halaman Sign In.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    try {
      await ref.read(authRepositoryProvider).signOut();
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak dapat mengakhiri sesi. Coba lagi.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AdaptiveNavigationShell(
      title: 'Laporan Sdirbingakkum',
      actions: [
        PopupMenuButton<String>(
          tooltip: 'Menu akun',
          onSelected: (value) {
            if (value == 'signout') {
              _confirmSignOut(context, ref);
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem<String>(
              value: 'signout',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.logout_rounded),
                  SizedBox(width: 12),
                  Text('Keluar / Sign Out'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.description_outlined),
          selectedIcon: Icon(Icons.description),
          label: 'Laporan',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: 'Pengaturan',
        ),
      ],
      body: const _HomeContent(),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Foundation siap',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Flutter mobile-first dengan satu codebase untuk Android, Web, dan Windows.',
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cloud-first', style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                const Text(
                  'Build, test, dan deployment release path dijalankan melalui GitHub Actions. Supabase dikonsumsi sebagai backend terpisah.',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
