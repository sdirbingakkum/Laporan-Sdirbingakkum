import 'package:flutter/material.dart';

const _bg = Color(0xFF03150F);
const _surface = Color(0xFF09231A);
const _surfaceSoft = Color(0xFF0D2C20);
const _gold = Color(0xFFD7A93C);
const _goldLight = Color(0xFFF1D37A);
const _text = Color(0xFFF8F5EC);
const _muted = Color(0xFFB7C2BC);

enum StatisticsModule { pelanggaran, lakaLalin, simTni, k9, provos }

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({required this.module, super.key});

  final StatisticsModule module;

  List<_StatColumn> get _columns {
    switch (module) {
      case StatisticsModule.pelanggaran:
        return const [
          _StatColumn(
            label: '2026',
            cards: [
              _StatCardData('TATIB', '25', Color(0xFFF09A4A)),
              _StatCardData('LALIN', '70', Color(0xFF5D8FE0)),
            ],
          ),
          _StatColumn(
            label: 'SEPT',
            cards: [
              _StatCardData('TATIB', '5', Color(0xFFF09A4A)),
              _StatCardData('LALIN', '10', Color(0xFF5D8FE0)),
            ],
          ),
        ];
      case StatisticsModule.lakaLalin:
        return const [
          _StatColumn(
            label: '2026',
            cards: [
              _StatCardData('JUMLAH KASUS', '200', Color(0xFFE15B5B)),
              _StatCardData('LAKA GANDA', '100', Color(0xFFF09A4A)),
              _StatCardData('TUNGGAL', '50', Color(0xFFE3BE4F)),
              _StatCardData('TABRAK LARI', '50', Color(0xFFE15B5B)),
            ],
          ),
          _StatColumn(
            label: 'SEPT',
            cards: [
              _StatCardData('JUMLAH KASUS', '30', Color(0xFFE15B5B)),
              _StatCardData('LAKA GANDA', '20', Color(0xFFF09A4A)),
              _StatCardData('TUNGGAL', '5', Color(0xFFE3BE4F)),
              _StatCardData('TABRAK LARI', '5', Color(0xFFE15B5B)),
            ],
          ),
        ];
      case StatisticsModule.simTni:
        return const [
          _StatColumn(
            label: '2026',
            cards: [
              _StatCardData('A', '200', Color(0xFF5D8FE0)),
              _StatCardData('BI', '100', Color(0xFF49A86B)),
              _StatCardData('BII', '50', Color(0xFF5D8FE0)),
              _StatCardData('BII SUS', '25', Color(0xFFF09A4A)),
              _StatCardData('C', '25', Color(0xFF5D8FE0)),
            ],
          ),
          _StatColumn(
            label: 'SEPT',
            cards: [
              _StatCardData('A', '20', Color(0xFF5D8FE0)),
              _StatCardData('BI', '10', Color(0xFF49A86B)),
              _StatCardData('BII', '5', Color(0xFF5D8FE0)),
              _StatCardData('BII SUS', '5', Color(0xFFF09A4A)),
              _StatCardData('C', '5', Color(0xFF5D8FE0)),
            ],
          ),
        ];
      case StatisticsModule.k9:
        return const [];
      case StatisticsModule.provos:
        return const [
          _StatColumn(
            label: '2026',
            cards: [
              _StatCardData('JUMLAH', '2000', Color(0xFF49A86B)),
              _StatCardData('SUDAH DIK/TAR', '500', Color(0xFF49A86B)),
              _StatCardData('BELUM DIK/TAR', '1500', Color(0xFFF09A4A)),
            ],
          ),
          _StatColumn(
            label: 'SEPT',
            cards: [
              _StatCardData('JUMLAH', '250', Color(0xFF49A86B)),
              _StatCardData('SUDAH DIK/TAR', '50', Color(0xFF49A86B)),
              _StatCardData('BELUM DIK/TAR', '200', Color(0xFFF09A4A)),
            ],
          ),
        ];
    }
  }

  List<_RankData> get _ranking {
    switch (module) {
      case StatisticsModule.pelanggaran:
        return const [
          _RankData('POMDAM V/BRW', 130),
          _RankData('POMDAM III/SLW', 85),
          _RankData('POMDAM I/BB', 64),
          _RankData('POMDAM JAYA', 42),
          _RankData('POMDAM IV/DIP', 30),
        ];
      case StatisticsModule.lakaLalin:
        return const [
          _RankData('POMDAM V/BRW', 45),
          _RankData('POMDAM JAYA', 38),
          _RankData('POMDAM I/BB', 30),
          _RankData('POMDAM XII/TPR', 25),
          _RankData('POMDAM III/SLW', 18),
        ];
      case StatisticsModule.simTni:
        return const [
          _RankData('POMDAM JAYA', 450),
          _RankData('POMDAM II/SWJ', 320),
          _RankData('POMDAM V/BRW', 210),
          _RankData('POMDAM I/BB', 190),
          _RankData('POMDAM IM', 110),
        ];
      case StatisticsModule.k9:
        return const [];
      case StatisticsModule.provos:
        return const [
          _RankData('POMDAM III/SLW', 624),
          _RankData('POMDAM V/BRW', 617),
          _RankData('POMDAM I/BB', 535),
          _RankData('POMDAM JAYA', 511),
          _RankData('POMDAM IV/DIP', 463),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasContent = module != StatisticsModule.k9;
    return Scaffold(
      key: ValueKey('statistics-${module.name}'),
      backgroundColor: _bg,
      body: Stack(
        children: [
          const Positioned.fill(child: _StatisticsBackdrop()),
          SafeArea(
            child: Stack(
              children: [
                Positioned.fill(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: Column(
                          children: [
                            SizedBox(
                              width: 170,
                              height: 112,
                              child: ClipRect(
                                child: Transform.scale(
                                  scale: 1.48,
                                  child: Image.asset(
                                    'assets/images/pomad_puspomad.webp',
                                    fit: BoxFit.contain,
                                    semanticLabel: 'Logo PUSPOMAD',
                                  ),
                                ),
                              ),
                            ),
                            if (hasContent)
                              _ContentBody(columns: _columns, ranking: ranking),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 12,
                  child: Material(
                    color: _surface.withValues(alpha: 0.88),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => Navigator.of(context).pop(),
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          color: _goldLight,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContentBody extends StatelessWidget {
  const _ContentBody({required this.columns, required this.ranking});

  final List<_StatColumn> columns;
  final List<_RankData> ranking;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final useTwoColumns = constraints.maxWidth >= 600;
            if (useTwoColumns) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _StatsColumnView(column: columns[0])),
                  const SizedBox(width: 14),
                  Expanded(child: _StatsColumnView(column: columns[1])),
                ],
              );
            }
            return Column(
              children: [
                _StatsColumnView(column: columns[0]),
                const SizedBox(height: 14),
                _StatsColumnView(column: columns[1]),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        if (ranking.isNotEmpty)
          _AnalysisButton(onPressed: () => _showRankingSheet(context, ranking)),
      ],
    );
  }
}

Future<void> _showRankingSheet(
  BuildContext context,
  List<_RankData> ranking,
) async {
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      final maxValue = ranking.fold<int>(
        0,
        (max, item) => item.value > max ? item.value : max,
      );

      return Container(
        height: MediaQuery.sizeOf(context).height * 0.68,
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 26),
        decoration: const BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(top: BorderSide(color: _gold, width: 0.8)),
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Analisis Visual',
              style: TextStyle(
                color: _goldLight,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Top 5 POMDAM',
              style: TextStyle(
                color: _muted,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.4,
              ),
            ),
            const SizedBox(height: 22),
            Expanded(
              child: ListView.separated(
                itemCount: ranking.length,
                separatorBuilder: (_, index) => const SizedBox(height: 18),
                itemBuilder: (context, index) {
                  final item = ranking[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.name,
                              style: const TextStyle(
                                color: _text,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Text(
                            item.value.toString(),
                            style: const TextStyle(
                              color: _goldLight,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          minHeight: 9,
                          value: maxValue == 0 ? 0 : item.value / maxValue,
                          backgroundColor: Colors.black38,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            _goldLight,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _AnalysisButton extends StatelessWidget {
  const _AnalysisButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: onPressed,
      icon: const Icon(Icons.bar_chart_rounded, size: 18),
      label: const Text(
        'ANALISIS STATISTIK',
        style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.7),
      ),
      style: FilledButton.styleFrom(
        backgroundColor: _surface.withValues(alpha: 0.88),
        foregroundColor: _goldLight,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: _gold.withValues(alpha: 0.22)),
        ),
      ),
    );
  }
}

class _StatsColumnView extends StatelessWidget {
  const _StatsColumnView({required this.column});

  final _StatColumn column;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surface.withValues(alpha: 0.56),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _gold.withValues(alpha: 0.13)),
      ),
      child: Column(
        children: [
          Text(
            column.label,
            style: const TextStyle(
              color: _goldLight,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 3.4,
            ),
          ),
          const SizedBox(height: 11),
          for (final card in column.cards) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
              decoration: BoxDecoration(
                color: _surfaceSoft.withValues(alpha: 0.90),
                borderRadius: BorderRadius.circular(15),
                border: Border(left: BorderSide(color: card.color, width: 3)),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      card.label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    card.value,
                    style: TextStyle(
                      color: card.color,
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 9),
          ],
        ],
      ),
    );
  }
}

class _StatColumn {
  const _StatColumn({required this.label, required this.cards});

  final String label;
  final List<_StatCardData> cards;
}

class _StatCardData {
  const _StatCardData(this.label, this.value, this.color);

  final String label;
  final String value;
  final Color color;
}

class _RankData {
  const _RankData(this.name, this.value);

  final String name;
  final int value;
}

class _StatisticsBackdrop extends StatelessWidget {
  const _StatisticsBackdrop();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _StatisticsBackdropPainter());
  }
}

class _StatisticsBackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1;

    paint.color = _gold.withValues(alpha: 0.10);
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(size.width * 0.08, size.height * 0.88),
        radius: size.width * 0.72,
      ),
      -0.8,
      1.5,
      false,
      paint,
    );
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(size.width * 0.95, size.height * 0.15),
        radius: size.width * 0.60,
      ),
      1.9,
      1.0,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
