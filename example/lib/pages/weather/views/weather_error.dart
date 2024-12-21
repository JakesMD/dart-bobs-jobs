import 'package:bobs_jobs_example/shared/_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WeatherError extends StatelessWidget {
  const WeatherError({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.read<WeatherFetchCubit>().state;
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('🙈', style: TextStyle(fontSize: 64)),
        Text(
          switch (state.failure) {
            WeatherFetchException.requestFailed => 'Something went wrong!',
            WeatherFetchException.notFound => "We couldn't find that city!"
          },
          style: theme.textTheme.headlineSmall,
        ),
      ],
    );
  }
}
