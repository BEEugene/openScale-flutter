import 'package:flutter/material.dart';
import 'package:openscale/l10n/app_localizations.dart';

enum DateRange { week, month, quarter, year, all }

class DateRangeSelector extends StatelessWidget {
  final DateRange selectedRange;
  final ValueChanged<DateRange> onRangeChanged;

  const DateRangeSelector({
    super.key,
    required this.selectedRange,
    required this.onRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<DateRange>(
      segments: [
        ButtonSegment(value: DateRange.week, label: const Text('7d')),
        ButtonSegment(value: DateRange.month, label: const Text('30d')),
        ButtonSegment(value: DateRange.quarter, label: const Text('90d')),
        ButtonSegment(value: DateRange.year, label: const Text('1y')),
        ButtonSegment(
          value: DateRange.all,
          label: Text(AppLocalizations.of(context)!.all),
        ),
      ],
      selected: {selectedRange},
      onSelectionChanged: (selected) => onRangeChanged(selected.first),
    );
  }
}
