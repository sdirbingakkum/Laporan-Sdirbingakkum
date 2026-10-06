import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:laporan_sdirbingakkum/app/app.dart';
import 'package:laporan_sdirbingakkum/features/auth/presentation/sign_in_page.dart';

void main() {
  testWidgets('application shows configuration gate without secret', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: LaporanSdirbingakkumApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Konfigurasi aplikasi belum lengkap'), findsOneWidget);
  });

  testWidgets('sign in page renders mobile-first form', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: SignInPage()),
      ),
    );

    expect(find.text('Selamat datang kembali'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
  });

  testWidgets('sign in form validates required fields', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: SignInPage()),
      ),
    );

    await tester.tap(find.text('Masuk'));
    await tester.pump();

    expect(find.text('Email wajib diisi.'), findsOneWidget);
    expect(find.text('Password wajib diisi.'), findsOneWidget);
  });
}
