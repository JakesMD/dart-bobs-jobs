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
            onError: (error, s) => 'error',
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
            onError: (error, s) => 'error',
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
            onError: (error, s) => 'error1',
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
            onError: (error, s) => 'error1',
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
            onError: (error, s) => 'error1',
          ).thenAttempt(
            run: (value) => value + 1,
            onError: (error, stack) => 'error2',
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
            onError: (error, s) => 'error1',
          ).thenAttempt(
            run: (value) => throw Exception(),
            onError: (error, stack) => 'error2',
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
            onError: (error, s) => 'error1',
          ).thenAttempt(
            run: (value) => 1,
            onError: (error, stack) => 'error2',
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
            onError: (error, s) => 'error1',
          ).thenAttempt(
            run: (value) => throw Exception(),
            onError: (error, stack) => 'error2',
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
              BobsJob.attempt(run: () => 1, onError: (error, s) => 'error1')
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
            onError: (error, s) => 'error1',
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
            onError: (error, s) => 'error1',
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
            onError: (error, s) => 'error1',
          ).thenEvaluateOnFailure((error) => 'error2');

          final result = await job.run();

          bobsExpectFailure(result, 'error2');
        }),
      );
    });

    group('chainOnSuccess', () {
      test(
        requirement(
          Given: 'a successful job',
          When: 'the job is chained with another successful job',
          Then: 'returns the second success',
        ),
        procedure(() async {
          final job1 = BobsJob.attempt(
            run: () => 1,
            onError: (error, s) => -1,
          );
          final job2 = BobsJob.attempt(
            run: () => '2',
            onError: (error, s) => '-2',
          );

          final combinedJob = job1.chainOnSuccess<String, String>(
            nextJob: (s) => job2,
            onFailure: (f) => fail('Should not be called'),
          );

          final result = await combinedJob.run();

          bobsExpectSuccess(result, '2');
        }),
      );
      test(
        requirement(
          Given: 'a successful job',
          When: 'the job is chained with a failing job',
          Then: 'returns the second failure',
        ),
        procedure(() async {
          final job1 = BobsJob.attempt(
            run: () => 1,
            onError: (error, s) => -1,
          );
          final job2 = BobsJob.attempt(
            run: () => throw Exception(),
            onError: (error, s) => '-2',
          );

          final combinedJob = job1.chainOnSuccess<String, String>(
            nextJob: (s) => job2,
            onFailure: (f) => fail('Should not be called'),
          );

          final result = await combinedJob.run();

          bobsExpectFailure(result, '-2');
        }),
      );

      test(
        requirement(
          Given: 'a failing job',
          When: 'the job is chained with another job',
          Then: 'returns the [onFailure] result',
        ),
        procedure(() async {
          final job1 = BobsJob.attempt(
            run: () => throw Exception(),
            onError: (error, s) => -1,
          );

          final combinedJob = job1.chainOnSuccess<String, String>(
            nextJob: (s) => fail('Should not be called'),
            onFailure: (f) => f.toString(),
          );

          final result = await combinedJob.run();

          bobsExpectFailure(result, '-1');
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
