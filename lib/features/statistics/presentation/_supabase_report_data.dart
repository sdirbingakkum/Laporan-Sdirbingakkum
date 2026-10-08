import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseReportData {
  static Future<Map<String, dynamic>> load(StatisticsModule module) async {
    final client = Supabase.instance.client;
    final periods = List<Map<String, dynamic>>.from(
      await client.from('report_periods').select('id,report_year,report_month'),
    );
    final periodById = <String, Map<String, dynamic>>{
      for (final row in periods) row['id'].toString(): row,
    };

    final pomdams = List<Map<String, dynamic>>.from(
      await client.from('pomdams').select('id,code'),
    );
    final pomdamById = <String, String>{
      for (final row in pomdams) row['id'].toString(): row['code'].toString(),
    };

    switch (module) {
      case StatisticsModule.pelanggaran:
        return _violations(client, periodById, pomdamById);
      case StatisticsModule.lakaLalin:
        return _laka(client, periodById, pomdamById);
      case StatisticsModule.simTni:
        return _sim(client, periodById, pomdamById);
      case StatisticsModule.provos:
        return _provos(client, periodById, pomdamById);
      case StatisticsModule.k9:
        return const {};
    }
  }

  static int _int(dynamic value) =>
      value is num ? value.toInt() : int.tryParse(value?.toString() ?? '') ?? 0;

  static int _sum(
    List<Map<String, dynamic>> rows,
    Map<String, Map<String, dynamic>> periods, {
    int? month,
    String? type,
    Map<String, String>? typeById,
  }) {
    var total = 0;
    for (final row in rows) {
      final period = periods[row['period_id']?.toString()];
      if (period == null || period['report_year'] != 2026) continue;
      if (month != null && period['report_month'] != month) continue;
      if (type != null &&
          typeById?[row['type_id']?.toString()] != type) continue;
      total += _int(row['value']);
    }
    return total;
  }

  static Map<String, dynamic> _base(
    List<Map<String, dynamic>> rows,
    Map<String, Map<String, dynamic>> periods,
    Map<String, String> pomdams, {
    int? month,
  }) {
    final totals = <String, int>{};
    for (final row in rows) {
      final period = periods[row['period_id']?.toString()];
      if (period == null || period['report_year'] != 2026) continue;
      if (month != null && period['report_month'] != month) continue;
      final code = pomdams[row['pomdam_id']?.toString()];
      if (code == null) continue;
      totals[code] = (totals[code] ?? 0) + _int(row['value']);
    }
    final entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return {'total': entries.fold<int>(0, (s, e) => s + e.value), 'ranking': entries.take(5).toList()};
  }

  static Future<Map<String, dynamic>> _violations(
    SupabaseClient client,
    Map<String, Map<String, dynamic>> periods,
    Map<String, String> pomdams,
  ) async {
    final rows = List<Map<String, dynamic>>.from(
      await client.from('violation_records').select(
        'period_id,pomdam_id,personnel_category_id,value',
      ),
    );
    final cats = List<Map<String, dynamic>>.from(
      await client.from('personnel_categories').select('id,code'),
    );
    final catById = {for (final c in cats) c['id'].toString(): c['code'].toString()};

    int sum({int? month, String? cat}) {
      var total = 0;
      for (final row in rows) {
        final p = periods[row['period_id']?.toString()];
        if (p == null || p['report_year'] != 2026) continue;
        if (month != null && p['report_month'] != month) continue;
        if (cat != null && catById[row['personnel_category_id']?.toString()] != cat) continue;
        total += _int(row['value']);
      }
      return total;
    }

    final rankingData = _base(rows, periods, pomdams, month: 7);
    return {
      'columns': [
        ['2026', {'TATIB': sum(month: 7, cat: 'BA'), 'LALIN': sum(month: 7, cat: 'TA')}],
        ['SEPT', {'TATIB': sum(month: 9, cat: 'BA'), 'LALIN': sum(month: 9, cat: 'TA')}],
      ],
      'ranking': rankingData['ranking'],
    };
  }

  static Future<Map<String, dynamic>> _laka(
    SupabaseClient client,
    Map<String, Map<String, dynamic>> periods,
    Map<String, String> pomdams,
  ) async {
    final rows = List<Map<String, dynamic>>.from(
      await client.from('laka_accident_records').select(
        'period_id,pomdam_id,accident_type_id,value',
      ),
    );
    final types = List<Map<String, dynamic>>.from(
      await client.from('accident_types').select('id,code'),
    );
    final typeById = {for (final t in types) t['id'].toString(): t['code'].toString()};

    int sum({int? month, String? type}) {
      var total = 0;
      for (final row in rows) {
        final p = periods[row['period_id']?.toString()];
        if (p == null || p['report_year'] != 2026) continue;
        if (month != null && p['report_month'] != month) continue;
        if (type != null && typeById[row['accident_type_id']?.toString()] != type) continue;
        total += _int(row['value']);
      }
      return total;
    }

    final rankingData = _base(rows, periods, pomdams, month: 9);
    return {
      'columns': [
        ['2026', {
          'JUMLAH KASUS': sum(),
          'LAKA GANDA': sum(type: 'GANDA'),
          'TUNGGAL': sum(type: 'TUNGGAL'),
          'TABRAK LARI': sum(type: 'TABRAK_LARI')
        }],
        ['SEPT', {
          'JUMLAH KASUS': sum(month: 9),
          'LAKA GANDA': sum(month: 9, type: 'GANDA'),
          'TUNGGAL': sum(month: 9, type: 'TUNGGAL'),
          'TABRAK LARI': sum(month: 9, type: 'TABRAK_LARI')
        }],
      ],
      'ranking': rankingData['ranking'],
    };
  }

  static Future<Map<String, dynamic>> _sim(
    SupabaseClient client,
    Map<String, Map<String, dynamic>> periods,
    Map<String, String> pomdams,
  ) async {
    final rows = List<Map<String, dynamic>>.from(
      await client.from('sim_records').select('period_id,pomdam_id,sim_type_id,value'),
    );
    final types = List<Map<String, dynamic>>.from(await client.from('sim_types').select('id,code'));
    final typeById = {for (final t in types) t['id'].toString(): t['code'].toString()};

    const month = 7;
    int sum(String type) {
      var total = 0;
      for (final row in rows) {
        final p = periods[row['period_id']?.toString()];
        if (p == null || p['report_year'] != 2026 || p['report_month'] != month) continue;
        if (typeById[row['sim_type_id']?.toString()] != type) continue;
        total += _int(row['value']);
      }
      return total;
    }
    final cards = {'A': sum('A'), 'BI': sum('BI'), 'BII': sum('BII'), 'BII SUS': sum('BII_KHUSUS'), 'C': sum('C')};
    final rankingData = _base(rows, periods, pomdams, month: month);
    return {
      'columns': [['2026', cards], ['JUL', cards]],
      'totalSim': cards.values.fold<int>(0, (s, v) => s + v),
      'ranking': rankingData['ranking'],
    };
  }

  static Future<Map<String, dynamic>> _provos(
    SupabaseClient client,
    Map<String, Map<String, dynamic>> periods,
    Map<String, String> pomdams,
  ) async {
    final personnel = List<Map<String, dynamic>>.from(
      await client.from('provos_personnel_records').select('period_id,pomdam_id,value'),
    );
    final education = List<Map<String, dynamic>>.from(
      await client.from('provos_education_records').select('period_id,pomdam_id,education_status_id,value'),
    );
    final statuses = List<Map<String, dynamic>>.from(
      await client.from('education_statuses').select('id,code'),
    );
    final statusById = {for (final s in statuses) s['id'].toString(): s['code'].toString()};

    int sumPersonnel() {
      var total = 0;
      for (final row in personnel) {
        final p = periods[row['period_id']?.toString()];
        if (p?['report_year'] == 2026) total += _int(row['value']);
      }
      return total;
    }

    int sumEducation(String code) {
      var total = 0;
      for (final row in education) {
        final p = periods[row['period_id']?.toString()];
        if (p?['report_year'] != 2026) continue;
        if (statusById[row['education_status_id']?.toString()] != code) continue;
        total += _int(row['value']);
      }
      return total;
    }

    final rankingData = _base(personnel, periods, pomdams);
    return {
      'columns': [['2026', {
        'JUMLAH': sumPersonnel(),
        'SUDAH DIK/TAR': sumEducation('SUDAH'),
        'BELUM DIK/TAR': sumEducation('BELUM')
      }]],
      'ranking': rankingData['ranking'],
    };
  }
}

enum StatisticsModule { pelanggaran, lakaLalin, simTni, k9, provos }
