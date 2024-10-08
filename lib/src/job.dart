// ignore_for_file: avoid_positional_boolean_parameters

import 'dart:async';

import 'package:bobs_jobs/bobs_jobs.dart';

/// {@template BobsJob}
///
/// Represents a job that can either succeed or fail.
/// A job is a function that returns a [BobsOutcome].
///
/// `F`: The type of the failure value.
///
/// `S`: The type of the success value.
///
/// {@endtemplate}
class BobsJob<F, S> {
  /// {@macro BobsJob}
  const BobsJob({
    required FutureOr<BobsOutcome<F, S>> Function() run,
    this.isAsync = false,
    this.delayDuration = const Duration(milliseconds: 500),
  })  : _job = run,
        _debugJob = null;

  const BobsJob._({
    required FutureOr<BobsOutcome<F, S>> Function(bool isDebugMode) run,
    this.isAsync = false,
    this.delayDuration = const Duration(milliseconds: 500),
  })  : _debugJob = run,
        _job = null;

  /// Creates a new job that attempts to run the given function.
  ///
  /// `Run`: The function to run.
  ///
  /// `onError`: The function called with the error if `run` throws an
  /// error.
  ///
  /// `isAsync`:
  /// {@macro bobs_jobs.BobsJob.isAsync}
  factory BobsJob.attempt({
    required FutureOr<S> Function() run,
    required F Function(Object error, StackTrace stack) onError,
    bool isAsync = true,
    Duration delayDuration = const Duration(milliseconds: 500),
  }) =>
      BobsJob<F, S>(
        isAsync: isAsync,
        delayDuration: delayDuration,
        run: () async {
          try {
            return BobsSuccess<F, S>(await run());
          } catch (error, stack) {
            return BobsFailure<F, S>(onError(error, stack));
          }
        },
      );

  /// {@template bobs_jobs.BobsJob.isAsync}
  ///
  /// Whether the job is asynchronous. If true and `isDebugMode` is true, the
  /// job will be delayed by`delayDuration`.
  ///
  /// {@endtemplate}
  final bool isAsync;

  /// The duration to delay the job if `isDebugMode` is true.
  final Duration delayDuration;

  final FutureOr<BobsOutcome<F, S>> Function()? _job;

  final FutureOr<BobsOutcome<F, S>> Function(bool isDebugMode)? _debugJob;

  /// Runs another function if the first job succeeds.
  ///
  /// `run`: The function to run with the successful outcome of
  /// the first job.
  ///
  /// `isAsync`:
  /// {@macro bobs_jobs.BobsJob.isAsync}
  BobsJob<F, S2> then<S2>({
    required FutureOr<S2> Function(S) run,
    bool isAsync = false,
    Duration delayDuration = const Duration(milliseconds: 500),
  }) =>
      BobsJob._(
        isAsync: isAsync,
        delayDuration: delayDuration,
        run: (debug) async {
          final result = await this.run(isDebugMode: debug);
          return result.evaluate(
            onFailure: BobsFailure<F, S2>.new,
            onSuccess: (success) async => BobsSuccess(await run(success)),
          );
        },
      );

  /// Runs another function if the first job succeeds.
  ///
  /// `run`: The function to run with the successful outcome of
  /// the first job.
  ///
  /// `onError`: The function called with the error if `run` throws an
  /// error.
  ///
  /// `isAsync`:
  /// {@macro bobs_jobs.BobsJob.isAsync}
  BobsJob<F, S2> thenAttempt<S2>({
    required FutureOr<S2> Function(S) run,
    required F Function(Object error, StackTrace stack) onError,
    bool isAsync = true,
    Duration delayDuration = const Duration(milliseconds: 500),
  }) =>
      BobsJob._(
        isAsync: isAsync,
        delayDuration: delayDuration,
        run: (debug) async {
          final result = await this.run(isDebugMode: debug);
          return result.evaluate(
            onFailure: BobsFailure<F, S2>.new,
            onSuccess: (success) => BobsJob.attempt(
              run: () => run(success),
              onError: onError,
            ).run(),
          );
        },
      );

  /// Evaluates the outcome of the job.
  BobsJob<F2, S2> thenEvaluate<F2, S2>({
    required F2 Function(F error) onFailure,
    required S2 Function(S success) onSuccess,
  }) =>
      BobsJob._(
        run: (debug) async {
          final result = await this.run(isDebugMode: debug);
          return result.evaluate(
            onFailure: (failure) => BobsFailure<F2, S2>(onFailure(failure)),
            onSuccess: (success) => BobsSuccess<F2, S2>(onSuccess(success)),
          );
        },
      );

  /// Evaluates the outcome of the job but only in the case of a failure.
  BobsJob<F2, S> thenEvaluateOnFailure<F2>(F2 Function(F error) onFailure) =>
      BobsJob._(
        run: (debug) async {
          final result = await this.run(isDebugMode: debug);
          return result.evaluate(
            onFailure: (failure) => BobsFailure<F2, S>(onFailure(failure)),
            onSuccess: BobsSuccess<F2, S>.new,
          );
        },
      );

  /// Chains a job instance with another job instance if the first job succeeds.
  ///
  /// `onFailure`: Called when the first job fails. Its casts the failure value
  /// of the first job to the new failure type.
  ///
  /// `nextJob`: The job to run with the success outcome of the first job.
  BobsJob<F2, S2> chainOnSuccess<F2, S2>({
    required F2 Function(F failure) onFailure,
    required BobsJob<F2, S2> Function(S success) nextJob,
  }) =>
      BobsJob._(
        run: (debug) async {
          final result1 = await this.run(isDebugMode: debug);

          if (result1 is BobsFailure<F, S>) {
            return BobsFailure<F2, S2>(onFailure(result1.value));
          }

          return await nextJob((result1 as BobsSuccess<F, S>).value)
              .run(isDebugMode: debug);
        },
      );

  /// Runs the job.
  ///
  /// If `isDebugMode` is true, the job will be delayed by `delayDuration` to
  /// simulate a real-world scenario.
  FutureOr<BobsOutcome<F, S>> run({bool isDebugMode = false}) {
    if (isAsync && isDebugMode) {
      return Future.delayed(delayDuration).then(
        (_) => _debugJob?.call(true) ?? _job!.call(),
      );
    }
    return _debugJob?.call(false) ?? _job!.call();
  }
}

/// Creates a fake job that always succeeds with the given value.
///
/// This is used for testing.
BobsJob<F, S> bobsFakeSuccessJob<F, S>(S value) => BobsJob<F, S>(
      run: () async => BobsSuccess<F, S>(value),
    );

/// Creates a fake job that always fails with the given value.
///
/// This is used for testing.
BobsJob<F, S> bobsFakeFailureJob<F, S>(F value) => BobsJob<F, S>(
      run: () async => BobsFailure<F, S>(value),
    );
