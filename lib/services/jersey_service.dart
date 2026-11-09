import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/jersey.dart';

class JerseyPage {
  const JerseyPage(this.items, this.totalCount);
  final List<Jersey> items;
  final int totalCount;
}

/// All Supabase calls for the `jerseys` table.
class JerseyService {
  JerseyService(this._db);

  final SupabaseClient _db;
  static const _table = 'jerseys';

  /// Fetches ONE page of jerseys whose price is within [minPrice, maxPrice].
  ///
  /// Filtering and pagination both happen in the Supabase query:
  ///  * `.gte()` / `.lte()` keep only rows inside the price slider range
  ///  * `.range(from, to)` returns only the rows for the requested page
  ///  * `.count(CountOption.exact)` returns the total number of matching rows
  ///    so the UI knows how many pages exist.
  Future<JerseyPage> fetchPage({
    required int page,
    required int pageSize,
    required double minPrice,
    required double maxPrice,
    String search = '',
    String? edition,
  }) async {
    final from = page * pageSize;
    final to = from + pageSize - 1;

    var query = _db
        .from(_table)
        .select()
        .gte('price', minPrice)
        .lte('price', maxPrice);

    final term = search.replaceAll(RegExp(r'[,()%*]'), ' ').trim();
    if (term.isNotEmpty) {
      query = query.or('player_name.ilike.%$term%,team.ilike.%$term%');
    }
    if (edition != null) {
      query = query.eq('edition', edition);
    }

    final response = await query
        .order('price', ascending: true)
        .order('id', ascending: true)
        .range(from, to)
        .count(CountOption.exact);

    return JerseyPage(
      response.data.map(Jersey.fromMap).toList(),
      response.count,
    );
  }

  /// Lowest and highest price in the table, used as the slider's limits.
  Future<(double, double)> fetchPriceBounds() async {
    final lowest = await _db
        .from(_table)
        .select('price')
        .order('price', ascending: true)
        .limit(1)
        .maybeSingle();
    final highest = await _db
        .from(_table)
        .select('price')
        .order('price', ascending: false)
        .limit(1)
        .maybeSingle();
    return (
      (lowest?['price'] as num?)?.toDouble() ?? 0,
      (highest?['price'] as num?)?.toDouble() ?? 0,
    );
  }

  Future<void> create(Jersey jersey) =>
      _db.from(_table).insert(jersey.toMap());

  Future<void> update(Jersey jersey) =>
      _db.from(_table).update(jersey.toMap()).eq('id', jersey.id!);

  Future<void> delete(int id) => _db.from(_table).delete().eq('id', id);
}
