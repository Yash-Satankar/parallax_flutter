import 'package:flutter_test/flutter_test.dart';
import 'package:parallax_mobile/main.dart';

void main() {
  testWidgets('App root initializes properly', (WidgetTester tester) async {
    await tester.pumpWidget(const ParallaxApp());
    expect(find.byType(ParallaxApp), findsOneWidget);
  });
}
