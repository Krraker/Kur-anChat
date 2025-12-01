import 'package:flutter_test/flutter_test.dart';
import 'package:ayet_rehberi/main.dart';

void main() {
  testWidgets('App starts with ChatScreen', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const MyApp());

    // Verify app title
    expect(find.text('Ayet Rehberi'), findsOneWidget);

    // Verify empty state message
    expect(find.text('Hoş Geldiniz'), findsOneWidget);

    // Verify example questions exist
    expect(find.text('Örnek sorular:'), findsOneWidget);
  });

  testWidgets('Example questions are tappable', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Find an example question
    final exampleButton = find.text('Sabır hakkında ne diyor?');
    expect(exampleButton, findsOneWidget);

    // Tap it (this would normally trigger API call)
    // Note: For real testing, mock the API service
    await tester.tap(exampleButton);
    await tester.pump();
  });
}


