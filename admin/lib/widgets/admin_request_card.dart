import 'package:flutter/material.dart';

import '../models/app_request.dart';
import '../theme/app_theme.dart';
import 'status_chip.dart';

class AdminRequestCard extends StatelessWidget {
  final AppRequest request;
  final Future<void> Function(
    String status, {
    String? estimatedDuration,
  }) onStatusChanged;
  final Future<void> Function(String estimatedDuration) onEtaChanged;

  const AdminRequestCard({
    super.key,
    required this.request,
    required this.onStatusChanged,
    required this.onEtaChanged,
  });

  /// Test-friendly constructor used by widget tests with a raw map.
  factory AdminRequestCard.fromMap(
    Map<dynamic, dynamic> map, {
    Key? key,
    Future<void> Function(String status, {String? estimatedDuration})?
        onStatusChanged,
    Future<void> Function(String estimatedDuration)? onEtaChanged,
  }) {
    final id = (map['id'] ?? 'test').toString();
    return AdminRequestCard(
      key: key,
      request: AppRequest.fromMap(id, map),
      onStatusChanged: onStatusChanged ?? (_, {estimatedDuration}) async {},
      onEtaChanged: onEtaChanged ?? (_) async {},
    );
  }

  Future<void> _handleStatusChange(BuildContext context, String? value) async {
    if (value == null) return;
    final next = AppRequest.displayStage(value);
    final current = request.stage;
    if (next == current &&
        !(next == AppRequest.statusAccepted && !request.hasEta)) {
      return;
    }

    if (next == AppRequest.statusAccepted) {
      final eta = await showEtaPickerDialog(
        context,
        initial: request.etaDisplay,
        title: 'Accept request',
        subtitle: 'Set an estimated delivery time before confirming.',
        confirmLabel: 'Accept',
      );
      if (eta == null || eta.isEmpty) return;
      await onStatusChanged(
        AppRequest.statusAccepted,
        estimatedDuration: eta,
      );
      return;
    }

    await onStatusChanged(next);
  }

  Future<void> _editEta(BuildContext context) async {
    final eta = await showEtaPickerDialog(
      context,
      initial: request.etaDisplay,
      title: 'Update estimate',
      subtitle: 'Change the estimated delivery time shown to the user.',
      confirmLabel: 'Save',
    );
    if (eta == null || eta.isEmpty) return;
    await onEtaChanged(eta);
  }

  @override
  Widget build(BuildContext context) {
    final dropdownValue = request.stage;

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
            if (request.hasEta) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    size: 14,
                    color: MapDevTheme.cyan,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Estimated: ${request.etaDisplay}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: MapDevTheme.cyan,
                    ),
                  ),
                ],
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
                    initialValue: dropdownValue,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: AppRequest.selectableStatuses
                        .map(
                          (s) => DropdownMenuItem(
                            value: s,
                            child: Text(AppRequest.statusLabel(s)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => _handleStatusChange(context, value),
                  ),
                ),
              ],
            ),
            if (request.stage == AppRequest.statusAccepted) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _editEta(context),
                  icon: const Icon(Icons.edit_calendar_outlined, size: 18),
                  label: Text(
                    request.hasEta ? 'Update estimate' : 'Set estimate',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Returns the chosen ETA string, or `null` if cancelled.
Future<String?> showEtaPickerDialog(
  BuildContext context, {
  String? initial,
  String title = 'Estimated time',
  String subtitle = 'How long until delivery?',
  String confirmLabel = 'Confirm',
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => _EtaPickerDialog(
      initial: initial,
      title: title,
      subtitle: subtitle,
      confirmLabel: confirmLabel,
    ),
  );
}

class _EtaPickerDialog extends StatefulWidget {
  final String? initial;
  final String title;
  final String subtitle;
  final String confirmLabel;

  const _EtaPickerDialog({
    this.initial,
    required this.title,
    required this.subtitle,
    required this.confirmLabel,
  });

  @override
  State<_EtaPickerDialog> createState() => _EtaPickerDialogState();
}

class _EtaPickerDialogState extends State<_EtaPickerDialog> {
  static const _customKey = '__custom__';

  late String _selected;
  late final TextEditingController _customController;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial?.trim() ?? '';
    if (initial.isNotEmpty && AppRequest.etaPresets.contains(initial)) {
      _selected = initial;
      _customController = TextEditingController();
    } else if (initial.isNotEmpty) {
      _selected = _customKey;
      _customController = TextEditingController(text: initial);
    } else {
      _selected = '2 months';
      _customController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  String? get _resolvedEta {
    if (_selected == _customKey) {
      final custom = _customController.text.trim();
      return custom.isEmpty ? null : custom;
    }
    return _selected;
  }

  @override
  Widget build(BuildContext context) {
    final canConfirm = _resolvedEta != null;

    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.subtitle,
              style: const TextStyle(
                fontSize: 13,
                color: MapDevTheme.muted,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final preset in AppRequest.etaPresets)
                  ChoiceChip(
                    label: Text(preset),
                    selected: _selected == preset,
                    onSelected: (_) => setState(() => _selected = preset),
                  ),
                ChoiceChip(
                  label: const Text('Custom'),
                  selected: _selected == _customKey,
                  onSelected: (_) => setState(() => _selected = _customKey),
                ),
              ],
            ),
            if (_selected == _customKey) ...[
              const SizedBox(height: 14),
              TextField(
                controller: _customController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Custom estimate',
                  hintText: 'e.g. 6 weeks',
                ),
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) {
                  final eta = _resolvedEta;
                  if (eta != null) Navigator.of(context).pop(eta);
                },
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: canConfirm
              ? () => Navigator.of(context).pop(_resolvedEta)
              : null,
          child: Text(widget.confirmLabel),
        ),
      ],
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
