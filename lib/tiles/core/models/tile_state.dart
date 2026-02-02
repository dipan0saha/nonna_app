/// Generic tile state wrapper for managing loading, error, and data states
///
/// Provides a common state pattern for all tiles in the application.
/// Supports generic data types for flexibility.
class TileState<T> {
  /// The current data (null if loading or error)
  final T? data;

  /// Error message if state is error
  final String? error;

  /// Error details for debugging
  final dynamic errorDetails;

  /// Whether the tile is currently loading
  final bool isLoading;

  /// Whether the tile has an error
  final bool hasError;

  /// Whether the tile has data
  final bool hasData;

  /// Whether the tile is empty (has data but data is empty)
  final bool isEmpty;

  /// Creates a loading state
  const TileState.loading()
      : data = null,
        error = null,
        errorDetails = null,
        isLoading = true,
        hasError = false,
        hasData = false,
        isEmpty = false;

  /// Creates an error state
  const TileState.error(this.error, [this.errorDetails])
      : data = null,
        isLoading = false,
        hasError = true,
        hasData = false,
        isEmpty = false;

  /// Creates a data state
  const TileState.data(this.data)
      : error = null,
        errorDetails = null,
        isLoading = false,
        hasError = false,
        hasData = true,
        isEmpty = false;

  /// Creates an empty state
  const TileState.empty()
      : data = null,
        error = null,
        errorDetails = null,
        isLoading = false,
        hasError = false,
        hasData = false,
        isEmpty = true;

  /// Pattern matching helper for handling different states
  R when<R>({
    required R Function() loading,
    required R Function(String error, dynamic errorDetails) error,
    required R Function(T data) data,
    required R Function() empty,
  }) {
    if (isLoading) {
      return loading();
    } else if (hasError) {
      return error(this.error!, errorDetails);
    } else if (isEmpty) {
      return empty();
    } else {
      return data(this.data as T);
    }
  }

  /// Optional pattern matching (returns null if state doesn't match)
  R? maybeWhen<R>({
    R Function()? loading,
    R Function(String error, dynamic errorDetails)? error,
    R Function(T data)? data,
    R Function()? empty,
    required R Function() orElse,
  }) {
    if (isLoading && loading != null) {
      return loading();
    } else if (hasError && error != null) {
      return error(this.error!, errorDetails);
    } else if (isEmpty && empty != null) {
      return empty();
    } else if (hasData && data != null) {
      return data(this.data as T);
    }
    return orElse();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TileState<T> &&
        other.data == data &&
        other.error == error &&
        other.isLoading == isLoading &&
        other.hasError == hasError &&
        other.hasData == hasData &&
        other.isEmpty == isEmpty;
  }

  @override
  int get hashCode {
    return data.hashCode ^
        error.hashCode ^
        isLoading.hashCode ^
        hasError.hashCode ^
        hasData.hashCode ^
        isEmpty.hashCode;
  }

  @override
  String toString() {
    if (isLoading) return 'TileState.loading()';
    if (hasError) return 'TileState.error($error)';
    if (isEmpty) return 'TileState.empty()';
    return 'TileState.data($data)';
  }
}
