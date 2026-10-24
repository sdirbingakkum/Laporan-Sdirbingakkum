import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

bool _supportsPeriodSelector(StatisticsModule module) {
  return module == StatisticsModule.pelanggaran ||
      module == StatisticsModule.lakaLalin ||
      module == StatisticsModule.simTni;
}

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

class StatisticsPeriodOption {
  const StatisticsPeriodOption({
    required this.key,
    required this.label,
    required this.startMonth,
    required this.endMonth,
  });

  final String key;
  final String label;
  final int startMonth;
  final int endMonth;
}

class StatisticsViewData {
  const StatisticsViewData({
    required this.columns,
    required this.ranking,
    this.totalSim,
    this.periodOptions = const [],
    this.selectedPeriodKey,
  });

  final List<StatisticsColumnData> columns;
  final List<StatisticsRankData> ranking;
  final int? totalSim;
  final List<StatisticsPeriodOption> periodOptions;
  final String? selectedPeriodKey;
}

class StatisticsColumnData {
  const StatisticsColumnData({required this.label, required this.cards});

  final String label;
  final List<StatisticsCardData> cards;
}

class StatisticsCardData {
  const StatisticsCardData({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;
}

class StatisticsRankData {
  const StatisticsRankData(this.name, this.value);

  final String name;
  final int value;
}

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({
    required this.module,
    this.dataLoader,
    this.periodDataLoader,
    super.key,
  });

  final StatisticsModule module;
  final Future<StatisticsViewData> Function(StatisticsModule module)?
  dataLoader;
  final Future<StatisticsViewData> Function(
    StatisticsModule module,
    String periodKey,
  )?
  periodDataLoader;

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  late Future<StatisticsViewData> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = (widget.dataLoader ?? _SupabaseReportRepository.load)(
      widget.module,
    );
  }

  void _changeComparisonPeriod(String periodKey) {
    setState(() {
      final periodDataLoader = widget.periodDataLoader;
      if (periodDataLoader != null) {
        _dataFuture = periodDataLoader(widget.module, periodKey);
      } else if (widget.dataLoader != null) {
        _dataFuture = widget.dataLoader!(widget.module);
      } else {
        _dataFuture = _SupabaseReportRepository.loadForPeriod(
          widget.module,
          periodKey,
        );
      }
    });
  }

  Future<void> _signOut(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
  }

