import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openscale/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import 'package:openscale/core/bloc/measurement/measurement_bloc.dart';
import 'package:openscale/core/bloc/user/user_bloc.dart';
import 'package:openscale/ui/navigation/app_router.dart';
import 'package:openscale/ui/widgets/measurement_card.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MeasurementBloc, MeasurementState>(
      builder: (context, measurementState) {
        return BlocBuilder<UserBloc, UserState>(
          builder: (context, userState) {
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  title: Text(
                    userState.selectedUser?.name ??
                        AppLocalizations.of(context)!.appTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      onPressed: () => context.push(AppRoutes.settings),
                    ),
                  ],
                  floating: true,
                ),
                _buildBody(context, measurementState),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, MeasurementState state) {
    if (state.isLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final measurements = state.measurements;

    if (measurements.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.scale_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.noMeasurementsYet,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.tonal(
                onPressed: () => context.push(AppRoutes.measurementNew),
                child: Text(AppLocalizations.of(context)!.addMeasurement),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 100),
      sliver: SliverList.separated(
        itemCount: measurements.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final measurement = measurements[index];
          return MeasurementCard(
            dateTime: measurement.dateTime,
            weightValue: measurement.weight,
            trend: measurement.trend,
            measurementValues: measurement.values
                .map(
                  (v) => MeasurementCardValue(
                    label: v.typeName,
                    value: v.value,
                    unit: v.unit,
                    color: v.color,
                  ),
                )
                .toList(),
            onTap: () => context.push(
              '${AppRoutes.measurementDetail}/${measurement.id}',
            ),
          );
        },
      ),
    );
  }
}
