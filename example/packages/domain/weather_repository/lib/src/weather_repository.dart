import 'package:bobs_jobs/bobs_jobs.dart';
import 'package:open_meteo_client/open_meteo_client.dart' show OpenMeteoClient;
import 'package:weather_repository/weather_repository.dart';

/// {@template weather_repository.WeatherRepository}
///
/// A repository that fetches weather data.
///
/// {@endtemplate}
class WeatherRepository {
  /// {@macro weather_repository.WeatherRepository}
  WeatherRepository({OpenMeteoClient? weatherApiClient})
      : _weatherApiClient = weatherApiClient ?? OpenMeteoClient();

  final OpenMeteoClient _weatherApiClient;

  /// Fetches the weather for a given [city].
  BobsJob<WeatherFetchException, Weather> fetchWeather({
    required String city,
  }) =>
      _weatherApiClient
          .fetchLocation(
            locationName: city,
          )
          .chainOnSuccess(
            onFailure: WeatherFetchException.fromFailure,
            nextJob: (location) => _weatherApiClient
                .fetchWeather(
                  latitude: location.latitude,
                  longitude: location.longitude,
                )
                .thenConvert(
                  onFailure: WeatherFetchException.fromFailure,
                  onSuccess: (weather) => Weather(
                    temperature: weather.temperature,
                    location: location.name,
                    condition: WeatherCondition.fromWeatherCode(
                      weather.weatherCode.toInt(),
                    ),
                  ),
                ),
          );
}
