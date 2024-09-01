import 'package:test/test.dart';

/// Represents the outcome of a job.
///
/// A job can either succeed or fail.
///
/// The [F] type represents the failure type.
/// The [S] type represents the success type.
sealed class Outcome<F, S> {
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
    if (this is Success<F, S>) {
      return onSuccess((this as Success<F, S>).value);
    } else {
      return onFailure((this as Failure<F, S>).value);
    }
  }
}

/// {@template Success}
///
/// Represents a successful outcome.
///
/// {@endtemplate}
final class Success<F, S> extends Outcome<F, S> {
  /// {@macro Success}
  Success(this.value);

  /// The success value.
  final S value;

  @override
  bool operator ==(Object other) =>
      other is Success<F, S> && other.value == value;

  @override
  int get hashCode => Object.hash(runtimeType, value);
}

/// {@template Failure}
///
/// Represents a failed outcome.
///
/// {@endtemplate}
final class Failure<F, S> extends Outcome<F, S> {
  /// {@macro Failure}
  Failure(this.value);

  /// The failure value.
  final F value;

  @override
  bool operator ==(Object other) =>
      other is Failure<F, S> && other.value == value;

  @override
  int get hashCode => Object.hash(runtimeType, value);
}

/// Creates a successful outcome.
Outcome<F, S> success<F, S>(S value) => Success<F, S>(value);

/// Creates a failed outcome.
Outcome<F, S> failure<F, S>(F value) => Failure<F, S>(value);

/// Expects the [actual] outcome to be equal to the [expected] successful
/// outcome.
void expectSuccess<F, S>(
  Outcome<F, S> actual,
  S expected, {
  String? reason,
  dynamic skip,
}) {
  return expect(actual, Success<F, S>(expected), reason: reason, skip: skip);
}

/// Expects the [actual] outcome to be equal to the [expected] failed outcome.
void expectFailure<F, S>(
  Outcome<F, S> actual,
  F expected, {
  String? reason,
  dynamic skip,
}) {
  return expect(actual, Failure<F, S>(expected), reason: reason, skip: skip);
}
