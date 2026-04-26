import 'package:flutter/material.dart';
import 'package:openscale/l10n/app_localizations.dart';

import 'package:openscale/ui/theme/app_colors.dart';

class MeasurementTypeSelector extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onTypeSelected;

  const MeasurementTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  static const _types = <(String, Color)>[
    ('weight', AppColors.weight),
    ('bmi', AppColors.bmi),
    ('fat', AppColors.fat),
    ('water', AppColors.water),
    ('muscle', AppColors.muscle),
    ('lbm', AppColors.lbm),
    ('bone', AppColors.bone),
    ('waist', AppColors.waist),
    ('visceralFat', AppColors.visceralFat),
  ];

  String _labelForType(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context)!;
    return switch (key) {
      'weight' => l10n.weight,
      'bmi' => l10n.bmi,
      'fat' => l10n.fat,
      'water' => l10n.water,
      'muscle' => l10n.muscle,
      'lbm' => l10n.lbm,
      'bone' => l10n.bone,
      'waist' => l10n.waist,
      'visceralFat' => l10n.visceral,
      _ => key,
    };
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _types.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (key, color) = _types[index];
          final isSelected = key == selectedType;
          return FilterChip(
            selected: isSelected,
            label: Text(_labelForType(context, key)),
            avatar: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            onSelected: (_) => onTypeSelected(key),
          );
        },
      ),
    );
  }
}
