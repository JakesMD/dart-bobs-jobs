import 'package:bobs_jobs/bobs_jobs.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:open_meteo_client/open_meteo_client.dart';
import 'package:test/test.dart';
import 'package:test_beautifier/test_beautifier.dart';

class MockHttpClient extends Mock implements http.Client {}

class MockResponse extends Mock implements http.Response {}

class FakeUri extends Fake implements Uri {}

void main() {
  group('OpenMeteoClient Tests', () {
    late http.Client httpClient;
    late OpenMeteoClient apiClient;
    final response = MockResponse();

    const testLocation = Location(
      id: 4887398,
      name: 'Chicago',
      latitude: 41.85003,
      longitude: -87.65005,
    );

    const testWeather = Weather(temperature: 15.3, weatherCode: 63);

    setUpAll(() {
      registerFallbackValue(FakeUri());
    });

    setUp(() {
      httpClient = MockHttpClient();
      apiClient = OpenMeteoClient(httpClient: httpClient);

      when(() => response.statusCode).thenReturn(200);
      when(() => httpClient.get(any())).thenAnswer((_) async => response);
    });

    group('constructor', () {
      test(
        requirement(
          When: 'contructed',
          Then: 'does not require an httpClient',
        ),
        procedure(() {
          expect(OpenMeteoClient(), isNotNull);
        }),
      );
    });

    group('fetchLocation', () {
      test(
        requirement(
          When: 'location fetched',
          Then: 'makes correct http request',
        ),
        procedure(() async {
          when(() => response.body).thenReturn('{}');

          await apiClient.fetchLocation(locationName: testLocation.name).run();

          verify(
            () => httpClient.get(
              Uri.https(
                'geocoding-api.open-meteo.com',
                '/v1/search',
                {'name': testLocation.name, 'count': '1'},
              ),
            ),
          ).called(1);
        }),
      );

      test(
        requirement(
          When: 'httpClient throws',
          Then: 'returns [request failed] exception',
        ),
        procedure(() async {
          when(() => httpClient.get(any())).thenThrow(Exception());

          final result = await apiClient
              .fetchLocation(locationName: testLocation.name)
              .run();

          expectBobsFailure(result, LocationFetchException.requestFailed);
        }),
      );

      test(
        requirement(
          Given: 'response is not 200',
          When: 'location fetched',
          Then: 'returns [request failed] exception',
        ),
        procedure(() async {
          when(() => response.statusCode).thenReturn(400);

          final result = await apiClient
              .fetchLocation(locationName: testLocation.name)
              .run();

          expectBobsFailure(result, LocationFetchException.requestFailed);
        }),
      );

      test(
        requirement(
          Given: 'error response',
          When: 'location fetched',
          Then: 'returns [not found] exception',
        ),
        procedure(() async {
          when(() => response.body).thenReturn('{}');

          final result = await apiClient
              .fetchLocation(locationName: testLocation.name)
              .run();

          expectBobsFailure(result, LocationFetchException.notFound);
        }),
      );

      test(
        requirement(
          Given: 'response is empty',
          When: 'location fetched',
          Then: 'returns [not found] exception',
        ),
        procedure(() async {
          when(() => response.body).thenReturn('{"results": []}');

          final result = await apiClient
              .fetchLocation(locationName: testLocation.name)
              .run();

          expectBobsFailure(result, LocationFetchException.notFound);
        }),
      );

      test(
        requirement(
          Given: 'response is valid',
          When: 'location fetched',
          Then: 'returns Location',
        ),
        procedure(() async {
          when(() => response.body).thenReturn(
            '''
            {
              "results": [
                {
                  "id": ${testLocation.id},
                  "name": "${testLocation.name}",
                  "latitude": ${testLocation.latitude},
                  "longitude": ${testLocation.longitude}
                }
              ]
            }''',
          );

          final result = await apiClient
              .fetchLocation(locationName: testLocation.name)
              .run();

          expectBobsSuccess(result, testLocation);
        }),
      );
    });

    group('fetchWeather', () {
      test(
        requirement(
          When: 'weather fetched',
          Then: 'makes correct http request',
        ),
        procedure(() async {
          when(() => response.body).thenReturn('{}');

          await apiClient
              .fetchWeather(
                latitude: testLocation.latitude,
                longitude: testLocation.longitude,
              )
              .run();

          verify(
            () => httpClient.get(
              Uri.https('api.open-meteo.com', 'v1/forecast', {
                'latitude': '${testLocation.latitude}',
                'longitude': '${testLocation.longitude}',
                'current_weather': 'true',
              }),
            ),
          ).called(1);
        }),
      );

      test(
        requirement(
          When: 'httpClient throws',
          Then: 'returns [request failed] exception',
        ),
        procedure(() async {
          when(() => httpClient.get(any())).thenThrow(Exception());

          final result = await apiClient
              .fetchWeather(
                latitude: testLocation.latitude,
                longitude: testLocation.longitude,
              )
              .run();

          expectBobsFailure(result, WeatherFetchException.requestFailed);
        }),
      );

      test(
        requirement(
          Given: 'response is not 200',
          When: 'location fetched',
          Then: 'returns [request failed] exception',
        ),
        procedure(() async {
          when(() => response.statusCode).thenReturn(400);

          final result = await apiClient
              .fetchWeather(
                latitude: testLocation.latitude,
                longitude: testLocation.longitude,
              )
              .run();

          expectBobsFailure(result, WeatherFetchException.requestFailed);
        }),
      );

      test(
        requirement(
          Given: 'response is empty',
          When: 'location fetched',
          Then: 'returns [not found] exception',
        ),
        procedure(() async {
          when(() => response.body).thenReturn('{}');

          final result = await apiClient
              .fetchWeather(
                latitude: testLocation.latitude,
                longitude: testLocation.longitude,
              )
              .run();

          expectBobsFailure(result, WeatherFetchException.notFound);
        }),
      );

      test(
        requirement(
          Given: 'response is valid',
          When: 'location fetched',
          Then: 'returns Weather',
        ),
        procedure(() async {
          when(() => response.body).thenReturn(
            '''
            {
              "latitude": 43,
              "longitude": -87.875,
              "generationtime_ms": 0.2510547637939453,
              "utc_offset_seconds": 0,
              "timezone": "GMT",
              "timezone_abbreviation": "GMT",
              "elevation": 189,
              "current_weather": {
                "temperature": ${testWeather.temperature},
                "windspeed": 25.8,
                "winddirection": 310,
                "weathercode": ${testWeather.weatherCode},
                "time": "2022-09-12T01:00"
              }
            }''',
          );

          final result = await apiClient
              .fetchWeather(
                latitude: testLocation.latitude,
                longitude: testLocation.longitude,
              )
              .run();

          expectBobsSuccess(result, testWeather);
        }),
      );
    });
  });
}
