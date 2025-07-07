import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sgav_frontend/guard/presentation/guard_panel.dart';
import 'package:sgav_frontend/guard/widgets/traffic_light.dart';

void main() {
  testWidgets('GuardPanel initial UI and empty input validation', (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: GuardPanel(),
      ),
    );

    // Verify initial UI: TextField, 'Verificar' button, idle traffic light
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Verificar'), findsOneWidget);
    expect(find.byKey(const ValueKey(TrafficLightState.idle)), findsOneWidget);

    // Tap 'Verificar' without input and verify SnackBar message
    await tester.tap(find.text('Verificar'));
    await tester.pump(); // Trigger SnackBar
    expect(find.text('Ingresa una patente primero'), findsOneWidget);
  });
}