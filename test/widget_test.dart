import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:map_dev/main.dart';

void main() {
  testWidgets('RequestCard renders request details', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RequestCard(
            request: {
              'app_name': 'Demo App',
              'app_description': 'A sample request description',
              'requester_name': 'Jane Doe',
              'contact': 'jane@example.com',
              'phone_number': '+1234567890',
              'timestamp': '2026-01-15T10:30:00.000Z',
            },
          ),
        ),
      ),
    );

    expect(find.text('DEMO APP'), findsOneWidget);
    expect(find.text('A sample request description'), findsOneWidget);
    expect(find.text('Jane Doe'), findsOneWidget);
    expect(find.text('jane@example.com'), findsOneWidget);
    expect(find.text('+1234567890'), findsOneWidget);
  });
}
