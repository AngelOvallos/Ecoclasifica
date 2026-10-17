import 'package:flutter_test/flutter_test.dart';
import 'package:ecoclasifica/main.dart'; // Asegúrate de que esta ruta sea correcta

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    // Construye la app y dispara un frame
    await tester.pumpWidget(const MyApp());

    // Verifica que algún widget clave de tu app exista
    expect(find.text('Ecoclasifica'), findsOneWidget); // Ejemplo: busca el título
  });
}