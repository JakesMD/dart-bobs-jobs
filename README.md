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
    required double longitude,d
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
        .thenValidate(
            isValid: (response) => response.statusCode == 200,
            onInvalid: (response) => WeatherFetchException.requestFailed,
        )
        .thenAttempt(
            run: (response) => jsonDecode(response.body) as Map,
            onError: (error, stack) => WeatherFetchException.requestFailed,
        )
        .thenValidate(
            isValid: (json) => json.containsKey('current_weather'),
            onInvalid: (json) => WeatherFetchException.notFound,
        )
        .thenConvertSuccess(
            (json) => Weather.fromJson(json['current_weather'] as Map<String, dynamic>),
        );
```
``` dart
final outcome = fetchWeather(latitude: 123456, longitude: 123456);

final message = outcome.resolve(
    onFailure: (exception) => switch (exception) {
        WeatherFetchException.requestFailed => 'something went wrong',
        WeatherFetchException.notFound => 'weather not found',
    },
    onSuccess: (weather) => 'Weather: $weather',
);

print(message);
```

---

More docs coming...


[coverage_badge]: https://raw.githubusercontent.com/VeryGoodOpenSource/very_good_cli/main/coverage_badge.svg
[license_badge]: https://img.shields.io/badge/license-BSD3-blue.svg
[pub_badge]: https://img.shields.io/pub/v/bobs_jobs.svg
[pub_link]: https://pub.dartlang.org/packages/bobs_jobs
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg