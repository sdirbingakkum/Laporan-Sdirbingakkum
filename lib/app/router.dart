import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/auth/presentation/sign_in_page.dart';
import '../features/home/presentation/home_page.dart';
import '../features/statistics/presentation/statistics_page.dart';

class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Stream<AuthState> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

Page<dynamic> _buildExecutivePage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curve = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curve,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.985, end: 1.0).animate(curve),
          child: child,
        ),
      );
    },
  );
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final auth = Supabase.instance.client.auth;
  final refreshNotifier = _AuthRefreshNotifier(auth.onAuthStateChange);

  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final session = auth.currentSession;
      final onSignIn = state.matchedLocation == '/signin';

      if (session == null) {
        return onSignIn ? null : '/signin';
      }

      return onSignIn ? '/' : null;
    },
    routes: [
      GoRoute(
        path: '/signin',
        pageBuilder: (context, state) =>
            _buildExecutivePage(key: state.pageKey, child: const SignInPage()),
      ),
      GoRoute(
        path: '/',
        pageBuilder: (context, state) =>
            _buildExecutivePage(key: state.pageKey, child: const HomePage()),
      ),
      GoRoute(
        path: '/statistik/pelanggaran',
        pageBuilder: (context, state) => _buildExecutivePage(
          key: state.pageKey,
          child: const StatisticsPage(module: StatisticsModule.pelanggaran),
        ),
      ),
      GoRoute(
        path: '/statistik/laka-lalin',
        pageBuilder: (context, state) => _buildExecutivePage(
          key: state.pageKey,
          child: const StatisticsPage(module: StatisticsModule.lakaLalin),
        ),
      ),
      GoRoute(
        path: '/statistik/sim-tni',
        pageBuilder: (context, state) => _buildExecutivePage(
          key: state.pageKey,
          child: const StatisticsPage(module: StatisticsModule.simTni),
        ),
      ),
      GoRoute(
        path: '/statistik/k9',
        pageBuilder: (context, state) => _buildExecutivePage(
          key: state.pageKey,
          child: const StatisticsPage(module: StatisticsModule.k9),
        ),
      ),
      GoRoute(
        path: '/statistik/provos',
        pageBuilder: (context, state) => _buildExecutivePage(
          key: state.pageKey,
          child: const StatisticsPage(module: StatisticsModule.provos),
        ),
      ),
    ],
  );
});
