import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:map_dev_admin/admin/admin_app.dart';
import 'package:map_dev_admin/models/app_request.dart';
import 'package:map_dev_admin/widgets/status_chip.dart';

void main() {
  testWidgets('AdminRequestCard renders request details', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdminRequestCard.fromMap({
            'id': 'abc',
            'app_name': 'Demo App',
            'app_description': 'A sample request description',
            'requester_name': 'Jane Doe',
            'contact': 'jane@example.com',
            'phone_number': '+1234567890',
            'status': 'pending',
            'timestamp': '2026-01-15T10:30:00.000Z',
          }),
        ),
      ),
    );

    expect(find.text('DEMO APP'), findsOneWidget);
    expect(find.text('A sample request description'), findsOneWidget);
    expect(find.text('Jane Doe'), findsOneWidget);
    expect(find.text('jane@example.com'), findsOneWidget);
    expect(find.text('+1234567890'), findsOneWidget);
    expect(find.text('PENDING'), findsOneWidget);
  });

  testWidgets('StatusChip shows label', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: StatusChip(status: AppRequest.statusInProgress)),
      ),
    );
    expect(find.text('IN PROGRESS'), findsOneWidget);
  });
}
