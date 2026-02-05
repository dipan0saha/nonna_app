import 'package:flutter/material.dart';
import 'package:nonna_app/flutter_gen/gen_l10n/app_localizations.dart';

import '../core/widgets/custom_button.dart';
import '../core/widgets/empty_state.dart';
import '../core/widgets/error_view.dart';

/// Example widget demonstrating localization usage with Phase 1 widgets.
///
/// This example shows how to use the AppLocalizations class to access
/// localized strings throughout your app.
class LocalizationExampleScreen extends StatelessWidget {
  const LocalizationExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Access localized strings
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome section
            Text(
              l10n.welcome,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(l10n.helloUser('Maria')),
            const SizedBox(height: 24),

            // Common buttons with localization
            Text(
              'Common Buttons:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                CustomButton(
                  onPressed: () {},
                  label: l10n.common_save,
                  variant: ButtonVariant.primary,
                ),
                CustomButton(
                  onPressed: () {},
                  label: l10n.common_cancel,
                  variant: ButtonVariant.secondary,
                ),
                CustomButton(
                  onPressed: () {},
                  label: l10n.common_delete,
                  variant: ButtonVariant.tertiary,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Empty state example
            Text(
              'Empty State Example:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 300,
              child: EmptyState(
                title: l10n.empty_state_recipes_title,
                message: l10n.empty_state_recipes_message,
                actionLabel: l10n.empty_state_recipes_action,
                onAction: () {},
                icon: Icons.restaurant_menu,
              ),
            ),
            const SizedBox(height: 24),

            // Error view example
            Text(
              'Error View Example:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 300,
              child: ErrorView(
                title: l10n.error_title,
                message: l10n.error_network,
                onRetry: () {},
              ),
            ),
            const SizedBox(height: 24),

            // Plural forms example
            Text(
              'Plural Forms:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.plurals_recipes(0)),
                Text(l10n.plurals_recipes(1)),
                Text(l10n.plurals_recipes(5)),
                const SizedBox(height: 8),
                Text(l10n.plurals_minutes(1)),
                Text(l10n.plurals_minutes(30)),
              ],
            ),
            const SizedBox(height: 24),

            // Authentication strings
            Text(
              'Authentication:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: l10n.auth_email,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(
                    labelText: l10n.auth_password,
                    border: const OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                CustomButton(
                  onPressed: () {},
                  label: l10n.auth_login,
                  fullWidth: true,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Navigation labels
            Text(
              'Navigation:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const Icon(Icons.home),
                    Text(l10n.nav_home),
                  ],
                ),
                Column(
                  children: [
                    const Icon(Icons.restaurant),
                    Text(l10n.nav_recipes),
                  ],
                ),
                Column(
                  children: [
                    const Icon(Icons.favorite),
                    Text(l10n.nav_favorites),
                  ],
                ),
                Column(
                  children: [
                    const Icon(Icons.person),
                    Text(l10n.nav_profile),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recipe details
            Text(
              'Recipe Details:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.recipe_title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.timer, size: 16),
                        const SizedBox(width: 4),
                        Text(
                            '${l10n.recipe_prep_time}: ${l10n.plurals_minutes(15)}'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.restaurant, size: 16),
                        const SizedBox(width: 4),
                        Text('${l10n.recipe_servings}: 4'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.trending_up, size: 16),
                        const SizedBox(width: 4),
                        Text(
                            '${l10n.recipe_difficulty}: ${l10n.recipe_difficulty_easy}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example of a locale switcher widget
class LocaleSwitcher extends StatelessWidget {
  const LocaleSwitcher({
    super.key,
    required this.onLocaleChanged,
  });

  final ValueChanged<Locale> onLocaleChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentLocale = Localizations.localeOf(context);

    return PopupMenuButton<Locale>(
      icon: const Icon(Icons.language),
      tooltip: l10n.settings_language,
      onSelected: onLocaleChanged,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: const Locale('en'),
          child: Row(
            children: [
              if (currentLocale.languageCode == 'en')
                const Icon(Icons.check, size: 20)
              else
                const SizedBox(width: 20),
              const SizedBox(width: 8),
              const Text('English'),
            ],
          ),
        ),
        PopupMenuItem(
          value: const Locale('es'),
          child: Row(
            children: [
              if (currentLocale.languageCode == 'es')
                const Icon(Icons.check, size: 20)
              else
                const SizedBox(width: 20),
              const SizedBox(width: 8),
              const Text('Español'),
            ],
          ),
        ),
      ],
    );
  }
}
