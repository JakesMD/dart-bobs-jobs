import 'package:bobs_jobs/bobs_jobs.dart';
import 'package:test/test.dart';
import 'package:test_beautifier/test_beautifier.dart';

void main() {
  group('BobsNothing tests', () {
    group('bobsNothing', () {
      test(
        requirement(
          When: 'bobsNothing is called',
          Then: 'returns an instance of BobsNothing',
        ),
        procedure(() {
          expect(bobsNothing, isA<BobsNothing>());
        }),
      );
    });
  });
}
