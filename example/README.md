# Bob's Jobs Example App

This example app is a reimagining of the [Bloc weather app](https://github.com/felangel/bloc/tree/master/examples/flutter_weather), now enhanced with Bob's Jobs.

Explore the [open_meteo_client](packages/data/open_meteo_client/lib/src/open_meteo_client.dart) and [weather_repository](packages/domain/weather_repository/lib/src/weather_repository.dart) packages, along with their corresponding tests, to see Bob's Jobs in action. Additionally, check out the [WeatherFetchCubit](lib/shared/logic/weather_cubit/cubit.dart) to discover how Bob's Jobs simplifies Bloc management.

On the [WeatherError](lib/pages/weather/views/weather_error.dart) view, you'll see how Bob's Jobs streamlines error handling, making your UI more efficient and intuitive.

I added the [RequestCubitState](lib/shared/logic/request_cubit.dart) to the app, which `WeatherFetchCubit` extends. It’s a little hack I use in most of my apps to cut down on boilerplate and create a universal API for the UI.