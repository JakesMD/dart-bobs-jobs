import 'package:bloc/bloc.dart';
import 'package:bobs_jobs/bobs_jobs.dart';
import 'package:bobs_jobs_example/app.dart';
import 'package:bobs_jobs_example/weather_bloc_observer.dart';
import 'package:flutter/material.dart';
import 'package:weather_repository/weather_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = const WeatherBlocObserver();
  BigBob.onFailure = (failure, error, stack) => debugPrint('[$failure] $error');

  runApp(WeatherApp(weatherRepository: WeatherRepository()));
}
