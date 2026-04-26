import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openscale/l10n/app_localizations.dart';

import 'package:openscale/core/bloc/measurement/measurement_bloc.dart';
import 'package:openscale/ui/widgets/measurement_type_selector.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String _selectedType = 'weight';
  StatisticsPeriod _period = StatisticsPeriod.month;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MeasurementBloc, MeasurementState>(
      builder: (context, state) {
        final stats = _computeStats(state);
        final l10n = AppLocalizations.of(context)!;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: MeasurementTypeSelector(
                selectedType: _selectedType,
                onTypeSelected: (type) {
                  setState(() {
                    _selectedType = type;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SegmentedButton<StatisticsPeriod>(
                segments: [
                  ButtonSegment(
                    value: StatisticsPeriod.week,
                    label: Text(l10n.week),
                  ),
                  ButtonSegment(
                    value: StatisticsPeriod.month,
                    label: Text(l10n.month),
                  ),
                  ButtonSegment(
                    value: StatisticsPeriod.year,
                    label: Text(l10n.year),
                  ),
                ],
                selected: {_period},
                onSelectionChanged: (selected) {
                  setState(() {
                    _period = selected.first;
                  });
                },
              ),
            ),
            _StatCard(label: l10n.minimum, value: stats.min, unit: stats.unit),
            const SizedBox(height: 8),
            _StatCard(label: l10n.maximum, value: stats.max, unit: stats.unit),
            const SizedBox(height: 8),
            _StatCard(label: l10n.last, value: stats.last, unit: stats.unit),
            const SizedBox(height: 8),
            _StatCard(
              label: l10n.change,
              value: stats.change,
              unit: stats.unit,
            ),
            const SizedBox(height: 8),
            _StatCard(
              label: l10n.count,
              value: stats.count.toDouble(),
              unit: '',
              isCount: true,
            ),
          ],
        );
      },
    );
  }

  // Uses raw enriched values — NEVER averages for display
  _StatResult _computeStats(MeasurementState state) {
    final now = DateTime.now();
    final cutoff = switch (_period) {
      StatisticsPeriod.week => now.subtract(const Duration(days: 7)),
      StatisticsPeriod.month => now.subtract(const Duration(days: 30)),
      StatisticsPeriod.year => now.subtract(const Duration(days: 365)),
    };

    final filtered = state.measurements.where(
      (m) => m.dateTime.isAfter(cutoff),
    );

    if (filtered.isEmpty) {
      return _StatResult(
        min: 0,
        max: 0,
        last: 0,
        change: 0,
        count: 0,
        unit: 'kg',
      );
    }

    final values = filtered.map((m) {
      if (_selectedType == 'weight') return m.weight;
      final match = m.values
          .where((v) => v.typeKey == _selectedType)
          .firstOrNull;
      return match?.value ?? 0.0;
    }).toList();

    final sorted = List<double>.from(values)..sort();

    return _StatResult(
      min: sorted.first,
      max: sorted.last,
      last: values.last,
      change: values.length >= 2 ? values.last - values.first : 0,
      count: values.length,
      unit: _selectedType == 'weight' ? 'kg' : '',
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final bool isCount;

  const _StatCard({
    required this.label,
    required this.value,
    required this.unit,
    this.isCount = false,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue = isCount
        ? value.toInt().toString()
        : value.toStringAsFixed(1);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyLarge),
            Text(
              unit.isNotEmpty ? '$displayValue $unit' : displayValue,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

enum StatisticsPeriod { week, month, year }

class _StatResult {
  final double min;
  final double max;
  final double last;
  final double change;
  final int count;
  final String unit;

  const _StatResult({
    required this.min,
    required this.max,
    required this.last,
    required this.change,
    required this.count,
    required this.unit,
  });
}
