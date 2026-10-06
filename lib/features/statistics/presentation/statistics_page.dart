import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/app_header.dart';

const _bg = Color(0xFF03150F);
const _surface = Color(0xFF09231A);
const _gold = Color(0xFFD7A93C);
const _emerald = Color(0xFF34D399);
const _text = Color(0xFFF8F5EC);
const _muted = Color(0xFFB7C2BC);

enum StatisticsModule { pelanggaran, lakaLalin, simTni, k9, provos }

Color _moduleAccent(StatisticsModule module) {
  switch (module) {
    case StatisticsModule.pelanggaran:
      return const Color(0xFFF09A4A);
    case StatisticsModule.lakaLalin:
      return const Color(0xFFE15B5B);
    case StatisticsModule.simTni:
      return const Color(0xFF5D8FE0);
    case StatisticsModule.k9:
      return const Color(0xFFE3BE4F);
    case StatisticsModule.provos:
      return const Color(0xFF49A86B);
  }
}

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
              _StatCardData('TATIB', '25', Color(0xFFF59E0B)),
              _StatCardData('LALIN', '70', Color(0xFF38BDF8)),
            ],
          ),
          _StatColumn(
            label: 'SEPT',
            cards: [
              _StatCardData('TATIB', '5', Color(0xFFF59E0B)),
              _StatCardData('LALIN', '10', Color(0xFF38BDF8)),
            ],
          ),
        ];
      case StatisticsModule.lakaLalin:
        return const [
          _StatColumn(
            label: '2026',
            cards: [
              _StatCardData('JUMLAH KASUS', '200', Color(0xFF38BDF8)),
              _StatCardData('LAKA GANDA', '100', Color(0xFFF97316)),
              _StatCardData('TUNGGAL', '50', Color(0xFFF59E0B)),
              _StatCardData('TABRAK LARI', '50', Color(0xFFEF4444)),
            ],
          ),
          _StatColumn(
            label: 'SEPT',
            cards: [
              _StatCardData('JUMLAH KASUS', '30', Color(0xFF38BDF8)),
              _StatCardData('LAKA GANDA', '20', Color(0xFFF97316)),
              _StatCardData('TUNGGAL', '5', Color(0xFFF59E0B)),
              _StatCardData('TABRAK LARI', '5', Color(0xFFEF4444)),
            ],
          ),
        ];
      case StatisticsModule.simTni:
        return const [
          _StatColumn(
            label: '2026',
            cards: [
              _StatCardData('A', '200', Color(0xFF3B82F6)),
              _StatCardData('BI', '100', Color(0xFF06B6D4)),
              _StatCardData('BII', '50', Color(0xFF10B981)),
              _StatCardData('BII SUS', '25', Color(0xFF8B5CF6)),
              _StatCardData('C', '25', Color(0xFF6366F1)),
            ],
          ),
          _StatColumn(
            label: 'SEPT',
            cards: [
              _StatCardData('A', '20', Color(0xFF3B82F6)),
              _StatCardData('BI', '10', Color(0xFF06B6D4)),
              _StatCardData('BII', '5', Color(0xFF10B981)),
              _StatCardData('BII SUS', '5', Color(0xFF8B5CF6)),
              _StatCardData('C', '5', Color(0xFF6366F1)),
            ],
          ),
        ];
      case StatisticsModule.k9:
        return const [
          _StatColumn(
            label: '2026',
            cards: [
              _StatCardData('NYATA', '51', _emerald),
              _StatCardData('SESUAI ORGAS', '33', _gold),
              _StatCardData('KEKURANGAN', '8', Color(0xFFF59E0B)),
              _StatCardData('SATUAN', '4', Color(0xFF7DD3FC)),
            ],
          ),
        ];
      case StatisticsModule.provos:
        return [
          _StatColumn(
            label: DateTime.now().year.toString(),
            cards: [
              _StatCardData('JUMLAH', '2000', Color(0xFF94A3B8)),
              _StatCardData('SUDAH DIK/TAR', '500', Color(0xFF10B981)),
              _StatCardData('BELUM DIK/TAR', '1500', Color(0xFFF59E0B)),
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
        return const [
          _RankData('POMDAM V/BRW', 19),
          _RankData('YONPOMAD PUSPOMAD', 17),
          _RankData('POMDAM JAYA', 10),
          _RankData('POMDAM XII/TPR', 5),
        ];
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

  String get _title {
    switch (module) {
      case StatisticsModule.pelanggaran:
        return 'PELANGGARAN';
      case StatisticsModule.lakaLalin:
        return 'LAKA-LALIN';
      case StatisticsModule.simTni:
        return 'SIM TNI';
      case StatisticsModule.k9:
        return 'K9';
      case StatisticsModule.provos:
        return 'PROVOS TNI-AD';
    }
  }

  Future<void> _signOut(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final columns = _columns;
    assert(columns.isNotEmpty);
    assert(columns.every((column) => column.cards.isNotEmpty));

    return Scaffold(
      key: ValueKey('statistics-${module.name}'),
      backgroundColor: _bg,
      appBar: AppHeader(
        title: _title,
        subtitle: 'PUSPOMAD',
        onSignOut: () => _signOut(context),
        onBack: () => Navigator.of(context).pop(),
      ),
      body: AppBackground(
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: _ContentBody(
                  columns: columns,
                  module: module,
                  ranking: _ranking,
                  accent: _moduleAccent(module),
                  totalSim: module == StatisticsModule.simTni
                      ? columns.first.cards.fold<int>(
                          0,
                          (sum, card) => sum + (int.tryParse(card.value) ?? 0),
                        )
                      : null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ContentBody extends StatelessWidget {
  const _ContentBody({
    required this.columns,
    required this.module,
    required this.ranking,
    required this.accent,
    this.totalSim,
  });

  final List<_StatColumn> columns;
  final StatisticsModule module;
  final List<_RankData> ranking;
  final Color accent;
  final int? totalSim;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (totalSim != null) ...[
          _TotalSimCard(total: totalSim!, accent: accent),
          const SizedBox(height: 14),
        ],
        if (columns.length == 1)
          _StatsColumnView(column: columns.first, accent: accent)
        else
          Row(
            key: const ValueKey('report-period-columns'),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var index = 0; index < columns.length; index++) ...[
                if (index > 0) const SizedBox(width: 16),
                Expanded(
                  child: _StatsColumnView(
                    column: columns[index],
                    accent: accent,
                  ),
                ),
              ],
            ],
          ),
        const SizedBox(height: 16),
        if (ranking.isNotEmpty)
          _AnalysisButton(
            accent: accent,
            label: module == StatisticsModule.k9
                ? 'ANALISIS STATISTIK'
                : 'STATISTIK',
            onPressed: () => _showRankingSheet(
              context,
              module,
              ranking,
              accent,
              onItemTap: module == StatisticsModule.k9
                  ? (index) => _showK9UnitSheet(context, _k9Units[index])
                  : null,
            ),
          ),
      ],
    );
  }
}

class _TotalSimCard extends StatelessWidget {
  const _TotalSimCard({required this.total, required this.accent});

  final int total;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('sim-total-card'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.10),
            Colors.white.withValues(alpha: 0.035),
            _surface.withValues(alpha: 0.76),
          ],
          stops: const [0.0, 0.36, 1.0],
        ),
        borderRadius: BorderRadius.circular(6.4),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.045),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
          const BoxShadow(
            color: Colors.black26,
            blurRadius: 14,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'TOTAL SIM',
            style: TextStyle(
              color: _muted,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
            ),
          ),
          Text(
            total.toString(),
            style: TextStyle(
              color: accent,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _showRankingSheet(
  BuildContext context,
  StatisticsModule module,
  List<_RankData> ranking,
  Color accent, {
  Future<void> Function(int index)? onItemTap,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      final maxValue = ranking.fold<int>(
        0,
        (max, item) => item.value > max ? item.value : max,
      );
      final title = _moduleTitleForSheet(module);

      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            height: MediaQuery.sizeOf(context).height * 0.70,
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.05),
                  _surface.withValues(alpha: 0.92),
                  accent.withValues(alpha: 0.08),
                ],
              ),
              border: Border(
                top: BorderSide(
                  color: accent.withValues(alpha: 0.28),
                  width: 1,
                ),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 30,
                  offset: Offset(0, -10),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 6,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ANALISIS VISUAL',
                            style: TextStyle(
                              color: accent,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                              height: 1.05,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            module == StatisticsModule.k9
                                ? 'DATA K-9'
                                : 'TOP 5 POMDAM - $title',
                            style: const TextStyle(
                              color: _muted,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      tooltip: 'TUTUP',
                      onPressed: () => Navigator.of(context).pop(),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.05),
                        foregroundColor: _text,
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.10),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.4),
                        ),
                      ),
                      icon: const Icon(Icons.close_rounded, size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Expanded(
                  child: ListView.separated(
                    itemCount: ranking.length,
                    separatorBuilder: (_, index) => const SizedBox(height: 20),
                    itemBuilder: (context, index) {
                      final item = ranking[index];
                      final fill = index == 0 ? accent : _emerald;
                      final width = maxValue == 0 ? 0.0 : item.value / maxValue;

                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: width),
                        duration: Duration(milliseconds: 750 + index * 120),
                        curve: Curves.easeOutCubic,
                        builder: (context, progress, _) {
                          final content = Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.name,
                                      style: const TextStyle(
                                        color: _text,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    item.value.toString(),
                                    style: TextStyle(
                                      color: accent,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 7),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6.4),
                                child: Container(
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.22),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.05,
                                      ),
                                    ),
                                  ),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: progress,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            fill.withValues(alpha: 0.95),
                                            accent.withValues(alpha: 0.75),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );

                          return onItemTap == null
                              ? content
                              : InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () => onItemTap(index),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 3,
                                    ),
                                    child: content,
                                  ),
                                );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

