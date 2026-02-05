# Utils Test Failures

## Utils
- **share_helpers_test.dart**: Expected: not 'VWXYZ012' Actual: 'VWXYZ012'
- **image_helpers_test.dart**: Expected: null Actual: [255, 216, 255, 224, 0, 16, 74, 70, 73, 70, 0, 1, 1, 0, 0, 1, 0, 1, 0, 0, 255, 219, 0, 132, ...]
- **date_helpers_test.dart**: Expected: '3:45 PM' Actual: '3:45 PM'
- **date_helpers_test.dart**: Expected: '9:30 AM' Actual: '9:30 AM'
- **date_helpers_test.dart**: Expected: 'Jan 15, 2024 3:45 PM' Actual: 'Jan 15, 2024 3:45 PM'
- **date_helpers_test.dart**: Expected: 'in 10 minutes' Actual: 'in 9 minutes'
- **date_helpers_test.dart**: Expected: 'in 2 hours' Actual: 'in 1 hour'
- **date_helpers_test.dart**: Expected: 'in 3 days' Actual: 'in 2 days'
- **date_helpers_test.dart**: Expected: a value greater than or equal to <0> Actual: <-12>
- **date_helpers_test.dart**: Expected: a value greater than or equal to <0> Actual: <-24>
- **image_helpers_test.dart**: Expected: throws anything Actual: <Closure: () => Future<Uint8List?>> Which: returned a Future that emitted <null>

## Constants
- **spacing_test.dart**: Expected: SizedBox:<SizedBox(height: 8.0)> Actual: SizedBox:<SizedBox(height: 8.0)>
- **spacing_test.dart**: Expected: SizedBox:<SizedBox(height: 12.0)> Actual: SizedBox:<SizedBox(height: 12.0)>
- **spacing_test.dart**: Expected: SizedBox:<SizedBox(height: 16.0)> Actual: SizedBox:<SizedBox(height: 16.0)>
- **spacing_test.dart**: Expected: SizedBox:<SizedBox(height: 24.0)> Actual: SizedBox:<SizedBox(height: 24.0)>
- **spacing_test.dart**: Expected: SizedBox:<SizedBox(height: 32.0)> Actual: SizedBox:<SizedBox(height: 32.0)>
- **spacing_test.dart**: Expected: SizedBox:<SizedBox(width: 8.0)> Actual: SizedBox:<SizedBox(width: 8.0)>
- **spacing_test.dart**: Expected: SizedBox:<SizedBox(width: 12.0)> Actual: SizedBox:<SizedBox(width: 12.0)>
- **spacing_test.dart**: Expected: SizedBox:<SizedBox(width: 16.0)> Actual: SizedBox:<SizedBox(width: 16.0)>
- **spacing_test.dart**: Expected: SizedBox:<SizedBox(width: 24.0)> Actual: SizedBox:<SizedBox(width: 24.0)>
- **spacing_test.dart**: Expected: SizedBox:<SizedBox(width: 32.0)> Actual: SizedBox:<SizedBox(width: 32.0)>

## Enums
No failures.

## Extensions
- **list_extensions_test.dart**: type '(num, num) => num' is not a subtype of type '(int, int) => int' of 'combine'
- **list_extensions_test.dart**: type '(num, num) => num' is not a subtype of type '(int, int) => int' of 'combine'
- **date_extensions_test.dart**: Expected: <2> Actual: <3>
- **context_extensions_test.dart**: Expected: <true> Actual: <false>
- **context_extensions_test.dart**: Expected: 'es' Actual: 'en'

## Models
- **activity_event_test.dart**: type '_Map<dynamic, dynamic>' is not a subtype of type 'Map<String, dynamic>?' in type cast
- **tile_config_test.dart**: Expected: <619348339> Actual: <596919593>
- **notification_test.dart**: type '_Map<dynamic, dynamic>' is not a subtype of type 'Map<String, dynamic>?' in type cast

## Network
No failures.

## Services
- **realtime_service_test.dart**: Bad state: SupabaseClientManager not initialized. Call initialize() first.
- **realtime_service_test.dart**: Bad state: SupabaseClientManager not initialized. Call initialize() first.
- **realtime_service_test.dart**: Bad state: SupabaseClientManager not initialized. Call initialize() first.
- **realtime_service_test.dart**: Bad state: SupabaseClientManager not initialized. Call initialize() first.
- **realtime_service_test.dart**: Bad state: SupabaseClientManager not initialized. Call initialize() first.
- **backup_service_test.dart**: Compilation failed: The argument type 'Future<Map<String, String>> Function(Invocation)' can't be assigned to the parameter type 'PostgrestTransformBuilder<Map<String, dynamic>?> Function(Invocation)'.
- **backup_service_test.dart**: Compilation failed: The argument type 'Future<Null> Function(Invocation)' can't be assigned to the parameter type 'PostgrestTransformBuilder<Map<String, dynamic>?> Function(Invocation)'.
- **force_update_service_test.dart**: ❌ Error checking for updates: MissingPluginException(No implementation found for method getAll on channel dev.fluttercommunity.plus/package_info)
- **force_update_service_test.dart**: ❌ Error checking for updates: MissingPluginException(No implementation found for method getAll on channel dev.fluttercommunity.plus/package_info)
- **force_update_service_test.dart**: ❌ Error getting update info: MissingPluginException(No implementation found for method getAll on channel dev.fluttercommunity.plus/package_info)
