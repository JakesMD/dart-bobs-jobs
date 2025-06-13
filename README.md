# Bob's Jobs
Lightweight, descriptive functional programming for pragmatic Dart developers.

![coverage][coverage_badge]
[![pub package][pub_badge]][pub_link]
![style: very good analysis][very_good_analysis_badge]
![license: BSD 3][license_badge]


## 🧑‍💻 Who's Bob?

Bob started out like many developers—obsessed with "clean code." But after years of drowning in massive, sprawling codebases, he realized "clean" meant a total nightmare. Code that was supposed to be easy to maintain turned into a tangled mess of bugs, broken promises, and endless refactoring. Thanks, Bob 😉.

Then, Bob discovered functional programming. It promised to reduce bugs, improve maintainability, and make testing a breeze. But the tools? Cryptic naming conventions and bloated packages with hundreds of methods that were hard to wrap your head around—let alone Bob’s.

Bob needed something better. Something simple, clear, and practical. And Bob’s your uncle, this package was born—bringing the power of functional programming without the complexity.


## ✨ Features

- **Reads Like a Book:** No cryptic naming conventions—just clear, intuitive functional programming.
- **Lightweight:** Cuts through complexity, letting you clone, adapt, and integrate with ease—no need to wade through lengthy documentation.
- **Proven in Production:** Already trusted in multiple production Flutter apps, demonstrating its reliability and real-world practicality.



The current "Usage" section is quite long and dense, making it hard to quickly grasp the core benefits of BobsJobs. Here's a revised version that aims to be more concise, engaging, and structured, highlighting the advantages over pure Dart.



## 🕹️ Usage

BobsJobs introduces a more robust and readable way to handle operations that can succeed or fail, especially useful for asynchronous code in Dart and Flutter. Let's look at a common scenario: fetching weather data.

### Pure Dart vs. BobsJobs: A Comparison

Consider the traditional Dart approach for fetching weather data. It's functional, but error handling can lead to repetitive `try-catch` blocks and conditional logic.

#### Pure Dart
```dart
Future<Weather> fetchWeather({
    required double latitude,
    required double longitude,
}) async {
    final weatherRequest = Uri.https('api.open-meteo.com', 'v1/forecast', {
        'latitude': '$latitude',
        'longitude': '$longitude',
        'current_weather': 'true',
    });

    final weatherResponse = await _httpClient.get(weatherRequest);

    if (weatherResponse.statusCode != 200) {
        throw WeatherRequestFailure();
    }

    final bodyJson = jsonDecode(weatherResponse.body) as Map<String, dynamic>;

    if (!bodyJson.containsKey('current_weather')) {
        throw WeatherNotFoundFailure();
    }

    final weatherJson = bodyJson['current_weather'] as Map<String, dynamic>;

    return Weather.fromJson(weatherJson);
}
```

```dart
try {
    final weather = await fetchWeather(123456, 123456);
    print('Weather: $weather');
} on WeatherRequestFailure {
    print('something went wrong');
} on WeatherNotFoundFailure {
    print('weather not found');
} catch (e) {
    print('something went wrong');
}
```


Now, let's see how BobsJobs simplifies this by clearly separating the success and failure paths, leading to more readable and maintainable code.

#### BobsJobs
```dart
BobsJob<WeatherFetchException, Weather> fetchWeather({
    required double latitude,
    required double longitude,
}) =>
    BobsJob.attempt(
        run: () => _httpClient.get(
            Uri.https('api.open-meteo.com', 'v1/forecast', {
                'latitude': '$latitude',
                'longitude': '$longitude',
                'current_weather': 'true',
            }),
        ),
        onError: (error) => WeatherFetchException.requestFailed,
    )
        .thenValidateSuccess(
            isValid: (response) => response.statusCode == 200,
            onInvalid: (response) => WeatherFetchException.requestFailed,
        )
        .thenAttempt(
            run: (response) => jsonDecode(response.body) as Map,
            onError: (error, stack) => WeatherFetchException.requestFailed,
        )
        .thenValidateSuccess(
            isValid: (json) => json.containsKey('current_weather'),
            onInvalid: (json) => WeatherFetchException.notFound,
        )
        .thenConvertSuccess(
            (json) => Weather.fromJson(json['current_weather'] as Map<String, dynamic>),
        );
```

```dart
final outcome = await fetchWeather(latitude: 123456, longitude: 123456).run();

final message = outcome.resolve(
    onFailure: (exception) => switch (exception) {
        WeatherFetchException.requestFailed => 'something went wrong',
        WeatherFetchException.notFound => 'weather not found',
    },
    onSuccess: (weather) => 'Weather: $weather',
);

print(message);
```

