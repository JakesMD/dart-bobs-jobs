import 'package:jobs/jobs.dart';
import 'package:test/test.dart';
import 'package:test_beautifier/test_beautifier.dart';

void main() {
  group('Outcome tests', () {
    group('evaluate', () {
      test(
        requirement(
          Given: 'a successful outcome',
          When: 'the outcome is evaluated',
          Then: 'the success function is called',
        ),
        procedure(() {
          final result = success(1).evaluate(
            onFailure: (_) => fail('Should not be called'),
            onSuccess: (value) => value,
          );

          expect(result, 1);
        }),
      );

      test(
        requirement(
          Given: 'a failed outcome',
          When: 'the outcome is evaluated',
          Then: 'the failure function is called',
        ),
        procedure(() {
          final result = failure('error').evaluate(
            onFailure: (error) => error,
            onSuccess: (_) => fail('Should not be called'),
          );

          expect(result, 'error');
        }),
      );
    });

    group('Success', () {
      test(
        requirement(
          Given: 'a value',
          When: 'a success outcome is created',
          Then: 'the value is stored',
        ),
        procedure(() {
          final outcome = success(1);

          expect((outcome as Success).value, 1);
        }),
      );

      test(
        requirement(
          Given: 'a success outcome',
          When: 'hashcode is called',
          Then: 'does not throw an exception',
        ),
        procedure(() {
          expect(success(1).hashCode, isA<int>());
        }),
      );
    });

    group('Failure', () {
      test(
        requirement(
          Given: 'an error',
          When: 'a failure outcome is created',
          Then: 'the error is stored',
        ),
        procedure(() {
          final outcome = failure('error');

          expect((outcome as Failure).value, 'error');
        }),
      );

      test(
        requirement(
          Given: 'a failure outcome',
          When: 'hashcode is called',
          Then: 'does not throw an exception',
        ),
        procedure(() {
          expect(failure(1).hashCode, isA<int>());
        }),
      );
    });
  });
}
