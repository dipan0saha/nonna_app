import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/constants/supabase_tables.dart';
import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/models/event.dart';

/// Screen for editing an existing calendar event.
///
/// **Functional Requirements**: Section 3.6.4 - Additional Feature Screens
class EventEditScreen extends ConsumerStatefulWidget {
  const EventEditScreen({
    super.key,
    this.event,
    this.eventId,
  }) : assert(
          event != null || eventId != null,
          'Either event or eventId must be supplied',
        );

  final Event? event;
  final String? eventId;

  @override
  ConsumerState<EventEditScreen> createState() => _EventEditScreenState();
}

class _EventEditScreenState extends ConsumerState<EventEditScreen> {
  Event? _resolvedEvent;
  bool _isLoadingEvent = false;
  String? _resolveError;

  final _formKey = GlobalKey<FormState>();
  TextEditingController? _titleController;
  TextEditingController? _descriptionController;
  TextEditingController? _locationController;
  late DateTime _startsAt;
  DateTime? _endsAt;
  bool _isSaving = false;
  String? _saveError;

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _initializeWithEvent(widget.event!);
    } else {
      _isLoadingEvent = true;
      _fetchEvent();
    }
  }

  void _initializeWithEvent(Event event) {
    _resolvedEvent = event;
    _titleController = TextEditingController(text: event.title);
    _descriptionController =
        TextEditingController(text: event.description ?? '');
    _locationController = TextEditingController(text: event.location ?? '');
    _startsAt = event.startsAt;
    _endsAt = event.endsAt;
  }

  Future<void> _fetchEvent() async {
    try {
      final databaseService = ref.read(databaseServiceProvider);
      final response = await databaseService
          .select(SupabaseTables.events)
          .eq(SupabaseTables.id, widget.eventId!)
          .single();
      if (!mounted) return;
      final event = Event.fromJson(response);
      _initializeWithEvent(event);
      setState(() => _isLoadingEvent = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _resolveError = e.toString();
        _isLoadingEvent = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController?.dispose();
    _descriptionController?.dispose();
    _locationController?.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startsAt,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startsAt),
    );
    if (!mounted) return;
    setState(() {
      _startsAt = DateTime(
        picked.year,
        picked.month,
        picked.day,
        pickedTime?.hour ?? _startsAt.hour,
        pickedTime?.minute ?? _startsAt.minute,
      );
    });
  }

  Future<void> _pickEndDate() async {
    final initial = _endsAt ?? _startsAt.add(const Duration(hours: 1));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: _startsAt,
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (!mounted) return;
    setState(() {
      _endsAt = DateTime(
        picked.year,
        picked.month,
        picked.day,
        pickedTime?.hour ?? initial.hour,
        pickedTime?.minute ?? initial.minute,
      );
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_endsAt != null && _endsAt!.isBefore(_startsAt)) {
      setState(() => _saveError = 'End date must be after start date');
      return;
    }

    setState(() {
      _isSaving = true;
      _saveError = null;
    });

    try {
      final databaseService = ref.read(databaseServiceProvider);
      await databaseService.update(SupabaseTables.events, {
        'title': _titleController!.text.trim(),
        'description': _descriptionController!.text.trim().isEmpty
            ? null
            : _descriptionController!.text.trim(),
        'location': _locationController!.text.trim().isEmpty
            ? null
            : _locationController!.text.trim(),
        'starts_at': _startsAt.toUtc().toIso8601String(),
        'ends_at': _endsAt?.toUtc().toIso8601String(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq(SupabaseTables.id, _resolvedEvent!.id);

      if (!mounted) return;

      // Build the updated event to pass back so the detail screen
      // can refresh immediately without waiting for a DB round-trip.
      final updatedEvent = Event(
        id: _resolvedEvent!.id,
        babyProfileId: _resolvedEvent!.babyProfileId,
        createdByUserId: _resolvedEvent!.createdByUserId,
        title: _titleController!.text.trim(),
        description: _descriptionController!.text.trim().isEmpty
            ? null
            : _descriptionController!.text.trim(),
        location: _locationController!.text.trim().isEmpty
            ? null
            : _locationController!.text.trim(),
        startsAt: _startsAt,
        endsAt: _endsAt,
        videoLink: _resolvedEvent!.videoLink,
        coverPhotoUrl: _resolvedEvent!.coverPhotoUrl,
        createdAt: _resolvedEvent!.createdAt,
        updatedAt: DateTime.now().toUtc(),
        deletedAt: _resolvedEvent!.deletedAt,
      );
      Navigator.of(context).pop(updatedEvent);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _saveError = 'Failed to update event: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingEvent) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_resolveError != null) {
      return Scaffold(
          body: Center(child: Text('Failed to load event: $_resolveError')));
    }
    final dateFormat = DateFormat('EEE, MMM d, yyyy \u2013 h:mm a');

    return Scaffold(
      key: const Key('event_edit_screen'),
      appBar: AppBar(title: const Text('Edit Event')),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                key: const Key('edit_event_title_field'),
                controller: _titleController!,
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
                key: const Key('edit_event_description_field'),
                controller: _descriptionController!,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                textInputAction: TextInputAction.next,
              ),
              AppSpacing.verticalGapM,
              TextFormField(
                key: const Key('edit_event_location_field'),
                controller: _locationController!,
                decoration: const InputDecoration(
                  labelText: 'Location (optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                textInputAction: TextInputAction.next,
              ),
              AppSpacing.verticalGapM,
              ListTile(
                key: const Key('edit_event_start_date_tile'),
                contentPadding: EdgeInsets.zero,
                title: const Text('Start Date & Time'),
                subtitle: Text(dateFormat.format(_startsAt)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickStartDate,
              ),
              ListTile(
                key: const Key('edit_event_end_date_tile'),
                contentPadding: EdgeInsets.zero,
                title: const Text('End Date & Time (optional)'),
                subtitle: Text(
                  _endsAt != null ? dateFormat.format(_endsAt!) : 'Not set',
                ),
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
                key: const Key('save_edit_event_button'),
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Changes'),
              ),
              AppSpacing.verticalGapS,
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
