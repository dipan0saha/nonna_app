import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nonna_app/core/constants/supabase_tables.dart';
import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/di/providers.dart';

/// Screen for creating a new calendar event.
///
/// **Functional Requirements**: Section 3.6.4 - Additional Feature Screens
class EventCreationScreen extends ConsumerStatefulWidget {
  const EventCreationScreen({
    super.key,
    required this.babyProfileId,
    required this.createdByUserId,
    this.onCreated,
    this.onCancelled,
    this.onSaveEvent,
  });

  final String babyProfileId;
  final String createdByUserId;
  final VoidCallback? onCreated;
  final VoidCallback? onCancelled;
  final Future<void> Function(Map<String, dynamic> payload)? onSaveEvent;

  @override
  ConsumerState<EventCreationScreen> createState() =>
      _EventCreationScreenState();
}

class _EventCreationScreenState extends ConsumerState<EventCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;
  DateTime _startsAt = DateTime.now().add(const Duration(hours: 1));
  DateTime? _endsAt;
  bool _isSaving = false;
  String? _saveError;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _locationController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startsAt,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null && mounted) {
      setState(() {
        _startsAt = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _startsAt.hour,
          _startsAt.minute,
        );
      });
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endsAt ?? _startsAt.add(const Duration(hours: 1)),
      firstDate: _startsAt,
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null && mounted) {
      setState(() {
        _endsAt = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _endsAt?.hour ?? _startsAt.hour + 1,
          _endsAt?.minute ?? _startsAt.minute,
        );
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_endsAt != null && _endsAt!.isBefore(_startsAt)) {
      setState(() {
        _saveError = 'End date must be after start date';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _saveError = null;
    });

    try {
      final nowIso = DateTime.now().toIso8601String();
      final payload = {
        'baby_profile_id': widget.babyProfileId,
        'created_by_user_id': widget.createdByUserId,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        'location': _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        'starts_at': _startsAt.toIso8601String(),
        'ends_at': _endsAt?.toIso8601String(),
        'created_at': nowIso,
        'updated_at': nowIso,
      };

      if (widget.onSaveEvent != null) {
        await widget.onSaveEvent!(payload);
      } else {
        final databaseService = ref.read(databaseServiceProvider);
        await databaseService.insert(SupabaseTables.events, payload);
      }

      if (!mounted) return;
      setState(() => _isSaving = false);

      if (widget.onCreated != null) {
        widget.onCreated!.call();
      } else {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _saveError = 'Failed to save event: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEE, MMM d, yyyy');

    return Scaffold(
      key: const Key('event_creation_screen'),
      appBar: AppBar(title: const Text('New Event')),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                key: const Key('event_title_field'),
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Event Title',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Title is required' : null,
              ),
              AppSpacing.verticalGapM,
              TextFormField(
                key: const Key('event_description_field'),
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                textInputAction: TextInputAction.next,
              ),
              AppSpacing.verticalGapM,
              TextFormField(
                key: const Key('event_location_field'),
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location (optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                textInputAction: TextInputAction.next,
              ),
              AppSpacing.verticalGapM,
              ListTile(
                key: const Key('event_start_date_tile'),
                contentPadding: EdgeInsets.zero,
                title: const Text('Start Date'),
                subtitle: Text(dateFormat.format(_startsAt)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickStartDate,
              ),
              ListTile(
                key: const Key('event_end_date_tile'),
                contentPadding: EdgeInsets.zero,
                title: const Text('End Date (optional)'),
                subtitle: Text(
                    _endsAt != null ? dateFormat.format(_endsAt!) : 'Not set'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickEndDate,
              ),
              if (_saveError != null) ...[
                AppSpacing.verticalGapS,
                Text(
                  _saveError!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
              AppSpacing.verticalGapL,
              ElevatedButton(
                key: const Key('save_event_button'),
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Event'),
              ),
              AppSpacing.verticalGapS,
              OutlinedButton(
                onPressed: widget.onCancelled,
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
