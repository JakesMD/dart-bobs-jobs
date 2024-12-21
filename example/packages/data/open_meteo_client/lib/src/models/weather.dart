import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'weather.g.dart';

/// {@template open_meteo_client.Weather}
///
/// Represents the current weather in a certain location.
///
/// {@endtemplate}
@JsonSerializable()
class Weather with EquatableMixin {
  /// {@macro open_meteo_client.Weather}
  const Weather({required this.temperature, required this.weatherCode});

  /// Creates a [Weather] from a JSON object.
  factory Weather.fromJson(Map<String, dynamic> json) =>
      _$WeatherFromJson(json);

  /// The temperature in Celsius.
  final double temperature;

  /// The weather code.
  ///
  /// This code is used to determine the current weather conditions.
  @JsonKey(name: 'weathercode')
  final double weatherCode;

  @override
  List<Object?> get props => [temperature, weatherCode];
}
