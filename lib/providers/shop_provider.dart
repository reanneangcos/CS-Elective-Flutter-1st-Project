import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/jersey.dart';
import '../services/jersey_service.dart';

/// Holds the shop's state (current page, price range, filters, results) and
/// re-queries Supabase whenever any of them change.
class ShopProvider extends ChangeNotifier {
  ShopProvider(this._service);

  final JerseyService _service;

  /// Products per page (activity requirement: 6–8).
  static const int pageSize = 6;

  /// Slider step / rounding unit for the price bounds, in pesos.
  static const double priceStep = 100;

  // ---- results ----
  List<Jersey> jerseys = const [];
  int totalCount = 0;
  bool loading = false;
  String? error;

  // ---- pagination ----
  int page = 0; // zero-based

  // ---- filters ----
  double minBound = 0;
  double maxBound = priceStep;
  RangeValues priceRange = const RangeValues(0, priceStep);
  String search = '';
  String? edition;

  int _requestId = 0;
  Timer? _searchDebounce;

  int get totalPages => math.max(1, (totalCount / pageSize).ceil());
  bool get hasPrevious => page > 0;
  bool get hasNext => page < totalPages - 1;
  int get firstShown => totalCount == 0 ? 0 : page * pageSize + 1;
  int get lastShown => math.min((page + 1) * pageSize, totalCount);

  bool get isFullPriceRange =>
      priceRange.start <= minBound && priceRange.end >= maxBound;
  bool get hasActiveFilters =>
      !isFullPriceRange || search.isNotEmpty || edition != null;

  Future<void> init() async {
    await _loadBounds(resetRange: true);
    await _fetch();
  }

  // ---------------- price filter ----------------

  /// Called continuously while the slider is dragged — updates the labels only.
  void previewPriceRange(RangeValues values) {
    priceRange = values;
    notifyListeners();
  }

  /// Called when the user lets go of the slider — runs the Supabase query.
  Future<void> applyPriceRange(RangeValues values) {
    priceRange = values;
    page = 0;
    return _fetch();
  }

  // ---------------- other filters ----------------

  void setSearch(String value) {
    search = value.trim();
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      page = 0;
      _fetch();
    });
  }

  Future<void> setEdition(String? value) {
    edition = value;
    page = 0;
    return _fetch();
  }

  Future<void> clearFilters() {
    _searchDebounce?.cancel();
    search = '';
    edition = null;
    priceRange = RangeValues(minBound, maxBound);
    page = 0;
    return _fetch();
  }

  // ---------------- pagination ----------------

  Future<void> goToPage(int target) {
    final clamped = target.clamp(0, totalPages - 1);
    if (clamped == page) return Future.value();
    page = clamped;
    return _fetch();
  }

  Future<void> nextPage() => goToPage(page + 1);
  Future<void> previousPage() => goToPage(page - 1);

  // ---------------- create / update / delete ----------------

  Future<void> addJersey(Jersey jersey) async {
    await _service.create(jersey);
    await _afterWrite();
  }

  Future<void> updateJersey(Jersey jersey) async {
    await _service.update(jersey);
    await _afterWrite();
  }

  Future<void> deleteJersey(Jersey jersey) async {
    await _service.delete(jersey.id!);
    // If that was the only item on the last page, step back a page.
    final remaining = totalCount - 1;
    final lastPage = math.max(0, (remaining / pageSize).ceil() - 1);
    if (page > lastPage) page = lastPage;
    await _afterWrite();
  }

  Future<void> refresh() => _afterWrite();

  // ---------------- internals ----------------

  Future<void> _afterWrite() async {
    await _loadBounds(resetRange: false);
    await _fetch();
  }

  Future<void> _loadBounds({required bool resetRange}) async {
    try {
      final wasFullRange = isFullPriceRange;
      final (lo, hi) = await _service.fetchPriceBounds();
      minBound = (lo / priceStep).floorToDouble() * priceStep;
      maxBound = math.max(
        (hi / priceStep).ceilToDouble() * priceStep,
        minBound + priceStep,
      );
      if (resetRange || wasFullRange) {
        priceRange = RangeValues(minBound, maxBound);
      } else {
        final start = priceRange.start.clamp(minBound, maxBound);
        final end = priceRange.end.clamp(start, maxBound);
        priceRange = RangeValues(start, end);
      }
    } catch (e) {
      error = _describe(e);
    }
  }

  Future<void> _fetch() async {
    final requestId = ++_requestId;
    loading = true;
    error = null;
    notifyListeners();

    try {
      final result = await _service.fetchPage(
        page: page,
        pageSize: pageSize,
        minPrice: priceRange.start,
        maxPrice: priceRange.end,
        search: search,
        edition: edition,
      );
      if (requestId != _requestId) return; // a newer request superseded this one
      jerseys = result.items;
      totalCount = result.totalCount;
    } on PostgrestException catch (e) {
      if (requestId != _requestId) return;
      // PGRST103 = requested page is past the end (e.g. rows were deleted
      // elsewhere). Fall back to the first page.
      if (e.code == 'PGRST103' && page > 0) {
        page = 0;
        return _fetch();
      }
      error = _describe(e);
    } catch (e) {
      if (requestId != _requestId) return;
      error = _describe(e);
    } finally {
      if (requestId == _requestId) {
        loading = false;
        notifyListeners();
      }
    }
  }

  String _describe(Object e) =>
      e is PostgrestException ? e.message : 'Something went wrong: $e';

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }
}
