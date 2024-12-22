import 'package:bobs_jobs/bobs_jobs.dart';
import 'package:test/test.dart';
import 'package:test_beautifier/test_beautifier.dart';

void main() {
  group('BobsMaybe tests', () {
    group('resolve', () {
      test(
        requirement(
          Given: 'a present value',
          When: 'the maybe is resolved',
          Then: 'the [onPresent] function is called',
        ),
        procedure(() {
          final result = bobsPresent(1).resolve(
            onAbsent: () => fail('Should not be called'),
            onPresent: (value) => value,
          );

          expect(result, 1);
        }),
      );

      test(
        requirement(
          Given: 'an absent value',
          When: 'the maybe is resolved',
          Then: 'the [onAbsent] function is called',
        ),
        procedure(() {
          final result = BobsAbsent().resolve(
            onAbsent: () => 'bobsAbsent',
            onPresent: (_) => fail('Should not be called'),
          );

          expect(result, 'bobsAbsent');
        }),
      );
    });

    group('deriveOnBobsPresent', () {
      test(
        requirement(
          Given: 'a present value',
          When: 'the maybe is converted',
          Then: 'returns a new maybe with the new value',
        ),
        procedure(() {
          final result = bobsPresent(1).convert((value) => value + 1);

          expect(result, bobsPresent(2));
        }),
      );

      test(
        requirement(
          Given: 'an absent value',
          When: 'the maybe is converted',
          Then: 'returns an absent maybe',
        ),
        procedure(() {
          final result = BobsAbsent<int>().convert((value) => value + 1);

          expect(result, bobsAbsent());
        }),
      );
    });

    group('isPresent', () {
      test(
        requirement(
          Given: 'a present value',
          When: 'isPresent is called',
          Then: 'returns true',
        ),
        procedure(() {
          expect(bobsPresent(1).isPresent, isTrue);
        }),
      );

      test(
        requirement(
          Given: 'an absent value',
          When: 'isPresent is called',
          Then: 'returns false',
        ),
        procedure(() {
          expect(bobsAbsent().isPresent, isFalse);
        }),
      );
    });

    group('isAbsent', () {
      test(
        requirement(
          Given: 'a present value',
          When: 'isAbsent is called',
          Then: 'returns false',
        ),
        procedure(() {
          expect(bobsPresent(1).isAbsent, isFalse);
        }),
      );

      test(
        requirement(
          Given: 'an absent value',
          When: 'isAbsent is called',
          Then: 'returns true',
        ),
        procedure(() {
          expect(bobsAbsent().isAbsent, isTrue);
        }),
      );
    });

    group('bobsPresent', () {
      test(
        requirement(
          Given: 'a present value',
          When: 'a present is created',
          Then: 'returns a [BobsPresent] instance with the value',
        ),
        procedure(() {
          final p = bobsPresent(1);

          expect(p, BobsPresent(1));
          expect((p as BobsPresent).value, 1);
        }),
      );

      test(
        requirement(
          Given: 'a present value',
          When: 'hashcode is called',
          Then: 'does not fail',
        ),
        procedure(() {
          expect(bobsPresent(1).hashCode, isA<int>());
        }),
      );
    });

    group('bobsAbsent', () {
      test(
        requirement(
          When: 'an absent is created',
          Then: 'returns a [BobsAbsent] instance',
        ),
        procedure(() {
          final a = bobsAbsent<int>();

          expect(a, isA<BobsAbsent<int>>());
        }),
      );

      test(
        requirement(
          Given: 'absent with type and another absent without type',
          When: 'both are compared',
          Then: 'both are equal',
        ),
        procedure(() {
          late BobsMaybe<int> maybe;

          maybe = bobsAbsent<int>();

          expect(maybe, bobsAbsent());
        }),
      );

      test(
        requirement(
          Given: 'a present value',
          When: 'hashcode is called',
          Then: 'does not fail',
        ),
        procedure(() {
          expect(bobsAbsent().hashCode, isA<int>());
        }),
      );
    });
  });
}
