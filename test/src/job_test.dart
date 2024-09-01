import 'package:bobs_jobs/bobs_jobs.dart';
import 'package:test/test.dart';
import 'package:test_beautifier/test_beautifier.dart';

void main() {
  group('BobsJob tests', () {
    group('run', () {
      test(
        requirement(
          Given: 'a successful job',
          When: 'the job is run',
          Then: 'returns a success',
        ),
        procedure(() async {
          final job = BobsJob(run: () => BobsSuccess(1));

          final result = await job.run();

          bobsExpectSuccess(result, 1);
        }),
      );

      test(
        requirement(
          Given: 'a failing job',
          When: 'the job is run',
          Then: 'returns a failure',
        ),
        procedure(() async {
          final job = BobsJob(run: () => BobsFailure('error'));

          final result = await job.run();

          bobsExpectFailure(result, 'error');
        }),
      );

      test(
        requirement(
          Given: 'an async job and debug mode is enabled',
          When: 'the job is run',
          Then: 'outcome is delayed',
        ),
        procedure(() async {
          final job = BobsJob(
            run: () => BobsSuccess(1),
            isAsync: true,
          );

          final startTime = DateTime.now();

          await job.run(
            delayDuration: const Duration(milliseconds: 5),
            isDebugMode: true,
          );

          final endTime = DateTime.now();

          expect(
            endTime.difference(startTime).inMilliseconds,
            greaterThan(5),
          );
        }),
      );
    });

    group('attempt', () {
      test(
        requirement(
          Given: 'a successful job',
          When: 'the job is run',
          Then: 'returns a success',
        ),
        procedure(() async {
          final job = BobsJob.attempt(
            run: () => 1,
            onError: (error) => 'error',
          );

          final result = await job.run();

          bobsExpectSuccess(result, 1);
        }),
      );

      test(
        requirement(
          Given: 'a failing job',
          When: 'the job is run',
          Then: 'returns a failure',
        ),
        procedure(() async {
          final job = BobsJob.attempt(
            run: () => throw Exception(),
            onError: (error) => 'error',
          );

          final result = await job.run();

          bobsExpectFailure(result, 'error');
        }),
      );
    });

    group('then', () {
      test(
        requirement(
          Given: 'a successful job chained with another job',
          When: 'the job is run',
          Then: 'returns second success',
        ),
        procedure(() async {
          final job = BobsJob.attempt(
            run: () => 1,
            onError: (error) => 'error1',
          ).then(run: (value) => value + 1);

          final result = await job.run();

          bobsExpectSuccess(result, 2);
        }),
      );

      test(
        requirement(
          Given: 'a failing job chained with another job',
          When: 'the job is run',
          Then: 'returns the failure',
        ),
        procedure(() async {
          final job = BobsJob.attempt(
            run: () => throw Exception(),
            onError: (error) => 'error1',
          ).then(run: (value) => value);

          final result = await job.run();

          bobsExpectFailure(result, 'error1');
        }),
      );
    });

    group('thenAttempt', () {
      test(
        requirement(
          Given: 'a successful job chained with another successful job',
          When: 'the job is run',
          Then: 'returns second success',
        ),
        procedure(() async {
          final job = BobsJob.attempt(
            run: () => 1,
            onError: (error) => 'error1',
          ).thenAttempt(
            run: (value) => value + 1,
            onError: (error) => 'error2',
          );

          final result = await job.run();

          bobsExpectSuccess(result, 2);
        }),
      );

      test(
        requirement(
          Given: 'a successful job chained with a failing job',
          When: 'the job is run',
          Then: 'returns the second failure',
        ),
        procedure(() async {
          final job = BobsJob.attempt(
            run: () => 1,
            onError: (error) => 'error1',
          ).thenAttempt(
            run: (value) => throw Exception(),
            onError: (error) => 'error2',
          );

          final result = await job.run();

          bobsExpectFailure(result, 'error2');
        }),
      );

      test(
        requirement(
          Given: 'a failing job chained with a successful job',
          When: 'the job is run',
          Then: 'returns the first failure',
        ),
        procedure(() async {
          final job = BobsJob.attempt(
            run: () => throw Exception(),
            onError: (error) => 'error1',
          ).thenAttempt(
            run: (value) => 1,
            onError: (error) => 'error2',
          );

          final result = await job.run();

          bobsExpectFailure(result, 'error1');
        }),
      );

      test(
        requirement(
          Given: 'a failing job chained with another failing job',
          When: 'the job is run',
          Then: 'returns the first failure',
        ),
        procedure(() async {
          final job = BobsJob.attempt(
            run: () => throw Exception(),
            onError: (error) => 'error1',
          ).thenAttempt(
            run: (value) => throw Exception(),
            onError: (error) => 'error2',
          );

          final result = await job.run();

          bobsExpectFailure(result, 'error1');
        }),
      );
    });

    group('thenEvaluate', () {
      test(
        requirement(
          Given: 'a successful job',
          When: 'the job is evaluated',
          Then: 'returns the second success',
        ),
        procedure(() async {
          final job =
              BobsJob.attempt(run: () => 1, onError: (error) => 'error1')
                  .thenEvaluate(
            onFailure: (error) => fail('Should not be called'),
            onSuccess: (value) => 2,
          );

          final result = await job.run();
          bobsExpectSuccess(result, 2);
        }),
      );

      test(
        requirement(
          Given: 'a failing job',
          When: 'the job is evaluated',
          Then: 'returns the second failure',
        ),
        procedure(() async {
          final job = BobsJob.attempt(
            run: () => throw Exception(),
            onError: (error) => 'error1',
          ).thenEvaluate(
            onFailure: (error) => 'error2',
            onSuccess: (value) => fail('Should not be called'),
          );

          final result = await job.run();

          bobsExpectFailure(result, 'error2');
        }),
      );
    });

    group('thenEvaluateOnFailure', () {
      test(
        requirement(
          Given: 'a successful job',
          When: 'the job is evaluated',
          Then: 'returns the first success',
        ),
        procedure(() async {
          final job = BobsJob.attempt(
            run: () => 1,
            onError: (error) => 'error1',
          ).thenEvaluateOnFailure((error) => fail('Should not be called'));

          final result = await job.run();

          bobsExpectSuccess(result, 1);
        }),
      );

      test(
        requirement(
          Given: 'a failing job',
          When: 'the job is evaluated',
          Then: 'returns the second failure',
        ),
        procedure(() async {
          final job = BobsJob.attempt(
            run: () => throw Exception(),
            onError: (error) => 'error1',
          ).thenEvaluateOnFailure((error) => 'error2');

          final result = await job.run();

          bobsExpectFailure(result, 'error2');
        }),
      );
    });

    group('bobsFakeSuccessJob', () {
      test(
        requirement(
          Given: 'a fake success job',
          When: 'the job is run',
          Then: 'returns the success',
        ),
        procedure(() async {
          final job = bobsFakeSuccessJob(1);

          final result = await job.run();

          bobsExpectSuccess(result, 1);
        }),
      );
    });

    group('bobsFakeFailureJob', () {
      test(
        requirement(
          Given: 'a fake failure job',
          When: 'the job is run',
          Then: 'returns the failure',
        ),
        procedure(() async {
          final job = bobsFakeFailureJob(1);

          final result = await job.run();

          bobsExpectFailure(result, 1);
        }),
      );
    });
  });
}
