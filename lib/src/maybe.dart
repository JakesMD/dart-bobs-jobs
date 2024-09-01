/// A maybe type represents a value that may or may not be present.
sealed class Maybe<T> {
  /// Evaluates the maybe.
  ///
  /// If the maybe is present, the [onPresent] function is called with the
  /// value.
  /// If the maybe is absent, the [onAbsent] function is called.
  T2 evaluate<T2>({
    required T2 Function(T value) onPresent,
    required T2 Function() onAbsent,
  }) {
    if (this is Present<T>) {
      return onPresent((this as Present<T>).value);
    } else {
      return onAbsent();
    }
  }

  /// Derives a new maybe from the current maybe.
  ///
  /// If the maybe is present, the value will be replaced with the result of
  /// [onPresent].
  Maybe<T2> deriveOnPresent<T2>(T2 Function(T value) onPresent) {
    if (this is Present<T>) {
      return Present(onPresent((this as Present<T>).value));
    } else {
      return absent<T2>();
    }
  }
}

/// {@template Present}
///
/// Represents a present value.
///
/// {@endtemplate}
final class Present<T> extends Maybe<T> {
  /// {@macro Present}
  Present(this.value);

  /// The value.
  final T value;

  @override
  bool operator ==(Object other) => other is Present<T> && other.value == value;

  @override
  int get hashCode => Object.hash(runtimeType, value);
}

/// {@template Absent}
///
/// Represents an absent value.
///
/// {@endtemplate}
final class Absent<T> extends Maybe<T> {
  @override
  bool operator ==(Object other) => other is Absent;

  @override
  int get hashCode => Object.hash(runtimeType, null);
}

/// Creates an instance of [Absent].
Maybe<T> absent<T>() => Absent<T>();

/// Creates an instance of [Present].
Maybe<T> present<T>(T value) => Present(value);
