import 'package:firebase_database/firebase_database.dart';

import '../models/app_request.dart';

/// Thrown when [RequestRepository.create] is blocked by an active request.
class ActiveRequestException implements Exception {
  final AppRequest active;

  const ActiveRequestException(this.active);

  String get statusLabel => AppRequest.statusLabel(active.status);

  @override
  String toString() =>
      'You already have an app request in progress (${statusLabel.toLowerCase()}).';
}

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

  /// First active (non-done) request for [email], if any.
  Future<AppRequest?> findActiveForEmail(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty) return null;

    final snapshot = await _ref.get();
    final all = _parseList(snapshot);
    for (final r in all) {
      if (r.contact.trim().toLowerCase() != normalizedEmail) continue;
      if (r.isActive) return r;
    }
    return null;
  }

  /// Creates a request, or throws [ActiveRequestException] if one is in progress.
  Future<String> create(AppRequest draft) async {
    final normalized = AppRequest(
      id: draft.id,
      appName: draft.appName,
      appDescription: draft.appDescription,
      requesterName: draft.requesterName,
      contact: draft.contact.trim().toLowerCase(),
      phoneNumber: draft.phoneNumber.trim(),
      status: draft.status,
      estimatedDuration: draft.estimatedDuration,
      timestamp: draft.timestamp,
    );
    final active = await findActiveForEmail(normalized.contact);
    if (active != null) {
      throw ActiveRequestException(active);
    }

    final newRef = _ref.push();
    await newRef.set(normalized.toCreateMap());
    return newRef.key!;
  }

  Future<void> updateStatus(
    String id,
    String status, {
    String? estimatedDuration,
  }) async {
    final stage = AppRequest.displayStage(status);
    final writable = AppRequest.selectableStatuses.contains(stage)
        ? stage
        : AppRequest.statusPending;
    final updates = <String, dynamic>{'status': writable};
    if (estimatedDuration != null) {
      final trimmed = estimatedDuration.trim();
      if (trimmed.isNotEmpty) {
        updates['estimated_duration'] = trimmed;
      }
    }
    await _ref.child(id).update(updates);
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
