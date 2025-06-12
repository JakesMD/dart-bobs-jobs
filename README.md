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



## 🕹️ Usage  

### Pure Dart vs Bobs Jobs

#### Pure Dart
``` dart
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
``` dart
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

#### Bobs Jobs
``` dart
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
        onError: (error, stack) => WeatherFetchException.requestFailed,
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
``` dart
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

### BobsNothing
A `BobsNothing` represents... nothing. It's used for when a successful job doesn't return anything.

``` dart
BobsJob<DeleteException, BobsNothing> deleteBook(BigInt id) =>
    BobsJob.attempt(
      run: () => database.deleteBook(id),
      onError: (_) => DeleteException.databaseError,
    ).thenConvertSuccess((_) => bobsNothing);

final outcome = await deleteBook(BigInt.from(345)).run();

final message = outcome.resolve(
  onFailure: (_) => 'Failed',
  onSuccess: (_) => 'Succeeded',
);

print(message);
```


### BobsMaybe

A `BobsMaybe` represents a value that may or may not be present, or in other words, a value that may be null.

#### 1. Usecase: Improve handling of nullable values (useful for job outcomes)
``` dart
final nullableText = bobsMaybe('Hello World');

final message = maybe.resolve(
    onPresent: (text) => text,
    onAbsent: () => 'No text',
);

print(message); // Hello World
```

#### 2. Usecase: `copyWith`

In a normal `copyWith` method, passing a parameter that is null will result in the parameter being ignored. But what if you don't want it to be ignored?
``` dart
class Text {
  const Text({this.text});

  final String? text;

  Text copyWith({BobsMaybe<String>? text}) =>
      Text(text: text?.asNullable ?? this.text);
}

var text = const Text(text: 'Hello World');

text = text.copyWith();
print(text.text); // Hello World

text = text.copyWith(text: bobsPresent('Hello World 2'));
print(text.text); // Hello World 2

text = text.copyWith(text: bobsAbsent());
print(text.text); // null
```

#### Create `BobsMaybe` from nullable
``` dart
var maybe = bobsMaybe('not null');

print(maybe.isPresent) // true

maybe = bobsMaybe(null);

print(maybe.isPresent) // false
```

#### Resolve a `BobsMaybe`
``` dart
final maybe = bobsPresent('Hello World');

final message = maybe.resolve(
    onPresent: (text) => text,
    onAbsent: () => 'No text',
);

print(message); // Hello World
```

#### Create a present value
``` dart
var maybe = bobsPresent('Hello World');
print(maybe.isPresent) // true
```

#### Create an absent value
``` dart
var maybe = bobsAbsent();
print(maybe.isPresent) // false
```

#### Convert `BobsMaybe` to nullable
``` dart
var maybe = bobsPresent('Hello World');
var nullable = maybe.asNullable;

print(nullable) // Hello World

maybe = bobsAbsent();
nullable = maybe.asNullable;

print(nullable) // null
```

#### Convert the value if present
``` dart
final maybeText = bobsPresent('Hello World');
final maybeUppercaseText = maybeText.convert((text) => text.toUpperCase());
```



[coverage_badge]: https://raw.githubusercontent.com/VeryGoodOpenSource/very_good_cli/main/coverage_badge.svg
[license_badge]: https://img.shields.io/badge/license-BSD3-blue.svg
[pub_badge]: https://img.shields.io/pub/v/bobs_jobs.svg
[pub_link]: https://pub.dartlang.org/packages/bobs_jobs
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg