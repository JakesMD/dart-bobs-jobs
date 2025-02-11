import 'package:bobs_jobs/bobs_jobs.dart';
import 'package:test/test.dart';
import 'package:test_beautifier/test_beautifier.dart';

void main() {
  group('BobsJob tests', () {
    setUp(() {
      BigBob.onFailure = (_, __, ___) {};
    });

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

          expectBobsSuccess(result, 1);
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

          expectBobsFailure(result, 'error');
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

          expectBobsSuccess(result, 1);
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

          expectBobsFailure(result, 'error');
        }),
      );

      test(
        requirement(
          Given: 'a failing job',
          When: 'the job is run',
          Then: 'global [onFailure] callback is called',
        ),
        procedure(() async {
          BigBob.onFailure = (failure, error, stack) => expect(1, 1);

          final job = BobsJob.attempt(
            run: () => throw Exception(),
            onError: (error) => 'error',
          );

          await job.run();
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

          expectBobsSuccess(result, 2);
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

          expectBobsFailure(result, 'error1');
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

          expectBobsSuccess(result, 2);
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

          expectBobsFailure(result, 'error2');
        }),
      );

      test(
        requirement(
          Given: 'a successful job chained with a failing job',
          When: 'the job is run',
          Then: 'global [onFailure] callback is called',
        ),
        procedure(() async {
          BigBob.onFailure = (failure, error, stack) => expect(1, 1);

          final job = BobsJob.attempt(
            run: () => 1,
            onError: (error) => 'error1',
          ).thenAttempt(
            run: (value) => throw Exception(),
            onError: (error) => 'error2',
          );

          await job.run();
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

          expectBobsFailure(result, 'error1');
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

          expectBobsFailure(result, 'error1');
        }),
      );
    });

    group('thenConvert', () {
      test(
        requirement(
          Given: 'a successful job',
          When: 'the job is converted',
          Then: 'returns the second success',
        ),
        procedure(() async {
          final job =
              BobsJob.attempt(run: () => 1, onError: (error) => 'error1')
                  .thenConvert(
            onFailure: (error) => fail('Should not be called'),
            onSuccess: (value) => 2,
          );

          final result = await job.run();
          expectBobsSuccess(result, 2);
        }),
      );

      test(
        requirement(
          Given: 'a failing job',
          When: 'the job is converted',
          Then: 'returns the second failure',
        ),
        procedure(() async {
          final job = BobsJob.attempt(
            run: () => throw Exception(),
            onError: (error) => 'error1',
          ).thenConvert(
            onFailure: (error) => 'error2',
            onSuccess: (value) => fail('Should not be called'),
          );

          final result = await job.run();

          expectBobsFailure(result, 'error2');
        }),
      );
    });

    group('thenConvertSuccess', () {
      test(
        requirement(
          Given: 'a failing job',
          When: 'the job is converted',
          Then: 'returns the first failure',
        ),
        procedure(() async {
          final job = BobsJob.attempt(
            run: () => throw Exception(),
            onError: (error) => 'error1',
          ).thenConvertSuccess((success) => fail('Should not be called'));

          final result = await job.run();

          expectBobsFailure(result, 'error1');
        }),
      );

      test(
        requirement(
          Given: 'a successful job',
          When: 'the job is converted',
          Then: 'returns the second success',
        ),
        procedure(() async {
          final job = BobsJob.attempt(
            run: () => 1,
            onError: (error) => 'error1',
          ).thenConvertSuccess((success) => 2);

          final result = await job.run();

          expectBobsSuccess(result, 2);
        }),
      );
    });

    group('thenConvertFailure', () {
      test(
        requirement(
          Given: 'a successful job',
          When: 'the job is converted',
          Then: 'returns the first success',
        ),
        procedure(() async {
          final job = BobsJob.attempt(
            run: () => 1,
            onError: (error) => 'error1',
          ).thenConvertFailure((error) => fail('Should not be called'));

          final result = await job.run();

          expectBobsSuccess(result, 1);
        }),
      );

      test(
        requirement(
          Given: 'a failing job',
          When: 'the job is converted',
          Then: 'returns the second failure',
        ),
        procedure(() async {
          final job = BobsJob.attempt(
            run: () => throw Exception(),
            onError: (error) => 'error1',
          ).thenConvertFailure((error) => 'error2');

          final result = await job.run();

          expectBobsFailure(result, 'error2');
        }),
      );
    });

    group('thenValidate', () {
      test(
        requirement(
          Given: 'a successful job',
          When: 'the job is valid',
          Then: 'returns the success',
        ),
        procedure(() async {
          final job = BobsJob.attempt(
            run: () => 1,
            onError: (error) => 'error1',
          ).thenValidate(
            isValid: (value) => value == 1,
            onInvalid: (value) => fail('Should not be called'),
          );

          final result = await job.run();

          expectBobsSuccess(result, 1);
        }),
      );

      test(
        requirement(
          Given: 'a successful job',
          When: 'the job is invalid',
          Then: 'returns the second failure',
        ),
        procedure(() async {
          final job = BobsJob.attempt(
            run: () => 1,
            onError: (error) => 'error1',
          ).thenValidate(
            isValid: (value) => value != 1,
            onInvalid: (value) => 'error2',
          );

          final result = await job.run();

          expectBobsFailure(result, 'error2');
        }),
      );

      test(
        requirement(
          Given: 'a successful job',
          When: 'the job is invalid',
          Then: 'global [onFailure] callback is called',
        ),
        procedure(() async {
          BigBob.onFailure = (failure, _, __) => expect(1, 1);

          final job = BobsJob.attempt(
            run: () => 1,
            onError: (error) => 'error1',
          ).thenValidate(
            isValid: (value) => value != 1,
            onInvalid: (value) => 'error2',
          );

          await job.run();
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
            onError: (error) => -1,
          );
          final job2 = BobsJob.attempt(
            run: () => '2',
            onError: (error) => '-2',
          );

          final combinedJob = job1.chainOnSuccess<String, String>(
            nextJob: (s) => job2,
            onFailure: (f) => fail('Should not be called'),
          );

          final result = await combinedJob.run();

          expectBobsSuccess(result, '2');
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
            onError: (error) => -1,
          );
          final job2 = BobsJob.attempt(
            run: () => throw Exception(),
            onError: (error) => '-2',
          );

          final combinedJob = job1.chainOnSuccess<String, String>(
            nextJob: (s) => job2,
            onFailure: (f) => fail('Should not be called'),
          );

          final result = await combinedJob.run();

          expectBobsFailure(result, '-2');
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
            onError: (error) => -1,
          );

          final combinedJob = job1.chainOnSuccess<String, String>(
            nextJob: (s) => fail('Should not be called'),
            onFailure: (f) => f.toString(),
          );

          final result = await combinedJob.run();

          expectBobsFailure(result, '-1');
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

          expectBobsSuccess(result, 1);
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

          expectBobsFailure(result, 1);
        }),
      );
    });
  });
}
