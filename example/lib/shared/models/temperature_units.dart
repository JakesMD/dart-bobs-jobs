/// Represents different units of temperature.
enum TemperatureUnits {
  /// The temperature is in Fahrenheit.
  fahrenheit,

  /// The temperature is in Celsius.
  celsius;

  /// Returns `true` if this is [TemperatureUnits.celsius].
  bool get isCelcius => this == TemperatureUnits.celsius;

  /// Returns `true` if this is [TemperatureUnits.fahrenheit].
  bool get isFahrenheit => this == TemperatureUnits.fahrenheit;

  /// Returns the formatted temperature based on the given [value] in celsius.
  String formatted(double value) => isCelcius
      ? '${value.toStringAsPrecision(2)}°C'
      : '${((value * 9 / 5) + 32).toStringAsPrecision(2)}°F';
}
