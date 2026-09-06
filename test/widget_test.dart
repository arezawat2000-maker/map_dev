import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:map_dev/models/app_request.dart';
import 'package:map_dev/user/user_app.dart';
import 'package:map_dev/widgets/status_chip.dart';

void main() {
  testWidgets('User home shows request and track actions', (WidgetTester tester) async {
    await tester.pumpWidget(const MapDevUserApp());

    expect(find.text('MAP.DEV'), findsOneWidget);
    expect(find.text('Request an app'), findsOneWidget);
    expect(find.text('My requests'), findsOneWidget);
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
