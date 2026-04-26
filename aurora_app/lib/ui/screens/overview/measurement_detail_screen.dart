import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openscale/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:openscale/core/bloc/measurement/measurement_bloc.dart';
import 'package:openscale/ui/widgets/dialogs/confirm_dialog.dart';
import 'package:openscale/ui/widgets/dialogs/number_input_dialog.dart';

class MeasurementDetailScreen extends StatelessWidget {
  final String measurementId;

  const MeasurementDetailScreen({super.key, required this.measurementId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MeasurementBloc, MeasurementState>(
      builder: (context, state) {
        final measurement = state.measurements
            .where((m) => m.id == measurementId)
            .firstOrNull;

        if (measurement == null) {
          return Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.measurement),
            ),
            body: Center(
              child: Text(AppLocalizations.of(context)!.measurementNotFound),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(DateFormat.yMd().add_Hm().format(measurement.dateTime)),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _confirmDelete(context),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.dateTime,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat.yMMMMd().add_Hm().format(
                          measurement.dateTime,
                        ),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ...measurement.values.map(
                (value) => _MeasurementValueTile(
                  label: value.typeName,
                  value: value.value,
                  unit: value.unit,
                  color: value.color,
                  onEdit: () => _editValue(context, value),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context) {
    showConfirmDialog(
      context: context,
      title: AppLocalizations.of(context)!.deleteMeasurement,
      message: AppLocalizations.of(context)!.actionCannotBeUndone,
      isDestructive: true,
      onConfirm: () {
        context.read<MeasurementBloc>().add(DeleteMeasurement(measurementId));
        context.pop();
      },
    );
  }

  void _editValue(BuildContext context, MeasurementUiValue value) {
    showNumberInputDialog(
      context: context,
      title: value.typeName,
      initialValue: value.value,
      unit: value.unit,
    ).then((newValue) {
      if (newValue != null && context.mounted) {
        context.read<MeasurementBloc>().add(
          UpdateMeasurementValue(
            measurementId: measurementId,
            typeId: value.typeId,
            newValue: newValue,
          ),
        );
      }
    });
  }
}

class _MeasurementValueTile extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final Color color;
  final VoidCallback onEdit;

  const _MeasurementValueTile({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        title: Text(label),
        trailing: Text(
          '${value.toStringAsFixed(1)} $unit',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        onTap: onEdit,
      ),
    );
  }
}
