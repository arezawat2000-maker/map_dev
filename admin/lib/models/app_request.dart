/// App-request model for the MAP.DEV admin app.
///
/// Firebase Realtime Database path: `requests/{id}`
class AppRequest {
  static const String statusPending = 'pending';
  static const String statusReviewing = 'reviewing';
  static const String statusAccepted = 'accepted';
  static const String statusInProgress = 'in_progress';
  static const String statusCompleted = 'completed';
  static const String statusDeclined = 'declined';

  static const List<String> allStatuses = [
    statusPending,
    statusReviewing,
    statusAccepted,
    statusInProgress,
    statusCompleted,
    statusDeclined,
  ];

  final String id;
  final String appName;
  final String appDescription;
  final String requesterName;
  final String contact;
  final String phoneNumber;
  final String status;
  final String? timestamp;

  const AppRequest({
    required this.id,
    required this.appName,
    required this.appDescription,
    required this.requesterName,
    required this.contact,
    required this.phoneNumber,
    this.status = statusPending,
    this.timestamp,
  });

  factory AppRequest.fromMap(String id, Map<dynamic, dynamic> map) {
    return AppRequest(
      id: id,
      appName: (map['app_name'] ?? '').toString(),
      appDescription: (map['app_description'] ?? '').toString(),
      requesterName: (map['requester_name'] ?? '').toString(),
      contact: (map['contact'] ?? '').toString(),
      phoneNumber: (map['phone_number'] ?? '').toString(),
      status: _normalizeStatus(map['status']),
      timestamp: map['timestamp']?.toString(),
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {
      'app_name': appName,
      'app_description': appDescription,
      'requester_name': requesterName,
      'contact': contact,
      'phone_number': phoneNumber,
      'status': status,
      'timestamp': timestamp ?? DateTime.now().toUtc().toIso8601String(),
    };
  }

  static String _normalizeStatus(dynamic raw) {
    final value = (raw ?? statusPending).toString().toLowerCase().trim();
    if (allStatuses.contains(value)) return value;
    return statusPending;
  }

  static String statusLabel(String status) {
    switch (_normalizeStatus(status)) {
      case statusReviewing:
        return 'Under review';
      case statusAccepted:
        return 'Accepted';
      case statusInProgress:
        return 'In progress';
      case statusCompleted:
        return 'Completed';
      case statusDeclined:
        return 'Declined';
      case statusPending:
      default:
        return 'Pending';
    }
  }

  DateTime? get parsedTimestamp {
    if (timestamp == null || timestamp!.isEmpty) return null;
    try {
      return DateTime.parse(timestamp!);
    } catch (_) {
      return null;
    }
  }

  String get formattedDate {
    final date = parsedTimestamp;
    if (date == null) return '';
    final local = date.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    final h = local.hour.toString().padLeft(2, '0');
    final min = local.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $h:$min';
  }
}
