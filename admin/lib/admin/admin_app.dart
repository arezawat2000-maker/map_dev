import 'package:flutter/material.dart';

import '../models/app_request.dart';
import '../services/request_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/status_chip.dart';

class MapDevAdminApp extends StatelessWidget {
  const MapDevAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MAP.DEV Admin',
      debugShowCheckedModeBanner: false,
      theme: MapDevTheme.dark(),
      home: const AdminRequestsPage(),
    );
  }
}

class AdminRequestsPage extends StatefulWidget {
  const AdminRequestsPage({super.key});

  @override
  State<AdminRequestsPage> createState() => _AdminRequestsPageState();
}

class _AdminRequestsPageState extends State<AdminRequestsPage> {
  final _repo = RequestRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MAP.DEV REQUESTS'),
      ),
      body: StreamBuilder<List<AppRequest>>(
        stream: _repo.watchAll(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: MapDevTheme.red),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final requests = snapshot.data ?? [];
          if (requests.isEmpty) {
            return const Center(
              child: Text(
                'No requests found.',
                style: TextStyle(color: MapDevTheme.muted, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              return AdminRequestCard(
                key: ValueKey(requests[index].id),
                request: requests[index],
                onStatusChanged: (status) =>
                    _repo.updateStatus(requests[index].id, status),
              );
            },
          );
        },
      ),
    );
  }
}

class AdminRequestCard extends StatelessWidget {
  final AppRequest request;
  final Future<void> Function(String status) onStatusChanged;

  const AdminRequestCard({
    super.key,
    required this.request,
    required this.onStatusChanged,
  });

  /// Test-friendly constructor used by widget tests with a raw map.
  factory AdminRequestCard.fromMap(
    Map<dynamic, dynamic> map, {
    Key? key,
    Future<void> Function(String status)? onStatusChanged,
  }) {
    final id = (map['id'] ?? 'test').toString();
    return AdminRequestCard(
      key: key,
      request: AppRequest.fromMap(id, map),
      onStatusChanged: onStatusChanged ?? (_) async {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    request.appName.isEmpty
                        ? 'UNKNOWN APP'
                        : request.appName.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: MapDevTheme.cyan,
                    ),
                  ),
                ),
                StatusChip(status: request.status),
              ],
            ),
            if (request.formattedDate.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                request.formattedDate,
                style: const TextStyle(fontSize: 12, color: MapDevTheme.muted),
              ),
            ],
            const SizedBox(height: 12),
            const Text(
              'DESCRIPTION',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: MapDevTheme.muted,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              request.appDescription.isEmpty
                  ? 'No description provided'
                  : request.appDescription,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: MapDevTheme.border, height: 1),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _InfoSection(
                    icon: Icons.person_outline,
                    label: 'REQUESTER',
                    value: request.requesterName.isEmpty
                        ? 'Unknown'
                        : request.requesterName,
                  ),
                ),
                Expanded(
                  child: _InfoSection(
                    icon: Icons.email_outlined,
                    label: 'EMAIL',
                    value:
                        request.contact.isEmpty ? 'No email' : request.contact,
                  ),
                ),
                Expanded(
                  child: _InfoSection(
                    icon: Icons.phone_outlined,
                    label: 'PHONE',
                    value: request.phoneNumber.isEmpty
                        ? 'No phone'
                        : request.phoneNumber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Text(
                  'STATUS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: MapDevTheme.muted,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: request.status,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: AppRequest.allStatuses
                        .map(
                          (s) => DropdownMenuItem(
                            value: s,
                            child: Text(AppRequest.statusLabel(s)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null || value == request.status) return;
                      onStatusChanged(value);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoSection({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: MapDevTheme.muted),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: MapDevTheme.muted,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
