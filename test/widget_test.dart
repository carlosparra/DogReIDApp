import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dogreidapp/main.dart';

void main() {
  testWidgets('La app arranca mostrando el splash', (WidgetTester tester) async {
    await tester.pumpWidget(const DogReIDApp());
    await tester.pump(); // primera frame del splash
    // El splash muestra un indicador de carga mientras prepara la app.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
