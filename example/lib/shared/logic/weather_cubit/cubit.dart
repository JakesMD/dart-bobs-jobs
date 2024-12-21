import 'package:bloc/bloc.dart';
import 'package:bobs_jobs_example/shared/_shared.dart';

part 'state.dart';

/// {@template WeatherFetchCubit}
///
/// The cubit that handles fetching the weather.
///
/// {@endtemplate}
class WeatherFetchCubit extends Cubit<WeatherFetchState> {
  /// {@macro WeatherFetchCubit}
  WeatherFetchCubit({required this.weatherRepository})
      : super(
          WeatherFetchState.initial(
            weather: const Weather(
              condition: WeatherCondition.unknown,
              temperature: 0,
              location: '--',
            ),
            temperatureUnits: TemperatureUnits.celsius,
          ),
        );

  /// The repository this cubit uses to fetch the weather.
  final WeatherRepository weatherRepository;

  /// Fetches the weather for the given [city].
  Future<void> fetchWeather(String? city) async {
    if (city == null || city.isEmpty) return;

    emit(WeatherFetchState.inProgress(previousState: state));

    final result = await weatherRepository.fetchWeather(city: city).run();

    emit(WeatherFetchState.completed(previousState: state, outcome: result));
  }

  /// Refreshes the weather for the current location.
  Future<void> refreshWeather() async {
    if (!state.succeeded) return;
    if (state.isInitial) return;

    final result = await weatherRepository
        .fetchWeather(city: state.weather.location)
        .run();

    emit(WeatherFetchState.completed(previousState: state, outcome: result));
  }

  /// Toggles the temperature units between Fahrenheit and Celsius.
  void toggleUnits() {
    final units = state.temperatureUnits.isFahrenheit
        ? TemperatureUnits.celsius
        : TemperatureUnits.fahrenheit;

    emit(state.copyWith(temperatureUnits: units));
  }
}
