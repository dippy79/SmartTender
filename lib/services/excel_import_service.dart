import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import '../models/tender_import_model.dart';

class ExcelImportService {
  static const List<String> requiredHeaders = [
    'Title',
    'Department',
    'Location',
    'Value (₹)',
    'Deadline (DD/MM/YYYY)',
    'Category',
    'Status',
  ];

  static List<TenderImportRow> parseExcel(Uint8List bytes) {
    try {
      final excel = Excel.decodeBytes(bytes);
      if (excel.tables.isEmpty) {
        throw FormatException('No sheets found in Excel file');
      }
      final sheetName = excel.tables.keys.first;
      final sheet = excel.tables[sheetName]!;
      
      if (sheet.rows.isEmpty) {
        throw FormatException('Sheet is empty');
      }

      final headers = sheet.rows.first.map((cell) => cell?.value?.toString().trim() ?? '').toList();
      
      // Validate headers
      for (String required in requiredHeaders) {
        if (!headers.contains(required)) {
          throw FormatException('Missing required header: $required');
        }
      }

      return sheet.rows.skip(1)
        .where((row) => row.any((cell) => cell?.value != null && cell!.value.toString().trim().isNotEmpty))
        .map((row) {
          final rowMap = <String, dynamic>{};
          for (int col = 0; col < headers.length && col < row.length; col++) {
            rowMap[headers[col]] = row[col]?.value;
          }
          final parsed = TenderImportRow.fromExcelRow(rowMap);
          return parsed;
        }).toList();
    } catch (e) {
      throw FormatException('Invalid Excel file: $e');
    }
  }

  static Uint8List generateTemplate() {
    final excel = Excel.createExcel();
    final sheet = excel['Tenders'];

    // Headers
    sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('Title');
    sheet.cell(CellIndex.indexByString('B1')).value = TextCellValue('Department');
    sheet.cell(CellIndex.indexByString('C1')).value = TextCellValue('Location');
    sheet.cell(CellIndex.indexByString('D1')).value = TextCellValue('Value (₹)');
    sheet.cell(CellIndex.indexByString('E1')).value = TextCellValue('Deadline (DD/MM/YYYY)');
    sheet.cell(CellIndex.indexByString('F1')).value = TextCellValue('Category');
    sheet.cell(CellIndex.indexByString('G1')).value = TextCellValue('Status');

    // Sample row 1
    sheet.cell(CellIndex.indexByString('A2')).value = TextCellValue('NHAI Bridge Construction');
    sheet.cell(CellIndex.indexByString('B2')).value = TextCellValue('PWD');
    sheet.cell(CellIndex.indexByString('C2')).value = TextCellValue('Delhi-NCR');
    sheet.cell(CellIndex.indexByString('D2')).value = IntCellValue(42000000);
    sheet.cell(CellIndex.indexByString('E2')).value = TextCellValue('15/01/2025');
    sheet.cell(CellIndex.indexByString('F2')).value = TextCellValue('Civil');
    sheet.cell(CellIndex.indexByString('G2')).value = TextCellValue('Open');

    sheet.cell(CellIndex.indexByString('A3')).value = TextCellValue('Electrical Works Hospital');
    sheet.cell(CellIndex.indexByString('B3')).value = TextCellValue('Health Dept');
    sheet.cell(CellIndex.indexByString('C3')).value = TextCellValue('Mumbai');
    sheet.cell(CellIndex.indexByString('D3')).value = IntCellValue(12500000);
    sheet.cell(CellIndex.indexByString('E3')).value = TextCellValue('28/02/2025');
    sheet.cell(CellIndex.indexByString('F3')).value = TextCellValue('Electrical');
    sheet.cell(CellIndex.indexByString('G3')).value = TextCellValue('Draft');

    final bytes = excel.encode()!;
    return Uint8List.fromList(bytes);
  }

  static Uint8List exportToExcel(List<TenderImportRow> rows) {
    final excel = Excel.createExcel();
    final sheet = excel['SmartTender Export'];

    // Headers
    sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('#');
    sheet.cell(CellIndex.indexByString('B1')).value = TextCellValue('Title');
    sheet.cell(CellIndex.indexByString('C1')).value = TextCellValue('Department');
    sheet.cell(CellIndex.indexByString('D1')).value = TextCellValue('Value (₹)');
    sheet.cell(CellIndex.indexByString('E1')).value = TextCellValue('Deadline');
    sheet.cell(CellIndex.indexByString('F1')).value = TextCellValue('Status');

    final validRows = rows.where((r) => r.validationError == null).toList();
    for (int i = 0; i < validRows.length; i++) {
      final row = validRows[i];
      sheet.cell(CellIndex.indexByString('A${i+2}')).value = IntCellValue(i + 1);
      sheet.cell(CellIndex.indexByString('B${i+2}')).value = TextCellValue(row.title);
      sheet.cell(CellIndex.indexByString('C${i+2}')).value = TextCellValue(row.department);
      sheet.cell(CellIndex.indexByString('D${i+2}')).value = DoubleCellValue(row.value);
      sheet.cell(CellIndex.indexByString('E${i+2}')).value = TextCellValue(DateFormat('dd/MM/yyyy').format(row.deadline));
      sheet.cell(CellIndex.indexByString('F${i+2}')).value = TextCellValue(row.status);
    }

    // Summary
    final totalRow = validRows.length + 2;
    sheet.cell(CellIndex.indexByString('A$totalRow')).value = TextCellValue('Total');
    sheet.cell(CellIndex.indexByString('B$totalRow')).value = TextCellValue('${validRows.length} valid tenders');
    sheet.cell(CellIndex.indexByString('C$totalRow')).value = TextCellValue('Total Value');
    sheet.cell(CellIndex.indexByString('D$totalRow')).value = DoubleCellValue(validRows.fold<double>(0, (sum, r) => sum + r.value));
    sheet.cell(CellIndex.indexByString('E$totalRow')).value = TextCellValue('');
    sheet.cell(CellIndex.indexByString('F$totalRow')).value = TextCellValue('');

    final bytes = excel.encode()!;
    return Uint8List.fromList(bytes);
  }
}
