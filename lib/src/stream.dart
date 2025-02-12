import 'dart:async';

import 'package:bobs_jobs/bobs_jobs.dart';

class BobsStream<F, S> {
  const BobsStream({required this.stream});

  final Stream<BobsOutcome<F, S>> Function() stream;

  factory BobsStream.attempt({
    required Stream<S> stream,
    required F Function(Object error) onError,
  }) =>
      BobsStream<F, S>(
        stream: () async* {
          try {
            await for (final data in stream) {
              yield bobsSuccess(data);
            }
          } catch (error, stack) {
            final failure = onError(error);
            BigBob.onFailure(failure, error, stack);
            yield bobsFailure(failure);
          }
        },
      );

  BobsStream<F, S2> then<S2>({required FutureOr<S2> Function(S) run}) =>
      BobsStream(
        stream: () async* {
          await for (final result in stream()) {
            if (result.failed) {
              yield bobsFailure(result.asFailure);
            } else {
              yield BobsSuccess(await run(result.asSuccess));
            }
          }
        },
      );

  BobsStream<F, S2> thenAttempt<S2>({
    required FutureOr<S2> Function(S) run,
    required F Function(Object error) onError,
  }) =>
      BobsStream(
        stream: () async* {
          await for (final result in stream()) {
            if (result.failed) {
              yield bobsFailure(result.asFailure);
            } else {
              try {
                yield BobsSuccess(await run(result.asSuccess));
              } catch (error, stack) {
                final failure = onError(error);
                BigBob.onFailure(failure, error, stack);
                yield bobsFailure(failure);
              }
            }
          }
        },
      );

  BobsStream<F2, S2> thenConvert<F2, S2>({
    required F2 Function(F failure) onFailure,
    required S2 Function(S success) onSuccess,
  }) =>
      BobsStream(
        stream: () async* {
          await for (final result in stream()) {
            yield result.resolve(
              onFailure: (failure) => bobsFailure(onFailure(failure)),
              onSuccess: (success) => bobsSuccess(onSuccess(success)),
            );
          }
        },
      );

  BobsStream<F, S2> thenConvertSuccess<S2>(S2 Function(S success) onSuccess) =>
      BobsStream(
        stream: () async* {
          await for (final result in stream()) {
            yield result.resolve(
              onFailure: bobsFailure,
              onSuccess: (success) => bobsSuccess(onSuccess(success)),
            );
          }
        },
      );

  BobsStream<F2, S> thenConvertFailure<F2>(F2 Function(F failure) onFailure) =>
      BobsStream(
        stream: () async* {
          await for (final result in stream()) {
            yield result.resolve(
              onFailure: (failure) => bobsFailure(onFailure(failure)),
              onSuccess: bobsSuccess,
            );
          }
        },
      );

  BobsStream<F, S> thenValidate({
    required bool Function(S success) isValid,
    required F Function(S success) onInvalid,
  }) =>
      BobsStream(
        stream: () async* {
          await for (final result in stream()) {
            if (result.failed) {
              yield bobsFailure(result.asFailure);
            } else {
              final success = result.asSuccess;
              if (isValid(success)) {
                yield bobsSuccess(success);
              } else {
                final failure = onInvalid(success);
                BigBob.onFailure(failure, null, null);
                yield BobsFailure<F, S>(failure);
              }
            }
          }
        },
      );
}
