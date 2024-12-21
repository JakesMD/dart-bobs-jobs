import 'package:equatable/equatable.dart';
import 'package:weather_repository/weather_repository.dart';

/// {@template weather_repository.Weather}
///
/// Represents the current weather in a certain location.
///
/// {@endtemplate}
class Weather with EquatableMixin {
  /// {@macro weather_repository.Weather}
  const Weather({
    required this.location,
    required this.temperature,
    required this.condition,
  });

  /// The location of the weather.
  final String location;

  /// The temperature in celsius.
  final double temperature;

  /// The condition of the weather.
  final WeatherCondition condition;

  @override
  List<Object> get props => [location, temperature, condition];
}
