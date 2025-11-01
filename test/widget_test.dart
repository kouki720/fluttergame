import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eco_warrior_tunisia1/main.dart';

void main() {
  testWidgets('App starts with splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const EcoWarriorTunisia());
    expect(find.text('ECO WARRIOR'), findsOneWidget);
    expect(find.text('TUNISIA'), findsOneWidget);
  });
}