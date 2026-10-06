import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:laporan_sdirbingakkum/app/app.dart';
import 'package:laporan_sdirbingakkum/features/auth/presentation/sign_in_page.dart';
import 'package:laporan_sdirbingakkum/features/home/presentation/home_page.dart';
import 'package:laporan_sdirbingakkum/features/statistics/presentation/statistics_page.dart';

Future<void> _pumpSignInAtSize(WidgetTester tester, Size size) async {
  await tester.binding.setSurfaceSize(size);
  await tester.pumpWidget(
    const ProviderScope(child: MaterialApp(home: SignInPage())),
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpHomeAtSize(WidgetTester tester, Size size) async {
  await tester.binding.setSurfaceSize(size);
  await tester.pumpWidget(
    const ProviderScope(child: MaterialApp(home: HomePage())),
  );
  await tester.pumpAndSettle();
}

void main() {
  tearDown(() async {
    await TestWidgetsFlutterBinding.instance.setSurfaceSize(null);
  });

  testWidgets('application shows configuration gate without secret', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: LaporanSdirbingakkumApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Konfigurasi aplikasi belum lengkap'), findsOneWidget);
  });

  testWidgets('sign in page renders responsive form without extra footer', (
    tester,
  ) async {
    await _pumpSignInAtSize(tester, const Size(390, 844));

    expect(find.byType(SignInPage), findsOneWidget);
    expect(find.text('Akses Sistem'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
    expect(find.text('Akun terdaftar di lingkungan PUSPOMAD'), findsNothing);
    expect(find.text('© 2026 PUSPOMAD'), findsNothing);
    expect(find.byType(Scrollable), findsNothing);
  });

  testWidgets('sign in fits a short phone viewport without overflow', (
    tester,
  ) async {
    await _pumpSignInAtSize(tester, const Size(320, 568));

    expect(tester.takeException(), isNull);
    expect(find.byType(Scrollable), findsNothing);
    expect(find.text('Masuk'), findsOneWidget);
  });

  testWidgets('sign in fits a narrow short viewport without overflow', (
    tester,
  ) async {
    await _pumpSignInAtSize(tester, const Size(280, 480));

    expect(tester.takeException(), isNull);
    expect(find.byType(Scrollable), findsNothing);
    expect(find.text('Masuk'), findsOneWidget);
  });

  testWidgets('sign in form validates required fields', (tester) async {
    await _pumpSignInAtSize(tester, const Size(390, 844));

    final signInButton = find.widgetWithText(FilledButton, 'Masuk');
    await tester.tap(signInButton);
    await tester.pump();

    expect(find.text('Email wajib diisi.'), findsOneWidget);
    expect(find.text('Password wajib diisi.'), findsOneWidget);
  });

  testWidgets('main menu renders five pie menu sections', (tester) async {
    await _pumpHomeAtSize(tester, const Size(390, 844));

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('SEMUA STATISTIK'), findsOneWidget);
    expect(find.text('SDIRBINGAKKUM'), findsOneWidget);
    expect(find.text('Statistik Pelanggaran'), findsOneWidget);
    expect(find.text('Statistik Laka-lalin'), findsOneWidget);
    expect(find.text('Statistik SIM TNI'), findsOneWidget);
    expect(find.text('Statistik K9'), findsOneWidget);
    expect(find.text('Statistik Provos TNI-AD'), findsOneWidget);
    expect(find.byIcon(Icons.gavel_rounded), findsNWidgets(2));
    expect(find.byType(Scrollable), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pie menu navigates to a dedicated content page', (tester) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomePage()),
        GoRoute(
          path: '/statistik/pelanggaran',
          builder: (context, state) => const StatisticsPage(
            module: StatisticsModule.pelanggaran,
          ),
        ),
      ],
    );

    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    final gesture = find.byType(GestureDetector).last;
    final center = tester.getCenter(gesture);
    final size = tester.getSize(gesture);

    await tester.tapAt(
      Offset(
        center.dx,
        center.dy - size.width * 0.34,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsNothing);
    expect(find.byType(StatisticsPage), findsOneWidget);
    expect(find.text('TATIB'), findsWidgets);
    expect(find.text('Top 5 POMDAM'), findsNothing);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);
  });
}


  testWidgets('K9 opens as an empty content page', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(
      MaterialApp(
        home: const StatisticsPage(module: StatisticsModule.k9),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(StatisticsPage), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsNothing);
    expect(find.text('Statistik K9'), findsNothing);
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
