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
      GoRoute(path: '/signin', builder: (context, state) => const SignInPage()),
      GoRoute(path: '/', builder: (context, state) => const HomePage()),
      GoRoute(
        path: '/statistik/pelanggaran',
        builder: (context, state) => const StatisticsPage(
          module: StatisticsModule.pelanggaran,
        ),
      ),
      GoRoute(
        path: '/statistik/laka-lalin',
        builder: (context, state) => const StatisticsPage(
          module: StatisticsModule.lakaLalin,
        ),
      ),
      GoRoute(
        path: '/statistik/sim-tni',
        builder: (context, state) => const StatisticsPage(
          module: StatisticsModule.simTni,
        ),
      ),
      GoRoute(
        path: '/statistik/k9',
        builder: (context, state) => const StatisticsPage(
          module: StatisticsModule.k9,
        ),
      ),
      GoRoute(
        path: '/statistik/provos',
        builder: (context, state) => const StatisticsPage(
          module: StatisticsModule.provos,
        ),
      ),
    ],
  );
});