String _moduleTitleForSheet(StatisticsModule module) {
  switch (module) {
    case StatisticsModule.pelanggaran:
      return 'PELANGGARAN';
    case StatisticsModule.lakaLalin:
      return 'LAKA-LALIN';
    case StatisticsModule.simTni:
      return 'SIM TNI';
    case StatisticsModule.k9:
      return 'K9';
    case StatisticsModule.provos:
      return 'PROVOS TNI-AD';
  }
}

class _AnalysisButton extends StatelessWidget {
  const _AnalysisButton({
    required this.onPressed,
    required this.accent,
    this.label = 'STATISTIK',
  });

  final VoidCallback onPressed;
  final Color accent;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.03),
          foregroundColor: accent,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          side: BorderSide(color: accent.withValues(alpha: 0.32)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.4),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.bar_chart_rounded, size: 17, color: accent),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.6,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: accent.withValues(alpha: 0.52),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsColumnView extends StatelessWidget {
  const _StatsColumnView({required this.column, required this.accent});

  final _StatColumn column;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          column.label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _gold,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 8),
        for (var index = 0; index < column.cards.length; index++) ...[
          _AnimatedStatCard(
            card: column.cards[index],
            accent: accent,
            delay: Duration(milliseconds: index * 75),
          ),
          if (index != column.cards.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _AnimatedStatCard extends StatelessWidget {
  const _AnimatedStatCard({
    required this.card,
    required this.accent,
    required this.delay,
  });

  final _StatCardData card;
  final Color accent;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 720),
      curve: Curves.easeOutCubic,
      child: _GlassStatCard(card: card, accent: accent),
      builder: (context, value, child) {
        final progress = ((value * 1.18) - delay.inMilliseconds / 820).clamp(
          0.0,
          1.0,
        );
        return Opacity(
          opacity: progress,
          child: Transform.translate(
            offset: Offset(
              0,
              (1 - Curves.easeOutCubic.transform(progress)) * 16,
            ),
            child: Transform.scale(
              scale: 0.965 + progress * 0.035,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class _GlassStatCard extends StatelessWidget {
  const _GlassStatCard({required this.card, this.accent});

  final _StatCardData card;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final cardAccent = card.color;
    final lineAccent = accent ?? cardAccent;
    return ClipRRect(
      borderRadius: BorderRadius.circular(6.4),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 90),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.032),
                cardAccent.withValues(alpha: 0.045),
                _surface.withValues(alpha: 0.72),
              ],
              stops: const [0.0, 0.34, 1.0],
            ),
            // The accent remains the actual left edge of the card. It is not
            // a floating/translated overlay, so it cannot drift from position.
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
              right: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
              bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
              left: BorderSide(color: lineAccent, width: 3),
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 30,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -14,
                bottom: -14,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      center: Alignment.topLeft,
                      radius: 1.0,
                      colors: [
                        cardAccent.withValues(alpha: 0.038),
                        cardAccent.withValues(alpha: 0.009),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.58, 1.0],
                    ),
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.45,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    card.value,
                    style: TextStyle(
                      color: cardAccent,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.6,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _k9Units = <_K9UnitData>[
  _K9UnitData(name: 'POMDAM V/BRW', actual: 19, org: null, shortage: null),
  _K9UnitData(name: 'YONPOMAD PUSPOMAD', actual: 17, org: 12, shortage: null),
  _K9UnitData(name: 'POMDAM JAYA', actual: 10, org: 18, shortage: 8),
  _K9UnitData(name: 'POMDAM XII/TPR', actual: 5, org: 3, shortage: null),
];

class _K9UnitData {
  const _K9UnitData({
    required this.name,
    required this.actual,
    required this.org,
    required this.shortage,
  });

  final String name;
  final int actual;
  final int? org;
  final int? shortage;
}

Future<void> _showK9UnitSheet(BuildContext context, _K9UnitData unit) async {
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      final accent = _moduleAccent(StatisticsModule.k9);
      final cards = <_StatCardData>[
        _StatCardData('NYATA', unit.actual.toString(), _emerald),
        if (unit.org != null)
          _StatCardData('SESUAI ORGAS', unit.org.toString(), _gold),
        if (unit.shortage != null)
          _StatCardData(
            'KEKURANGAN',
            unit.shortage.toString(),
            const Color(0xFFF59E0B),
          ),
      ];

      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            height: MediaQuery.sizeOf(context).height * 0.48,
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.05),
                  _surface.withValues(alpha: 0.92),
                  accent.withValues(alpha: 0.08),
                ],
              ),
              border: Border(
                top: BorderSide(
                  color: accent.withValues(alpha: 0.28),
                  width: 1,
                ),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 30,
                  offset: Offset(0, -10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 6,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                Text(
                  unit.name,
                  style: const TextStyle(
                    color: Color(0xFFF1D37A),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.7,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'DATA K-9',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    for (var i = 0; i < cards.length; i++) ...[
                      if (i > 0) const SizedBox(width: 10),
                      Expanded(
                        child: _GlassStatCard(card: cards[i], accent: accent),
                      ),
                    ],
                  ],
                ),
                if (unit.org == null || unit.shortage == null) ...[
                  const SizedBox(height: 12),
                  Text(
                    unit.org == null
                        ? 'ORGANISASI K9 BELUM DICANTUMKAN PADA DATA SATUAN INI.'
                        : 'KEKURANGAN TIDAK TERCATAT PADA DATA SATUAN INI.',
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    },
  );
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
