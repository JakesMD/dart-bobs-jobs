# Dart Bob's Jobs

![coverage][coverage_badge]
[![pub package][pub_badge]][pub_link]
![style: very good analysis][very_good_analysis_badge]
![License: MIT][license_badge]

I appreciate the core ideas of functional programming, but I prefer a more balanced approach over going all-in.

Functional programming avoids mutable state that could change unexpectedly, making the code easier to read and maintain. But I also discovered that a well designed functional programming package could significantly improve ease of testing.

That’s why I created this Dart package: it cherry-picks the best features of functional programming while prioritizing simplicity, maintainability, and ease of testing.

Unlike many functional programming packages that are large and complex, this package is designed to be lightweight and intuitive. Its simplicity allows anyone to clone and adapt it to their needs without needing to sift through extensive documentation first.

I have deliberately avoided traditional functional programming naming conventions so that developers and reviewers with little prior knowledge of functional programming can easily understand your code.

Dart Bob's Jobs is already being used in multiple production Flutter apps, proving its reliability and practicality.



## 🕹️ Usage  

### Creating a Job  

Jobs don’t throw exceptions about the place. Instead, they handle errors gracefully by returning either the exception (if the job failed) or the result (if the job succeeded).  

Here’s a simple example:  
```dart
const jsonString = '{"name": "John", "age": 30}';

final job = BobsJob.attempt(
    run: () => jsonDecode(jsonString) as Map,
    onError: (error, stack) => InvalidJSONException(),
);

final outcome = await job.run();

final message = outcome.resolve(
    onFailure: (exception) => 'Invalid JSON.',
    onSuccess: (json) => json.toString(),
);

print(message);
```  

### Converting Outcomes
What if we only need a specific key from the JSON? We can easily do that by converting the success:
```dart
final job = BobsJob.attempt(
    run: () => jsonDecode(jsonString) as Map,
    onError: (error, stack) => InvalidJSONException(),
).thenConvertSuccess((json) => json['age'] as int);

final outcome = await job.run();

final message = outcome.resolve(
    onFailure: (exception) => 'Invalid JSON.',
    onSuccess: (age) => 'Age: $age',
);

print(message);
```  

### Chaining Jobs

But what if the JSON doesn’t contain the key we need? Instead of converting the success, we'll just chain another job:
```dart
final job = BobsJob.attempt(
    run: () => jsonDecode(jsonString) as Map,
    onError: (error, stack) => InvalidJSONException(),
).thenAttempt(
    run: (json) => json['age'] as int,
    onError: (error, stack) => InvalidJSONException(),
);
```  

### Validation
Or, instead of brute-forcing the call, we could simply add a validation step:
``` dart
final job = BobsJob.attempt(
    run: () => jsonDecode(jsonString) as Map,
    onError: (error, stack) => InvalidJSONException(),
)
    .thenValidate(
        isValid: (json) => json.containsKey('age'),
        onInvalid: (json) => InvalidJSONException(),
    )
    .thenConvertSuccess((json) => json['age'] as int);
```


More docs coming...




[coverage_badge]: https://raw.githubusercontent.com/VeryGoodOpenSource/very_good_cli/main/coverage_badge.svg
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[pub_badge]: https://img.shields.io/pub/v/bobs_jobs.svg
[pub_link]: https://pub.dartlang.org/packages/bobs_jobs
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg