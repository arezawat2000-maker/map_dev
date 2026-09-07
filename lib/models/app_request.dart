/// App-request model for the MAP.DEV user app.
///
/// Firebase Realtime Database path: `requests/{id}`
///
/// Progress stages (UX): pending → accepted (with ETA) → completed (done).
/// [statusDeclined] is kept for rejections. Legacy statuses `reviewing` and
/// `in_progress` are still read from Firebase and mapped for display/active logic.
class AppRequest {
  static const String statusPending = 'pending';
  static const String statusAccepted = 'accepted';
  static const String statusCompleted = 'completed';
  static const String statusDeclined = 'declined';

  /// Legacy — treated like pending for UX / still active.
  static const String statusReviewing = 'reviewing';

  /// Legacy — treated like accepted for UX / still active.
  static const String statusInProgress = 'in_progress';

  /// Statuses the admin UI can set.
  static const List<String> selectableStatuses = [
    statusPending,
    statusAccepted,
    statusCompleted,
    statusDeclined,
  ];

  /// All known statuses including legacy values from older data.
  static const List<String> allStatuses = [
    statusPending,
    statusReviewing,
    statusAccepted,
    statusInProgress,
    statusCompleted,
    statusDeclined,
  ];

  /// Terminal statuses — user may submit a new request.
  static const Set<String> doneStatuses = {
    statusCompleted,
    statusDeclined,
  };

  /// Preset ETA labels shown when accepting a request.
  static const List<String> etaPresets = [
    '1 week',
    '2 weeks',
    '1 month',
    '2 months',
    '3 months',
  ];

  final String id;
  final String appName;
  final String appDescription;
  final String requesterName;
  final String contact;
  final String phoneNumber;
  final String status;

  /// Human-readable duration set when accepted, e.g. `"2 months"`.
  /// Firebase field: `estimated_duration`.
  final String? estimatedDuration;
  final String? timestamp;

  const AppRequest({
    required this.id,
    required this.appName,
    required this.appDescription,
    required this.requesterName,
    required this.contact,
    required this.phoneNumber,
    this.status = statusPending,
    this.estimatedDuration,
    this.timestamp,
  });

  factory AppRequest.fromMap(String id, Map<dynamic, dynamic> map) {
    final rawEta = map['estimated_duration'] ?? map['eta'];
    final eta = rawEta?.toString().trim();
    return AppRequest(
      id: id,
      appName: (map['app_name'] ?? '').toString(),
      appDescription: (map['app_description'] ?? '').toString(),
      requesterName: (map['requester_name'] ?? '').toString(),
      contact: (map['contact'] ?? '').toString(),
      phoneNumber: (map['phone_number'] ?? '').toString(),
      status: _normalizeStatus(map['status']),
      estimatedDuration: (eta == null || eta.isEmpty) ? null : eta,
      timestamp: map['timestamp']?.toString(),
    );
  }

  Map<String, dynamic> toCreateMap() {
    final map = <String, dynamic>{
      'app_name': appName,
      'app_description': appDescription,
      'requester_name': requesterName,
      'contact': contact,
      'phone_number': phoneNumber,
      'status': status,
      'timestamp': timestamp ?? DateTime.now().toUtc().toIso8601String(),
    };
    if (estimatedDuration != null && estimatedDuration!.isNotEmpty) {
      map['estimated_duration'] = estimatedDuration;
    }
    return map;
  }

  static String _normalizeStatus(dynamic raw) {
    final value = (raw ?? statusPending).toString().toLowerCase().trim();
    if (allStatuses.contains(value)) return value;
    return statusPending;
  }

  /// Maps raw/legacy status onto the 3-stage UX model (+ declined).
  ///
  /// - `reviewing` → pending
  /// - `in_progress` → accepted
  static String displayStage(String status) {
    switch (_normalizeStatus(status)) {
      case statusAccepted:
      case statusInProgress:
        return statusAccepted;
      case statusCompleted:
        return statusCompleted;
      case statusDeclined:
        return statusDeclined;
      case statusPending:
      case statusReviewing:
      default:
        return statusPending;
    }
  }

  /// Progress index for the 3-step UI: 0 pending, 1 accepted, 2 done.
  /// Returns `-1` for declined.
  static int progressStep(String status) {
    switch (displayStage(status)) {
      case statusAccepted:
        return 1;
      case statusCompleted:
        return 2;
      case statusDeclined:
        return -1;
      case statusPending:
      default:
        return 0;
    }
  }

  static String statusLabel(String status) {
    switch (displayStage(status)) {
      case statusAccepted:
        return 'Accepted';
      case statusCompleted:
        return 'Done';
      case statusDeclined:
        return 'Declined';
      case statusPending:
      default:
        return 'Pending';
    }
  }

  /// Whether [status] is finished (allows a new request).
  /// Missing/unknown statuses normalize to [statusPending] and are active.
  /// Legacy `reviewing` / `in_progress` remain active.
  static bool isDoneStatus(String status) =>
      doneStatuses.contains(_normalizeStatus(status));

  /// Finished request — user may submit another.
  bool get isDone => isDoneStatus(status);

  /// Non-terminal request — blocks submitting another.
  bool get isActive => !isDone;

  String get stage => displayStage(status);

  int get step => progressStep(status);

  bool get hasEta =>
      estimatedDuration != null && estimatedDuration!.trim().isNotEmpty;

  /// Shown when accepted (or historically after completion).
  String? get etaDisplay => hasEta ? estimatedDuration!.trim() : null;

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
