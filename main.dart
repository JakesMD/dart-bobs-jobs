import 'dart:convert';

import 'package:bobs_jobs/bobs_jobs.dart';

class InvalidJSONException {}

void main() async {
  const jsonString = '{"name": "John", "age": 30}';

  final job = BobsJob.attempt(
    run: () => jsonDecode(jsonString) as Map,
    onError: (error, stack) => InvalidJSONException(),
  ).thenAttempt(
    run: (json) => json['age'] as int,
    onError: (error, stack) => InvalidJSONException(),
  );

  final outcome = await job.run();

  final message = outcome.resolve(
    onFailure: (exception) => 'Invalid JSON.',
    onSuccess: (age) => 'Age: $age',
  );

  print(message);
}
