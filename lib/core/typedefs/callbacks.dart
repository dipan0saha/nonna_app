/// Common callback type definitions for the Nonna app
///
/// Provides type-safe callback definitions for common use cases.

/// Callback with no parameters and no return value
typedef VoidCallback = void Function();

/// Callback with a single parameter and no return value
typedef ValueCallback<T> = void Function(T value);

/// Callback with two parameters and no return value
typedef TwoValueCallback<T1, T2> = void Function(T1 value1, T2 value2);

/// Callback with three parameters and no return value
typedef ThreeValueCallback<T1, T2, T3> = void Function(
    T1 value1, T2 value2, T3 value3);

/// Callback that returns a boolean
typedef BoolCallback = bool Function();

/// Callback with a parameter that returns a boolean
typedef BoolValueCallback<T> = bool Function(T value);

/// Callback that returns a value
typedef ValueGetter<T> = T Function();

/// Callback with a parameter that returns a value
typedef ValueTransformer<T, R> = R Function(T value);

/// Async callback with no parameters
typedef AsyncCallback = Future<void> Function();

/// Async callback with a single parameter
typedef AsyncValueCallback<T> = Future<void> Function(T value);

/// Async callback that returns a value
typedef AsyncValueGetter<T> = Future<T> Function();

/// Async callback with a parameter that returns a value
typedef AsyncValueTransformer<T, R> = Future<R> Function(T value);

/// Error callback
typedef ErrorCallback = void Function(Object error, StackTrace? stackTrace);

/// Success callback
typedef SuccessCallback = void Function();

/// Confirmation callback
typedef ConfirmCallback = Future<bool> Function();
