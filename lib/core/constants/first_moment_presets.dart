/// Static chip presets for the First Moment onboarding step.
///
/// Filled in during Phase 1d. Phase 0 provides the structure only.
class FirstMomentEventPreset {
  const FirstMomentEventPreset({
    required this.id,
    required this.label,
    required this.dayOffset,
  });

  final String id;
  final String label;

  /// Days offset from due date or birth date when seeding events.
  final int dayOffset;
}

class FirstMomentRegistryPreset {
  const FirstMomentRegistryPreset({
    required this.id,
    required this.label,
  });

  final String id;
  final String label;
}

/// Expecting-branch presets (Phase 1d).
class FirstMomentPresets {
  FirstMomentPresets._();

  static const List<FirstMomentEventPreset> expectingEvents = [
    FirstMomentEventPreset(
      id: 'gender_reveal',
      label: 'Gender Reveal',
      dayOffset: 0,
    ),
    FirstMomentEventPreset(
      id: 'baby_shower',
      label: 'Baby Shower',
      dayOffset: 7,
    ),
    FirstMomentEventPreset(
      id: 'due_date',
      label: 'Due Date',
      dayOffset: 14,
    ),
  ];

  static const List<FirstMomentRegistryPreset> expectingRegistry = [
    FirstMomentRegistryPreset(id: 'swaddles', label: 'Swaddles'),
    FirstMomentRegistryPreset(id: 'crib', label: 'Crib'),
    FirstMomentRegistryPreset(id: 'diapers', label: 'Diapers'),
  ];

  static const List<FirstMomentEventPreset> bornEvents = [
    FirstMomentEventPreset(
      id: 'first_checkup',
      label: 'First Checkup',
      dayOffset: 0,
    ),
    FirstMomentEventPreset(
      id: 'baptism',
      label: 'Baptism',
      dayOffset: 7,
    ),
    FirstMomentEventPreset(
      id: 'first_holidays',
      label: 'First Holidays',
      dayOffset: 14,
    ),
  ];

  static const List<FirstMomentRegistryPreset> bornRegistry = [
    FirstMomentRegistryPreset(id: 'diapers', label: 'Diapers'),
    FirstMomentRegistryPreset(id: 'onesies', label: 'Onesies'),
    FirstMomentRegistryPreset(id: 'bottles', label: 'Bottles'),
  ];

  /// UI cap — DB trigger allows max 2 events per calendar day (#20).
  static const int maxSelectableEvents = 2;
}