Notice how BobsJobs allows you to chain operations and handle potential failures at each step, making the flow of logic clearer and reducing nested `if` statements or `try-catch` blocks. The `outcome.resolve()` method then provides a clean way to handle either success or failure.


### Core Concepts

BobsJobs revolves around a few key concepts:

#### `BobsJob`
A `BobsJob` encapsulates an operation that can either succeed with a value or fail with an exception. It's designed for chaining operations and handling errors gracefully.

```dart
// Run a job that could fail
final myJob = BobsJob<MyException, MySuccess>.attempt(
    run: () => thisCouldFail(),
    onError: (error) => MyException.someReason,
);

final outcome = await myJob.run();

final message = outcome.resolve(
    onFailure: (failure) => 'Failed: $failure',
    onSuccess: (success) => 'Succeeded: $success',
);

print(message);
```

**Common `BobsJob` methods:**

* `thenConvertSuccess`: Transforms the success value into another type.
    ```dart
    clientJob.thenConvertSuccess((json) => Book.fromJson(json));
    ```
* `thenConvertFailure`: Transforms the failure value into another exception type.
    ```dart
    clientJob.thenConvertFailure((failure) => DeleteException.from(failure));
    ```
* `thenConvert`: Converts both success and failure values.
    ```dart
    clientJob.thenConvert(
        onFailure: (failure) => DeleteException.from(failure),
        onSuccess: (value) => Book.fromJson(value),
    );
    ```
* `thenValidateSuccess`: Validates the success value, causing a failure if invalid.
    ```dart
    clientJob.thenValidateSuccess(
        isValid: (response) => response.statusCode == 200,
        onInvalid: (response) => FetchException.invalidResponse,
    );
    ```
* `thenValidateFailure`: Validates the failure value, potentially converting a failure into a success.
    ```dart
    clientJob.thenValidateFailure(
        isValid: (exception) => exception is DatabaseException,
        onInvalid: (exception) => Book.empty(),
    );
    ```
* `thenAttempt`: Attempts another job after a successful completion of the current job.
    ```dart
    clientJob.thenAttempt(
        run: (response) => json.decode(response.data),
        onError: (error) => FetchException.invalidResponse,
    );
    ```
* `chainOnSuccess`: Chains two jobs together, where the second job depends on the success of the first.
    ```dart
    client1.doThis().chainOnSuccess(
        onFailure: (client1Failure) => Client2Exception.from(client1Failure),
        nextJob: (client1Success) => client2.doThat(client1Success),
    );
    ```


#### `BobsOutcome`
A `BobsOutcome` represents the immutable result of a `BobsJob` – it's either a success or a failure. This explicit representation makes it easy to handle both cases without complex control flow.

```dart
final outcome = bobsSuccess(123); // A successful outcome
// or: final outcome = bobsFailure(Error()); // A failed outcome

final message = outcome.resolve(
    onFailure: (_) => 'Failed',
    onSuccess: (value) => 'Success: $value',
);

print(message);
```

**Common `BobsOutcome` methods/properties:**

* `resolve`: The primary way to handle both success and failure outcomes.
    ```dart
    final outcome = bobsFailure(DatabaseException.notFound);

    final message = outcome.resolve(
        onFailure: (exception) => switch(exception) {
            DatabaseException.notFound => 'Not found',
            DatabaseException.unknown => 'Unknown error',
        },
        onSuccess: (value) => 'Success: $value',
    );

    print(message); // Not found
    ```