  String get _title {
    switch (widget.module) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: ValueKey('statistics-${widget.module.name}'),
      backgroundColor: _bg,
      appBar: AppHeader(
        title: _title,
        subtitle: 'PUSPOMAD',
        onSignOut: () => _signOut(context),
        onBack: () => context.pop(),
      ),
      body: AppBackground(
        child: SafeArea(
          top: false,
          child: FutureBuilder<StatisticsViewData>(
            future: _dataFuture,
            builder: (context, snapshot) {
              Widget content;
              if (snapshot.connectionState == ConnectionState.waiting) {
                content = const Center(
                  key: ValueKey('statistics-loading'),
                  child: CircularProgressIndicator(
                    color: Color(0xFFF1D37A),
                    strokeWidth: 2.2,
                  ),
                );
              } else if (snapshot.hasError || snapshot.data == null) {
                content = const _ReportDataError(
                  key: ValueKey('statistics-error'),
                );
              } else {
                final data = snapshot.data!;
                content = SingleChildScrollView(
                  key: const ValueKey('statistics-content'),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: _ContentBody(
                        columns: data.columns
                            .map(
                              (column) => _StatColumn(
                                label: column.label,
                                cards: column.cards
                                    .map(
                                      (card) => _StatCardData(
                                        card.label,
                                        card.value,
                                        card.color,
                                      ),
                                    )
                                    .toList(),
                              ),
                            )
                            .toList(),
                        module: widget.module,
                        ranking: data.ranking
                            .map((item) => _RankData(item.name, item.value))
                            .toList(),
                        accent: _moduleAccent(widget.module),
                        totalSim: data.totalSim,
                        periodOptions: data.periodOptions,
                        selectedPeriodKey: data.selectedPeriodKey,
                        onPeriodChanged: _supportsPeriodSelector(widget.module)
                            ? _changeComparisonPeriod
                            : null,
                      ),
                    ),
                  ),
                );
              }

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 320),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: content,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PelanggaranSourceData {
  const _PelanggaranSourceData({
    required this.periods,
    required this.pomdams,
    required this.rows,
    required this.categoryByViolationId,
  });

  final _ReportPeriodIndex periods;
  final Map<String, String> pomdams;
  final List<Map<String, dynamic>> rows;
  final Map<String, String> categoryByViolationId;
}

class _PeriodSourceData {
  const _PeriodSourceData({
    required this.periods,
    required this.pomdams,
    required this.rows,
    required this.typeById,
  });

  final _ReportPeriodIndex periods;
  final Map<String, String> pomdams;
  final List<Map<String, dynamic>> rows;
  final Map<String, String> typeById;
}

class _LatestReportMonth {
  const _LatestReportMonth(this.year, this.month);

  final int year;
  final int month;
}

class _ReportPeriodIndex {
  const _ReportPeriodIndex(this.byId);

  final Map<String, Map<String, dynamic>> byId;
}

class _SupabaseReportRepository {
  static int _toInt(dynamic value) {
    return value is num
        ? value.toInt()
        : int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static Future<_ReportPeriodIndex> _periods(SupabaseClient client) async {
    final rows = List<Map<String, dynamic>>.from(
      await client.from('report_periods').select('id,report_year,report_month'),
    );
    return _ReportPeriodIndex({
      for (final row in rows) row['id'].toString(): row,
    });
  }

  static Future<Map<String, String>> _pomdams(SupabaseClient client) async {
    final rows = List<Map<String, dynamic>>.from(
      await client.from('pomdams').select('id,code'),
    );
    return {
      for (final row in rows) row['id'].toString(): row['code'].toString(),
    };
  }

  static Future<_PelanggaranSourceData>? _pelanggaranSourceFuture;

  static Future<_PelanggaranSourceData> _loadPelanggaranSource(
    SupabaseClient client,
  ) async {
    try {
      return await (_pelanggaranSourceFuture ??= _fetchPelanggaranSource(
        client,
      ));
    } catch (_) {
      _pelanggaranSourceFuture = null;
      rethrow;
    }
  }

  static Future<_PelanggaranSourceData> _fetchPelanggaranSource(
    SupabaseClient client,
  ) async {
    final periods = await _periods(client);
    final pomdams = await _pomdams(client);
    const pageSize = 1000;
    final rows = <Map<String, dynamic>>[];

    // PostgREST may cap a response at 1,000 rows. Fetch stable, ordered pages
    // so totals and rankings include every record, not only the first page.
    for (var start = 0; ; start += pageSize) {
      final page = List<Map<String, dynamic>>.from(
        await client
            .from('violation_records')
            .select('id,period_id,pomdam_id,violation_id,value,data_status')
            .order('id')
            .range(start, start + pageSize - 1),
      );
      rows.addAll(page);
      if (page.length < pageSize) break;
    }

    final violations = List<Map<String, dynamic>>.from(
      await client.from('violations').select('id,category'),
    );
    final categoryByViolationId = <String, String>{
      for (final row in violations)
        row['id'].toString(): row['category']?.toString().toUpperCase() ?? '',
    };

    return _PelanggaranSourceData(
      periods: periods,
      pomdams: pomdams,
      rows: rows,
      categoryByViolationId: categoryByViolationId,
    );
  }

  static Future<StatisticsViewData> load(StatisticsModule module) async {
    final client = Supabase.instance.client;

    switch (module) {
      case StatisticsModule.pelanggaran:
        return _loadPelanggaran(client);
      case StatisticsModule.lakaLalin:
        return _loadLaka(client);
      case StatisticsModule.simTni:
        return _loadSim(client);
      case StatisticsModule.k9:
        return _loadK9();
      case StatisticsModule.provos:
        return _loadProvos(client);
    }
  }

  static Future<StatisticsViewData> loadForPeriod(
    StatisticsModule module,
    String periodKey,
  ) async {
    final client = Supabase.instance.client;
    switch (module) {
      case StatisticsModule.pelanggaran:
        return _loadPelanggaran(client, selectedPeriodKey: periodKey);
      case StatisticsModule.lakaLalin:
        return _loadLaka(client, selectedPeriodKey: periodKey);
      case StatisticsModule.simTni:
        return _loadSim(client, selectedPeriodKey: periodKey);
      case StatisticsModule.k9:
      case StatisticsModule.provos:
        return load(module);
    }
  }

  static const _monthShortNames = <String>[
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MEI',
    'JUN',
    'JUL',
    'AGU',
    'SEP',
    'OKT',
    'NOV',
    'DES',
  ];

  static List<StatisticsPeriodOption> _periodOptions(int latestMonth) {
    final options = <StatisticsPeriodOption>[];

    // The most recent month is shown first so it is easy to return to default.
    for (var month = latestMonth; month >= 1; month--) {
      options.add(
        StatisticsPeriodOption(
          key: 'month:$month',
          label: _monthShortNames[month - 1],
          startMonth: month,
          endMonth: month,
        ),
      );
    }

    const roman = <String>['I', 'II', 'III', 'IV'];
    for (var quarter = latestMonth ~/ 3; quarter >= 1; quarter--) {
      final startMonth = (quarter - 1) * 3 + 1;
      final endMonth = quarter * 3;
      options.add(
        StatisticsPeriodOption(
          key: 'quarter:$quarter',
          label: 'TRIWULAN ${roman[quarter - 1]}',
          startMonth: startMonth,
          endMonth: endMonth,
        ),
      );
    }

    for (var semester = latestMonth ~/ 6; semester >= 1; semester--) {
      final startMonth = (semester - 1) * 6 + 1;
      final endMonth = semester * 6;
      options.add(
        StatisticsPeriodOption(
          key: 'semester:$semester',
          label: 'SEMESTER ${semester == 1 ? 'I' : 'II'}',
          startMonth: startMonth,
          endMonth: endMonth,
        ),
      );
    }

    return options;
  }

  static Future<StatisticsViewData> _loadPelanggaran(
    SupabaseClient client, {
    String? selectedPeriodKey,
  }) async {
    final source = await _loadPelanggaranSource(client);
    final periods = source.periods;
    final pomdams = source.pomdams;
    final rows = source.rows;
    final categoryByViolationId = source.categoryByViolationId;

    int? latestYear;
    int? latestMonth;
    for (final row in rows) {
      final period = periods.byId[row['period_id']?.toString()];
      if (period == null) continue;
      final year = _toInt(period['report_year']);
      final month = _toInt(period['report_month']);
      if (year <= 0 || month < 1 || month > 12) continue;
      if (latestYear == null ||
          year > latestYear ||
          (year == latestYear && month > latestMonth!)) {
        latestYear = year;
        latestMonth = month;
      }
    }

    if (latestYear == null || latestMonth == null) {
      return StatisticsViewData(
        columns: [
          StatisticsColumnData(
            label: 'BELUM ADA DATA',
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
    }

    final reportYear = latestYear;
    final reportMonth = latestMonth;
    final options = _periodOptions(reportMonth);
    final requestedKey = selectedPeriodKey ?? 'month:$reportMonth';
    StatisticsPeriodOption? selectedOption;
    for (final option in options) {
      if (option.key == requestedKey) {
        selectedOption = option;
        break;
      }
    }
    selectedOption ??= options.first;

    int sum({
      required int startMonth,
      required int endMonth,
      String? category,
    }) {
      var total = 0;
      for (final row in rows) {
        if (row['data_status'] != 'VALID') continue;
        final period = periods.byId[row['period_id']?.toString()];
        if (period == null || _toInt(period['report_year']) != reportYear) {
          continue;
        }
        final month = _toInt(period['report_month']);
        if (month < startMonth || month > endMonth) continue;
        if (category != null &&
            categoryByViolationId[row['violation_id']?.toString()] !=
                category) {
          continue;
        }
        total += _toInt(row['value']);
      }
      return total;
    }

    final yearToDateLabel =
        '$reportYear · JAN–${_monthShortNames[reportMonth - 1]}';
    return StatisticsViewData(
      columns: [
        StatisticsColumnData(
          label: yearToDateLabel,
          cards: [
            StatisticsCardData(
              label: 'TATIB',
              value: sum(
                startMonth: 1,
                endMonth: reportMonth,
                category: 'B',
              ).toString(),
              color: const Color(0xFFF59E0B),
            ),
            StatisticsCardData(
              label: 'LALIN',
              value: sum(
                startMonth: 1,
                endMonth: reportMonth,
                category: 'C',
              ).toString(),
              color: const Color(0xFF38BDF8),
            ),
          ],
        ),
        StatisticsColumnData(
          label: selectedOption.label,
          cards: [
            StatisticsCardData(
              label: 'TATIB',
              value: sum(
                startMonth: selectedOption.startMonth,
                endMonth: selectedOption.endMonth,
                category: 'B',
              ).toString(),
              color: const Color(0xFFF59E0B),
            ),
            StatisticsCardData(
              label: 'LALIN',
              value: sum(
                startMonth: selectedOption.startMonth,
                endMonth: selectedOption.endMonth,
                category: 'C',
              ).toString(),
              color: const Color(0xFF38BDF8),
            ),
          ],
        ),
      ],
      ranking: _topFiveForRange(
        rows,
        periods,
        pomdams,
        year: reportYear,
        startMonth: selectedOption.startMonth,
        endMonth: selectedOption.endMonth,
      ),
      periodOptions: options,
      selectedPeriodKey: selectedOption.key,
    );
  }

  static List<StatisticsRankData> _topFiveForRange(
    List<Map<String, dynamic>> rows,
    _ReportPeriodIndex periods,
    Map<String, String> pomdams, {
    required int year,
    required int startMonth,
    required int endMonth,
  }) {
    final totals = <String, int>{};
    for (final row in rows) {
      if (row['data_status'] != 'VALID') continue;
      final period = periods.byId[row['period_id']?.toString()];
      if (period == null || _toInt(period['report_year']) != year) continue;
      final month = _toInt(period['report_month']);
      if (month < startMonth || month > endMonth) continue;
      final code = pomdams[row['pomdam_id']?.toString()];
      if (code == null || code.isEmpty) continue;
      totals[code] = (totals[code] ?? 0) + _toInt(row['value']);
    }

    final ranked = totals.entries.toList()
      ..sort((a, b) {
        final result = b.value.compareTo(a.value);
        return result != 0 ? result : a.key.compareTo(b.key);
      });

    return [
      for (final entry in ranked.take(5))
        StatisticsRankData(entry.key, entry.value),
    ];
  }

  static Future<_PeriodSourceData>? _lakaSourceFuture;
  static Future<_PeriodSourceData>? _simSourceFuture;

  static Future<List<Map<String, dynamic>>> _fetchAllRows(
    SupabaseClient client,
    String table,
    String columns,
  ) async {
    const pageSize = 1000;
    final rows = <Map<String, dynamic>>[];
    for (var start = 0; ; start += pageSize) {
      final page = List<Map<String, dynamic>>.from(
        await client
            .from(table)
            .select(columns)
            .order('id')
            .range(start, start + pageSize - 1),
      );
      rows.addAll(page);
      if (page.length < pageSize) break;
    }
    return rows;
  }

  static Future<_PeriodSourceData> _fetchPeriodSource(
    SupabaseClient client, {
    required String table,
    required String columns,
    required String typeTable,
  }) async {
    final periods = await _periods(client);
    final pomdams = await _pomdams(client);
    final rows = await _fetchAllRows(client, table, columns);
    final types = List<Map<String, dynamic>>.from(
      await client.from(typeTable).select('id,code'),
    );
    return _PeriodSourceData(
      periods: periods,
      pomdams: pomdams,
      rows: rows,
      typeById: {
        for (final row in types)
          row['id'].toString(): row['code']?.toString() ?? '',
      },
    );
  }

  static Future<_PeriodSourceData> _loadLakaSource(
    SupabaseClient client,
  ) async {
    try {
      return await (_lakaSourceFuture ??= _fetchPeriodSource(
        client,
        table: 'laka_accident_records',
        columns: 'id,period_id,pomdam_id,accident_type_id,value,data_status',
        typeTable: 'accident_types',
      ));
    } catch (_) {
      _lakaSourceFuture = null;
      rethrow;
    }
  }

  static Future<_PeriodSourceData> _loadSimSource(SupabaseClient client) async {
    try {
      return await (_simSourceFuture ??= _fetchPeriodSource(
        client,
        table: 'sim_records',
        columns: 'id,period_id,pomdam_id,sim_type_id,value,data_status',
        typeTable: 'sim_types',
      ));
    } catch (_) {
      _simSourceFuture = null;
      rethrow;
    }
  }

  static _LatestReportMonth? _latestReportingMonth(
    List<Map<String, dynamic>> rows,
    _ReportPeriodIndex periods,
  ) {
    int? latestYear;
    int? latestMonth;
    for (final row in rows) {
      if (row['data_status'] != 'VALID') continue;
      final period = periods.byId[row['period_id']?.toString()];
      if (period == null) continue;
      final year = _toInt(period['report_year']);
      final month = _toInt(period['report_month']);
      if (year <= 0 || month < 1 || month > 12) continue;
      if (latestYear == null ||
          year > latestYear ||
          (year == latestYear && month > latestMonth!)) {
        latestYear = year;
        latestMonth = month;
      }
    }
    if (latestYear == null || latestMonth == null) return null;
    return _LatestReportMonth(latestYear, latestMonth);
  }

  static StatisticsPeriodOption _resolveSelectedPeriod(
    List<StatisticsPeriodOption> options,
    int latestMonth,
    String? requestedKey,
  ) {
    final key = requestedKey ?? 'month:$latestMonth';
    for (final option in options) {
      if (option.key == key) return option;
    }
    return options.first;
  }

  static Future<StatisticsViewData> _loadLaka(
    SupabaseClient client, {
    String? selectedPeriodKey,
  }) async {
    final source = await _loadLakaSource(client);
    final periods = source.periods;
    final pomdams = source.pomdams;
    final rows = source.rows;
    final typeById = source.typeById;
    final latest = _latestReportingMonth(rows, periods);
    if (latest == null) {
      return const StatisticsViewData(
        columns: [
          StatisticsColumnData(
            label: 'BELUM ADA DATA',
            cards: [
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
        ranking: [],
      );
    }

    final options = _periodOptions(latest.month);
    final selected = _resolveSelectedPeriod(
      options,
      latest.month,
      selectedPeriodKey,
    );

    int sum({required int startMonth, required int endMonth, String? type}) {
      var total = 0;
      for (final row in rows) {
        if (row['data_status'] != 'VALID') continue;
        final period = periods.byId[row['period_id']?.toString()];
        if (period == null || _toInt(period['report_year']) != latest.year) {
          continue;
        }
        final month = _toInt(period['report_month']);
        if (month < startMonth || month > endMonth) continue;
        if (type != null &&
            typeById[row['accident_type_id']?.toString()] != type) {
          continue;
        }
        total += _toInt(row['value']);
      }
      return total;
    }

    List<StatisticsCardData> cardsForRange(int startMonth, int endMonth) => [
      StatisticsCardData(
        label: 'JUMLAH KASUS',
        value: sum(startMonth: startMonth, endMonth: endMonth).toString(),
        color: const Color(0xFF38BDF8),
      ),
      StatisticsCardData(
        label: 'LAKA GANDA',
        value: sum(
          startMonth: startMonth,
          endMonth: endMonth,
          type: 'GANDA',
        ).toString(),
        color: const Color(0xFFF97316),
      ),
      StatisticsCardData(
        label: 'TUNGGAL',
        value: sum(
          startMonth: startMonth,
          endMonth: endMonth,
          type: 'TUNGGAL',
        ).toString(),
        color: const Color(0xFFF59E0B),
      ),
      StatisticsCardData(
        label: 'TABRAK LARI',
        value: sum(
          startMonth: startMonth,
          endMonth: endMonth,
          type: 'TABRAK_LARI',
        ).toString(),
        color: const Color(0xFFEF4444),
      ),
    ];

    return StatisticsViewData(
      columns: [
        StatisticsColumnData(
          label: '${latest.year} · JAN–${_monthShortNames[latest.month - 1]}',
          cards: cardsForRange(1, latest.month),
        ),
        StatisticsColumnData(
          label: selected.label,
          cards: cardsForRange(selected.startMonth, selected.endMonth),
        ),
      ],
      ranking: _topFiveForRange(
        rows,
        periods,
        pomdams,
        year: latest.year,
        startMonth: selected.startMonth,
        endMonth: selected.endMonth,
      ),
      periodOptions: options,
      selectedPeriodKey: selected.key,
    );
  }

  static Future<StatisticsViewData> _loadSim(
    SupabaseClient client, {
    String? selectedPeriodKey,
  }) async {
    final source = await _loadSimSource(client);
    final periods = source.periods;
    final pomdams = source.pomdams;
    final rows = source.rows;
    final typeById = source.typeById;
    final latest = _latestReportingMonth(rows, periods);
    if (latest == null) {
      return const StatisticsViewData(
        columns: [
          StatisticsColumnData(
            label: 'BELUM ADA DATA',
            cards: [
              StatisticsCardData(
                label: 'A',
                value: '0',
                color: Color(0xFF3B82F6),
              ),
              StatisticsCardData(
                label: 'BI',
                value: '0',
                color: Color(0xFF06B6D4),
              ),
              StatisticsCardData(
                label: 'BII',
                value: '0',
                color: Color(0xFF10B981),
              ),
              StatisticsCardData(
                label: 'BII SUS',
                value: '0',
                color: Color(0xFF8B5CF6),
              ),
              StatisticsCardData(
                label: 'C',
                value: '0',
                color: Color(0xFF6366F1),
              ),
            ],
          ),
        ],
        ranking: [],
        totalSim: 0,
      );
    }

    final options = _periodOptions(latest.month);
    final selected = _resolveSelectedPeriod(
      options,
      latest.month,
      selectedPeriodKey,
    );

    int sum({
      required int startMonth,
      required int endMonth,
      required String code,
    }) {
      var total = 0;
      for (final row in rows) {
        if (row['data_status'] != 'VALID') continue;
        final period = periods.byId[row['period_id']?.toString()];
        if (period == null || _toInt(period['report_year']) != latest.year) {
          continue;
        }
        final month = _toInt(period['report_month']);
        if (month < startMonth || month > endMonth) continue;
        if (typeById[row['sim_type_id']?.toString()] != code) continue;
        total += _toInt(row['value']);
      }
      return total;
    }

    const definitions = <({String label, String code, Color color})>[
      (label: 'A', code: 'A', color: Color(0xFF3B82F6)),
      (label: 'BI', code: 'BI', color: Color(0xFF06B6D4)),
      (label: 'BII', code: 'BII', color: Color(0xFF10B981)),
      (label: 'BII SUS', code: 'BII_KHUSUS', color: Color(0xFF8B5CF6)),
      (label: 'C', code: 'C', color: Color(0xFF6366F1)),
    ];

    List<StatisticsCardData> cardsForRange(int startMonth, int endMonth) => [
      for (final definition in definitions)
        StatisticsCardData(
          label: definition.label,
          value: sum(
            startMonth: startMonth,
            endMonth: endMonth,
            code: definition.code,
          ).toString(),
          color: definition.color,
        ),
    ];

    final comparisonCards = cardsForRange(
      selected.startMonth,
      selected.endMonth,
    );
    final selectedTotal = comparisonCards.fold<int>(
      0,
      (sum, card) => sum + _toInt(card.value),
    );

    return StatisticsViewData(
      columns: [
        StatisticsColumnData(
          label: '${latest.year} · JAN–${_monthShortNames[latest.month - 1]}',
          cards: cardsForRange(1, latest.month),
        ),
        StatisticsColumnData(label: selected.label, cards: comparisonCards),
      ],
      ranking: _topFiveForRange(
        rows,
        periods,
        pomdams,
        year: latest.year,
        startMonth: selected.startMonth,
        endMonth: selected.endMonth,
      ),
      totalSim: selectedTotal,
      periodOptions: options,
      selectedPeriodKey: selected.key,
    );
  }

  static Future<StatisticsViewData> _loadK9() async {
    const units = _k9Units;
    final cards = [
      StatisticsCardData(
        label: 'NYATA',
        value: units.fold<int>(0, (sum, unit) => sum + unit.actual).toString(),
        color: _emerald,
      ),
      StatisticsCardData(
        label: 'SESUAI ORGAS',
        value: units
            .where((unit) => unit.org != null)
            .fold<int>(0, (sum, unit) => sum + unit.org!)
            .toString(),
        color: _gold,
      ),
      StatisticsCardData(
        label: 'KEKURANGAN',
        value: units
            .where((unit) => unit.shortage != null)
            .fold<int>(0, (sum, unit) => sum + unit.shortage!)
            .toString(),
        color: const Color(0xFFF59E0B),
      ),
      StatisticsCardData(
        label: 'SATUAN',
        value: units.length.toString(),
        color: const Color(0xFF7DD3FC),
      ),
    ];

    return StatisticsViewData(
      columns: [StatisticsColumnData(label: '2026', cards: cards)],
      ranking: const [
        StatisticsRankData('POMDAM V/BRW', 19),
        StatisticsRankData('YONPOMAD PUSPOMAD', 17),
        StatisticsRankData('POMDAM JAYA', 10),
        StatisticsRankData('POMDAM XII/TPR', 5),
      ],
    );
  }

  static Future<StatisticsViewData> _loadProvos(SupabaseClient client) async {
    final periods = await _periods(client);
    final pomdams = await _pomdams(client);
    final personnelRows = await _fetchAllRows(
      client,
      'provos_personnel_records',
      'id,period_id,pomdam_id,value,data_status',
    );
    final educationRows = await _fetchAllRows(
      client,
      'provos_education_records',
      'id,period_id,pomdam_id,education_status_id,value,data_status',
    );
    final statuses = List<Map<String, dynamic>>.from(
      await client.from('education_statuses').select('id,code'),
    );
    final statusById = <String, String>{
      for (final row in statuses)
        row['id'].toString(): row['code'].toString().toUpperCase(),
    };

    final latest = _latestReportingMonth([
      ...personnelRows,
      ...educationRows,
    ], periods);
    if (latest == null) {
      return const StatisticsViewData(
        columns: [
          StatisticsColumnData(
            label: 'BELUM ADA DATA',
            cards: [
              StatisticsCardData(
                label: 'JUMLAH',
                value: '0',
                color: Color(0xFF94A3B8),
              ),
              StatisticsCardData(
                label: 'SUDAH DIK/TAR',
                value: '0',
                color: Color(0xFF10B981),
              ),
              StatisticsCardData(
                label: 'BELUM DIK/TAR',
                value: '0',
                color: Color(0xFFF59E0B),
              ),
            ],
          ),
        ],
        ranking: [],
      );
    }

    int personnelTotal() {
      var total = 0;
      for (final row in personnelRows) {
        if (row['data_status'] != 'VALID') continue;
        final period = periods.byId[row['period_id']?.toString()];
        if (period == null || _toInt(period['report_year']) != latest.year) {
          continue;
        }
        final month = _toInt(period['report_month']);
        if (month < 1 || month > latest.month) continue;
        total += _toInt(row['value']);
      }
      return total;
    }

    int educationTotal(String status) {
      var total = 0;
      for (final row in educationRows) {
        if (row['data_status'] != 'VALID') continue;
        final period = periods.byId[row['period_id']?.toString()];
        if (period == null || _toInt(period['report_year']) != latest.year) {
          continue;
        }
        final month = _toInt(period['report_month']);
        if (month < 1 || month > latest.month) continue;
        if (statusById[row['education_status_id']?.toString()] != status) {
          continue;
        }
        total += _toInt(row['value']);
      }
      return total;
    }

    return StatisticsViewData(
      columns: [
        StatisticsColumnData(
          label: '${latest.year} · JAN–${_monthShortNames[latest.month - 1]}',
          cards: [
            StatisticsCardData(
              label: 'JUMLAH',
              value: personnelTotal().toString(),
              color: const Color(0xFF94A3B8),
            ),
            StatisticsCardData(
              label: 'SUDAH DIK/TAR',
              value: educationTotal('SUDAH').toString(),
              color: const Color(0xFF10B981),
            ),
            StatisticsCardData(
              label: 'BELUM DIK/TAR',
              value: educationTotal('BELUM').toString(),
              color: const Color(0xFFF59E0B),
            ),
          ],
        ),
      ],
      ranking: _topFiveForRange(
        personnelRows,
        periods,
        pomdams,
        year: latest.year,
        startMonth: 1,
        endMonth: latest.month,
      ),
    );
  }
}

class _ReportDataError extends StatelessWidget {
  const _ReportDataError({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.wifi_off_rounded, color: Color(0xFF7A6840), size: 40),
            SizedBox(height: 14),
            Text(
              'DATA LAPORAN TIDAK DAPAT DIMUAT.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _muted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
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
    this.periodOptions = const [],
    this.selectedPeriodKey,
    this.onPeriodChanged,
  });

  final List<_StatColumn> columns;
  final StatisticsModule module;
  final List<_RankData> ranking;
  final Color accent;
  final int? totalSim;
  final List<StatisticsPeriodOption> periodOptions;
  final String? selectedPeriodKey;
  final ValueChanged<String>? onPeriodChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (totalSim != null) ...[
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 550),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value.clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(0, (1 - value) * -10),
                  child: child,
                ),
              );
            },
            child: _TotalSimCard(total: totalSim!, accent: accent),
          ),
          const SizedBox(height: 14),
        ],
        if (columns.length == 1)
          _StatsColumnView(column: columns.first, accent: accent)
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 520;
              return Flex(
                key: const ValueKey('report-period-columns'),
                direction: compact ? Axis.vertical : Axis.horizontal,
                crossAxisAlignment: compact
                    ? CrossAxisAlignment.stretch
                    : CrossAxisAlignment.start,
                children: [
                  for (var index = 0; index < columns.length; index++) ...[
                    if (index > 0)
                      SizedBox(
                        width: compact ? 0 : 16,
                        height: compact ? 18 : 0,
                      ),
                    if (compact)
                      _StatsColumnView(
                        column: columns[index],
                        accent: accent,
                        module: module,
                        alignPeriodHeader: _supportsPeriodSelector(module),
                        periodOptions:
                            _supportsPeriodSelector(module) && index == 1
                            ? periodOptions
                            : const [],
                        selectedPeriodKey:
                            _supportsPeriodSelector(module) && index == 1
                            ? selectedPeriodKey
                            : null,
                        onPeriodChanged:
                            _supportsPeriodSelector(module) && index == 1
                            ? onPeriodChanged
                            : null,
                      )
                    else
                      Expanded(
                        child: _StatsColumnView(
                          column: columns[index],
                          accent: accent,
                          module: module,
                          alignPeriodHeader: _supportsPeriodSelector(module),
                          periodOptions:
                              _supportsPeriodSelector(module) && index == 1
                              ? periodOptions
                              : const [],
                          selectedPeriodKey:
                              _supportsPeriodSelector(module) && index == 1
                              ? selectedPeriodKey
                              : null,
                          onPeriodChanged:
                              _supportsPeriodSelector(module) && index == 1
                              ? onPeriodChanged
                              : null,
                        ),
                      ),
                  ],
                ],
              );
            },
          ),
        const SizedBox(height: 16),
        if (ranking.isNotEmpty)
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 650),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value.clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(0, (1 - value) * 12),
                  child: child,
                ),
              );
            },
            child: _AnalysisButton(
              accent: accent,
              label: 'STATISTIK',
              onPressed: () => _showRankingSheet(
                context,
                module,
                ranking,
                accent,
                analysisCards: columns.length > 1
                    ? columns[1].cards
                    : columns.first.cards,
                yearToDateCards: columns.first.cards,
                selectedPeriodLabel: columns.length > 1
                    ? columns[1].label
                    : columns.first.label,
                yearToDateLabel: columns.first.label,
                selectedTotal: totalSim,
                onItemTap: module == StatisticsModule.k9
                    ? (index) => _showK9UnitSheet(context, _k9Units[index])
                    : null,
              ),
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
              fontSize: 34,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.0,
              shadows: [
                Shadow(
                  color: accent.withValues(alpha: 0.45),
                  blurRadius: 16,
                  offset: const Offset(0, 2),
                ),
              ],
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
  List<_StatCardData> analysisCards = const [],
  List<_StatCardData> yearToDateCards = const [],
  String? selectedPeriodLabel,
  String? yearToDateLabel,
  int? selectedTotal,
  Future<void> Function(int index)? onItemTap,
}) async {
  int sumCards(List<_StatCardData> cards) {
    return cards.fold<int>(0, (sum, card) => sum + _analysisInt(card.value));
  }

  final periodTotal = selectedTotal ?? sumCards(analysisCards);
  final periodTitle = selectedPeriodLabel ?? 'PERIODE TERPILIH';
  final yearLabel = (yearToDateLabel ?? '').split('·').first.trim();
  final periodCaption = yearLabel.isEmpty
      ? periodTitle.toUpperCase()
      : '$periodTitle · $yearLabel';

  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    enableDrag: true,
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.90,
      minChildSize: 0.56,
      maxChildSize: 0.97,
      builder: (context, scrollController) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF13382A).withValues(alpha: 0.98),
                  _surface.withValues(alpha: 0.985),
                  _bg.withValues(alpha: 0.995),
                ],
              ),
              border: Border(
                top: BorderSide(
                  color: accent.withValues(alpha: 0.48),
                  width: 1.2,
                ),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 36,
                  offset: Offset(0, -10),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  const SizedBox(height: 9),
                  Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.32),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 15, 14, 13),
                    child: Row(
                      children: [
                        Container(
                          width: 43,
                          height: 43,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: accent.withValues(alpha: 0.34),
                            ),
                          ),
                          child: Icon(
                            module == StatisticsModule.simTni
                                ? Icons.insights_rounded
                                : Icons.bar_chart_rounded,
                            color: accent,
                            size: 23,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ANALISIS ${_moduleTitleForSheet(module)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: _text,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.35,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                module == StatisticsModule.simTni
                                    ? periodCaption
                                    : 'PUSPOMAD · RINGKASAN LAPORAN',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: accent.withValues(alpha: 0.98),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Tutup analisis',
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(
                            Icons.close_rounded,
                            color: _muted.withValues(alpha: 0.92),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 680),
                          child: module == StatisticsModule.simTni
                              ? _SimAnalysisSheetContent(
                                  categories: analysisCards,
                                  yearToDateCategories: yearToDateCards,
                                  ranking: ranking,
                                  total: periodTotal,
                                  periodLabel: periodTitle,
                                  yearToDateLabel:
                                      yearToDateLabel ?? 'KUMULATIF',
                                  accent: accent,
                                )
                              : Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    _AnalysisEntrance(
                                      index: 0,
                                      child: _AnalysisSectionTitle(
                                        title: module == StatisticsModule.k9
                                            ? 'RINGKASAN UNIT K9'
                                            : 'POMDAM DENGAN NILAI TERTINGGI',
                                        subtitle: module == StatisticsModule.k9
                                            ? 'Pilih unit untuk melihat rincian.'
                                            : 'Urutan berdasarkan nilai agregat laporan.',
                                        accent: accent,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    if (ranking.isEmpty)
                                      const _AnalysisEmptyState()
                                    else
                                      for (
                                        var index = 0;
                                        index < ranking.length;
                                        index++
                                      ) ...[
                                        _AnalysisEntrance(
                                          index: index + 1,
                                          child: _AnalysisRankingRow(
                                            rank: index + 1,
                                            name: ranking[index].name,
                                            value: ranking[index].value,
                                            maxValue: ranking.first.value,
                                            accent: accent,
                                            onTap: onItemTap == null
                                                ? null
                                                : () => onItemTap(index),
                                          ),
                                        ),
                                        if (index != ranking.length - 1)
                                          const SizedBox(height: 9),
                                      ],
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

int _analysisInt(String value) {
  return int.tryParse(value.replaceAll('.', '').replaceAll(',', '').trim()) ??
      0;
}

String _formatAnalysisNumber(int value) {
  return value.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => '.',
  );
}

String _formatAnalysisPercent(double value) {
  final safeValue = value.isFinite ? value.clamp(0.0, 100.0).toDouble() : 0.0;
  return '${safeValue.toStringAsFixed(1).replaceAll('.', ',')}%';
}

class _AnalysisEntrance extends StatelessWidget {
  const _AnalysisEntrance({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 420 + index * 65),
      curve: Curves.easeOutCubic,
      child: child,
      builder: (context, value, child) => Opacity(
        opacity: value.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, (1 - value) * 13),
          child: child,
        ),
      ),
    );
  }
}

class _AnalysisAnimatedBar extends StatelessWidget {
  const _AnalysisAnimatedBar({
    required this.value,
    required this.color,
    this.height = 7,
  });

  final double value;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final safeValue = value.isFinite ? value.clamp(0.0, 1.0).toDouble() : 0.0;
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(99),
      ),
      clipBehavior: Clip.hardEdge,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: safeValue),
        duration: const Duration(milliseconds: 850),
        curve: Curves.easeOutCubic,
        builder: (context, progress, child) => Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: progress,
            heightFactor: 1,
            child: child,
          ),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.65),
                color,
                color.withValues(alpha: 0.88),
              ],
            ),
            borderRadius: BorderRadius.circular(99),
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _AnalysisSectionTitle extends StatelessWidget {
  const _AnalysisSectionTitle({
    required this.title,
    required this.accent,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 3,
            height: 31,
            margin: const EdgeInsets.only(right: 11, top: 1),
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(99),
              boxShadow: [
                BoxShadow(color: accent.withValues(alpha: 0.34), blurRadius: 9),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 10,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalysisHeroCard extends StatelessWidget {
  const _AnalysisHeroCard({
    required this.total,
    required this.periodCaption,
    required this.yearToDateLabel,
    required this.yearTotal,
    required this.yearShare,
    required this.accent,
  });

  final int total;
  final String periodCaption;
  final String yearToDateLabel;
  final int yearTotal;
  final double yearShare;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 17, 18, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.19),
            const Color(0xFF12392A).withValues(alpha: 0.94),
            _surface.withValues(alpha: 0.92),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: accent.withValues(alpha: 0.30)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.07),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          const BoxShadow(
            color: Colors.black26,
            blurRadius: 16,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'TOTAL PENERBITAN',
                  style: TextStyle(
                    color: _muted.withValues(alpha: 0.95),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.8,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: accent.withValues(alpha: 0.28)),
                ),
                child: Text(
                  periodCaption,
                  style: TextStyle(
                    color: accent,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: total.toDouble()),
            duration: const Duration(milliseconds: 950),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) => Text(
              _formatAnalysisNumber(value.round()),
              style: TextStyle(
                color: _text,
                fontSize: 39,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.5,
                height: 1.0,
                shadows: [
                  Shadow(color: accent.withValues(alpha: 0.34), blurRadius: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.calendar_month_rounded,
                color: accent.withValues(alpha: 0.95),
                size: 15,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  'Akumulasi tahun berjalan: ${_formatAnalysisNumber(yearTotal)} SIM ($yearToDateLabel).',
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 10,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          _AnalysisAnimatedBar(
            value: yearShare / 100,
            color: accent,
            height: 6,
          ),
          const SizedBox(height: 7),
          Text(
            '${_formatAnalysisPercent(yearShare)} dari akumulasi tahun berjalan berada pada periode pilihan.',
            style: TextStyle(
              color: _text.withValues(alpha: 0.88),
              fontSize: 10,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalysisMetricCard extends StatelessWidget {
  const _AnalysisMetricCard({
    required this.title,
    required this.value,
    required this.detail,
    required this.icon,
    required this.accent,
    this.largeValue = false,
  });

  final String title;
  final String value;
  final String detail;
  final IconData icon;
  final Color accent;
  final bool largeValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 116),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accent, size: 15),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _text,
              fontSize: largeValue ? 24 : 14,
              height: 1.15,
              fontWeight: FontWeight.w900,
              letterSpacing: largeValue ? -0.5 : 0,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            detail,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _muted,
              fontSize: 9,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalysisInsightRow extends StatelessWidget {
  const _AnalysisInsightRow({
    required this.icon,
    required this.title,
    required this.description,
    required this.accent,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.028),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.065)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 31,
            height: 31,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: accent, size: 17),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.25,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 10,
                    height: 1.45,
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

class _AnalysisRankingRow extends StatelessWidget {
  const _AnalysisRankingRow({
    required this.rank,
    required this.name,
    required this.value,
    required this.maxValue,
    required this.accent,
    this.shareLabel,
    this.onTap,
  });

  final int rank;
  final String name;
  final int value;
  final int maxValue;
  final Color accent;
  final String? shareLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ratio = maxValue <= 0 ? 0.0 : value / maxValue;
    final rankColor = rank == 1
        ? const Color(0xFFF1D37A)
        : rank == 2
        ? const Color(0xFFBBC7CE)
        : rank == 3
        ? const Color(0xFFD89B70)
        : accent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.028),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.065)),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: rankColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: rankColor.withValues(alpha: 0.30)),
                ),
                child: Text(
                  rank.toString().padLeft(2, '0'),
                  style: TextStyle(
                    color: rankColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _text,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _AnalysisAnimatedBar(
                      value: ratio,
                      color: rankColor,
                      height: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatAnalysisNumber(value),
                    style: TextStyle(
                      color: rankColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                    ),
                  ),
                  if (shareLabel != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      shareLabel!,
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnalysisEmptyState extends StatelessWidget {
  const _AnalysisEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: const Column(
        children: [
          Icon(Icons.query_stats_rounded, color: _muted, size: 26),
          SizedBox(height: 9),
          Text(
            'BELUM ADA DATA ANALISIS',
            style: TextStyle(
              color: _text,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Belum ada nilai yang dapat diurutkan untuk laporan ini.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _muted, fontSize: 10, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _SimCategoryRow extends StatelessWidget {
  const _SimCategoryRow({
    required this.label,
    required this.count,
    required this.share,
    required this.color,
  });

  final String label;
  final int count;
  final double share;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.027),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.055)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 30,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(99),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.25),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatAnalysisNumber(count),
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    _formatAnalysisPercent(share),
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          _AnalysisAnimatedBar(value: share / 100, color: color, height: 7),
        ],
      ),
    );
  }
}

class _SimYearComparisonRow extends StatelessWidget {
  const _SimYearComparisonRow({
    required this.label,
    required this.periodValue,
    required this.yearValue,
    required this.periodShare,
    required this.color,
  });

  final String label;
  final int periodValue;
  final int yearValue;
  final double periodShare;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.025),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.055)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '${_formatAnalysisNumber(periodValue)} / ${_formatAnalysisNumber(yearValue)}',
                style: const TextStyle(
                  color: _text,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              Expanded(
                child: _AnalysisAnimatedBar(
                  value: periodShare / 100,
                  color: color,
                  height: 5,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                _formatAnalysisPercent(periodShare),
                style: TextStyle(
                  color: color,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Kontribusi periode pilihan terhadap akumulasi jenis SIM ini.',
            style: TextStyle(color: _muted, fontSize: 8, height: 1.35),
          ),
        ],
      ),
    );
  }
}

class _SimAnalysisSheetContent extends StatelessWidget {
  const _SimAnalysisSheetContent({
    required this.categories,
    required this.yearToDateCategories,
    required this.ranking,
    required this.total,
    required this.periodLabel,
    required this.yearToDateLabel,
    required this.accent,
  });

  final List<_StatCardData> categories;
  final List<_StatCardData> yearToDateCategories;
  final List<_RankData> ranking;
  final int total;
  final String periodLabel;
  final String yearToDateLabel;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final categoryTotal = categories.fold<int>(
      0,
      (sum, card) => sum + _analysisInt(card.value),
    );
    final periodTotal = total > 0 ? total : categoryTotal;
    final yearTotal = yearToDateCategories.fold<int>(
      0,
      (sum, card) => sum + _analysisInt(card.value),
    );
    final topFiveTotal = ranking.fold<int>(0, (sum, item) => sum + item.value);
    final categoryDenominator = categoryTotal > 0 ? categoryTotal : periodTotal;
    final ytdShare = yearTotal > 0 ? periodTotal / yearTotal * 100 : 0.0;
    final topFiveShare = periodTotal > 0
        ? topFiveTotal / periodTotal * 100
        : 0.0;
    final yearByCategory = <String, _StatCardData>{
      for (final card in yearToDateCategories) card.label: card,
    };
    final orderedCategories = categories.toList()
      ..sort((a, b) => _analysisInt(b.value).compareTo(_analysisInt(a.value)));
    final dominant = orderedCategories.isEmpty ? null : orderedCategories.first;
    final dominantValue = dominant == null ? 0 : _analysisInt(dominant.value);
    final dominantShare = categoryDenominator > 0
        ? dominantValue / categoryDenominator * 100
        : 0.0;
    final leader = ranking.isEmpty ? null : ranking.first;
    final leaderShare = periodTotal > 0 && leader != null
        ? leader.value / periodTotal * 100
        : 0.0;
    final yearName = yearToDateLabel.split('·').first.trim();
    final periodCaption = yearName.isEmpty
        ? periodLabel.toUpperCase()
        : '$periodLabel · $yearName';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _AnalysisEntrance(
          index: 0,
          child: _AnalysisHeroCard(
            total: periodTotal,
            periodCaption: periodCaption,
            yearToDateLabel: yearToDateLabel,
            yearTotal: yearTotal,
            yearShare: ytdShare,
            accent: accent,
          ),
        ),
        const SizedBox(height: 18),
        _AnalysisEntrance(
          index: 1,
          child: _AnalysisSectionTitle(
            title: 'RINGKASAN EKSEKUTIF',
            subtitle:
                'Tiga sinyal utama untuk membaca distribusi SIM pada periode ini.',
            accent: accent,
          ),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = (constraints.maxWidth - 10) / 2;
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                SizedBox(
                  width: width,
                  child: _AnalysisEntrance(
                    index: 2,
                    child: _AnalysisMetricCard(
                      title: 'JENIS TERBANYAK',
                      value: dominant?.label ?? '—',
                      detail: dominant == null
                          ? 'Belum ada nilai kategori.'
                          : '${_formatAnalysisNumber(dominantValue)} SIM · ${_formatAnalysisPercent(dominantShare)} dari periode',
                      icon: Icons.donut_large_rounded,
                      accent: dominant?.color ?? accent,
                    ),
                  ),
                ),
                SizedBox(
                  width: width,
                  child: _AnalysisEntrance(
                    index: 3,
                    child: _AnalysisMetricCard(
                      title: 'POMDAM TERATAS',
                      value: leader?.name ?? '—',
                      detail: leader == null
                          ? 'Belum ada peringkat Pomdam.'
                          : '${_formatAnalysisNumber(leader.value)} SIM · ${_formatAnalysisPercent(leaderShare)} dari periode',
                      icon: Icons.military_tech_rounded,
                      accent: accent,
                    ),
                  ),
                ),
                SizedBox(
                  width: constraints.maxWidth,
                  child: _AnalysisEntrance(
                    index: 4,
                    child: _AnalysisMetricCard(
                      title: 'KONTRIBUSI TOP 5 POMDAM',
                      value: _formatAnalysisPercent(topFiveShare),
                      detail:
                          '${_formatAnalysisNumber(topFiveTotal)} SIM dari ${_formatAnalysisNumber(periodTotal)} SIM tercatat pada periode terpilih.',
                      icon: Icons.leaderboard_rounded,
                      accent: accent,
                      largeValue: true,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 22),
        _AnalysisEntrance(
          index: 5,
          child: _AnalysisSectionTitle(
            title: 'KOMPOSISI JENIS SIM',
            subtitle:
                'Jumlah dan porsi setiap kategori terhadap total periode terpilih.',
            accent: accent,
          ),
        ),
        const SizedBox(height: 10),
        for (var index = 0; index < categories.length; index++) ...[
          _AnalysisEntrance(
            index: index + 6,
            child: _SimCategoryRow(
              label: categories[index].label,
              count: _analysisInt(categories[index].value),
              share: categoryDenominator > 0
                  ? _analysisInt(categories[index].value) /
                        categoryDenominator *
                        100
                  : 0,
              color: categories[index].color,
            ),
          ),
          if (index != categories.length - 1) const SizedBox(height: 8),
        ],
        const SizedBox(height: 22),
        _AnalysisEntrance(
          index: 11,
          child: _AnalysisSectionTitle(
            title: 'RINCIAN VS KUMULATIF',
            subtitle:
                'Angka kiri adalah periode pilihan; angka kanan adalah akumulasi tahun berjalan.',
            accent: accent,
          ),
        ),
        const SizedBox(height: 10),
        for (var index = 0; index < categories.length; index++) ...[
          Builder(
            builder: (context) {
              final card = categories[index];
              final annual = yearByCategory[card.label];
              final periodValue = _analysisInt(card.value);
              final yearValue = annual == null ? 0 : _analysisInt(annual.value);
              final share = yearValue > 0 ? periodValue / yearValue * 100 : 0.0;
              return _AnalysisEntrance(
                index: index + 12,
                child: _SimYearComparisonRow(
                  label: card.label,
                  periodValue: periodValue,
                  yearValue: yearValue,
                  periodShare: share,
                  color: card.color,
                ),
              );
            },
          ),
          if (index != categories.length - 1) const SizedBox(height: 8),
        ],
        const SizedBox(height: 22),
        _AnalysisEntrance(
          index: 18,
          child: _AnalysisSectionTitle(
            title: 'POMDAM DENGAN PENERBITAN TERTINGGI',
            subtitle:
                'Peringkat berdasarkan total seluruh kategori SIM pada periode pilihan.',
            accent: accent,
          ),
        ),
        const SizedBox(height: 10),
        if (ranking.isEmpty)
          const _AnalysisEmptyState()
        else
          for (var index = 0; index < ranking.length; index++) ...[
            _AnalysisEntrance(
              index: index + 19,
              child: _AnalysisRankingRow(
                rank: index + 1,
                name: ranking[index].name,
                value: ranking[index].value,
                maxValue: ranking.first.value,
                accent: accent,
                shareLabel: _formatAnalysisPercent(
                  periodTotal > 0
                      ? ranking[index].value / periodTotal * 100
                      : 0,
                ),
              ),
            ),
            if (index != ranking.length - 1) const SizedBox(height: 8),
          ],
        const SizedBox(height: 22),
        _AnalysisEntrance(
          index: 25,
          child: _AnalysisSectionTitle(
            title: 'TEMUAN UTAMA',
            subtitle:
                'Ringkasan otomatis yang dihitung dari angka tampil di atas.',
            accent: accent,
          ),
        ),
        const SizedBox(height: 10),
        if (dominant != null) ...[
          _AnalysisEntrance(
            index: 26,
            child: _AnalysisInsightRow(
              icon: Icons.pie_chart_rounded,
              title: 'Kategori dominan: ${dominant.label}',
              description:
                  'Kategori ini mencatat ${_formatAnalysisNumber(dominantValue)} SIM, setara ${_formatAnalysisPercent(dominantShare)} dari total penerbitan pada periode terpilih.',
              accent: dominant.color,
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (leader != null) ...[
          _AnalysisEntrance(
            index: 27,
            child: _AnalysisInsightRow(
              icon: Icons.emoji_events_rounded,
              title: 'Pomdam dengan nilai tertinggi',
              description:
                  '${leader.name} berada di peringkat pertama dengan ${_formatAnalysisNumber(leader.value)} SIM atau ${_formatAnalysisPercent(leaderShare)} dari total periode.',
              accent: accent,
            ),
          ),
          const SizedBox(height: 8),
        ],
        _AnalysisEntrance(
          index: 28,
          child: _AnalysisInsightRow(
            icon: Icons.groups_rounded,
            title: 'Konsentrasi lima Pomdam teratas',
            description:
                'Lima peringkat teratas secara gabungan mencatat ${_formatAnalysisNumber(topFiveTotal)} SIM (${_formatAnalysisPercent(topFiveShare)} dari total periode). Angka ini menunjukkan porsi penerbitan yang terkonsentrasi pada kelompok teratas.',
            accent: accent,
          ),
        ),
        const SizedBox(height: 8),
        _AnalysisEntrance(
          index: 29,
          child: _AnalysisInsightRow(
            icon: Icons.calendar_month_rounded,
            title: 'Konteks tahun berjalan',
            description:
                'Periode terpilih mencatat ${_formatAnalysisNumber(periodTotal)} dari ${_formatAnalysisNumber(yearTotal)} SIM pada akumulasi (${_formatAnalysisPercent(ytdShare)}). Perbandingan ini menggunakan kumulatif yang tampil pada laporan.',
            accent: accent,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Catatan: analisis dihitung dari data SIM berstatus VALID yang tersedia di database. Nilai persentase dibulatkan satu angka desimal.',
          style: TextStyle(
            color: _muted.withValues(alpha: 0.82),
            fontSize: 9,
            height: 1.45,
          ),
        ),
      ],
    );
  }
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
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.4),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.12),
            Colors.white.withValues(alpha: 0.025),
            accent.withValues(alpha: 0.06),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: accent,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          side: BorderSide(color: accent.withValues(alpha: 0.38)),
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
              color: accent.withValues(alpha: 0.65),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsColumnView extends StatelessWidget {
  const _StatsColumnView({
    required this.column,
    required this.accent,
    this.module = StatisticsModule.pelanggaran,
    this.alignPeriodHeader = false,
    this.periodOptions = const [],
    this.selectedPeriodKey,
    this.onPeriodChanged,
  });

  final _StatColumn column;
  final Color accent;
  final StatisticsModule module;
  final bool alignPeriodHeader;
  final List<StatisticsPeriodOption> periodOptions;
  final String? selectedPeriodKey;
  final ValueChanged<String>? onPeriodChanged;

  Widget _buildHeader() {
    final selectorIsReady =
        periodOptions.isNotEmpty &&
        selectedPeriodKey != null &&
        onPeriodChanged != null;

    if (selectorIsReady) {
      return Container(
        height: 42,
        padding: const EdgeInsets.only(left: 8, right: 4),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(6.4),
          border: Border.all(color: accent.withValues(alpha: 0.28)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            key: ValueKey(switch (module) {
              StatisticsModule.pelanggaran => 'pelanggaran-period-dropdown',
              StatisticsModule.lakaLalin => 'laka-lalin-period-dropdown',
              StatisticsModule.simTni => 'sim-tni-period-dropdown',
              StatisticsModule.k9 => 'k9-period-dropdown',
              StatisticsModule.provos => 'provos-period-dropdown',
            }),
            value: selectedPeriodKey,
            isExpanded: true,
            isDense: true,
            icon: Icon(Icons.expand_more_rounded, color: _gold, size: 18),
            dropdownColor: _surface,
            borderRadius: BorderRadius.circular(8),
            style: const TextStyle(
              color: _gold,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
            items: [
              for (final option in periodOptions)
                DropdownMenuItem<String>(
                  value: option.key,
                  child: Text(
                    option.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: (value) {
              if (value != null) onPeriodChanged!(value);
            },
          ),
        ),
      );
    }

    final label = Text(
      column.label,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: _gold,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.0,
        shadows: [
          Shadow(
            color: _gold.withValues(alpha: 0.40),
            blurRadius: 12,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );

    return alignPeriodHeader
        ? SizedBox(height: 42, child: Center(child: label))
        : label;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(),
        const SizedBox(height: 8),
        for (var index = 0; index < column.cards.length; index++) ...[
          _AnimatedStatCard(
            card: column.cards[index],
            accent: accent,
            delay: Duration(milliseconds: index * 75),
          ),
          if (index != column.cards.length - 1) const SizedBox(height: 14),
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
                Colors.white.withValues(alpha: 0.065),
                cardAccent.withValues(alpha: 0.045),
                _surface.withValues(alpha: 0.72),
              ],
              stops: const [0.0, 0.34, 1.0],
            ),
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
              right: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
              bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
              left: BorderSide(color: lineAccent, width: 3.2),
            ),
            boxShadow: [
              BoxShadow(
                color: lineAccent.withValues(alpha: 0.07),
                blurRadius: 22,
                offset: const Offset(-2, 4),
              ),
              const BoxShadow(
                color: Colors.black26,
                blurRadius: 26,
                offset: Offset(0, 6),
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
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    card.value,
                    style: TextStyle(
                      color: cardAccent,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.6,
                      height: 1.0,
                      shadows: [
                        Shadow(
                          color: cardAccent.withValues(alpha: 0.38),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
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
                Container(
                  height: 1,
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Color(0x33FFFFFF),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFD7A93C).withValues(alpha: 0.30),
                          const Color(0xFFF1D37A).withValues(alpha: 0.55),
                          const Color(0xFFD7A93C).withValues(alpha: 0.30),
                        ],
                      ),
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
                    shadows: [
                      Shadow(
                        color: Color(0x66D7A93C),
                        blurRadius: 12,
                        offset: Offset(0, 1),
                      ),
                    ],
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
