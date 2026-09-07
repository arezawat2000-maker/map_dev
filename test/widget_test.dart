import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:map_dev/models/app_request.dart';
import 'package:map_dev/models/chat_message.dart';
import 'package:map_dev/models/chat_meta.dart';
import 'package:map_dev/widgets/status_chip.dart';

void main() {
  testWidgets('StatusChip shows accepted for legacy in_progress',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: StatusChip(status: AppRequest.statusInProgress)),
      ),
    );
    expect(find.text('ACCEPTED'), findsOneWidget);
  });

  testWidgets('StatusChip shows done for completed', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: StatusChip(status: AppRequest.statusCompleted)),
      ),
    );
    expect(find.text('DONE'), findsOneWidget);
  });

  test('legacy reviewing maps to pending stage', () {
    expect(
      AppRequest.displayStage(AppRequest.statusReviewing),
      AppRequest.statusPending,
    );
    expect(AppRequest.isDoneStatus(AppRequest.statusReviewing), isFalse);
  });

  test('legacy in_progress maps to accepted and stays active', () {
    expect(
      AppRequest.displayStage(AppRequest.statusInProgress),
      AppRequest.statusAccepted,
    );
    expect(AppRequest.isDoneStatus(AppRequest.statusInProgress), isFalse);
  });

  test('estimated_duration is parsed from map', () {
    final request = AppRequest.fromMap('1', {
      'app_name': 'Demo',
      'status': 'accepted',
      'estimated_duration': '2 months',
    });
    expect(request.etaDisplay, '2 months');
    expect(request.stage, AppRequest.statusAccepted);
  });

  test('chat gate: empty allows one; then blocked until enabled', () {
    expect(
      ChatMeta.canUserSend(chatEnabled: false, messagesEmpty: true),
      isTrue,
    );
    expect(
      ChatMeta.canUserSend(chatEnabled: false, messagesEmpty: false),
      isFalse,
    );
    expect(
      ChatMeta.canUserSend(chatEnabled: true, messagesEmpty: false),
      isTrue,
    );
  });

  test('admin messages show Map.dev to users and username to admins', () {
    const msg = ChatMessage(
      id: '1',
      text: 'Hi',
      sender: 'admin',
      senderName: 'Alex',
      senderEmail: 'alex@map.dev',
    );
    expect(msg.displayNameForUser(), 'Map.dev');
    expect(msg.displayNameForAdmin(), 'Alex');
  });
}
