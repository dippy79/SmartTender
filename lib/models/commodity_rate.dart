import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class CommodityRate {
  final String id;
  final String name;
  final String unit;
  final double currentPrice;
  final double previousPrice;
  final double changePercent;
  final String category;
  final DateTime updatedAt;

  const CommodityRate({
    required this.id,
    required this.name,
    required this.unit,
    required this.currentPrice,
    required this.previousPrice,
    required this.changePercent,
    required this.category,
    required this.updatedAt,
  });

  factory CommodityRate.fromMap(Map<String, dynamic> map) {
    return CommodityRate(
      id: map['id'] as String,
      name: map['name'] as String,
      unit: map['unit'] as String,
      currentPrice: (map['current_price'] as num).toDouble(),
      previousPrice: (map['previous_price'] as num).toDouble(),
      changePercent: (map['change_percent'] as num).toDouble(),
      category: map['category'] as String,
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'unit': unit,
      'current_price': currentPrice,
      'previous_price': previousPrice,
      'change_percent': changePercent,
      'category': category,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isUp => changePercent > 0;
  bool get isDown => changePercent < 0;
  bool get isFlat => changePercent == 0;

  String get formattedPrice {
    final format = NumberFormat('#,##,###');
    return '₹${format.format(currentPrice)}';
  }

  String get formattedChange {
    return '${isUp ? '▲' : isDown ? '▼' : '━'} ${changePercent.abs().toStringAsFixed(1)}%';
  }

  Color get changeColor {
    if (isUp) return AppTheme.accentGreen;
    if (isDown) return AppTheme.accentRed;
    return AppTheme.textMuted;
  }
}

class PricePoint {
  final double price;
  final DateTime date;

  const PricePoint({
    required this.price,
    required this.date,
  });

  factory PricePoint.fromMap(Map<String, dynamic> map) {
    return PricePoint(
      price: (map['current_price'] as num).toDouble(),
      date: DateTime.parse(map['updated_at'] as String),
    );
  }
}
