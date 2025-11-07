import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gastito/main.dart';

void main() {
  testWidgets('App starts and shows Gastito title', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const GastitoApp());

    // Verify that our app starts with the correct title
    expect(find.text('Gastito'), findsOneWidget);
    
    // Verify that the bottom navigation bar is present
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    
    // Verify that today's tab is active by default
    expect(find.text('Hoy'), findsOneWidget);
    expect(find.text('Estadísticas'), findsOneWidget);
  });

  testWidgets('Add expense modal appears', (WidgetTester tester) async {
    await tester.pumpWidget(const GastitoApp());

    // Tap the add button
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Verify that the modal appears with the correct fields
    expect(find.text('Agregar Gasto'), findsOneWidget);
    expect(find.text('¿En qué gastaste?'), findsOneWidget);
    expect(find.text('Monto'), findsOneWidget);
  });

  testWidgets('Navigation between tabs works', (WidgetTester tester) async {
    await tester.pumpWidget(const GastitoApp());

    // Verify we start in the "Hoy" tab
    expect(find.byIcon(Icons.today), findsOneWidget);

    // Tap on the statistics tab
    await tester.tap(find.text('Estadísticas'));
    await tester.pumpAndSettle();

    // Verify we switched to statistics tab
    expect(find.text('Gastos de la Semana'), findsOneWidget);
  });
}