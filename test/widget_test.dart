import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:laporan_sdirbingakkum/core/config/app_config.dart';
import 'package:laporan_sdirbingakkum/shared/widgets/app_background.dart';
import 'package:laporan_sdirbingakkum/features/auth/presentation/sign_in_page.dart';
import 'package:laporan_sdirbingakkum/features/home/presentation/home_page.dart';
import 'package:laporan_sdirbingakkum/shared/widgets/app_header.dart';
import 'package:laporan_sdirbingakkum/features/statistics/presentation/statistics_page.dart';

Future<void> _setSurfaceSize(WidgetTester tester, Size size) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() async {
    await tester.binding.setSurfaceSize(null);
  });
}

Future<void> _pumpSignInAtSize(WidgetTester tester, Size size) async {
  await _setSurfaceSize(tester, size);
  await tester.pumpWidget(
    const ProviderScope(child: MaterialApp(home: SignInPage())),
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpHomeAtSize(WidgetTester tester, Size size) async {
  await _setSurfaceSize(tester, size);
  await tester.pumpWidget(
    const ProviderScope(child: MaterialApp(home: HomePage())),
  );
  await tester.pumpAndSettle();
}

String _routeFor(StatisticsModule module) {
  switch (module) {
    case StatisticsModule.pelanggaran:
      return '/statistik/pelanggaran';
    case StatisticsModule.lakaLalin:
      return '/statistik/laka-lalin';
    case StatisticsModule.simTni:
      return '/statistik/sim-tni';
    case StatisticsModule.k9:
      return '/statistik/k9';
    case StatisticsModule.provos:
      return '/statistik/provos';
  }
}

Future<StatisticsViewData> _testStatisticsData(StatisticsModule module) async {
  switch (module) {
    case StatisticsModule.pelanggaran:
      return StatisticsViewData(
        columns: [
          StatisticsColumnData(
            label: '2026',
            cards: const [
              StatisticsCardData(
                label: 'TATIB',
                value: '0',
                color: Color(0xFFF59E0B),
              ),
              StatisticsCardData(
                label: 'LALIN',
                value: '0',
                color: Color(0xFF38BDF8),
              ),
            ],
          ),
          StatisticsColumnData(
            label: 'SEPT',
            cards: const [
              StatisticsCardData(
                label: 'TATIB',
                value: '0',
                color: Color(0xFFF59E0B),
              ),
              StatisticsCardData(
                label: 'LALIN',
                value: '0',
                color: Color(0xFF38BDF8),
              ),
            ],
          ),
        ],
        ranking: const [],
      );
    case StatisticsModule.lakaLalin:
      return StatisticsViewData(
        columns: [
          StatisticsColumnData(
            label: '2026',
            cards: const [
              StatisticsCardData(
                label: 'JUMLAH KASUS',
                value: '0',
                color: Color(0xFF38BDF8),
              ),
              StatisticsCardData(
                label: 'LAKA GANDA',
                value: '0',
                color: Color(0xFFF97316),
              ),
              StatisticsCardData(
                label: 'TUNGGAL',
                value: '0',
                color: Color(0xFFF59E0B),
              ),
              StatisticsCardData(
                label: 'TABRAK LARI',
                value: '0',
                color: Color(0xFFEF4444),
              ),
            ],
          ),
          StatisticsColumnData(
            label: 'SEPT',
            cards: const [
              StatisticsCardData(
                label: 'JUMLAH KASUS',
                value: '0',
                color: Color(0xFF38BDF8),
              ),
              StatisticsCardData(
                label: 'LAKA GANDA',
                value: '0',
                color: Color(0xFFF97316),
              ),
              StatisticsCardData(
                label: 'TUNGGAL',
                value: '0',
                color: Color(0xFFF59E0B),
              ),
              StatisticsCardData(
                label: 'TABRAK LARI',
                value: '0',
                color: Color(0xFFEF4444),
              ),
            ],
          ),
        ],
        ranking: const [],
      );
    case StatisticsModule.simTni:
      const cards = [
        StatisticsCardData(label: 'A', value: '0', color: Color(0xFF3B82F6)),
        StatisticsCardData(label: 'BI', value: '0', color: Color(0xFF06B6D4)),
        StatisticsCardData(label: 'BII', value: '0', color: Color(0xFF10B981)),
        StatisticsCardData(
          label: 'BII SUS',
          value: '0',
          color: Color(0xFF8B5CF6),
        ),
        StatisticsCardData(label: 'C', value: '0', color: Color(0xFF6366F1)),
      ];
      return StatisticsViewData(
        columns: [
          StatisticsColumnData(label: '2026', cards: cards),
          StatisticsColumnData(label: 'JUL', cards: cards),
        ],
        ranking: const [
          StatisticsRankData('POMDAM TEST', 0),
        ],
        totalSim: 400,
      );
    case StatisticsModule.k9:
      return StatisticsViewData(
        columns: [
          StatisticsColumnData(
            label: '2026',
            cards: const [
              StatisticsCardData(
                label: 'NYATA',
                value: '51',
                color: Color(0xFF34D399),
              ),
              StatisticsCardData(
                label: 'SESUAI ORGAS',
                value: '33',
                color: Color(0xFFD7A93C),
              ),
              StatisticsCardData(
                label: 'KEKURANGAN',
                value: '8',
                color: Color(0xFFF59E0B),
              ),
              StatisticsCardData(
                label: 'SATUAN',
                value: '4',
                color: Color(0xFF7DD3FC),
              ),
            ],
          ),
        ],
        ranking: const [
          StatisticsRankData('POMDAM V/BRW', 19),
          StatisticsRankData('YONPOMAD PUSPOMAD', 17),
          StatisticsRankData('POMDAM JAYA', 10),
          StatisticsRankData('POMDAM XII/TPR', 5),
        ],
      );
    case StatisticsModule.provos:
      return StatisticsViewData(
        columns: [
          StatisticsColumnData(
            label: DateTime.now().year.toString(),
            cards: const [
              StatisticsCardData(
                label: 'JUMLAH',
                value: '4833',
                color: Color(0xFF3B82F6),
              ),
              StatisticsCardData(
                label: 'SUDAH DIK/TAR',
                value: '1304',
                color: Color(0xFF10B981),
              ),
              StatisticsCardData(
                label: 'BELUM DIK/TAR',
                value: '3488',
                color: Color(0xFFEF4444),
              ),
            ],
          ),
        ],
        ranking: const [],
      );
  }
}

void main() {
  test('standalone build has embedded Supabase configuration fallback', () {
    final config = AppConfig.fromEnvironment();

    expect(config.isConfigured, isTrue);
    expect(config.supabaseUrl, 'https://ybepaqmrrgsaeqnqrsrf.supabase.co');
  });

  testWidgets('sign in page renders responsive form without extra footer', (
    tester,
  ) async {
    await _pumpSignInAtSize(tester, const Size(390, 844));

    expect(find.byType(SignInPage), findsOneWidget);
    expect(find.byType(AppBackground), findsOneWidget);
    expect(find.text('AKSES SISTEM'), findsNothing);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('USERNAME'), findsOneWidget);
    expect(find.text('EMAIL'), findsNothing);
    expect(find.text('MASUK'), findsOneWidget);
    expect(find.text('MASUK MENGGUNAKAN AKUN YANG TERDAFTAR.'), findsNothing);
    expect(find.text('SISTEM LAPORAN BIDANG GAKKUM'), findsNothing);
    expect(
      find.text('PROFESIONAL • RESPONSIF • INTEGRITAS • MODERN • ADAPTIF'),
      findsNothing,
    );
    expect(find.text('© 2026 PUSPOMAD'), findsNothing);
    expect(find.byType(SingleChildScrollView), findsNothing);
  });

  testWidgets('sign in fits a short phone viewport without overflow', (
    tester,
  ) async {
    await _pumpSignInAtSize(tester, const Size(320, 568));

    expect(tester.takeException(), isNull);
    expect(find.byType(SingleChildScrollView), findsNothing);
    expect(find.text('MASUK'), findsOneWidget);
  });

  testWidgets('sign in fits a narrow short viewport without overflow', (
    tester,
  ) async {
    await _pumpSignInAtSize(tester, const Size(280, 480));

    expect(tester.takeException(), isNull);
    expect(find.byType(SingleChildScrollView), findsNothing);
    expect(find.text('MASUK'), findsOneWidget);
  });

  testWidgets('sign in form validates required fields', (tester) async {
    await _pumpSignInAtSize(tester, const Size(390, 844));

    final signInButton = find.widgetWithText(FilledButton, 'MASUK');
    await tester.tap(signInButton);
    await tester.pump();

    expect(find.text('USERNAME WAJIB DIISI.'), findsOneWidget);
    expect(find.text('PASSWORD WAJIB DIISI.'), findsOneWidget);
  });

  testWidgets('sign in rejects a typed email domain', (tester) async {
    await _pumpSignInAtSize(tester, const Size(390, 844));

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'NAMA@PUSPOMAD.MIL.ID');
    await tester.enterText(fields.at(1), 'PASSWORD');

    await tester.tap(find.widgetWithText(FilledButton, 'MASUK'));
    await tester.pump();

    expect(find.text('MASUKKAN USERNAME TANPA DOMAIN.'), findsOneWidget);
  });

  testWidgets('post-login header is fixed and unframed', (tester) async {
    await _pumpHomeAtSize(tester, const Size(390, 844));

    expect(find.byType(AppHeader), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byType(PopupMenuButton<String>), findsOneWidget);
    expect(find.text('SDIRBINGAKKUM'), findsOneWidget);
  });

  testWidgets('main menu renders five pie menu sections', (tester) async {
    await _pumpHomeAtSize(tester, const Size(390, 844));

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(AppBackground), findsOneWidget);
    expect(find.text('LAPORAN STATISTIK'), findsNothing);
    expect(find.text('ANALISIS STATISTIK'), findsNothing);
    expect(find.text('SDIRBINGAKKUM'), findsOneWidget);
    expect(find.text('PELANGGARAN'), findsOneWidget);
    expect(find.text('LAKA-LALIN'), findsOneWidget);
    expect(find.text('SIM TNI'), findsOneWidget);
    expect(find.text('K9'), findsOneWidget);
    expect(find.text('PROVOS TNI-AD'), findsOneWidget);
    expect(find.byIcon(Icons.apps_rounded), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pie menu navigates through all five modules', (tester) async {
    final modules = <StatisticsModule>[
      StatisticsModule.pelanggaran,
      StatisticsModule.lakaLalin,
      StatisticsModule.simTni,
      StatisticsModule.k9,
      StatisticsModule.provos,
    ];

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomePage()),
        for (final module in modules)
          GoRoute(
            path: _routeFor(module),
            builder: (context, state) =>
                StatisticsPage(module: module, dataLoader: _testStatisticsData),
          ),
      ],
    );

    await _setSurfaceSize(tester, const Size(390, 844));
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );
    await tester.pumpAndSettle();

    for (var index = 0; index < modules.length; index++) {
      final gesture = find.byKey(const ValueKey('main-pie-menu'));
      expect(gesture, findsOneWidget);
      final center = tester.getCenter(gesture);
      final size = tester.getSize(gesture);
      final angle =
          -math.pi / 2 + (2 * math.pi / modules.length) * (index + 0.5);

      await tester.tapAt(
        Offset(
          center.dx + math.cos(angle) * size.width * 0.36,
          center.dy + math.sin(angle) * size.height * 0.36,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsNothing);
      expect(
        find.byKey(ValueKey('statistics-${modules[index].name}')),
        findsOneWidget,
      );
      expect(find.byType(AppBackground), findsOneWidget);

      if (modules[index] == StatisticsModule.pelanggaran) {
        expect(find.text('TATIB'), findsWidgets);
      } else if (modules[index] == StatisticsModule.lakaLalin) {
        expect(find.text('JUMLAH KASUS'), findsWidgets);
      } else if (modules[index] == StatisticsModule.simTni) {
        expect(find.text('BII SUS'), findsWidgets);
      } else if (modules[index] == StatisticsModule.provos) {
        expect(find.text('SUDAH DIK/TAR'), findsWidgets);
      } else {
        expect(find.text('2026'), findsOneWidget);
        expect(find.text('AGUSTUS 2026'), findsNothing);
        expect(find.byType(SingleChildScrollView), findsOneWidget);
      }

      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);
    }
  });

  testWidgets('pie menu remains usable on compact mobile viewports', (
    tester,
  ) async {
    const sizes = <Size>[
      Size(390, 844),
      Size(360, 800),
      Size(320, 568),
      Size(280, 480),
    ];

    for (final size in sizes) {
      await _pumpHomeAtSize(tester, size);
      expect(tester.takeException(), isNull);
      expect(find.byType(SingleChildScrollView), findsNothing);

      final gesture = find.byType(GestureDetector).last;
      final pieSize = tester.getSize(gesture);
      expect(pieSize.width, lessThanOrEqualTo(size.width - 40));
      expect(pieSize.height, lessThanOrEqualTo(size.height));
    }
  });

  testWidgets('SIM TNI shows total SIM above aligned period columns', (
    tester,
  ) async {
    await _setSurfaceSize(tester, const Size(390, 844));
    await tester.pumpWidget(
      MaterialApp(
        home: StatisticsPage(
          module: StatisticsModule.simTni,
          dataLoader: _testStatisticsData,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('sim-total-card')), findsOneWidget);
    expect(find.text('TOTAL SIM'), findsOneWidget);
    expect(find.text('400'), findsOneWidget);
    expect(find.text('STATISTIK'), findsOneWidget);
    expect(find.text('ANALISIS STATISTIK'), findsNothing);
    expect(find.byKey(const ValueKey('report-period-columns')), findsOneWidget);
  });

  testWidgets('PROVOS shows only the current year period', (tester) async {
    await _setSurfaceSize(tester, const Size(390, 844));
    await tester.pumpWidget(
      MaterialApp(
        home: StatisticsPage(
          module: StatisticsModule.provos,
          dataLoader: _testStatisticsData,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(DateTime.now().year.toString()), findsOneWidget);
    expect(find.text('SEPT'), findsNothing);
    expect(find.byKey(const ValueKey('report-period-columns')), findsNothing);
  });

  testWidgets('K9 is populated with the standard report layout', (
    tester,
  ) async {
    await _setSurfaceSize(tester, const Size(390, 844));
    await tester.pumpWidget(
      MaterialApp(
        home: StatisticsPage(
          module: StatisticsModule.k9,
          dataLoader: _testStatisticsData,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(StatisticsPage), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.text('K9'), findsOneWidget);
    expect(find.byKey(const ValueKey('report-period-columns')), findsNothing);
    expect(find.text('2026'), findsOneWidget);
    expect(find.text('2026'), findsOneWidget);
    expect(find.text('AGUSTUS 2026'), findsNothing);
    expect(find.text('NYATA'), findsOneWidget);
    expect(find.text('51'), findsOneWidget);
    expect(find.text('SESUAI ORGAS'), findsOneWidget);
    expect(find.text('33'), findsOneWidget);
    expect(find.text('KEKURANGAN'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('SATUAN'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('ANALISIS STATISTIK'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
