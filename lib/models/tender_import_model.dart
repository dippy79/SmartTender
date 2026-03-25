import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class TenderImportRow {
  final String title;
  final String department;
  final String location;
  final double value;
  final DateTime deadline;
  final String category;
  final String status;
  String? validationError;

  static const List<String> validCategories = [
    'Civil', 'Electrical', 'Mechanical', 'IT', 'Supply',
    'Architecture', 'Transport', 'General', 'Manufacturing', 'Real Estate',
  ];

  static const List<String> validStatuses = [
    'Open', 'Draft', 'Submitted', 'Won', 'Lost', 'Closed',
  ];

  TenderImportRow({
    required this.title,
    required this.department,
    required this.location,
    required this.value,
    required this.deadline,
    required this.category,
    required this.status,
    this.validationError,
  });

  factory TenderImportRow.fromExcelRow(Map<String, dynamic> row) {
    final title = row['Title']?.toString().trim() ?? '';
    final department = row['Department']?.toString().trim() ?? '';
    final location = row['Location']?.toString().trim() ?? '';
    
    double? valueParsed;
    final valueStr = row['Value (₹)']?.toString().replaceAll(',', '').replaceAll('₹', '').trim();
    if (valueStr != null && valueStr.isNotEmpty) {
      valueParsed = double.tryParse(valueStr);
    }

    DateTime? deadlineParsed;
    final deadlineStr = row['Deadline (DD/MM/YYYY)']?.toString().trim();
    if (deadlineStr != null && deadlineStr.isNotEmpty) {
      try {
        deadlineParsed = DateFormat('dd/MM/yyyy').parse(deadlineStr);
      } catch (e) {
        debugPrint('Tender import error: $e');
      }
    }

    final category = row['Category']?.toString().trim() ?? '';
    final status = row['Status']?.toString().trim() ?? '';

    final rowData = TenderImportRow(
      title: title,
      department: department,
      location: location,
      value: valueParsed ?? -1,
      deadline: deadlineParsed ?? DateTime.now(),
      category: category,
      status: status,
    );

    rowData.validationError = _validate(rowData);
    return rowData;
  }

  static String? _validate(TenderImportRow row) {
    if (row.title.isEmpty || row.title.length < 10) {
      return 'Title too short (min 10 chars)';
    }
    if (row.value <= 0) {
      return 'Value must be a positive number';
    }
    if (row.deadline.isBefore(DateTime.now())) {
      return 'Deadline must be a future date';
    }
    if (!validCategories.any((c) => c.toLowerCase() == row.category.toLowerCase())) {
      return 'Invalid category. Valid: ${validCategories.take(5).join(', ')}${validCategories.length > 5 ? '...' : ''}';
    }
    if (!validStatuses.any((s) => s.toLowerCase() == row.status.toLowerCase())) {
      return 'Invalid status. Valid: ${validStatuses.join(', ')}';
    }
    return null;
  }

  Map<String, dynamic> toSupabaseMap() => {
    'title': title,
    'department': department,
    'location': location,
    'value': value,
    'deadline': deadline.toIso8601String(),
    'category': category,
    'status': status.toLowerCase(),
    'type': 'imported',
    'created_at': DateTime.now().toIso8601String(),
  };
}
