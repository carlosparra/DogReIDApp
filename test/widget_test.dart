import 'package:flutter_test/flutter_test.dart';

import 'package:dogreidapp/main.dart';

void main() {
  testWidgets('Home muestra las acciones Buscar y Reportar', (WidgetTester tester) async {
    await tester.pumpWidget(const DogReIDApp());
    expect(find.text('Buscar'), findsWidgets);
    expect(find.text('Reportar'), findsOneWidget);
  });
}
