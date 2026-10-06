import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:laporan_sdirbingakkum/app/app.dart';

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
}
