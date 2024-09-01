import 'package:jobs/jobs.dart';
import 'package:test/test.dart';
import 'package:test_beautifier/test_beautifier.dart';

void main() {
  group('Maybe tests', () {
    group('evaluate', () {
      test(
        requirement(
          Given: 'a present value',
          When: 'the maybe is evaluated',
          Then: 'the [onPresent] function is called',
        ),
        procedure(() {
          final result = present(1).evaluate(
            onAbsent: () => fail('Should not be called'),
            onPresent: (value) => value,
          );

          expect(result, 1);
        }),
      );

      test(
        requirement(
          Given: 'a absent value',
          When: 'the maybe is evaluated',
          Then: 'the [onAbsent] function is called',
        ),
        procedure(() {
          final result = Absent().evaluate(
            onAbsent: () => 'absent',
            onPresent: (_) => fail('Should not be called'),
          );

          expect(result, 'absent');
        }),
      );
    });

    group('deriveOnPresent', () {
      test(
        requirement(
          Given: 'a present value',
          When: 'the maybe is derived',
          Then: 'returns a new maybe with the new value',
        ),
        procedure(() {
          final result = present(1).deriveOnPresent((value) => value + 1);

          expect(result, present(2));
        }),
      );

      test(
        requirement(
          Given: 'a absent value',
          When: 'the maybe is derived',
          Then: 'returns an absent maybe',
        ),
        procedure(() {
          final result = Absent<int>().deriveOnPresent((value) => value + 1);

          expect(result, absent());
        }),
      );
    });

    group('present', () {
      test(
        requirement(
          Given: 'a present value',
          When: 'a present is created',
          Then: 'returns a [Present] instance with the value',
        ),
        procedure(() {
          final p = present(1);

          expect(p, Present(1));
          expect((p as Present).value, 1);
        }),
      );

      test(
        requirement(
          Given: 'a present value',
          When: 'hashcode is called',
          Then: 'does not fail',
        ),
        procedure(() {
          expect(present(1).hashCode, isA<int>());
        }),
      );
    });

    group('absent', () {
      test(
        requirement(
          When: 'an absent is created',
          Then: 'returns a [Absent] instance',
        ),
        procedure(() {
          final a = absent<int>();

          expect(a, isA<Absent<int>>());
        }),
      );

      test(
        requirement(
          Given: 'absent with type and another absent without type',
          When: 'both are compared',
          Then: 'both are equal',
        ),
        procedure(() {
          late Maybe<int> maybe;

          maybe = absent<int>();

          expect(maybe, absent());
        }),
      );

      test(
        requirement(
          Given: 'a present value',
          When: 'hashcode is called',
          Then: 'does not fail',
        ),
        procedure(() {
          expect(absent().hashCode, isA<int>());
        }),
      );
    });
  });
}
