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
        ranking: const [StatisticsRankData('POMDAM TEST', 0)],
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

const _testPelanggaranPeriodOptions = <StatisticsPeriodOption>[
  StatisticsPeriodOption(
    key: 'month:9',
    label: 'SEP',
    startMonth: 9,
    endMonth: 9,
  ),
  StatisticsPeriodOption(
    key: 'quarter:3',
    label: 'TRIWULAN III',
    startMonth: 7,
    endMonth: 9,
  ),
  StatisticsPeriodOption(
    key: 'quarter:2',
    label: 'TRIWULAN II',
    startMonth: 4,
    endMonth: 6,
  ),
  StatisticsPeriodOption(
    key: 'quarter:1',
    label: 'TRIWULAN I',
    startMonth: 1,
    endMonth: 3,
  ),
  StatisticsPeriodOption(
    key: 'semester:1',
    label: 'SEMESTER I',
    startMonth: 1,
    endMonth: 6,
  ),
];

Future<StatisticsViewData> _testPelanggaranPeriodData(
  StatisticsModule module,
  String periodKey,
) async {
  if (module != StatisticsModule.pelanggaran) {
    return _testStatisticsData(module);
  }

  final option = _testPelanggaranPeriodOptions.firstWhere(
    (item) => item.key == periodKey,
  );
  final isQuarterThree = periodKey == 'quarter:3';

  return StatisticsViewData(
    columns: [
      StatisticsColumnData(
        label: '2026 · JAN–SEP',
        cards: const [
          StatisticsCardData(
            label: 'TATIB',
            value: '55',
            color: Color(0xFFF59E0B),
          ),
          StatisticsCardData(
            label: 'LALIN',
            value: '138',
            color: Color(0xFF38BDF8),
          ),
        ],
      ),
      StatisticsColumnData(
        label: option.label,
        cards: [
          StatisticsCardData(
            label: 'TATIB',
            value: isQuarterThree ? '20' : '13',
            color: const Color(0xFFF59E0B),
          ),
          StatisticsCardData(
            label: 'LALIN',
            value: isQuarterThree ? '38' : '12',
            color: const Color(0xFF38BDF8),
          ),
        ],
      ),
    ],
    ranking: const [],
    periodOptions: _testPelanggaranPeriodOptions,
    selectedPeriodKey: option.key,
  );
}

