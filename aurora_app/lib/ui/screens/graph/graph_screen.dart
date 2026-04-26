import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openscale/l10n/app_localizations.dart';

import 'package:openscale/core/bloc/measurement/measurement_bloc.dart';
import 'package:openscale/ui/widgets/date_range_selector.dart';
import 'package:openscale/ui/widgets/measurement_type_selector.dart';

class GraphScreen extends StatefulWidget {
  const GraphScreen({super.key});

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  DateRange _dateRange = DateRange.month;
  String _selectedType = 'weight';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MeasurementBloc, MeasurementState>(
      builder: (context, state) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: DateRangeSelector(
                selectedRange: _dateRange,
                onRangeChanged: (range) {
                  setState(() {
                    _dateRange = range;
                  });
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(child: _buildChart(context, state)),
          ],
        );
      },
    );
  }

  Widget _buildChart(BuildContext context, MeasurementState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final points = _filterPoints(state);

    if (points.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.noDataForSelectedPeriod,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: _calculateInterval(points),
            getDrawingHorizontalLine: (value) => FlLine(
              color: Theme.of(context).colorScheme.outlineVariant,
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: _calculateTimeInterval(points),
                getTitlesWidget: (value, meta) {
                  final date = DateTime.fromMillisecondsSinceEpoch(
                    value.toInt(),
                  );
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      '${date.day}/${date.month}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 48,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.labelSmall,
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: points,
              isCurved: true,
              preventCurveOverShooting: true,
              color: Theme.of(context).colorScheme.primary,
              barWidth: 2.5,
              dotData: FlDotData(
                show: points.length < 30,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 3,
                    color: Theme.of(context).colorScheme.primary,
                    strokeWidth: 0,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.08),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final date = DateTime.fromMillisecondsSinceEpoch(
                    spot.x.toInt(),
                  );
                  return LineTooltipItem(
                    '${spot.y.toStringAsFixed(1)}\n'
                    '${date.day}.${date.month}.${date.year}',
                    TextStyle(
                      color: Theme.of(context).colorScheme.onInverseSurface,
                      fontSize: 12,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  List<FlSpot> _filterPoints(MeasurementState state) {
    final now = DateTime.now();
    final cutoff = switch (_dateRange) {
      DateRange.week => now.subtract(const Duration(days: 7)),
      DateRange.month => now.subtract(const Duration(days: 30)),
      DateRange.quarter => now.subtract(const Duration(days: 90)),
      DateRange.year => now.subtract(const Duration(days: 365)),
      DateRange.all => DateTime(2000),
    };

    return state.measurements.where((m) => m.dateTime.isAfter(cutoff)).map((m) {
      final value = _getValueForType(m);
      return FlSpot(m.dateTime.millisecondsSinceEpoch.toDouble(), value);
    }).toList();
  }

  double _getValueForType(MeasurementUiModel measurement) {
    if (_selectedType == 'weight') return measurement.weight;
    final match = measurement.values
        .where((v) => v.typeKey == _selectedType)
        .firstOrNull;
    return match?.value ?? 0.0;
  }

  double _calculateInterval(List<FlSpot> points) {
    if (points.isEmpty) return 1;
    final values = points.map((p) => p.y).toList()..sort();
    final range = values.last - values.first;
    if (range == 0) return 1;
    return range / 5;
  }

  double _calculateTimeInterval(List<FlSpot> points) {
    if (points.length < 2) return 1;
    final timeRange = points.last.x - points.first.x;
    return timeRange / 5;
  }
}
