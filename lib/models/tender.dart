import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class Tender {
  final String id;
  final String title;
  final String department;
  final String location;
  final double value;
  final DateTime deadline;
  final String status;
  final String category;
  final String type;
  final bool isBookmarked;
  final DateTime createdAt;

  const Tender({
    required this.id,
    required this.title,
    required this.department,
    required this.location,
    required this.value,
    required this.deadline,
    required this.status,
    required this.category,
    required this.type,
    required this.isBookmarked,
    required this.createdAt,
  });

  factory Tender.fromMap(Map<String, dynamic> map) {
    return Tender(
      id: map['id'] as String,
      title: map['title'] as String,
      department: map['department'] as String,
      location: map['location'] as String,
      value: (map['value'] as num).toDouble(),
      deadline: DateTime.parse(map['deadline'] as String),
      status: map['status'] as String,
      category: map['category'] as String,
      type: map['type'] as String,
      isBookmarked: map['is_bookmarked'] as bool? ?? false,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  bool get isUrgent => deadline.difference(DateTime.now()).inDays < 7;
  bool get isNew => DateTime.now().difference(createdAt).inHours < 48;
  bool get isExpired => deadline.isBefore(DateTime.now());

  String get formattedValue {
    if (value >= 10000000) return '₹${(value/10000000).toStringAsFixed(1)}Cr';
    if (value >= 100000) return '₹${(value/100000).toStringAsFixed(1)}L';
    return '₹${NumberFormat('#,##,###').format(value)}';
  }

  String get deadlineFormatted => DateFormat('dd MMM yyyy').format(deadline);
  int get daysLeft => deadline.difference(DateTime.now()).inDays;

  String get effectiveStatus {
    if (isExpired) return 'Closed';
    if (isUrgent) return 'Urgent';
    if (isNew) return 'New';
    return status;
  }

  Color get dotColor {
    if (isUrgent) return AppTheme.accentRed;
    if (isNew) return AppTheme.accentBlue;
    return AppTheme.accentGreen;
  }
}
