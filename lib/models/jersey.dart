import 'package:flutter/material.dart';

class Jersey {
  const Jersey({
    this.id,
    required this.playerName,
    required this.team,
    required this.number,
    required this.edition,
    required this.price,
    required this.stock,
    required this.primaryColor,
    required this.secondaryColor,
  });

  final int? id;
  final String playerName;
  final String team;
  final String number;
  final String edition;
  final double price;
  final int stock;
  final String primaryColor;
  final String secondaryColor;

  static const editions = ['Icon', 'Association', 'Statement', 'City', 'Classic'];

  Color get primary => _parseHex(primaryColor);
  Color get secondary => _parseHex(secondaryColor);

  factory Jersey.fromMap(Map<String, dynamic> map) => Jersey(
        id: map['id'] as int?,
        playerName: map['player_name'] as String,
        team: map['team'] as String,
        number: map['number'].toString(),
        edition: map['edition'] as String,
        price: (map['price'] as num).toDouble(),
        stock: (map['stock'] as num?)?.toInt() ?? 0,
        primaryColor: map['primary_color'] as String,
        secondaryColor: map['secondary_color'] as String,
      );

  /// Columns sent on insert/update (id and created_at are set by the database).
  Map<String, dynamic> toMap() => {
        'player_name': playerName,
        'team': team,
        'number': number,
        'edition': edition,
        'price': price,
        'stock': stock,
        'primary_color': primaryColor,
        'secondary_color': secondaryColor,
      };

  static Color _parseHex(String hex) {
    final clean = hex.replaceFirst('#', '');
    final value = int.tryParse(clean.length == 6 ? 'FF$clean' : clean, radix: 16);
    return Color(value ?? 0xFF1D428A);
  }
}
