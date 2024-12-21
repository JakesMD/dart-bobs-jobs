import 'package:open_meteo_client/open_meteo_client.dart' as open_meteo_client;

/// An exception that can occur when fetching weather.
enum WeatherFetchException {
  /// The request failed.
  requestFailed,

  /// The weather was not found.
  notFound;

  /// Converts a failure from the [open_meteo_client] package to a
  /// [WeatherFetchException].
  static WeatherFetchException fromFailure(Object? failure) {
    if (failure is open_meteo_client.LocationFetchException) {
      return switch (failure) {
        open_meteo_client.LocationFetchException.requestFailed =>
          WeatherFetchException.requestFailed,
        open_meteo_client.LocationFetchException.notFound =>
          WeatherFetchException.notFound,
      };
    }
    if (failure is open_meteo_client.WeatherFetchException) {
      return switch (failure) {
        open_meteo_client.WeatherFetchException.requestFailed =>
          WeatherFetchException.requestFailed,
        open_meteo_client.WeatherFetchException.notFound =>
          WeatherFetchException.notFound,
      };
    }
    return WeatherFetchException.requestFailed;
  }
}
