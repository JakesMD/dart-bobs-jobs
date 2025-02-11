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
  const BobsJob({required FutureOr<BobsOutcome<F, S>> Function() run})
      : _job = run;

  /// Creates a new job that attempts to run the given function.
  ///
  /// `Run`: The function to run.
  ///
  /// `onError`: The function called with the error if `run` throws an
  /// error.
  factory BobsJob.attempt({
    required FutureOr<S> Function() run,
    required F Function(Object error) onError,
  }) =>
      BobsJob<F, S>(
        run: () async {
          try {
            return BobsSuccess<F, S>(await run());
          } catch (error, stack) {
            final failure = onError(error);
            BigBob.onFailure(failure, error, stack);
            return BobsFailure<F, S>(failure);
          }
        },
      );

  final FutureOr<BobsOutcome<F, S>> Function()? _job;

  /// Runs another function if the first job succeeds.
  ///
  /// `run`: The function to run with the successful outcome of
  /// the first job.
  BobsJob<F, S2> then<S2>({required FutureOr<S2> Function(S) run}) => BobsJob(
        run: () async {
          final result = await this.run();
          return result.resolve(
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
  BobsJob<F, S2> thenAttempt<S2>({
    required FutureOr<S2> Function(S) run,
    required F Function(Object error) onError,
  }) =>
      BobsJob(
        run: () async {
          final result = await this.run();
          return result.resolve(
            onFailure: BobsFailure<F, S2>.new,
            onSuccess: (success) => BobsJob.attempt(
              run: () => run(success),
              onError: onError,
            ).run(),
          );
        },
      );

  /// Converts the outcome of the job to a new outcome.
  ///
  /// `onFailure`: The function to convert the failure value.
  ///
  /// `onSuccess`: The function to convert the success value.
  BobsJob<F2, S2> thenConvert<F2, S2>({
    required F2 Function(F failure) onFailure,
    required S2 Function(S success) onSuccess,
  }) =>
      BobsJob(
        run: () async {
          final result = await this.run();
          return result.resolve(
            onFailure: (failure) => BobsFailure<F2, S2>(onFailure(failure)),
            onSuccess: (success) => BobsSuccess<F2, S2>(onSuccess(success)),
          );
        },
      );

  /// Converts the success outcome of the job to a new success outcome.
  BobsJob<F, S2> thenConvertSuccess<S2>(S2 Function(S success) onSuccess) =>
      BobsJob(
        run: () async {
          final result = await this.run();
          return result.resolve(
            onFailure: BobsFailure<F, S2>.new,
            onSuccess: (success) => BobsSuccess<F, S2>(onSuccess(success)),
          );
        },
      );

  /// Converts the failure outcome of the job to a new failure outcome.
  BobsJob<F2, S> thenConvertFailure<F2>(F2 Function(F failure) onFailure) =>
      BobsJob(
        run: () async {
          final result = await this.run();
          return result.resolve(
            onFailure: (failure) => BobsFailure<F2, S>(onFailure(failure)),
            onSuccess: BobsSuccess<F2, S>.new,
          );
        },
      );

  /// Validates the success outcome of the job.
  ///
  /// This enables you to return a failure outcome from a success outcome.
  ///
  /// `isValid`: The function to determine if the success outcome is valid.
  ///
  /// `onInvalid`: The failure value to return if the success outcome is
  ///              invalid.
  BobsJob<F, S> thenValidate({
    required bool Function(S success) isValid,
    required F Function(S success) onInvalid,
  }) =>
      BobsJob(
        run: () async {
          final result = await this.run();
          return result.resolve(
            onFailure: BobsFailure<F, S>.new,
            onSuccess: (success) {
              if (isValid(success)) return BobsSuccess<F, S>(success);

              final failure = onInvalid(success);
              BigBob.onFailure(failure, null, null);
              return BobsFailure<F, S>(failure);
            },
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
      BobsJob(
        run: () async {
          final result1 = await this.run();

          if (result1.failed) {
            return BobsFailure<F2, S2>(onFailure(result1.asFailure));
          }

          return await nextJob(result1.asSuccess).run();
        },
      );

  /// Runs the job.
  FutureOr<BobsOutcome<F, S>> run() => _job!.call();
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
