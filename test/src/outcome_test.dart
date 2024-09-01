import 'package:bobs_jobs/bobs_jobs.dart';
import 'package:test/test.dart';
import 'package:test_beautifier/test_beautifier.dart';

void main() {
  group('BobsOutcome tests', () {
    group('evaluate', () {
      test(
        requirement(
          Given: 'a successful outcome',
          When: 'the outcome is evaluated',
          Then: 'the success function is called',
        ),
        procedure(() {
          final result = bobsSuccess(1).evaluate(
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
          final result = bobsFailure('error').evaluate(
            onFailure: (error) => error,
            onSuccess: (_) => fail('Should not be called'),
          );

          expect(result, 'error');
        }),
      );
    });

    group('BobsSuccess', () {
      test(
        requirement(
          Given: 'a value',
          When: 'a success outcome is created',
          Then: 'the value is stored',
        ),
        procedure(() {
          final outcome = bobsSuccess(1);

          expect((outcome as BobsSuccess).value, 1);
        }),
      );

      test(
        requirement(
          Given: 'a success outcome',
          When: 'hashcode is called',
          Then: 'does not throw an exception',
        ),
        procedure(() {
          expect(bobsSuccess(1).hashCode, isA<int>());
        }),
      );
    });

    group('BobsFailure', () {
      test(
        requirement(
          Given: 'an error',
          When: 'a failure outcome is created',
          Then: 'the error is stored',
        ),
        procedure(() {
          final outcome = bobsFailure('error');

          expect((outcome as BobsFailure).value, 'error');
        }),
      );

      test(
        requirement(
          Given: 'a failure outcome',
          When: 'hashcode is called',
          Then: 'does not throw an exception',
        ),
        procedure(() {
          expect(bobsFailure(1).hashCode, isA<int>());
        }),
      );
    });
  });
}
