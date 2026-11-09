import 'dart:math' as math;

import 'package:courtside_kits/models/jersey.dart';
import 'package:courtside_kits/providers/shop_provider.dart';
import 'package:courtside_kits/services/jersey_service.dart';
import 'package:courtside_kits/utils/format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory stand-in for Supabase that applies the same price filter and
/// range-based pagination as the real query.
class FakeJerseyService implements JerseyService {
  FakeJerseyService(this.rows);
  final List<Jersey> rows;
  int _nextId = 1000;

  @override
  Future<JerseyPage> fetchPage({
    required int page,
    required int pageSize,
    required double minPrice,
    required double maxPrice,
    String search = '',
    String? edition,
  }) async {
    final matches = rows
        .where((j) => j.price >= minPrice && j.price <= maxPrice)
        .where((j) => edition == null || j.edition == edition)
        .toList()
      ..sort((a, b) => a.price.compareTo(b.price));
    final from = page * pageSize;
    final to = math.min(from + pageSize, matches.length);
    return JerseyPage(from >= matches.length ? [] : matches.sublist(from, to), matches.length);
  }

  @override
  Future<(double, double)> fetchPriceBounds() async {
    final prices = rows.map((j) => j.price);
    return (prices.reduce(math.min), prices.reduce(math.max));
  }

  @override
  Future<void> create(Jersey jersey) async => rows.add(_withId(jersey, _nextId++));

  @override
  Future<void> update(Jersey jersey) async =>
      rows[rows.indexWhere((j) => j.id == jersey.id)] = jersey;

  @override
  Future<void> delete(int id) async => rows.removeWhere((j) => j.id == id);

  Jersey _withId(Jersey j, int id) => Jersey(
        id: id,
        playerName: j.playerName,
        team: j.team,
        number: j.number,
        edition: j.edition,
        price: j.price,
        stock: j.stock,
        primaryColor: j.primaryColor,
        secondaryColor: j.secondaryColor,
      );
}

Jersey jersey(int id, double price) => Jersey(
      id: id,
      playerName: 'Player $id',
      team: 'Los Angeles Lakers',
      number: '$id',
      edition: 'Icon',
      price: price,
      stock: 5,
      primaryColor: '#552583',
      secondaryColor: '#FDB927',
    );

void main() {
  test('peso formats thousands', () {
    expect(peso(4999), '₱4,999');
    expect(peso(1500000), '₱1,500,000');
    expect(peso(250), '₱250');
  });

  group('ShopProvider', () {
    late ShopProvider shop;

    setUp(() async {
      // 14 jerseys priced 1000, 1500, ..., 7500
      final rows = [for (var i = 0; i < 14; i++) jersey(i + 1, 1000 + i * 500)];
      shop = ShopProvider(FakeJerseyService(rows));
      await shop.init();
    });

    test('loads the first page of 6 and the price bounds', () {
      expect(shop.jerseys.length, ShopProvider.pageSize);
      expect(shop.totalCount, 14);
      expect(shop.totalPages, 3);
      expect(shop.minBound, 1000);
      expect(shop.maxBound, 7500);
      expect(shop.priceRange, const RangeValues(1000, 7500));
    });

    test('pages forward and backward', () async {
      await shop.nextPage();
      expect(shop.page, 1);
      expect(shop.jerseys.first.price, 4000);
      await shop.nextPage();
      expect(shop.jerseys.length, 2);
      expect(shop.hasNext, isFalse);
      await shop.previousPage();
      expect(shop.page, 1);
    });

    test('price range filters results and resets to page 1', () async {
      await shop.goToPage(2);
      await shop.applyPriceRange(const RangeValues(2000, 4000));
      expect(shop.page, 0);
      expect(shop.totalCount, 5);
      expect(shop.jerseys.every((j) => j.price >= 2000 && j.price <= 4000), isTrue);
    });

    test('deleting the last item on the last page steps back a page', () async {
      await shop.applyPriceRange(const RangeValues(1000, 4000)); // 7 items → 2 pages
      await shop.goToPage(1);
      expect(shop.jerseys.length, 1);
      await shop.deleteJersey(shop.jerseys.single);
      expect(shop.page, 0);
      expect(shop.totalCount, 6);
    });
  });
}
