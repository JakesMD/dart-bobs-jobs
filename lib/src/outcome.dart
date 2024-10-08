import 'package:test/test.dart';

/// Represents the outcome of a job.
///
/// A job can either succeed or fail.
///
/// The [F] type represents the failure type.
/// The [S] type represents the success type.
sealed class BobsOutcome<F, S> {
  /// Evaluates the outcome of the job.
  ///
  /// If the job failed, the [onFailure] function is called with the failure
  /// value.
  /// If the job succeeded, the [onSuccess] function is called with the success
  /// value.
  T evaluate<T>({
    required T Function(F failure) onFailure,
    required T Function(S success) onSuccess,
  }) {
    if (this is BobsSuccess<F, S>) {
      return onSuccess((this as BobsSuccess<F, S>).value);
    } else {
      return onFailure((this as BobsFailure<F, S>).value);
    }
  }
}

/// {@template BobsSuccess}
///
/// Represents a successful outcome.
///
/// {@endtemplate}
final class BobsSuccess<F, S> extends BobsOutcome<F, S> {
  /// {@macro BobsSuccess}
  BobsSuccess(this.value);

  /// The success value.
  final S value;

  @override
  bool operator ==(Object other) =>
      other is BobsSuccess<F, S> && other.value == value;

  @override
  int get hashCode => Object.hash(runtimeType, value);
}

/// {@template BobsFailure}
///
/// Represents a failed outcome.
///
/// {@endtemplate}
final class BobsFailure<F, S> extends BobsOutcome<F, S> {
  /// {@macro BobsFailure}
  BobsFailure(this.value);

  /// The failure value.
  final F value;

  @override
  bool operator ==(Object other) =>
      other is BobsFailure<F, S> && other.value == value;

  @override
  int get hashCode => Object.hash(runtimeType, value);
}

/// Creates a successful outcome.
BobsOutcome<F, S> bobsSuccess<F, S>(S value) => BobsSuccess<F, S>(value);

/// Creates a failed outcome.
BobsOutcome<F, S> bobsFailure<F, S>(F value) => BobsFailure<F, S>(value);

/// Expects the [actual] outcome to be equal to the [expected] successful
/// outcome.
void bobsExpectSuccess<F, S>(
  BobsOutcome<F, S> actual,
  S expected, {
  String? reason,
  dynamic skip,
}) {
  return expect(
    actual,
    BobsSuccess<F, S>(expected),
    reason: reason,
    skip: skip,
  );
}

/// Expects the [actual] outcome to be equal to the [expected] failed outcome.
void bobsExpectFailure<F, S>(
  BobsOutcome<F, S> actual,
  F expected, {
  String? reason,
  dynamic skip,
}) {
  return expect(
    actual,
    BobsFailure<F, S>(expected),
    reason: reason,
    skip: skip,
  );
}
