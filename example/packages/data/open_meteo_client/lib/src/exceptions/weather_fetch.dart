/// An exception that can occur when fetching weather.
enum WeatherFetchException {
  /// The request failed.
  requestFailed,

  /// The weather was not found.
  notFound;
}
