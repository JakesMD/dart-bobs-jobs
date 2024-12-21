import 'package:bobs_jobs_example/pages/_pages.dart';
import 'package:bobs_jobs_example/pages/weather/views/_views.dart';
import 'package:bobs_jobs_example/shared/_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WeatherPage extends StatelessWidget {
  const WeatherPage({super.key});

  void _onSettingsPressed(BuildContext context) {
    Navigator.of(context).push<void>(SettingsPage.route());
  }

  Future<void> _onRefresh(BuildContext context) {
    return context.read<WeatherFetchCubit>().refreshWeather();
  }

  Future<void> _onSearchPressed(BuildContext context) async {
    final city = await Navigator.of(context).push(SearchPage.route());
    if (!context.mounted) return;
    await context.read<WeatherFetchCubit>().fetchWeather(city);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _onSettingsPressed(context),
          ),
        ],
      ),
      body: Center(
        child: BlocBuilder<WeatherFetchCubit, WeatherFetchState>(
          builder: (context, state) {
            return switch (state.status) {
              RequestCubitStatus.initial => const WeatherEmpty(),
              RequestCubitStatus.inProgress => const WeatherLoading(),
              RequestCubitStatus.failed => const WeatherError(),
              RequestCubitStatus.succeeded =>
                WeatherPopulated(onRefresh: () => _onRefresh(context)),
            };
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.search, semanticLabel: 'Search'),
        onPressed: () => _onSearchPressed(context),
      ),
    );
  }
}
