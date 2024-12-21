part of 'cubit.dart';

/// {@template WeatherFetchState}
///
/// The state for the [WeatherFetchCubit].
///
/// {@endtemplate}
class WeatherFetchState
    extends RequestCubitState<WeatherFetchException, Weather> {
  WeatherFetchState._({
    required Weather weather,
    required this.temperatureUnits,
    required this.lastUpdated,
    required super.status,
    super.outcome,
  }) : _previousWeather = weather;

  /// {@macro WeatherFetchState}
  ///
  /// The initial state.
  WeatherFetchState.initial({
    required Weather weather,
    required this.temperatureUnits,
  })  : _previousWeather = weather,
        lastUpdated = DateTime.now(),
        super.initial();

  /// {@macro WeatherFetchState}
  ///
  /// The in progress state.
  WeatherFetchState.inProgress({
    required WeatherFetchState previousState,
  })  : _previousWeather = previousState.weather,
        temperatureUnits = previousState.temperatureUnits,
        lastUpdated = previousState.lastUpdated,
        super.inProgress();

  /// {@macro WeatherFetchState}
  ///
  /// The completed state.
  WeatherFetchState.completed({
    required super.outcome,
    required WeatherFetchState previousState,
  })  : _previousWeather = previousState.weather,
        temperatureUnits = previousState.temperatureUnits,
        lastUpdated = DateTime.now(),
        super.completed();

  /// The temperature units to display the weather in.
  final TemperatureUnits temperatureUnits;

  /// The time the weather was last updated.
  final DateTime lastUpdated;

  final Weather _previousWeather;

  /// The weather that was fetched.
  Weather get weather => succeeded ? success : _previousWeather;

  /// The formatted temperature based on the [temperatureUnits].
  String get formattedTemperature =>
      temperatureUnits.formatted(weather.temperature);

  String get conditionToEmoji => switch (weather.condition) {
        WeatherCondition.clear => '☀️',
        WeatherCondition.rainy => '🌧️',
        WeatherCondition.cloudy => '☁️',
        WeatherCondition.snowy => '🌨️',
        WeatherCondition.unknown => '❓',
      };

  /// Returns a copy of this state with the given fields replaced with the
  /// new values.
  WeatherFetchState copyWith({TemperatureUnits? temperatureUnits}) =>
      WeatherFetchState._(
        status: status,
        outcome: outcome,
        weather: weather,
        temperatureUnits: temperatureUnits ?? this.temperatureUnits,
        lastUpdated: lastUpdated,
      );

  @override
  List<Object?> get props =>
      super.props..addAll([temperatureUnits, lastUpdated, weather]);
}
