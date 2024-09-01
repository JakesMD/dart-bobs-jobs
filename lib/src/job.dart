import 'dart:async';

import 'package:jobs/jobs.dart';

/// {@template Job}
///
/// Represents a job that can either succeed or fail.
/// A job is a function that returns a [Outcome].
///
/// `F`: The type of the failure value.
///
/// `S`: The type of the success value.
///
/// {@endtemplate}
class Job<F, S> {
  /// {@macro Job}
  const Job({
    required FutureOr<Outcome<F, S>> Function() run,
    this.isAsync = false,
  }) : _job = run;

  /// Creates a new job that attempts to run the given function.
  ///
  /// `Run`: The function to run.
  ///
  /// `onError`: The function called with the error if `run` throws an
  /// error.
  ///
  /// `isAsync`:
  /// {@macro jobs.Job.isAsync}
  factory Job.attempt({
    required FutureOr<S> Function() run,
    required F Function(Object error) onError,
    bool isAsync = true,
  }) =>
      Job<F, S>(
        isAsync: isAsync,
        run: () async {
          try {
            return Success<F, S>(await run());
          } catch (error) {
            return Failure<F, S>(onError(error));
          }
        },
      );

  /// {@template jobs.Job.isAsync}
  ///
  /// Whether the job is asynchronous. If true and `isDebugMode` is true, the
  /// job will be delayed by`delayDuration`.
  ///
  /// {@endtemplate}
  final bool isAsync;

  final FutureOr<Outcome<F, S>> Function() _job;

  /// Chains a job with another job if the first job succeeds.
  ///
  /// `run`: The function to run with the successful outcome of
  /// the first job.
  ///
  /// `isAsync`:
  /// {@macro jobs.Job.isAsync}
  Job<F, S2> then<S2>({
    required FutureOr<S2> Function(S) run,
    bool isAsync = false,
  }) =>
      Job(
        isAsync: isAsync,
        run: () async {
          final result = await this.run();
          return result.evaluate(
            onFailure: Failure<F, S2>.new,
            onSuccess: (success) async => Success(await run(success)),
          );
        },
      );

  /// Chains the job with another job if the first job succeeds.
  ///
  /// `run`: The function to run with the successful outcome of
  /// the first job.
  ///
  /// `onError`: The function called with the error if `run` throws an
  /// error.
  ///
  /// `isAsync`:
  /// {@macro jobs.Job.isAsync}
  Job<F, S2> thenAttempt<S2>({
    required FutureOr<S2> Function(S) run,
    required F Function(Object error) onError,
    bool isAsync = true,
  }) =>
      Job(
        isAsync: isAsync,
        run: () async {
          final result = await this.run();
          return result.evaluate(
            onFailure: Failure<F, S2>.new,
            onSuccess: (success) => Job.attempt(
              run: () => run(success),
              onError: onError,
            ).run(),
          );
        },
      );

  /// Evaluates the outcome of the job.
  Job<F2, S2> thenEvaluate<F2, S2>({
    required F2 Function(F error) onFailure,
    required S2 Function(S success) onSuccess,
  }) =>
      Job(
        run: () async {
          final result = await this.run();
          return result.evaluate(
            onFailure: (failure) => Failure<F2, S2>(onFailure(failure)),
            onSuccess: (success) => Success<F2, S2>(onSuccess(success)),
          );
        },
      );

  /// Evaluates the outcome of the job but only in the case of a failure.
  Job<F2, S> thenEvaluateOnFailure<F2>(F2 Function(F error) onFailure) => Job(
        run: () async {
          final result = await this.run();
          return result.evaluate(
            onFailure: (failure) => Failure<F2, S>(onFailure(failure)),
            onSuccess: Success<F2, S>.new,
          );
        },
      );

  /// Runs the job.
  ///
  /// If `isDebugMode` is true, the job will be delayed by `delayDuration` to
  /// simulate a real-world scenario.
  FutureOr<Outcome<F, S>> run({
    bool isDebugMode = false,
    Duration delayDuration = const Duration(milliseconds: 500),
  }) {
    if (isAsync && isDebugMode) {
      return Future.delayed(delayDuration).then((_) => _job.call());
    }
    return _job.call();
  }
}

/// Creates a fake job that always succeeds with the given value.
///
/// This is used for testing.
Job<F, S> fakeSuccessJob<F, S>(S value) => Job<F, S>(
      run: () async => Success<F, S>(value),
    );

/// Creates a fake job that always fails with the given value.
///
/// This is used for testing.
Job<F, S> fakeFailureJob<F, S>(F value) => Job<F, S>(
      run: () async => Failure<F, S>(value),
    );
