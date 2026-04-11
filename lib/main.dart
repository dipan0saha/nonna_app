import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nonna_app/flutter_gen/gen_l10n/app_localizations.dart';

import 'core/router/app_router.dart';
import 'core/services/app_initialization_service.dart';
import 'l10n/l10n.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize all third-party integrations
  // (Supabase, OneSignal, Firebase Analytics)
  final result = await AppInitializationService.initialize();

  if (result.hasWarnings) {
    debugPrint('⚠️  Optional services failed: ${result.warnings.join(", ")}');
  }

  if (result.success) {
    runApp(const ProviderScope(child: MyApp()));
  } else {
    runApp(InitializationErrorApp(error: result.criticalError ?? 'Unknown'));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      title: 'Nonna App',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),

      // Localization configuration
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: L10n.all,
      localeResolutionCallback: L10n.localeResolutionCallback,
    );
  }
}

/// Fallback app shown when critical initialization (Supabase) fails.
///
/// Displays a user-friendly error message with a retry button that
/// restarts the initialization flow.
class InitializationErrorApp extends StatelessWidget {
  final String error;
  const InitializationErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nonna App',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
                const SizedBox(height: 24),
                const Text(
                  'Unable to Connect',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  'Nonna could not connect to the server. '
                  'Please check your internet connection and try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => main(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
