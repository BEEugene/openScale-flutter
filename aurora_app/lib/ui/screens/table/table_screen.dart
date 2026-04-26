import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openscale/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:openscale/core/bloc/measurement/measurement_bloc.dart';
import 'package:openscale/ui/navigation/app_router.dart';
import 'package:openscale/ui/widgets/date_range_selector.dart';

class TableScreen extends StatefulWidget {
  const TableScreen({super.key});

  @override
  State<TableScreen> createState() => _TableScreenState();
}

class _TableScreenState extends State<TableScreen> {
  DateRange _dateRange = DateRange.all;
  int _sortColumnIndex = 0;
  bool _sortAscending = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MeasurementBloc, MeasurementState>(
      builder: (context, state) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
            Expanded(child: _buildTable(context, state)),
          ],
        );
      },
    );
  }

  Widget _buildTable(BuildContext context, MeasurementState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filtered = _filterMeasurements(state);

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.noMeasurements,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      );
    }

    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: DataTable(
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _sortAscending,
          headingRowColor: WidgetStateProperty.all(
            Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          columns: [
            DataColumn(
              label: Text(l10n.date),
              onSort: (col, asc) => _onSort(col, asc),
            ),
            DataColumn(
              label: Text(l10n.weight),
              numeric: true,
              onSort: (col, asc) => _onSort(col, asc),
            ),
            DataColumn(
              label: Text(l10n.bmi),
              numeric: true,
              onSort: (col, asc) => _onSort(col, asc),
            ),
            DataColumn(
              label: Text(l10n.fatPercent),
              numeric: true,
              onSort: (col, asc) => _onSort(col, asc),
            ),
            DataColumn(
              label: Text(l10n.waterPercent),
              numeric: true,
              onSort: (col, asc) => _onSort(col, asc),
            ),
            DataColumn(
              label: Text(l10n.musclePercent),
              numeric: true,
              onSort: (col, asc) => _onSort(col, asc),
            ),
          ],
          rows: filtered.map((measurement) {
            return DataRow(
              cells: [
                DataCell(
                  Text(DateFormat.yMd().format(measurement.dateTime)),
                  onTap: () => context.push(
                    '${AppRoutes.measurementDetail}/${measurement.id}',
                  ),
                ),
                DataCell(
                  Text(measurement.weight.toStringAsFixed(1)),
                  onTap: () => context.push(
                    '${AppRoutes.measurementDetail}/${measurement.id}',
                  ),
                ),
                DataCell(
                  Text(_formatValue(measurement, 'bmi')),
                  onTap: () => context.push(
                    '${AppRoutes.measurementDetail}/${measurement.id}',
                  ),
                ),
                DataCell(
                  Text(_formatValue(measurement, 'fat')),
                  onTap: () => context.push(
                    '${AppRoutes.measurementDetail}/${measurement.id}',
                  ),
                ),
                DataCell(
                  Text(_formatValue(measurement, 'water')),
                  onTap: () => context.push(
                    '${AppRoutes.measurementDetail}/${measurement.id}',
                  ),
                ),
                DataCell(
                  Text(_formatValue(measurement, 'muscle')),
                  onTap: () => context.push(
                    '${AppRoutes.measurementDetail}/${measurement.id}',
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  List<MeasurementUiModel> _filterMeasurements(MeasurementState state) {
    final now = DateTime.now();
    final cutoff = switch (_dateRange) {
      DateRange.week => now.subtract(const Duration(days: 7)),
      DateRange.month => now.subtract(const Duration(days: 30)),
      DateRange.quarter => now.subtract(const Duration(days: 90)),
      DateRange.year => now.subtract(const Duration(days: 365)),
      DateRange.all => DateTime(2000),
    };

    final result = state.measurements
        .where((m) => m.dateTime.isAfter(cutoff))
        .toList();

    result.sort((a, b) {
      int cmp;
      switch (_sortColumnIndex) {
        case 0:
          cmp = a.dateTime.compareTo(b.dateTime);
        case 1:
          cmp = a.weight.compareTo(b.weight);
        default:
          cmp = a.dateTime.compareTo(b.dateTime);
      }
      return _sortAscending ? cmp : -cmp;
    });

    return result;
  }

  void _onSort(int col, bool asc) {
    setState(() {
      _sortColumnIndex = col;
      _sortAscending = asc;
    });
  }

  String _formatValue(MeasurementUiModel measurement, String typeKey) {
    final match = measurement.values
        .where((v) => v.typeKey == typeKey)
        .firstOrNull;
    if (match == null) return '-';
    return match.value.toStringAsFixed(1);
  }
}
