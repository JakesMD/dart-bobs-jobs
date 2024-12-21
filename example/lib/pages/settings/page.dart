import 'package:bobs_jobs_example/shared/_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage._();

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const SettingsPage._());
  }

  void _onUnitsToggled(BuildContext context) {
    context.read<WeatherFetchCubit>().toggleUnits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: <Widget>[
          BlocBuilder<WeatherFetchCubit, WeatherFetchState>(
            buildWhen: (previous, current) =>
                previous.temperatureUnits != current.temperatureUnits,
            builder: (context, state) {
              return ListTile(
                title: const Text('Temperature Units'),
                isThreeLine: true,
                subtitle: const Text(
                  'Use metric measurements for temperature units.',
                ),
                trailing: Switch(
                  value: state.temperatureUnits.isCelcius,
                  onChanged: (_) => _onUnitsToggled(context),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
