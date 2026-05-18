import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nonna_app/core/constants/supabase_tables.dart';
import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/enums/user_role.dart';
import 'package:nonna_app/core/models/baby_membership.dart';

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

  // Follower invite state
  List<BabyMembership> _followers = [];
  Set<String> _selectedFollowerIds = {};
  bool _loadingFollowers = true;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _locationController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadFollowers());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  /// Loads active followers for this baby profile so they can be invited.
  Future<void> _loadFollowers() async {
    try {
      final databaseService = ref.read(databaseServiceProvider);
      final response = await databaseService
          .select(SupabaseTables.babyMemberships)
          .eq(SupabaseTables.babyProfileId, widget.babyProfileId)
          .eq('role', UserRole.follower.toJson());

      final rawList = response as List;
      if (rawList.isEmpty) {
        if (mounted) setState(() => _loadingFollowers = false);
        return;
      }

      final userIds =
          rawList.map((m) => (m as Map)['user_id'] as String).toList();
      final profilesResponse = await databaseService
          .select(
            SupabaseTables.userProfiles,
            columns:
                '${SupabaseTables.userId}, ${SupabaseTables.displayName}, ${SupabaseTables.avatarUrl}',
          )
          .inFilter(SupabaseTables.userId, userIds);

      final profileMap = <String, Map<String, dynamic>>{
        for (final p in profilesResponse as List<dynamic>)
          (p as Map)[SupabaseTables.userId] as String:
              Map<String, dynamic>.from(p),
      };

      final memberships = rawList.map((json) {
        final memberJson = Map<String, dynamic>.from(json as Map);
        final profile = profileMap[memberJson['user_id'] as String];
        if (profile != null) {
          memberJson[SupabaseTables.displayName] =
              profile[SupabaseTables.displayName];
          memberJson[SupabaseTables.avatarUrl] =
              profile[SupabaseTables.avatarUrl];
        }
        return BabyMembership.fromJson(memberJson);
      }).toList();

      if (!mounted) return;
      setState(() {
        _followers = memberships.where((m) => m.isActive).toList();
        _loadingFollowers = false;
      });
    } catch (e) {
      debugPrint('⚠️  Failed to load followers for invite: $e');
      if (mounted) setState(() => _loadingFollowers = false);
    }
  }

  /// Sends event invitations to selected followers via push notification.
  /// Each follower can RSVP themselves after receiving the notification.
  Future<void> _sendEventInvites(String eventId) async {
    if (_selectedFollowerIds.isEmpty) return;

    final supabaseClient = ref.read(supabaseClientProvider);
    final selectedFollowers =
        _followers.where((f) => _selectedFollowerIds.contains(f.userId));

    for (final follower in selectedFollowers) {
      try {
        await supabaseClient.functions.invoke(
          'notification-trigger',
          body: {
            'recipientUserId': follower.userId,
            'notificationType': 'event',
            'title': "You're invited: ${_titleController.text.trim()}",
            'message':
                'You have been invited to an event. Tap to view details.',
            'data': {
              'eventId': eventId,
              'babyProfileId': widget.babyProfileId,
            },
          },
        );
      } catch (e) {
        debugPrint('⚠️  Failed to invite follower ${follower.userId}: $e');
      }
    }
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
      final nowIso = DateTime.now().toUtc().toIso8601String();
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
        'starts_at': _startsAt.toUtc().toIso8601String(),
        'ends_at': _endsAt?.toUtc().toIso8601String(),
        'created_at': nowIso,
        'updated_at': nowIso,
      };

      if (widget.onSaveEvent != null) {
        await widget.onSaveEvent!(payload);
      } else {
        final databaseService = ref.read(databaseServiceProvider);
        final rows =
            await databaseService.insert(SupabaseTables.events, payload);
        final eventId = (rows.first as Map)['id'] as String;
        await _sendEventInvites(eventId);
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
    final dateFormat = DateFormat('EEE, MMM d, yyyy – h:mm a');

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
              // Invite followers section
              AppSpacing.verticalGapM,
              const Divider(),
              AppSpacing.verticalGapS,
              Text(
                'Invite Followers',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              AppSpacing.verticalGapXS,
              if (_loadingFollowers)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.s),
                  child: Center(
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              else if (_followers.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Text(
                    'No followers to invite yet.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                )
              else
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: _followers.map((follower) {
                    final isSelected =
                        _selectedFollowerIds.contains(follower.userId);
                    final label =
                        follower.displayName ?? follower.userId.substring(0, 8);
                    return FilterChip(
                      key: Key('follower_chip_${follower.userId}'),
                      label: Text(label),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedFollowerIds.add(follower.userId);
                          } else {
                            _selectedFollowerIds.remove(follower.userId);
                          }
                        });
                      },
                    );
                  }).toList(),
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
