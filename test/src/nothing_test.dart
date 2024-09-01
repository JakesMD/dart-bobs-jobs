import 'package:jobs/jobs.dart';
import 'package:test/test.dart';
import 'package:test_beautifier/test_beautifier.dart';

void main() {
  group('Nothing tests', () {
    group('cNothing', () {
      test(
        requirement(
          When: 'cNothing is called',
          Then: 'returns an instance of Nothing',
        ),
        procedure(() {
          expect(cNothing, isA<Nothing>());
        }),
      );
    });
  });
}
