/// A maybe type represents a value that may or may not be present.
sealed class BobsMaybe<T> {
  /// Evaluates the maybe.
  ///
  /// If the maybe is present, the [onPresent] function is called with the
  /// value.
  /// If the maybe is absent, the [onAbsent] function is called.
  T2 evaluate<T2>({
    required T2 Function(T value) onPresent,
    required T2 Function() onAbsent,
  }) {
    if (this is BobsPresent<T>) {
      return onPresent((this as BobsPresent<T>).value);
    } else {
      return onAbsent();
    }
  }

  /// Derives a new maybe from the current maybe.
  ///
  /// If the maybe is present, the value will be replaced with the result of
  /// [onPresent].
  BobsMaybe<T2> deriveOnBobsPresent<T2>(T2 Function(T value) onPresent) {
    if (this is BobsPresent<T>) {
      return BobsPresent(onPresent((this as BobsPresent<T>).value));
    } else {
      return bobsAbsent<T2>();
    }
  }
}

/// {@template BobsPresent}
///
/// Represents a present value.
///
/// {@endtemplate}
final class BobsPresent<T> extends BobsMaybe<T> {
  /// {@macro BobsPresent}
  BobsPresent(this.value);

  /// The value.
  final T value;

  @override
  bool operator ==(Object other) =>
      other is BobsPresent<T> && other.value == value;

  @override
  int get hashCode => Object.hash(runtimeType, value);
}

/// {@template BobsAbsent}
///
/// Represents an absent value.
///
/// {@endtemplate}
final class BobsAbsent<T> extends BobsMaybe<T> {
  @override
  bool operator ==(Object other) => other is BobsAbsent;

  @override
  int get hashCode => Object.hash(runtimeType, null);
}

/// Creates an instance of [BobsAbsent].
BobsMaybe<T> bobsAbsent<T>() => BobsAbsent<T>();

/// Creates an instance of [BobsPresent].
BobsMaybe<T> bobsPresent<T>(T value) => BobsPresent(value);
