import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/main.dart';

void main() {
  testWidgets('App starts with splash screen', (WidgetTester tester) async {
    // Lance l'application
    await tester.pumpWidget(const EcoWarriorTunisia());

    // Vérifie que le splash screen s'affiche
    expect(find.text('ECO WARRIOR'), findsOneWidget);
    expect(find.text('TUNISIA'), findsOneWidget);
  });
}