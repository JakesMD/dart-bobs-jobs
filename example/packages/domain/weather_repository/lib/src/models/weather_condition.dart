/// Represents a weather condition.
enum WeatherCondition {
  /// Its a sunny day.
  clear,

  /// Its a rainy day.
  rainy,

  /// Its a cloudy day.
  cloudy,

  /// Its a snowy day.
  snowy,

  /// Unable to determine the weather condition.
  unknown;

  /// Converts a weather condition code from the weather API to a
  /// [WeatherCondition].
  static WeatherCondition fromWeatherCode(int code) {
    switch (code) {
      case 0:
        return WeatherCondition.clear;
      case 1:
      case 2:
      case 3:
      case 45:
      case 48:
        return WeatherCondition.cloudy;
      case 51:
      case 53:
      case 55:
      case 56:
      case 57:
      case 61:
      case 63:
      case 65:
      case 66:
      case 67:
      case 80:
      case 81:
      case 82:
      case 95:
      case 96:
      case 99:
        return WeatherCondition.rainy;
      case 71:
      case 73:
      case 75:
      case 77:
      case 85:
      case 86:
        return WeatherCondition.snowy;
      default:
        return WeatherCondition.unknown;
    }
  }
}
