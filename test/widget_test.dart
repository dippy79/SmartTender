import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tender/main.dart';

void main() {
  testWidgets('Smart Tender app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartTenderApp());
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
