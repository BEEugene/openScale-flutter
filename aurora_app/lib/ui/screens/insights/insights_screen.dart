import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openscale/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import 'package:openscale/core/bloc/measurement/measurement_bloc.dart';
import 'package:openscale/ui/theme/app_colors.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MeasurementBloc, MeasurementState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.measurements.isEmpty) {
          return Center(
            child: Text(
              AppLocalizations.of(context)!.noDataYet,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          );
        }

        final insights = _computeInsights(state, context);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _InsightCard(
              icon: Icons.trending_down,
              iconColor: AppColors.trendDown,
              title: AppLocalizations.of(context)!.monthlyChange,
              value: insights.monthlyChange,
            ),
            const SizedBox(height: 8),
            _InsightCard(
              icon: Icons.local_fire_department,
              iconColor: AppColors.trendUp,
              title: AppLocalizations.of(context)!.currentStreak,
              value: insights.streakText,
            ),
            const SizedBox(height: 8),
            _InsightCard(
              icon: Icons.calendar_today,
              iconColor: AppColors.brandBlue,
              title: AppLocalizations.of(context)!.mostActiveDay,
              value: insights.mostActiveDay,
            ),
            const SizedBox(height: 8),
            _InsightCard(
              icon: Icons.flag,
              iconColor: AppColors.fat,
              title: AppLocalizations.of(context)!.goalProgress,
              value: insights.goalProgress,
            ),
            const SizedBox(height: 8),
            _InsightCard(
              icon: Icons.show_chart,
              iconColor: AppColors.water,
              title: AppLocalizations.of(context)!.avgWeeklyWeighIns,
              value: insights.avgWeeklyCount,
            ),
            const SizedBox(height: 8),
            _InsightCard(
              icon: Icons.access_time,
              iconColor: AppColors.muscle,
              title: AppLocalizations.of(context)!.lastMeasurement,
              value: insights.lastMeasurementDate,
            ),
          ],
        );
      },
    );
  }

  _InsightsData _computeInsights(MeasurementState state, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final measurements = state.measurements;
    final now = DateTime.now();

    // Monthly change
    final monthAgo = now.subtract(const Duration(days: 30));
    final recent = measurements.where((m) => m.dateTime.isAfter(monthAgo));
    double monthlyChange = 0;
    if (recent.isNotEmpty) {
      final sorted = recent.toList()
        ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
      monthlyChange = sorted.last.weight - sorted.first.weight;
    }
    final changeSign = monthlyChange >= 0 ? '+' : '';
    final monthlyChangeText = l10n.kgThisMonth(
      '$changeSign${monthlyChange.toStringAsFixed(1)}',
    );

    // Streak
    final today = DateTime(now.year, now.month, now.day);
    int streakDays = 0;
    for (int i = 0; i < 365; i++) {
      final checkDate = today.subtract(Duration(days: i));
      final hasMeasurement = measurements.any(
        (m) =>
            m.dateTime.year == checkDate.year &&
            m.dateTime.month == checkDate.month &&
            m.dateTime.day == checkDate.day,
      );
      if (hasMeasurement) {
        streakDays++;
      } else if (i > 0) {
        break;
      }
    }

    // Most active day of week
    final dayCounts = <int, int>{};
    for (final m in measurements) {
      final weekday = m.dateTime.weekday;
      dayCounts[weekday] = (dayCounts[weekday] ?? 0) + 1;
    }
    final mostActiveWeekday = dayCounts.entries.fold<MapEntry<int, int>?>(
      null,
      (prev, e) {
        if (prev == null || e.value > prev.value) return e;
        return prev;
      },
    );
    final dayNames = [
      '',
      l10n.monday,
      l10n.tuesday,
      l10n.wednesday,
      l10n.thursday,
      l10n.friday,
      l10n.saturday,
      l10n.sunday,
    ];
    final mostActiveDay = mostActiveWeekday != null
        ? dayNames[mostActiveWeekday.key]
        : '-';

    // Goal progress placeholder
    final goalProgress = l10n.setGoalInUserSettings;

    // Average weekly count
    final totalDays = measurements.isNotEmpty
        ? now.difference(measurements.last.dateTime).inDays + 1
        : 1;
    final avgWeekly = (measurements.length / totalDays * 7).toStringAsFixed(1);

    // Last measurement
    final lastDate = measurements.isNotEmpty
        ? DateFormat.yMd().add_Hm().format(measurements.first.dateTime)
        : '-';

    return _InsightsData(
      monthlyChange: monthlyChangeText,
      streakText: l10n.streakDays(streakDays),
      mostActiveDay: mostActiveDay,
      goalProgress: goalProgress,
      avgWeeklyCount: l10n.avgWeeklyCount(avgWeekly),
      lastMeasurementDate: lastDate,
    );
  }
}

class _InsightCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;

  const _InsightCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightsData {
  final String monthlyChange;
  final String streakText;
  final String mostActiveDay;
  final String goalProgress;
  final String avgWeeklyCount;
  final String lastMeasurementDate;

  const _InsightsData({
    required this.monthlyChange,
    required this.streakText,
    required this.mostActiveDay,
    required this.goalProgress,
    required this.avgWeeklyCount,
    required this.lastMeasurementDate,
  });
}
