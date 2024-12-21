import 'package:bobs_jobs/bobs_jobs.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_meteo_client/open_meteo_client.dart' as open_meteo_client;
import 'package:test/test.dart';
import 'package:test_beautifier/test_beautifier.dart';
import 'package:weather_repository/weather_repository.dart';

class MockOpenMeteoClient extends Mock
    implements open_meteo_client.OpenMeteoClient {}

void main() {
  group('WeatherRepository Tests', () {
    late open_meteo_client.OpenMeteoClient weatherApiClient;
    late WeatherRepository weatherRepository;

    setUp(() {
      weatherApiClient = MockOpenMeteoClient();
      weatherRepository = WeatherRepository(weatherApiClient: weatherApiClient);
    });

    group('constructor', () {
      test(
        requirement(
          Given: 'No api client injected',
          When: 'Instantiating WeatherRepository',
          Then: 'Instantiates internal weather api client',
        ),
        procedure(() {
          expect(WeatherRepository(), isNotNull);
        }),
      );
    });

    group('fetchWeather', () {
      const testClientLocation = open_meteo_client.Location(
        id: 123232,
        name: 'chicago',
        latitude: 41.85003,
        longitude: -87.65005,
      );

      const testClientWeather = open_meteo_client.Weather(
        temperature: 42.42,
        weatherCode: 0,
      );

      BobsJob<open_meteo_client.LocationFetchException,
              open_meteo_client.Location>
          mockFetchLocation() => weatherApiClient.fetchLocation(
                locationName: any(named: 'locationName'),
              );

      BobsJob<open_meteo_client.WeatherFetchException,
              open_meteo_client.Weather>
          mockFetchWeather() => weatherApiClient.fetchWeather(
                latitude: any(named: 'latitude'),
                longitude: any(named: 'longitude'),
              );

      test(
        requirement(
          Given: 'a city',
          When: 'fetchWeather is called',
          Then: 'calls locationSearch with correct city',
        ),
        procedure(() async {
          when(mockFetchLocation)
              .thenReturn(bobsFakeSuccessJob(testClientLocation));
          when(mockFetchWeather)
              .thenReturn(bobsFakeSuccessJob(testClientWeather));

          await weatherRepository
              .fetchWeather(city: testClientLocation.name)
              .run();

          verify(
            () => weatherApiClient.fetchLocation(
              locationName: testClientLocation.name,
            ),
          ).called(1);
        }),
      );

      test(
        requirement(
          When: 'fetchLocation returns [not found] exception',
          Then: 'returns [request failed] exception',
        ),
        procedure(() async {
          when(mockFetchLocation).thenReturn(
            bobsFakeFailureJob(
              open_meteo_client.LocationFetchException.notFound,
            ),
          );

          final result = await weatherRepository
              .fetchWeather(city: testClientLocation.name)
              .run();

          expectBobsFailure(result, WeatherFetchException.notFound);
        }),
      );

      test(
        requirement(
          When: 'fetchLocation returns [request failed] exception',
          Then: 'returns [request failed] exception',
        ),
        procedure(() async {
          when(mockFetchLocation).thenReturn(
            bobsFakeFailureJob(
              open_meteo_client.LocationFetchException.requestFailed,
            ),
          );

          final result = await weatherRepository
              .fetchWeather(city: testClientLocation.name)
              .run();

          expectBobsFailure(result, WeatherFetchException.requestFailed);
        }),
      );

      test(
        requirement(
          Given: 'coordinates',
          When: 'fetchWeather is called',
          Then: 'calls fetchWeather with correct latitude/longitude',
        ),
        procedure(() async {
          when(mockFetchLocation)
              .thenReturn(bobsFakeSuccessJob(testClientLocation));
          when(mockFetchWeather)
              .thenReturn(bobsFakeSuccessJob(testClientWeather));

          await weatherRepository
              .fetchWeather(city: testClientLocation.name)
              .run();

          verify(
            () => weatherApiClient.fetchWeather(
              latitude: testClientLocation.latitude,
              longitude: testClientLocation.longitude,
            ),
          ).called(1);
        }),
      );

      test(
        requirement(
          When: 'fetchWeather returns [request failed] exception',
          Then: 'returns [request failed] exception',
        ),
        procedure(() async {
          when(mockFetchLocation)
              .thenReturn(bobsFakeSuccessJob(testClientLocation));
          when(mockFetchWeather).thenReturn(
            bobsFakeFailureJob(
              open_meteo_client.WeatherFetchException.requestFailed,
            ),
          );

          final result = await weatherRepository
              .fetchWeather(city: testClientLocation.name)
              .run();

          expectBobsFailure(result, WeatherFetchException.requestFailed);
        }),
      );

      test(
        requirement(
          When: 'fetchWeather returns [not found] exception',
          Then: 'returns [not found] exception',
        ),
        procedure(() async {
          when(mockFetchLocation)
              .thenReturn(bobsFakeSuccessJob(testClientLocation));
          when(mockFetchWeather).thenReturn(
            bobsFakeFailureJob(
              open_meteo_client.WeatherFetchException.notFound,
            ),
          );

          final result = await weatherRepository
              .fetchWeather(city: testClientLocation.name)
              .run();

          expectBobsFailure(result, WeatherFetchException.notFound);
        }),
      );

      test(
        requirement(
          Given: 'weather code representing clear weather',
          When: 'fetchWeather is called',
          Then: 'returns weather with condition clear',
        ),
        procedure(() async {
          when(mockFetchLocation)
              .thenReturn(bobsFakeSuccessJob(testClientLocation));
          when(mockFetchWeather).thenReturn(
            bobsFakeSuccessJob(
              open_meteo_client.Weather(
                temperature: testClientWeather.temperature,
                weatherCode: 0,
              ),
            ),
          );

          final result = await weatherRepository
              .fetchWeather(city: testClientLocation.name)
              .run();

          expectBobsSuccess(
            result,
            Weather(
              temperature: testClientWeather.temperature,
              location: testClientLocation.name,
              condition: WeatherCondition.clear,
            ),
          );
        }),
      );

      test(
        requirement(
          Given: 'weather code representing cloudy weather',
          When: 'fetchWeather is called',
          Then: 'returns weather with condition cloudy',
        ),
        procedure(() async {
          when(mockFetchLocation)
              .thenReturn(bobsFakeSuccessJob(testClientLocation));
          when(mockFetchWeather).thenReturn(
            bobsFakeSuccessJob(
              open_meteo_client.Weather(
                temperature: testClientWeather.temperature,
                weatherCode: 1,
              ),
            ),
          );

          final result = await weatherRepository
              .fetchWeather(city: testClientLocation.name)
              .run();

          expectBobsSuccess(
            result,
            Weather(
              temperature: testClientWeather.temperature,
              location: testClientLocation.name,
              condition: WeatherCondition.cloudy,
            ),
          );
        }),
      );

      test(
        requirement(
          Given: 'weather code representing rainy weather',
          When: 'fetchWeather is called',
          Then: 'returns weather with condition rainy',
        ),
        procedure(() async {
          when(mockFetchLocation)
              .thenReturn(bobsFakeSuccessJob(testClientLocation));
          when(mockFetchWeather).thenReturn(
            bobsFakeSuccessJob(
              open_meteo_client.Weather(
                temperature: testClientWeather.temperature,
                weatherCode: 51,
              ),
            ),
          );

          final result = await weatherRepository
              .fetchWeather(city: testClientLocation.name)
              .run();

          expectBobsSuccess(
            result,
            Weather(
              temperature: testClientWeather.temperature,
              location: testClientLocation.name,
              condition: WeatherCondition.rainy,
            ),
          );
        }),
      );

      test(
        requirement(
          Given: 'weather code representing snowy weather',
          When: 'fetchWeather is called',
          Then: 'returns weather with condition snowy',
        ),
        procedure(() async {
          when(mockFetchLocation)
              .thenReturn(bobsFakeSuccessJob(testClientLocation));
          when(mockFetchWeather).thenReturn(
            bobsFakeSuccessJob(
              open_meteo_client.Weather(
                temperature: testClientWeather.temperature,
                weatherCode: 71,
              ),
            ),
          );
          final result = await weatherRepository
              .fetchWeather(city: testClientLocation.name)
              .run();

          expectBobsSuccess(
            result,
            Weather(
              temperature: testClientWeather.temperature,
              location: testClientLocation.name,
              condition: WeatherCondition.snowy,
            ),
          );
        }),
      );

      test(
        requirement(
          Given: 'weather code representing unknown weather',
          When: 'fetchWeather is called',
          Then: 'returns weather with condition unkown',
        ),
        procedure(() async {
          when(mockFetchLocation)
              .thenReturn(bobsFakeSuccessJob(testClientLocation));
          when(mockFetchWeather).thenReturn(
            bobsFakeSuccessJob(
              open_meteo_client.Weather(
                temperature: testClientWeather.temperature,
                weatherCode: -1,
              ),
            ),
          );

          final result = await weatherRepository
              .fetchWeather(city: testClientLocation.name)
              .run();

          expectBobsSuccess(
            result,
            Weather(
              temperature: testClientWeather.temperature,
              location: testClientLocation.name,
              condition: WeatherCondition.unknown,
            ),
          );
        }),
      );
    });
  });
}