Future<StatisticsViewData> _testSelectablePeriodData(
  StatisticsModule module,
  String periodKey,
) async {
  final option = _testPelanggaranPeriodOptions.firstWhere(
    (item) => item.key == periodKey,
  );
  final isQuarterThree = periodKey == 'quarter:3';

  if (module == StatisticsModule.lakaLalin) {
    return StatisticsViewData(
      columns: [
        StatisticsColumnData(
          label: '2026 · JAN–SEP',
          cards: const [
            StatisticsCardData(
              label: 'JUMLAH KASUS',
              value: '106',
              color: Color(0xFF38BDF8),
            ),
            StatisticsCardData(
              label: 'LAKA GANDA',
              value: '63',
              color: Color(0xFFF97316),
            ),
            StatisticsCardData(
              label: 'TUNGGAL',
              value: '41',
              color: Color(0xFFF59E0B),
            ),
            StatisticsCardData(
              label: 'TABRAK LARI',
              value: '2',
              color: Color(0xFFEF4444),
            ),
          ],
        ),
        StatisticsColumnData(
          label: option.label,
          cards: [
            StatisticsCardData(
              label: 'JUMLAH KASUS',
              value: isQuarterThree ? '42' : '9',
              color: const Color(0xFF38BDF8),
            ),
            StatisticsCardData(
              label: 'LAKA GANDA',
              value: isQuarterThree ? '24' : '4',
              color: const Color(0xFFF97316),
            ),
            StatisticsCardData(
              label: 'TUNGGAL',
              value: isQuarterThree ? '17' : '5',
              color: const Color(0xFFF59E0B),
            ),
            StatisticsCardData(
              label: 'TABRAK LARI',
              value: isQuarterThree ? '1' : '0',
              color: const Color(0xFFEF4444),
            ),
          ],
        ),
      ],
      ranking: const [StatisticsRankData('POMDAM TEST', 42)],
      periodOptions: _testPelanggaranPeriodOptions,
      selectedPeriodKey: option.key,
    );
  }

  if (module == StatisticsModule.simTni) {
    final comparisonValues = isQuarterThree
        ? const ['953', '356', '83', '8', '1207']
        : const ['318', '122', '33', '4', '523'];
    final annualValues = const ['2734', '1081', '320', '118', '3232'];
    const labels = ['A', 'BI', 'BII', 'BII SUS', 'C'];
    const colors = [
      Color(0xFF3B82F6),
      Color(0xFF06B6D4),
      Color(0xFF10B981),
      Color(0xFF8B5CF6),
      Color(0xFF6366F1),
    ];
    final comparisonCards = [
      for (var index = 0; index < labels.length; index++)
        StatisticsCardData(
          label: labels[index],
          value: comparisonValues[index],
          color: colors[index],
        ),
    ];
    final comparisonTotal = isQuarterThree ? 2607 : 1000;

    return StatisticsViewData(
      columns: [
        StatisticsColumnData(
          label: '2026 · JAN–SEP',
          cards: [
            for (var index = 0; index < labels.length; index++)
              StatisticsCardData(
                label: labels[index],
                value: annualValues[index],
                color: colors[index],
              ),
          ],
        ),
        StatisticsColumnData(label: option.label, cards: comparisonCards),
      ],
      ranking: const [StatisticsRankData('POMDAM TEST', 2607)],
      totalSim: comparisonTotal,
      periodOptions: _testPelanggaranPeriodOptions,
      selectedPeriodKey: option.key,
    );
  }

  return _testStatisticsData(module);
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
      const menuItemCount = 5;
      final angle =
          -math.pi / 2 + (2 * math.pi / menuItemCount) * (index + 0.5);

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

  testWidgets('pie menu remains tappable after system back from a report', (
    tester,
  ) async {
    final modules = <StatisticsModule>[
      StatisticsModule.pelanggaran,
      StatisticsModule.lakaLalin,
    ];

    Page<void> executivePage({required LocalKey key, required Widget child}) {
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

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) =>
              executivePage(key: state.pageKey, child: const HomePage()),
        ),
        for (final module in modules)
          GoRoute(
            path: _routeFor(module),
            pageBuilder: (context, state) => executivePage(
              key: state.pageKey,
              child: StatisticsPage(
                module: module,
                dataLoader: _testStatisticsData,
              ),
            ),
          ),
      ],
    );

    await _setSurfaceSize(tester, const Size(390, 844));
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );
    await tester.pumpAndSettle();

    Future<void> tapModule(int index) async {
      final menu = find.byKey(const ValueKey('main-pie-menu'));
      expect(menu, findsOneWidget);
      final center = tester.getCenter(menu);
      final size = tester.getSize(menu);
      const menuItemCount = 5;
      final angle =
          -math.pi / 2 + (2 * math.pi / menuItemCount) * (index + 0.5);
      await tester.tapAt(
        Offset(
          center.dx + math.cos(angle) * size.width * 0.36,
          center.dy + math.sin(angle) * size.height * 0.36,
        ),
      );
    }

    await tapModule(0);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('statistics-pelanggaran')),
      findsOneWidget,
    );

    // Exercise the platform/Router back path instead of the on-screen arrow.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);

    await tapModule(1);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('statistics-lakaLalin')), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);
    expect(tester.takeException(), isNull);
    router.dispose();
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

  testWidgets(
    'Pelanggaran period dropdown defaults to latest month and refreshes values',
    (tester) async {
      await _setSurfaceSize(tester, const Size(390, 844));
      await tester.pumpWidget(
        MaterialApp(
          home: StatisticsPage(
            module: StatisticsModule.pelanggaran,
            dataLoader: (module) =>
                _testPelanggaranPeriodData(module, 'month:9'),
            periodDataLoader: _testPelanggaranPeriodData,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('pelanggaran-period-dropdown')),
        findsOneWidget,
      );
      expect(find.text('SEP'), findsOneWidget);
      expect(find.text('SEPTEMBER 2026'), findsNothing);
      expect(find.text('55'), findsOneWidget);
      expect(find.text('138'), findsOneWidget);
      expect(find.text('13'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);

      await tester.tap(
        find.byKey(const ValueKey('pelanggaran-period-dropdown')),
      );
      await tester.pumpAndSettle();
      expect(find.text('TRIWULAN III'), findsOneWidget);
      await tester.tap(find.text('TRIWULAN III'));
      await tester.pumpAndSettle();

      expect(find.text('20'), findsOneWidget);
      expect(find.text('38'), findsOneWidget);
      // Selecting a comparison period must not change the year-to-date column.
      expect(find.text('55'), findsOneWidget);
      expect(find.text('138'), findsOneWidget);
      expect(find.text('13'), findsNothing);
      expect(find.text('12'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Laka Lalin period dropdown refreshes values', (tester) async {
    await _setSurfaceSize(tester, const Size(390, 844));
    await tester.pumpWidget(
      MaterialApp(
        home: StatisticsPage(
          module: StatisticsModule.lakaLalin,
          dataLoader: (module) => _testSelectablePeriodData(module, 'month:9'),
          periodDataLoader: _testSelectablePeriodData,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('laka-lalin-period-dropdown')),
      findsOneWidget,
    );
    expect(find.text('106'), findsOneWidget);
    expect(find.text('42'), findsNothing);
    expect(find.text('9'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('laka-lalin-period-dropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('TRIWULAN III'));
    await tester.pumpAndSettle();

    expect(find.text('106'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
    expect(find.text('9'), findsNothing);
    expect(find.text('24'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('SIM TNI period dropdown refreshes categories and total', (
    tester,
  ) async {
    await _setSurfaceSize(tester, const Size(390, 844));
    await tester.pumpWidget(
      MaterialApp(
        home: StatisticsPage(
          module: StatisticsModule.simTni,
          dataLoader: (module) => _testSelectablePeriodData(module, 'month:9'),
          periodDataLoader: _testSelectablePeriodData,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('sim-tni-period-dropdown')),
      findsOneWidget,
    );
    expect(find.text('1000'), findsOneWidget);
    expect(find.text('7485'), findsNothing);
    expect(find.text('2734'), findsOneWidget);
    expect(find.text('SEP'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('sim-tni-period-dropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('TRIWULAN III'));
    await tester.pumpAndSettle();

    expect(find.text('2607'), findsOneWidget);
    expect(find.text('1207'), findsOneWidget);
    expect(find.text('2734'), findsOneWidget);
    expect(find.text('1000'), findsNothing);
    expect(tester.takeException(), isNull);
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

  testWidgets(
    'SIM TNI animated analysis sheet is detailed and responsive on mobile',
    (tester) async {
      const sizes = <Size>[Size(390, 844), Size(320, 568)];

      for (final size in sizes) {
        await _setSurfaceSize(tester, size);
        await tester.pumpWidget(
          MaterialApp(
            home: StatisticsPage(
              module: StatisticsModule.simTni,
              dataLoader: (module) =>
                  _testSelectablePeriodData(module, 'month:9'),
              periodDataLoader: _testSelectablePeriodData,
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('STATISTIK'));
        await tester.pumpAndSettle();

        expect(find.byType(DraggableScrollableSheet), findsOneWidget);
        expect(find.text('ANALISIS SIM TNI'), findsOneWidget);
        expect(find.text('TOTAL PENERBITAN'), findsOneWidget);
        expect(find.text('RINGKASAN EKSEKUTIF'), findsOneWidget);
        expect(find.text('KOMPOSISI JENIS SIM'), findsOneWidget);
        expect(find.text('RINCIAN VS KUMULATIF'), findsOneWidget);
        expect(
          find.text('POMDAM DENGAN PENERBITAN TERTINGGI'),
          findsOneWidget,
        );
        expect(find.text('TEMUAN UTAMA'), findsOneWidget);
        expect(find.text('KONTRIBUSI TOP 5 POMDAM'), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.tap(find.byTooltip('Tutup analisis'));
        await tester.pumpAndSettle();
      }
    },
  );

  testWidgets('PROVOS shows only the three cumulative indicators', (
    tester,
  ) async {
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
    expect(find.byKey(const ValueKey('provos-period-dropdown')), findsNothing);
    expect(find.byKey(const ValueKey('report-period-columns')), findsNothing);
    expect(find.text('JUMLAH'), findsOneWidget);
    expect(find.text('SUDAH DIK/TAR'), findsOneWidget);
    expect(find.text('BELUM DIK/TAR'), findsOneWidget);
    expect(find.text('4833'), findsOneWidget);
    expect(find.text('1304'), findsOneWidget);
    expect(find.text('3488'), findsOneWidget);
    expect(find.text('SEPT'), findsNothing);
    expect(tester.takeException(), isNull);
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
    expect(find.text('STATISTIK'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
