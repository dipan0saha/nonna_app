import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nonna_app/core/constants/spacing.dart';
import 'package:nonna_app/core/constants/supabase_tables.dart';
import 'package:nonna_app/core/di/providers.dart';
import 'package:nonna_app/core/models/registry_item.dart';

/// Screen for editing an existing registry item.
class RegistryItemEditScreen extends ConsumerStatefulWidget {
  const RegistryItemEditScreen({
    super.key,
    required this.item,
  });

  final RegistryItem item;

  @override
  ConsumerState<RegistryItemEditScreen> createState() =>
      _RegistryItemEditScreenState();
}

class _RegistryItemEditScreenState
    extends ConsumerState<RegistryItemEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _linkController;
  late int _priority;
  bool _isSaving = false;
  String? _saveError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _descriptionController =
        TextEditingController(text: widget.item.description ?? '');
    _linkController = TextEditingController(text: widget.item.linkUrl ?? '');
    _priority = widget.item.priority;
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

    try {
      await ref
          .read(databaseServiceProvider)
          .update(SupabaseTables.registryItems, {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        'link_url': _linkController.text.trim().isNotEmpty
            ? _linkController.text.trim()
            : null,
        'priority': _priority,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', widget.item.id);

      if (!mounted) return;
      context.pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _saveError = e.toString();
      });
    }
  }

  InputDecoration _fieldDecoration(BuildContext context, String label,
      {Widget? prefixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      border: const OutlineInputBorder(),
      prefixIcon: prefixIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final fieldStyle =
        TextStyle(color: Theme.of(context).colorScheme.onSurface);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Registry Item')),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                style: fieldStyle,
                decoration: _fieldDecoration(context, 'Item Name'),
                textInputAction: TextInputAction.next,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Item name is required'
                    : null,
              ),
              AppSpacing.verticalGapM,
              TextFormField(
                controller: _descriptionController,
                style: fieldStyle,
                decoration: _fieldDecoration(context, 'Description (optional)'),
                maxLines: 3,
                textInputAction: TextInputAction.next,
              ),
              AppSpacing.verticalGapM,
              TextFormField(
                controller: _linkController,
                style: fieldStyle,
                decoration: _fieldDecoration(
                  context,
                  'Link URL (optional)',
                  prefixIcon: const Icon(Icons.link),
                ),
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.done,
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
                      value: _priority.toDouble(),
                      min: 1,
                      max: 5,
                      divisions: 4,
                      label: '$_priority',
                      onChanged: (v) => setState(() => _priority = v.round()),
                    ),
                  ),
                  SizedBox(
                    width: 32,
                    child: Text(
                      '$_priority',
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
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ],
              AppSpacing.verticalGapL,
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Changes'),
              ),
              AppSpacing.verticalGapS,
              OutlinedButton(
                onPressed: _isSaving ? null : () => context.pop(false),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
