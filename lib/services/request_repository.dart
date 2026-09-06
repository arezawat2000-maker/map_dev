import 'package:firebase_database/firebase_database.dart';

import '../models/app_request.dart';

/// Firebase Realtime Database access for app requests.
class RequestRepository {
  RequestRepository({FirebaseDatabase? database})
      : _ref = (database ?? FirebaseDatabase.instance).ref('requests');

  final DatabaseReference _ref;

  Stream<List<AppRequest>> watchAll() {
    return _ref.onValue.map((event) => _parseList(event.snapshot));
  }

  /// Stream requests matching [email] (case-insensitive) and optional [phone].
  Stream<List<AppRequest>> watchForContact({
    required String email,
    String? phone,
  }) {
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedPhone = _digitsOnly(phone);

    return watchAll().map((all) {
      return all.where((r) {
        final emailMatch =
            r.contact.trim().toLowerCase() == normalizedEmail;
        if (!emailMatch) return false;
        if (normalizedPhone == null || normalizedPhone.isEmpty) return true;
        return _digitsOnly(r.phoneNumber) == normalizedPhone;
      }).toList();
    });
  }

  Future<String> create(AppRequest draft) async {
    final newRef = _ref.push();
    await newRef.set(draft.toCreateMap());
    return newRef.key!;
  }

  Future<void> updateStatus(String id, String status) async {
    final normalized = AppRequest.allStatuses.contains(status)
        ? status
        : AppRequest.statusPending;
    await _ref.child(id).update({'status': normalized});
  }

  List<AppRequest> _parseList(DataSnapshot snapshot) {
    if (snapshot.value == null) return [];

    final data = snapshot.value;
    if (data is! Map) return [];

    final list = <AppRequest>[];
    data.forEach((key, value) {
      if (value is Map) {
        list.add(AppRequest.fromMap(key.toString(), value));
      }
    });

    list.sort((a, b) {
      final tA = a.timestamp ?? '';
      final tB = b.timestamp ?? '';
      return tB.compareTo(tA);
    });
    return list;
  }

  static String? _digitsOnly(String? value) {
    if (value == null) return null;
    final digits = value.replaceAll(RegExp(r'\D'), '');
    return digits.isEmpty ? null : digits;
  }
}
