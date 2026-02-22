import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nonna_app/core/constants/spacing.dart';

/// Screen for creating a new registry item.
///
/// **Functional Requirements**: Section 3.6.4 - Additional Feature Screens
class RegistryItemCreationScreen extends ConsumerStatefulWidget {
  const RegistryItemCreationScreen({
    super.key,
    required this.babyProfileId,
    required this.createdByUserId,
    this.onCreated,
    this.onCancelled,
  });

  final String babyProfileId;
  final String createdByUserId;
  final VoidCallback? onCreated;
  final VoidCallback? onCancelled;

  @override
  ConsumerState<RegistryItemCreationScreen> createState() =>
      _RegistryItemCreationScreenState();
}

class _RegistryItemCreationScreenState
    extends ConsumerState<RegistryItemCreationScreen> {
  static const int _defaultPriority = 3;

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _linkController;
  int _priority = _defaultPriority;
  bool _isSaving = false;
  String? _saveError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _linkController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _saveError = null;
    });

    // In production this would call a service to persist the item.
    await Future<void>.delayed(const Duration(milliseconds: 200));

    if (!mounted) return;
    setState(() => _isSaving = false);
    widget.onCreated?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('registry_item_creation_screen'),
      appBar: AppBar(title: const Text('Add Registry Item')),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                key: const Key('item_name_field'),
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Item name is required' : null,
              ),
              AppSpacing.verticalGapM,
              TextFormField(
                key: const Key('item_description_field'),
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
                key: const Key('item_link_field'),
                controller: _linkController,
                decoration: const InputDecoration(
                  labelText: 'Link URL (optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link),
                ),
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.next,
              ),
              AppSpacing.verticalGapM,
              Text(
                'Priority',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              AppSpacing.verticalGapXS,
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      key: const Key('priority_slider'),
                      value: _priority.toDouble(),
                      min: 1,
                      max: 5,
                      divisions: 4,
                      label: '$_priority',
                      onChanged: (v) =>
                          setState(() => _priority = v.round()),
                    ),
                  ),
                  SizedBox(
                    width: 32,
                    child: Text(
                      '$_priority',
                      key: const Key('priority_value_text'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
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
                key: const Key('save_item_button'),
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Add Item'),
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
