import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:openscale/core/bloc/measurement/measurement_bloc.dart';
import 'package:openscale/core/bloc/user/user_bloc.dart';
import 'package:openscale/core/bloc/settings/settings_bloc.dart';

class AppBlocProviders extends StatelessWidget {
  final Widget child;

  const AppBlocProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              UserBloc(context.read<UserRepository>())..add(const LoadUsers()),
        ),
        BlocProvider(create: (context) => SettingsBloc()),
        BlocProvider(
          create: (context) =>
              MeasurementBloc(context.read<MeasurementRepository>()),
        ),
      ],
      child: child,
    );
  }
}