* `asSuccess`: Retrieves the success value (throws if it's a failure).
    ```dart
    final outcome = bobsSuccess('Hello World');
    print(outcome.asSuccess); // Hello World
    ```
* `asFailure`: Retrieves the failure value (throws if it's a success).
    ```dart
    final outcome = bobsFailure(DatabaseException.notFound);
    print(outcome.asFailure); // DatabaseException.notFound
    ```


#### `BobsNothing`
`BobsNothing` is a special type used when a successful `BobsJob` doesn't need to return a specific value. It's similar to `void` but fits within the `BobsJob`'s generic type system.

```dart
BobsJob<DeleteException, BobsNothing> deleteBook(BigInt id) =>
    BobsJob.attempt(
      run: () => database.deleteBook(id),
      onError: (_) => DeleteException.databaseError,
    ).thenConvertSuccess((_) => bobsNothing); // Indicate no return value

final outcome = await deleteBook(BigInt.from(345)).run();

final message = outcome.resolve(
  onFailure: (_) => 'Failed',
  onSuccess: (_) => 'Succeeded',
);

print(message);
```


#### `BobsMaybe`
`BobsMaybe` provides a clear and explicit way to handle nullable values, avoiding potential `NullPointerExceptions` and improving code readability. It's particularly useful for `copyWith` methods and when an outcome might legitimately be absent.

```dart
// Usecase 1: Improve handling of nullable values (useful for job outcomes)
final nullableText = bobsMaybe('Hello World');

final message = nullableText.resolve(
    onPresent: (text) => text,
    onAbsent: () => 'No text',
);

print(message); // Hello World
```

```dart
// Usecase 2: copyWith methods where null is a meaningful value
class Text {
  const Text({this.text});

  final String? text;

  Text copyWith({BobsMaybe<String>? text}) =>
      Text(text: text != null ? text.asNullable : this.text);
}

var text = const Text(text: 'Hello World');

text = text.copyWith();
print(text.text); // Hello World

text = text.copyWith(text: bobsPresent('Hello World 2'));
print(text.text); // Hello World 2

text = text.copyWith(text: bobsAbsent()); // Explicitly set to null
print(text.text); // null
```

**Common `BobsMaybe` methods/properties:**

* `bobsMaybe(value)`: Creates a `BobsMaybe` from a nullable value.
    ```dart
    var maybe = bobsMaybe('not null');
    print(maybe.isPresent); // true

    maybe = bobsMaybe(null);
    print(maybe.isPresent); // false
    ```
* `resolve`: Handles both present and absent cases.
    ```dart
    final maybe = bobsPresent('Hello World');
    final message = maybe.resolve(
        onPresent: (text) => text,
        onAbsent: () => 'No text',
    );
    print(message); // Hello World
    ```
* `bobsPresent(value)`: Creates a `BobsMaybe` with a present value.
    ```dart
    var maybe = bobsPresent('Hello World');
    print(maybe.isPresent); // true
    ```
* `bobsAbsent()`: Creates a `BobsMaybe` representing an absent value.
    ```dart
    var maybe = bobsAbsent();
    print(maybe.isPresent); // false
    ```
* `asNullable`: Converts `BobsMaybe` back to a nullable Dart type.
    ```dart
    var maybe = bobsPresent('Hello World');
    var nullable = maybe.asNullable;
    print(nullable); // Hello World

    maybe = bobsAbsent();
    nullable = maybe.asNullable;
    print(nullable); // null
    ```
* `convert`: Transforms the value if present.
    ```dart
    final maybeText = bobsPresent('Hello World');
    final maybeUppercaseText = maybeText.convert((text) => text.toUpperCase());
    ```


#### `BigBob`
`BigBob` offers a static `onFailure` callback, perfect for global error logging or analytics whenever a `BobsJob` encounters a failure.

```dart
BigBob.onFailure = (failure, error, stack) => debugPrint('[$failure] $error');
```


### `BobsStream` (Experimental)
`BobsStream` aims to bring the robust error handling of `BobsJob` to streams. It wraps stream errors into `BobsOutcome`s, providing a consistent way to manage success and failure within a stream's lifecycle. Detailed documentation will be provided as this feature stabilizes.


### Testing
BobsJobs provides straightforward helpers to mock and assert `BobsJob` outcomes in your tests, simplifying the testing of your functional flows.

* **Mock a successful job:**
    ```dart
    when(() => myMockedJob).thenReturn(bobsFakeSuccessJob(MySuccessValue));
    ```
* **Mock a failing job:**
    ```dart
    when(() => myMockedJob).thenReturn(bobsFakeFailureJob(MyFailureValue));
    ```
* **Expect a successful outcome:**
    ```dart
    final outcome = await myMockedJob.run();
    expectBobsSuccess(outcome, MySuccessValue());
    ```
* **Expect a failing outcome:**
    ```dart
    final outcome = await myMockedJob.run();
    expectBobsFailure(outcome, MyFailureValue());
    ```

[coverage_badge]: https://raw.githubusercontent.com/VeryGoodOpenSource/very_good_cli/main/coverage_badge.svg
[license_badge]: https://img.shields.io/badge/license-BSD3-blue.svg
[pub_badge]: https://img.shields.io/pub/v/bobs_jobs.svg
[pub_link]: https://pub.dartlang.org/packages/bobs_jobs
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg