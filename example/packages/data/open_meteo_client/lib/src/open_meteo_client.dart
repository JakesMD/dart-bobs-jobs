import 'dart:convert';

import 'package:bobs_jobs/bobs_jobs.dart';
import 'package:http/http.dart' as http;
import 'package:open_meteo_client/open_meteo_client.dart';

/// {@template open_meteo_client.OpenMeteoClient}
///
/// A Dart API Client which wraps the [Open Meteo API](https://open-meteo.com).
///
/// {@endtemplate}
class OpenMeteoClient {
  /// {@macro open_meteo_client.OpenMeteoClient}
  OpenMeteoClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  /// The HTTP client used to make requests.
  final http.Client _httpClient;

  /// Fetches the [Location] with the given name.
  BobsJob<LocationFetchException, Location> fetchLocation({
    required String locationName,
  }) =>
      BobsJob.attempt(
        run: () => _httpClient.get(
          Uri.https(
            'geocoding-api.open-meteo.com',
            '/v1/search',
            {'name': locationName, 'count': '1'},
          ),
        ),
        onError: (_, __) => LocationFetchException.requestFailed,
      )
          .thenValidate(
            isValid: (response) => response.statusCode == 200,
            onInvalid: (_) => LocationFetchException.requestFailed,
          )
          .thenConvertSuccess((response) => jsonDecode(response.body) as Map)
          .thenValidate(
            isValid: (json) => json.containsKey('results'),
            onInvalid: (_) => LocationFetchException.notFound,
          )
          .thenConvertSuccess((json) => json['results'] as List)
          .thenValidate(
            isValid: (results) => results.isNotEmpty,
            onInvalid: (_) => LocationFetchException.notFound,
          )
          .thenConvertSuccess(
            (results) =>
                Location.fromJson(results.first as Map<String, dynamic>),
          );

  /// Fetches [Weather] for a given [latitude] and [longitude].
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
        onError: (_, __) => WeatherFetchException.requestFailed,
      )
          .thenValidate(
            isValid: (response) => response.statusCode == 200,
            onInvalid: (_) => WeatherFetchException.requestFailed,
          )
          .thenConvertSuccess((response) => jsonDecode(response.body) as Map)
          .thenValidate(
            isValid: (json) => json.containsKey('current_weather'),
            onInvalid: (_) => WeatherFetchException.notFound,
          )
          .thenConvertSuccess(
            (json) => Weather.fromJson(
              json['current_weather'] as Map<String, dynamic>,
            ),
          );
}
