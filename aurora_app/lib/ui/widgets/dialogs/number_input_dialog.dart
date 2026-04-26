import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:openscale/l10n/app_localizations.dart';

Future<double?> showNumberInputDialog({
  required BuildContext context,
  required String title,
  double initialValue = 0,
  String unit = '',
}) {
  final controller = TextEditingController(text: initialValue.toString());

  return showDialog<double>(
    context: context,
    builder: (dialogContext) {
      final l10n = AppLocalizations.of(dialogContext)!;
      return AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
          ],
          decoration: InputDecoration(
            suffixText: unit.isNotEmpty ? unit : null,
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              Navigator.pop(dialogContext, value);
            },
            child: Text(l10n.ok),
          ),
        ],
      );
    },
  );
}
