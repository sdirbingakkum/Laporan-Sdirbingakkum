import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/features/statistics/presentation/statistics_page.dart';

StatisticsViewData _data(StatisticsModule module) {
  switch (module) {
    case StatisticsModule.pelanggaran:
      return const StatisticsViewData(
        columns: [
          StatisticsColumnData(
            label: '2026',
            cards: [
              StatisticsCardData(label: 'TATIB', value: '12', color: Color(0xFFF59E0B)),
              StatisticsCardData(label: 'LALIN', value: '18', color: Color(0xFF38BDF8)),
            ],
          ),
          StatisticsColumnData(
            label: 'SEPT',
            cards: [
              StatisticsCardData(label: 'TATIB', value: '4', color: Color(0xFFF59E0B)),
              StatisticsCardData(label: 'LALIN', value: '8', color: Color(0xFF38BDF8)),
            ],
          ),
        ],
        ranking: [
          StatisticsRankData('POMDAM JAYA', 9),
          StatisticsRankData('POMDAM IV/DIP', 7),
          StatisticsRankData('POMDAM V/BRW', 6),
          StatisticsRankData('POMDAM II/SWJ', 5),
          StatisticsRankData('POMDAM III/SLW', 4),
        ],
      );
    case StatisticsModule.lakaLalin:
      return const StatisticsViewData(
        columns: [
          StatisticsColumnData(
            label: '2026',
            cards: [
              StatisticsCardData(label: 'JUMLAH KASUS', value: '16', color: Color(0xFF38BDF8)),
              StatisticsCardData(label: 'LAKA GANDA', value: '6', color: Color(0xFFF97316)),
              StatisticsCardData(label: 'TUNGGAL', value: '8', color: Color(0xFFF59E0B)),
              StatisticsCardData(label: 'TABRAK LARI', value: '2', color: Color(0xFFEF4444)),
            ],
          ),
          StatisticsColumnData(
            label: 'SEPT',
            cards: [
              StatisticsCardData(label: 'JUMLAH KASUS', value: '8', color: Color(0xFF38BDF8)),
              StatisticsCardData(label: 'LAKA GANDA', value: '3', color: Color(0xFFF97316)),
              StatisticsCardData(label: 'TUNGGAL', value: '4', color: Color(0xFFF59E0B)),
              StatisticsCardData(label: 'TABRAK LARI', value: '1', color: Color(0xFFEF4444)),
            ],
          ),
        ],
        ranking: [
          StatisticsRankData('POMDAM JAYA', 5),
          StatisticsRankData('POMDAM IV/DIP', 3),
          StatisticsRankData('POMDAM V/BRW', 2),
          StatisticsRankData('POMDAM III/SLW', 2),
          StatisticsRankData('POMDAM II/SWJ', 1),
        ],
      );
    case StatisticsModule.simTni:
      return const StatisticsViewData(
        columns: [
          StatisticsColumnData(
            label: '2026',
            cards: [
              StatisticsCardData(label: 'A', value: '207', color: Color(0xFF3B82F6)),
              StatisticsCardData(label: 'BI', value: '80', color: Color(0xFF06B6D4)),
              StatisticsCardData(label: 'BII', value: '23', color: Color(0xFF10B981)),
              StatisticsCardData(label: 'BII SUS', value: '4', color: Color(0xFF8B5CF6)),
              StatisticsCardData(label: 'C', value: '337', color: Color(0xFF6366F1)),
            ],
          ),
          StatisticsColumnData(
            label: 'JUL',
            cards: [
              StatisticsCardData(label: 'A', value: '207', color: Color(0xFF3B82F6)),
              StatisticsCardData(label: 'BI', value: '80', color: Color(0xFF06B6D4)),
              StatisticsCardData(label: 'BII', value: '23', color: Color(0xFF10B981)),
              StatisticsCardData(label: 'BII SUS', value: '4', color: Color(0xFF8B5CF6)),
              StatisticsCardData(label: 'C', value: '337', color: Color(0xFF6366F1)),
            ],
          ),
        ],
        ranking: [
          StatisticsRankData('POMDAM JAYA', 180),
          StatisticsRankData('POMDAM IV/DIP', 145),
          StatisticsRankData('POMDAM V/BRW', 120),
          StatisticsRankData('POMDAM III/SLW', 105),
          StatisticsRankData('POMDAM II/SWJ', 88),
        ],
        totalSim: 651,
      );
    case StatisticsModule.k9:
      return const StatisticsViewData(
        columns: [
          StatisticsColumnData(
            label: '2026',
            cards: [
              StatisticsCardData(label: 'NYATA', value: '51', color: Color(0xFF34D399)),
              StatisticsCardData(label: 'SESUAI ORGAS', value: '33', color: Color(0xFFD7A93C)),
              StatisticsCardData(label: 'KEKURANGAN', value: '8', color: Color(0xFFF59E0B)),
              StatisticsCardData(label: 'SATUAN', value: '4', color: Color(0xFF7DD3FC)),
            ],
          ),
        ],
        ranking: [
          StatisticsRankData('POMDAM V/BRW', 19),
          StatisticsRankData('YONPOMAD PUSPOMAD', 17),
          StatisticsRankData('POMDAM JAYA', 10),
          StatisticsRankData('POMDAM XII/TPR', 5),
        ],
      );
    case StatisticsModule.provos:
      return const StatisticsViewData(
        columns: [
          StatisticsColumnData(
            label: '2026',
            cards: [
              StatisticsCardData(label: 'JUMLAH', value: '4833', color: Color(0xFF3B82F6)),
              StatisticsCardData(label: 'SUDAH DIK/TAR', value: '1304', color: Color(0xFF10B981)),
              StatisticsCardData(label: 'BELUM DIK/TAR', value: '3488', color: Color(0xFFEF4444)),
            ],
          ),
        ],
        ranking: [
          StatisticsRankData('POMDAM JAYA', 1330),
          StatisticsRankData('POMDAM IV/DIP', 1180),
          StatisticsRankData('POMDAM V/BRW', 1110),
          StatisticsRankData('POMDAM III/SLW', 1040),
          StatisticsRankData('POMDAM II/SWJ', 980),
        ],
      );
  }
}

Future<void> _saveSnapshot(WidgetTester tester, String name) async {
  await expectLater(
    find.byKey(const ValueKey('pr1-visual-root')),
    matchesGoldenFile('goldens/pr1_' + name + '.png'),
  );
}

void main() {
  final modules = <StatisticsModule>[
    StatisticsModule.pelanggaran,
    StatisticsModule.lakaLalin,
    StatisticsModule.simTni,
    StatisticsModule.k9,
    StatisticsModule.provos,
  ];

  for (final module in modules) {
    testWidgets('snapshot ' + module.name, (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      await tester.pumpWidget(
        MaterialApp(
          home: RepaintBoundary(
            key: const ValueKey('pr1-visual-root'),
            child: StatisticsPage(
              module: module,
              dataLoader: (value) async => _data(value),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await _saveSnapshot(tester, module.name);
    });
  }
}
