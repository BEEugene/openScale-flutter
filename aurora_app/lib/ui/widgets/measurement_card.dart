import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:openscale/ui/theme/app_colors.dart';

class MeasurementCard extends StatelessWidget {
  final DateTime dateTime;
  final double weightValue;
  final String trend;
  final List<MeasurementCardValue> measurementValues;
  final VoidCallback onTap;

  const MeasurementCard({
    super.key,
    required this.dateTime,
    required this.weightValue,
    required this.trend,
    required this.measurementValues,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat.yMd().add_Hm().format(dateTime),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${weightValue.toStringAsFixed(1)} kg',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (measurementValues.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _MeasurementDots(values: measurementValues),
                    ],
                  ],
                ),
              ),
              _TrendIcon(trend: trend),
            ],
          ),
        ),
      ),
    );
  }
}

class _MeasurementDots extends StatelessWidget {
  final List<MeasurementCardValue> values;

  const _MeasurementDots({required this.values});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: values.map((v) {
        return Tooltip(
          message: '${v.label}: ${v.value.toStringAsFixed(1)} ${v.unit}',
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: v.color, shape: BoxShape.circle),
          ),
        );
      }).toList(),
    );
  }
}

class _TrendIcon extends StatelessWidget {
  final String trend;

  const _TrendIcon({required this.trend});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (trend) {
      'up' => (Icons.trending_up, AppColors.trendUp),
      'down' => (Icons.trending_down, AppColors.trendDown),
      _ => (Icons.trending_flat, AppColors.trendStable),
    };

    return Icon(icon, color: color, size: 24);
  }
}

class MeasurementCardValue {
  final String label;
  final double value;
  final String unit;
  final Color color;

  const MeasurementCardValue({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });
}
